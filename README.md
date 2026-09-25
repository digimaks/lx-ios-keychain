# KeychainWrapperPackage

A thin, typed wrapper around the iOS keychain.

It is one of the Swift packages used by **Digimaks**, a mobile digital wallet
continuing the work of the
[NOBID Consortium](https://www.nobidconsortium.com/) (the Nordic-Baltic eID
Project), one of the EU Large Scale Pilots preparing for eIDAS 2.0.

## Background

This package is the continuation of
[nobid-lsp-latvia/lx-ios-keychain](https://github.com/nobid-lsp-latvia/lx-ios-keychain),
developed within the NOBID Consortium and carried forward under the name
**Digimaks**.

## Requirements

- iOS 15+
- Swift 5.9+ / Xcode 15+

## Installation

Add the package to your `Package.swift`:

```swift
.package(url: "<repository-url>", from: "1.0.0")
```

or add it in Xcode via **File → Add Package Dependencies…**.

## Overview

| Type | Responsibility |
| ---- | -------------- |
| `KeychainManager` | Add, retrieve, update and delete keychain items, with `String` / `Int` / `Data` conversion helpers |

Items are written with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` and
`kSecAttrSynchronizable = false`, so they stay on the device and are never
synchronised to iCloud. Callers that supply their own `kSecAttrAccessControl`
keep full control of the access policy.

## Licence

Licensed under the [EUPL-1.2](LICENSE). See [Notice](Notice) for attribution.
