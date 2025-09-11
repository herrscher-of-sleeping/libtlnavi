package tests;

class GraphTests {
    @Test
    function testInternalRepresentation() {
		var graph = new Graph.Graph(100);
        graph.addEdge(1, 2, 123);
        graph.addEdge(1, 3, 123);
    }
}