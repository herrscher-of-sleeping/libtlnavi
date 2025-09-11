import TranslocatorGeojson.TranslocatorsGeojson;
import haxe.Json;
import sys.io.File;

class Main {
	static function main() {
		var args = Sys.args();
		var tlGeojsonPath = args[0];
		Sys.println("tlGeojsonPath: " + tlGeojsonPath);
		if (tlGeojsonPath == null) {
			Sys.println('Usage: tl-navi translocators.geojson');
			Sys.exit(1);
		}
		var tlGeojson: TranslocatorsGeojson = Json.parse(File.getContent(tlGeojsonPath));
		var g = new Graph.Graph(100);

		for (feature in tlGeojson.features) {
			trace(feature);
		}



		g.addEdge(1, 2, 123);
		var g2 = g.clone();
	}
}
