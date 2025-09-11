all:
	haxe build.hxml
	node bin/js/main.js translocators.geojson
