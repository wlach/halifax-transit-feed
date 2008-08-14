default: feed.zip

feed.zip: hfxtable.txt
	./table.py --input=hfxtable.txt --output=feed.zip

hfxtable.txt: hfxtable.txt.in 1-to-dartmouth.txt 1-to-mumford.txt 7-robie-to-gottingen.txt 7-gottingen-to-robie.txt
	cp hfxtable.txt.in hfxtable.txt
	./parse-times.pl 1-to-dartmouth.txt 1 >> hfxtable.txt
	./parse-times.pl 1-to-mumford.txt 1 >> hfxtable.txt
	./parse-times.pl 7-robie-to-gottingen.txt 1 >> hfxtable.txt
	./parse-times.pl 7-gottingen-to-robie.txt >> hfxtable.txt

clean:
	rm -f hfxtable.txt feed.zip