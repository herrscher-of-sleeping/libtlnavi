package tests;

import massive.munit.Assert;
import massive.munit.TestRunner;
import massive.munit.client.RichPrintClient;

class Main {
	static function main() {
		var client = new RichPrintClient();
		var runner = new TestRunner(client);
		runner.run([TestSuite]);
	}
}

class TestSuite extends massive.munit.TestSuite {
	public function new() {
		super();
		add(TestCase);
		add(GraphTests);
	}
}

class TestCase {
	@Test
	function testSuccess() {
		Assert.isTrue(true);
	}
}