package tests;

import massive.munit.Assert;
import massive.munit.TestRunner;
import massive.munit.client.RichPrintClient;

class Main {
	static function main() {
        trace('Henlo');
		var client = new RichPrintClient();
		var runner = new TestRunner(client);
		runner.run([TestSuite]);
	}
}

class TestSuite extends massive.munit.TestSuite {
	public function new() {
		super();
		add(TestCase);
		add(TestCase2);
	}
}

class TestCase {
	@Test
	function testSuccess() {
		Sys.sleep(Math.random());
		Assert.isTrue(true);
	}

	@Test
	function testFailure() {
		Sys.sleep(Math.random());
		Assert.areEqual("A", "B");
	}

	@Test
	function testError() {
		Sys.sleep(Math.random());
		throw "error";
	}

	@Test
	function testEmpty() {
		Sys.sleep(Math.random());
	}

	@Test @Ignore("Description")
	function testIgnore() {}
}

class TestCase2 {
	@Test
	function testSuccess() {
		Assert.isTrue(true);
	}
}