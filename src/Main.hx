import haxe.io.Bytes;
import QuadTree.GamePoint;
import QuadTree.QuadTree;
import QuadTree.AABB;
import QuadTree.GamePoint;
import Graph.Graph;
import TranslocatorGeojson.TranslocatorsGeojson;
import TranslocatorGeojson.GeojsonPoint;
import haxe.Json;
import sys.io.File;

typedef Config = {
	public var translocatorWeight: Int;
	public var from: GamePoint;
	public var to: GamePoint;
	public var initialTranslocatorQuerySize: Int;
}

function makePoint(point: GeojsonPoint): GamePoint {
	return new GamePoint(point[0], -point[1]);
}

function buildGraph(tlGeojson: TranslocatorsGeojson, config: Config): Graph {
	var graph = new Graph(tlGeojson.features.length * 2 + 2);
	var tlWeight = config.translocatorWeight;
	var flatTlList = [];
	var quadTree = new QuadTree<GamePoint>(new AABB(new GamePoint(0, 0), 1050000), 10);
	var flatPointListById = [];
	// Create flat point list, quad tree, fill graph with TL connections
	for (i in 0...tlGeojson.features.length) {
		var tlId0 = i * 2;
		var tlId1 = tlId0 + 1;
		var pt0 = makePoint(tlGeojson.features[i].geometry.coordinates[0]);
		var pt1 = makePoint(tlGeojson.features[i].geometry.coordinates[1]);

		graph.addEdge(tlId0, tlId1, tlWeight);
		graph.addEdge(tlId1, tlId0, tlWeight);

		flatPointListById.push(pt0);
		flatPointListById.push(pt1);

		quadTree.insert(pt0, tlId0);
		quadTree.insert(pt1, tlId1);
	}
	var size = config.initialTranslocatorQuerySize;
	var halfsize = Math.floor(size / 2);
	var minCount = 10;
	// Connect TLs with close TLs
	for (id in 0...flatPointListById.length) {
		var queryResults = [];
		var pt = flatPointListById[id];
		quadTree.queryRange(
			new AABB(new GamePoint(pt.x - halfsize, pt.y - halfsize), size),
			minCount,
			queryResults
		);
		for (result in queryResults) {
			if (result.id != id) {
				graph.addEdge(id, result.id, pt.dist(result.point), true);
			}
		}
	}
	// Add start end end points to the graph
	{
		var startPointId = tlGeojson.features.length * 2 + 1;
		var endPointId = startPointId + 1;
		graph.addEdge(startPointId, endPointId, config.from.dist(config.to));
		var queryResults = [];
		quadTree.queryRange(
			new AABB(new GamePoint(config.from.x - halfsize, config.from.y - halfsize), size),
			minCount,
			queryResults
		);
		for (i in 0...queryResults.length) {
			graph.addEdge(startPointId, queryResults[i].id, config.from.dist(queryResults[i].point));
		}

		queryResults = [];
		quadTree.queryRange(
			new AABB(new GamePoint(config.to.x - halfsize, config.to.y - halfsize), size),
			minCount,
			queryResults
		);
		for (i in 0...queryResults.length) {
			graph.addEdge(endPointId, queryResults[i].id, config.to.dist(queryResults[i].point));
		}
	}

	return graph;
}


class Main {
	static function main() {
		var args = Sys.args();
		var tlGeojsonPath = args[0];
		Sys.println("tlGeojsonPath: " + tlGeojsonPath);
		if (tlGeojsonPath == null) {
			Sys.println('Usage: tl-navi translocators.geojson');
			Sys.exit(1);
		}
		var fileContents = File.getContent(tlGeojsonPath);
		// var sha = Sha256.encode(fileContents);
		// trace(sha);
		var tlGeojson: TranslocatorsGeojson = Json.parse(fileContents);
		var g = buildGraph(tlGeojson, {
			translocatorWeight: 100,
			from: new GamePoint(0, 0),
			to: new GamePoint(100000, 0),
			initialTranslocatorQuerySize: 1000,
		});

		g.addEdge(1, 2, 123);
		var g2 = g.clone();
		// Sys.println(g);
	}
}
