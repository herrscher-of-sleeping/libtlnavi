import TranslocatorGeojson.TranslocatorsGeojson;

class Graph {
    public var edges: Array<Array<Int>> = [];
    public var weights: Array<Array<Float>> = [];

    public function new(vertices: Int) {
        for (i in 0...vertices + 1) {
            edges.push([]);
            weights.push([]);
        }
    }

    public function addEdge(i: Int, j: Int, weight: Float, scan: Bool=false) {
		if (scan) {
			var posI = edges[i].indexOf(j);
			var posJ = edges[j].indexOf(i);
			if (posI != -1) {
				weights[i][posI] = weight;
				weights[j][posJ] = weight;
				return;
			}
		}
		trace('${edges.length}, ${edges[i].length}, $i, $j');
        edges[i].push(j);
        weights[i].push(weight);
        edges[j].push(i);
        weights[j].push(weight);
    }

    public function clone(): Graph {
        var g = new Graph(this.edges.length);
        g.edges = edges.map(function(e) return e.copy());
        g.weights = weights.map(function(w) return w.copy());
        return g;
    }
}