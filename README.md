# Toncoin Wallet (iOS)

This is the source code and build instructions for a Toncoin Wallet implementation for iOS.

1. Install Xcode 14.3.1

```
https://apps.apple.com/app/xcode/id497799835
```

Make sure to launch Xcode at least once and set up command-line tools paths (Xcode — Preferences — Locations — Command Line Tools)

2. Install Bazel 5.4.0

```
brew install build-system/bazel.rb
```

2. Install OpenSSL 1.1

```
brew install openssl@1.1
```

3. Generate Xcode project

Note:
It is recommended to use an artifact cache to optimize build speed. Prepend any of the following commands with

```
export BAZEL_CACHE_DIR="path/to/existing/directory"
```

```
sh wallet_env.sh make wallet_project
```
