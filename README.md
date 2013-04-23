NSDictionary-based memory cache.

## Requirements

- iOS 5.0 or later
- ARC

## Features

- detects unused objects and removes them.
- works automatically on receiving memory warning.

## Usage

### Setting objects

```objectivec
[[ISMemoryCache sharedCache] setObject:object forKey:@"key"];
```

### Loading objects

```objectivec
[[ISMemoryCache sharedCache] objectForKey:@"key"];
```

### Removing unused objects

remove object which is not retained by any other objects.

```objectivec
[[ISMemoryCache sharedCache] removeUnretainedObjects];
```

## Installing

Add `ISMemoryCache/ISMemoryCache.{h,m}` to your Xcode project.

### CocoaPods

If you use CocoaPods, you can install ISMemoryCache by inserting config below.

```
pod 'ISMemoryCache', :git => 'https://github.com/ishkawa/ISMemoryCache.git'
```

## License

Copyright (c) 2013 Yosuke Ishikawa

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
