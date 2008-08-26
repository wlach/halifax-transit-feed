default: hfxfeed.zip

hfxfeed.zip: hfxtable.txt table.py
	./table.py --input=hfxtable.txt --output=hfxfeed.zip

ROUTE_FILES=1-to-dartmouth.yml


# 1-to-mumford.txt \
# 	2-to-downtown-via-north.txt 2-to-wedgewood-via-main.txt \
# 	3-to-shopping-malls.txt 3-to-manors.txt \
# 	4-to-farnham-gate-via-rosedale.txt 4-to-downtown-via-north.txt \
# 	5-to-springvale.txt 5-to-downtown.txt \
# 	6-to-stonehaven.txt 6-to-downtown.txt \
# 	7-robie-to-gottingen.txt 7-gottingen-to-robie.txt \
# 	9-to-point-pleasant-park.txt 9-to-mumford.txt

hfxtable.yml: hfxtable.yml.in $(ROUTE_FILES) indent-route.pl
	cp hfxtable.yml.in hfxtable.yml
	@$(foreach ROUTE_FILE, $(ROUTE_FILES), \
		echo "Parsing $(ROUTE_FILE)"; \
		./indent-route.pl < $(ROUTE_FILE) >> hfxtable.txt;)

clean:
	rm -f hfxtable.txt hfxfeed.zip