default: hfxfeed.zip

hfxfeed.zip: hfxtable.txt table.py
	./table.py --input=hfxtable.txt --output=hfxfeed.zip

ROUTE_FILES=1-to-dartmouth.txt 1-to-mumford.txt \
	7-robie-to-gottingen.txt 7-gottingen-to-robie.txt \
	2-to-downtown-via-north.txt 2-to-wedgewood-via-main.txt \
	3-to-shopping-malls.txt 3-to-manors.txt \
	4-to-farnham-gate-via-rosedale.txt 4-to-downtown-via-north.txt \
	5-to-springvale.txt 5-to-downtown.txt \
	6-to-stonehaven.txt 6-to-downtown.txt

hfxtable.txt: hfxtable.txt.in $(ROUTE_FILES) parse-times.pl
	cp hfxtable.txt.in hfxtable.txt
	@$(foreach ROUTE_FILE, $(ROUTE_FILES), \
		echo "Parsing $(ROUTE_FILE)"; \
		./parse-times.pl $(ROUTE_FILE) >> hfxtable.txt;)

clean:
	rm -f hfxtable.txt hfxfeed.zip