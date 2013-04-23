test:
	xcodebuild \
		-sdk iphonesimulator \
		-workspace ISMemoryCache.xcworkspace \
		-scheme ISMemoryCacheTests \
		-configuration Debug \
		clean build \
		ONLY_ACTIVE_ARCH=NO \
		TEST_AFTER_BUILD=YES
