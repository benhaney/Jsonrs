# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2022-08-14
### Added
- Precompiled binaries via [rustler_precompiled](https://github.com/philss/rustler_precompiled)

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
- Make `decode` and `decode!` accept a second (unused) options argument for compatibility

## [0.1.1] - 2019-11-08
### Changed
- Support decoding strings with a nesting depth over 128

## [0.1.0] - 2019-11-03
### Added
- Initial release
