class Main {
	static function main() {
		var g = new Graph.Graph(100);
		trace("Hwllo");
		g.addEdge(1, 2, 123);
		var g2 = g.clone();
	}
}
