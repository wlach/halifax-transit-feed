default: hfxfeed.zip

hfxfeed.zip: hfxtable.yml table.py
	./table.py --input=hfxtable.yml --output=hfxfeed.zip

ROUTE_FILES=1-to-dartmouth.yml 1-to-mumford.yml \
 	2-to-downtown-via-north.yml 2-to-wedgewood-via-main.yml \
 	3-to-shopping-malls.yml 3-to-manors.yml \
 	4-to-farnham-gate-via-rosedale.yml 4-to-downtown-via-north.yml \
 	5-to-springvale.yml 5-to-downtown.yml \
 	6-to-stonehaven.yml 6-to-downtown.yml \
 	7-robie-to-gottingen.yml 7-gottingen-to-robie.yml \
 	9-to-point-pleasant-park.yml 9-to-mumford.yml \
	17-to-hospitals-universities.yml 17-to-lacewood.yml \
	18-to-smu.yml 18-to-lacewood.yml \
	21-to-timberlea.yml 21-to-lacewood-halifax.yml \
	23-to-timberlea.yml 23-to-mumford-halifax.yml \
	42-to-lacewood.yml 42-to-dalhousie.yml \
	58-to-lucien-drive.yml \
	80-to-bedford-halifax.yml 80-to-bedford-sackville.yml \
	81-to-downtown-halifax.yml

hfxtable.yml: hfxtable.yml.in $(ROUTE_FILES) indent-route.pl
	cp hfxtable.yml.in hfxtable.yml
	@$(foreach ROUTE_FILE, $(ROUTE_FILES), \
		echo "Parsing $(ROUTE_FILE)"; \
		./indent-route.pl < $(ROUTE_FILE) >> hfxtable.yml;)

clean:
	rm -f hfxtable.yml hfxfeed.zip *~
