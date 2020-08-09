package;
import tink.unit.*;
import tink.testrunner.Reporter;
import tink.testrunner.*;

class RunTests {
	static function main() {
		ANSI.stripIfUnavailable = false;
		var reporter = new BasicReporter(new AnsiFormatter());
		Runner.run(TestBatch.make([new Test(),]), reporter).handle(Runner.exit);
	}
}


