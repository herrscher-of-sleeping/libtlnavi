package tests;

import massive.munit.Assert;
import PriorityQueue;

class PriorityQueueTests {
    @Test
    function testInternalRepresentation() {
		var queue = new PriorityQueue();
		queue.insert(1, 1);
		queue.insert(2, 42);
		queue.insert(3, 3);
		Assert.isTrue(queue.extract_max() == 2);
		Assert.isTrue(queue.extract_max() == 3);
		Assert.isTrue(queue.extract_max() == 1);
    }
}