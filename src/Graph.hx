import TranslocatorGeojson.TranslocatorsGeojson;

class Graph {
    var edges: Array<Array<Int>> = [];
    var weights: Array<Array<Float>> = [];

    public function new(vertices: Int = 0) {
        for (i in 0...vertices) {
            edges.push([]);
            weights.push([]);
        }
    }

    public static function fromGeodata(geodata) {

    }

    public function addEdge(i: Int, j: Int, weight: Float) {
        edges[i].push(j);
        weights[i].push(weight);
        edges[j].push(i);
        weights[j].push(weight);
        trace('Add edge for $i, $j, weight $weight');
    }

    public function clone(): Graph {
        var g = new Graph();
        g.edges = edges.map(function(e) return e.copy());
        g.weights = weights.map(function(w) return w.copy());
        return g;
    }
}