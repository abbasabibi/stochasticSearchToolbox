%result = runtests(pwd,'Recursively',true,'BaseFolder', '+UnitTests');

import matlab.unittest.TestSuite;

suite = TestSuite.fromPackage('UnitTests');
result = run(suite);

