import haxe.Log;

class Point {
	public var x: Int; // West/East
	public var y: Int; // North/South
	@:optional public var z: Int; // Height
	public function new(x: Int, y: Int, z: Int=null) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public function create(x: Int, y: Int, z: Int=null): Point {
		return new Point(x, y, z);
	}

	public function toString(): String {
		return 'Point[${this.x}, ${this.y}]';
	}

	public function dist(other: Point): Float {
		var squared = Math.pow(this.x - other.x, 2) + Math.pow(this.y - other.y, 2);
		// TODO: use vertical coordinate too if exists
		return Math.pow(squared, 0.5);
	}
}

// #region These 2 are inverted on y axis relative to each other
// In the game positive y coordinates go south from the spawn
// However on the web map and in Geojson files that's negative y
// This library works with GamePoint internally in the main logic

class MapPoint extends Point {
	function toGamePoint(): GamePoint {
		return new GamePoint(this.x, -this.y, this.z);
	}

	override public function create(x: Int, y: Int, z: Int=null): MapPoint{
		return new MapPoint(x, y, z);
	}
}

class GamePoint extends Point {
	function toMapPoint(): MapPoint {
		return new MapPoint(this.x, -this.y, this.z);
	}

	override public function create(x: Int, y: Int, z: Int=null): GamePoint{
		return new GamePoint(x, y, z);
	}
}

// #endregion

class AABB {
	public var start: Point;
	public var end: Point;
	public var center: Point;
	public var size: Int;

	public function new(start: Point, size: Int) {
		this.start = start;
		this.end = new Point(start.x + size, start.y + size);
		this.size = size;
		this.center = new Point(Math.floor((start.x + end.x) / 2), Math.floor((start.y + end.y) / 2));
	}
	public function containsPoint(point: Point): Bool {
		return (
			point.x >= this.start.x &&
			point.x < this.end.x &&
			point.y >= this.start.y &&
			point.y < this.end.y
		);
	}

	public function intersectsAABB(other: AABB): Bool {
		return (
			this.start.x <= other.end.x &&
			this.end.x >= other.start.x &&
			this.start.y <= other.end.y &&
			this.end.y >= other.start.y
		);
	}

	public function toString() {
		return 'AABB[${start.x}, ${start.y}, ${end.x}, ${end.y}]';
	}
}

typedef QuadTreeSubtrees<T:Point> = {
	public var NW: QuadTree<T>;
	public var NE: QuadTree<T>;
	public var SW: QuadTree<T>;
	public var SE: QuadTree<T>;
}

typedef QuadTreeQueryResult<T: Point> = {
	public var point: T;
	public var id: Int;
}

class QuadTree<T:Point> {
	var nodeCapacity: Int;
	var boundary: AABB;
	var points: Array<T> = [];
	var ids: Array<Int> = [];
	var subtrees: QuadTreeSubtrees<T> = null;
	var parent: QuadTree<T>;

	public function new(boundary: AABB, nodeCapacity: Int, parent: QuadTree<T> = null) {
		this.boundary = boundary;
		this.nodeCapacity = nodeCapacity;
		this.parent = parent;
	}

	private function subdivide(): QuadTreeSubtrees<T> {
		var topCenter = this.boundary.center.create(this.boundary.center.x, this.boundary.start.y);
		var leftCenter = this.boundary.center.create(this.boundary.start.x, this.boundary.center.y);
		var halfSize = Math.floor(this.boundary.size / 2);
		return {
			NW: new QuadTree(new AABB(this.boundary.start, halfSize), this.nodeCapacity, this),
			NE: new QuadTree(new AABB(topCenter, halfSize), this.nodeCapacity, this),
			SW: new QuadTree(new AABB(leftCenter, halfSize), this.nodeCapacity, this),
			SE: new QuadTree(new AABB(this.boundary.center, halfSize), this.nodeCapacity, this),
		}
	}

	function getNodeCount(): Int {
		return this.points.length + (this.subtrees != null ?
				this.subtrees?.NE.getNodeCount() +
				this.subtrees?.NW.getNodeCount() +
				this.subtrees?.SE.getNodeCount() +
				this.subtrees?.SW.getNodeCount()
				: 0);
	}

	public function insert(p: T, id: Int): Bool {
		if (!this.boundary.containsPoint(p)) {
			return false;
		}
		if (this.points.length < this.nodeCapacity && this.subtrees == null)  {
			this.points.push(p);
			this.ids.push(id);
			return true;
		}
		if (this.subtrees == null) {
			this.subtrees = this.subdivide();
			for (i in 0...this.points.length) {
				var pt = this.points[i];
				var ptId = this.ids[i];
				if (!(this.subtrees.NW.insert(pt, ptId) ||
						this.subtrees.NE.insert(pt, ptId) ||
						this.subtrees.SW.insert(pt, ptId) ||
						this.subtrees.SE.insert(pt, ptId))
				) {
					// This should never happen
					Log.trace("Couldn't insert point");
				}
			}
			this.points = [];
			this.ids = [];
		}
		var _ok =
			this.subtrees.NW.insert(p, id) ||
			this.subtrees.NE.insert(p, id) ||
			this.subtrees.SW.insert(p, id) ||
			this.subtrees.SE.insert(p, id);
		return true;
	}

	public function queryAmount(amount: Int, result: Array<QuadTreeQueryResult<T>>) {

	}

	public function queryRange(range: AABB, minCount: Int=null, result: Array<QuadTreeQueryResult<T>>) {
		// while (result.length < minCount)
		if (!this.boundary.intersectsAABB(range)) {
			return;
		}
		if (this.subtrees == null) {
			for (i in 0...this.points.length) {
				var pt = this.points[i];
				var id = this.ids[i];
				if (range.containsPoint(pt)) {
					result.push( { point: pt, id: id });
				}
			}
			return;
		}
		this.subtrees.NW.queryRange(range, result);
		this.subtrees.NE.queryRange(range, result);
		this.subtrees.SW.queryRange(range, result);
		this.subtrees.SE.queryRange(range, result);
		if (minCount != null && result.length < minCount) {

		}
	}

	public function toString() {
		var sb: Array<String> = [];
		var treeStack = [];
		treeStack.push({tree: this, indent: 0});
		while(treeStack.length > 0) {
			var cur = treeStack.pop();
			var indent = StringTools.rpad("", "-", cur.indent);
			sb.push('${indent}Tree ${cur.tree.boundary.toString()}');
			for (pt in cur.tree.points) {
				sb.push('${indent}>Point[${pt.x}, ${pt.y}]');
			}
			if (cur.tree.subtrees != null) {
				treeStack.push({ tree: cur.tree.subtrees.SE, indent: cur.indent + 1 });
				treeStack.push({ tree: cur.tree.subtrees.SW, indent: cur.indent + 1 });
				treeStack.push({ tree: cur.tree.subtrees.NE, indent: cur.indent + 1 });
				treeStack.push({ tree: cur.tree.subtrees.NW, indent: cur.indent + 1 });
			}
		}
		return sb.join("\n");
	}
}