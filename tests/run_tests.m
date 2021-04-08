function output= run_tests
test_folder = fileparts(which('test_header.m'));
test_suite = testsuite(test_folder);

output = run(test_suite);
