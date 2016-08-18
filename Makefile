watch:
	watchy -w src -- make build

build: clean
	mkdir -p build
	cp src/manifest.json build
	cp src/fullscreen.js build
	cp src/zxcvbn.js build
	cp src/popup.html build
	cp src/loop.svg build
	cp src/icon.png build
	elm make src/Main.elm --output build/popup.js

release: firefox chrome

firefox: build
	web-ext build -s build -a ./release

chrome: build
	mkdir -p release/
	zip -r release/chrome.crx build/

clean:
	rm -rf build
	rm -rf release

deps:
	npm install -g web-ext
	npm install -g watchy

.PHONY: build clean deps firefox chrome release
