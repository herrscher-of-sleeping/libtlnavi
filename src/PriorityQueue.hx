class PriorityQueue<T> {
	var nodes: Array<{element: T, priority: Float}> = [];

	public function new() {
	}

	public function insert(element: T, priority: Float) {
		nodes.push({element: element, priority: priority});
	}

	public function extract_max(): T {
		var highest = 0;
		for (i in 1...nodes.length) {
			if (nodes[i].priority > nodes[highest].priority) {
				highest = i;
			}
		}
		return nodes.splice(highest, 1)[0].element;
	}
}