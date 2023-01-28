DIR = test/wiki_pages

run: 
	@./script.sh


clean:
	@rm -rf ${DIR}


test: ${DIR}
	@./script.sh

${DIR}: clean
	@cp -r resources/wiki_pages ${DIR}
