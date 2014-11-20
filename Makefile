test:
	xcodebuild clean test\
		-sdk iphonesimulator \
		-workspace ISMemoryCache.xcworkspace \
		-scheme ISMemoryCache \
		-configuration Debug \
		-destination "name=iPhone 6,OS=8.1" \
		OBJROOT=build \
		GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES \
		GCC_GENERATE_TEST_COVERAGE_FILES=YES

coveralls:
	coveralls -e UnitTests -e Pods

