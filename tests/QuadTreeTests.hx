package tests;

import massive.munit.Assert;

import QuadTree.AABB;
import QuadTree.QuadTree;
import QuadTree.Point;

class QuadTreeTests {
    @Test
    function testInternalRepresentation() {
		var qt = new QuadTree(new AABB(new Point(0, 0), 100), 4);
		qt.insert(new Point(0, 0), 1);
		qt.insert(new Point(10, 10), 2);
		var queryResult = [];
		qt.queryRange(new AABB(new Point(0, 0), 10), queryResult);
		Assert.isTrue(queryResult.length == 1, "Length is " + queryResult.length);
		Assert.isTrue(queryResult[0].id == 1);
		Assert.isTrue(queryResult[0].point.x == 0);
		Assert.isTrue(queryResult[0].point.y == 0);
    }
}