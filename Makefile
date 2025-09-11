all:
	haxe build.hxml
# 	node bin/js/main.js translocators.geojson
	neko bin/neko/main.n translocators.geojson
