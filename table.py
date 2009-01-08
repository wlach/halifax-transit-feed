#!/usr/bin/python

# Copyright (C) 2007 Google Inc.
# Copyright (C) 2008 William Lachance
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import transitfeed
from transitfeed import ServicePeriod
from optparse import OptionParser
import yaml, sys, os.path
import re

stops = {}

def ProcessOptions(schedule, options):
  
  # the follow features are REQUIRED
  agency_name = options.get('agency_name')
  agency_url = options.get('agency_url')
  agency_timezone = options.get('agency_timezone')

  service_periods = []

  service_periods.append(ServicePeriod(id="weekday"))
  service_periods[0].SetWeekdayService()
  service_periods.append(ServicePeriod(id="saturday"))
  service_periods[1].SetDayOfWeekHasService(5)
  service_periods.append(ServicePeriod(id="sunday"))
  service_periods[2].SetDayOfWeekHasService(6)

  # the service period options are, well, optional
  for service_period in service_periods:
    if options.get('start_date'):
      service_period.SetStartDate(options['start_date'])
    if options.get('end_date'):
      service_period.SetEndDate(options['end_date'])
    if options.get('add_date'):
      service_period.SetDateHasService(options['add_date'])
    if options.get('remove_date'):
      service_period.SetDateHasService(options['remove_date'], 
                                       has_service=False)

  # Add all service period objects to the schedule
  schedule.SetDefaultServicePeriod(service_periods[0], validate=False)
  schedule.AddServicePeriodObject(service_periods[1], validate=False)
  schedule.AddServicePeriodObject(service_periods[2], validate=False)

  if not (agency_name and agency_url and agency_timezone):
    print "You must provide agency information"

  schedule.NewDefaultAgency(agency_name=agency_name, agency_url=agency_url,
                            agency_timezone=agency_timezone)


# Remove any stops from stopsdata that aren't serviced by any routes in
# routedata.
def PruneStops(stopsdata, routedata):
  stopset = set()
  for route in routedata:
    stopset.update(route['time_points'])
    for between_list in route['between_stops']:
      stopset.update(route['between_stops'][between_list])

  toprune = list()
  for i, stop in enumerate(stopsdata):
    if stop['stop_code'] not in stopset:
      print "Pruning unused stop %s " % stop['stop_code']
      toprune.append(i)

  # Prune the list in reverse order, as the indices will change otherwise.
  toprune.sort()
  toprune.reverse()
  for prunee in toprune:
    del stopsdata[prunee]

def AddStops(schedule, stopsdata):
  for stopdata in stopsdata:
    stop_code = stopdata['stop_code']
    # we have to manually add the stop instead of using AddStop, cause 
    # we want the stop_code
    stop_id = unicode(len(schedule.stops))
    stop = transitfeed.Stop(stop_id=stop_id, lat=stopdata['lat'], 
                            lng=stopdata['lng'], name=stopdata['name'], 
                            stop_code=stop_code)
    schedule.AddStopObject(stop)
    stops[stop_code] = stop


def AddTripsToSchedule(schedule, route, routedata, service_id, stop_times):

  service_period = schedule.GetServicePeriod(service_id)
  timerex = re.compile('^(\d+)(\d\d)([a-z])$')

  for trip in stop_times:
    t = route.AddTrip(schedule, headsign=routedata['long_name'], service_period=service_period)

    if len(trip) > len(routedata['time_points']):
        print "Length of trip (%s) exceeds number of time points (%s)!" % (len(trip), len(routedata['time_points']))
        class StopTimesError(Exception): pass
        raise StopTimesError()
    else:
      trip_stops = []  # Build a list of (time, stop_code) tuples
      i = 0
      for stop_time in trip:
        matches = timerex.match(stop_time)
        if matches:
          hour, minute, shift = (int(matches.group(1)), 
                                 str(matches.group(2)), 
                                 matches.group(3))
          if shift == 'p' and hour < 12:
            hour += 12
          elif shift == 'x':
            if hour == 12:
              hour += 12
            else:
              hour += 24

          # munge hours and minutes if they're < 10
          if hour < 10:
            hour = "0" + str(hour)

          clock_time = str(hour) + ":" + minute + ":00"
          seconds = transitfeed.TimeToSecondsSinceMidnight(clock_time)
          trip_stops.append((seconds, routedata['time_points'][i]) )  
        elif re.search(r'^\-$', stop_time):
          pass
        i = i + 1

    trip_stops.sort()  # Sort by time
    prev_stop_code = None
    between_stops = routedata.get('between_stops')

    for (time, stop_code) in trip_stops:      
      if prev_stop_code and between_stops:
        between_stop_list = between_stops.get('%s-%s' % (prev_stop_code, stop_code))
        if between_stop_list:
          for between_stop_code in between_stop_list:          
            t.AddStopTime(stop=stops[between_stop_code]) 

      t.AddStopTime(stop=stops[stop_code], arrival_secs=time,
                    departure_secs=time)
      prev_stop_code = stop_code


    
def AddRouteToSchedule(schedule, routedata):
  r = schedule.AddRoute(short_name=str(routedata['short_name']), 
                        long_name=routedata['long_name'],
                        route_type='Bus')
  AddTripsToSchedule(schedule, r, routedata, "weekday", routedata['stop_times'])
  if routedata.get('stop_times_saturday'):
    AddTripsToSchedule(schedule, r, routedata, "saturday", routedata['stop_times_saturday'])  
  if routedata.get('stop_times_sunday'):
    AddTripsToSchedule(schedule, r, routedata, "sunday", routedata['stop_times_sunday'])  

def main():
  parser = OptionParser()
  parser.add_option('--input', dest='input',
                    help='Path of input file')
  parser.add_option('--output', dest='output',
                    help='Path of output file, should end in .zip')
  parser.set_defaults(output='feed.zip')
  (options, args) = parser.parse_args()

  schedule = transitfeed.Schedule()
  stream = open(options.input, 'r')
  data = yaml.load(stream)
  ProcessOptions(schedule, data['options'])
  PruneStops(data['stops'], data['routes'])
  AddStops(schedule, data['stops'])

  for route in data['routes']:
    AddRouteToSchedule(schedule, route)

  schedule.WriteGoogleTransitFeed(options.output)


if __name__ == '__main__':
  main()
