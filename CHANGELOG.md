# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.1] - 2023-06-16
### Changed
- Bump `rustler` to 0.28 to support OTP 26

### Fixed
- Attempting to handle some specific errors no longer raises a new error

## [0.3.0] - 2023-03-15
### Added
- Support for compression via the `compress` encode option (#15, thanks @mmmries)

### Changed
- Errors returned from `encode/2` are now descriptive strings instead of a generic atom. Instead of `{:error, :encode_error}`, you may now see something like `{:error, "Expected to deserialize a UTF-8 stringable term"}`. This is technically a breaking change.

## [0.2.1] - 2022-11-06
### Added
- Precompiled binary support for `aarch64-unknown-linux-musl`

### Fixed
- Bump `rustler_precompiled` to 0.5.4 to avoid https://github.com/philss/rustler_precompiled/issues/38

## [0.2.0] - 2022-08-14
### Added
- Precompiled binaries via [rustler_precompiled](https://github.com/philss/rustler_precompiled) (#10, thanks @lytedev)

## [0.1.6] - 2021-03-11
### Fixed
- Prevent `:ok` and `:error` atoms from being encoded as capitalized strings, inconsistent with other atom encoding

## [0.1.5] - 2021-02-06
### Fixed
- Honor custom encodings in nested structs

## [0.1.4] - 2020-04-02
### Fixed
- Correct typespec in NIF stub that caused issues with Dialyzer

## [0.1.3] - 2019-12-02
### Changed
- Limit nesting depth to 128 again when decoding strings

## [0.1.2] - 2019-12-02
### Changed
- Make `decode` and `decode!` accept a second (unused) options argument for compatibility (#1, thanks @joedevivo)

## [0.1.1] - 2019-11-08
### Changed
- Support decoding strings with a nesting depth over 128

## 0.1.0 - 2019-11-03
### Added
- Initial release


[Unreleased]: https://github.com/benhaney/Jsonrs/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/benhaney/Jsonrs/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/benhaney/Jsonrs/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/benhaney/Jsonrs/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/benhaney/Jsonrs/compare/v0.1.6...v0.2.0
[0.1.6]: https://github.com/benhaney/Jsonrs/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/benhaney/Jsonrs/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/benhaney/Jsonrs/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/benhaney/Jsonrs/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/benhaney/Jsonrs/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/benhaney/Jsonrs/compare/v0.1.0...v0.1.1
