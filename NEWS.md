# Changelog

## [1.1.1-dev][Unreleased] - Unreleased

### Added

* Special exception to the AGPL license for the CSS styles
* License information for icons in "classic" and "classic-full" styles

### Changed

* Relicensed under the GNU Affero General Public License version 3 or
  later (AGPL-3.0-or-later)

## [1.1.0] - 2026-10-31

### Added

* Options that accept keywords can now handle leading and trailing
  whitespace around each keyword
* Support uutils coreutils installed with "uu-" prefix
* Compatibility with zsh

### Changed

* Require coreutils `touch` and `tr`
* Clarify that `file` is optional

### Fixed

* Suppress warning message that may appear if using `-d HTML` and the
  HTML does not contain `%s`

## 1.0.0 - 2026-10-09

* Initial release

[Unreleased]: https://github.com/jefferyto/dir-index.sh/compare/1.1.0...main
[1.1.0]: https://github.com/jefferyto/dir-index.sh/compare/1.0.0...1.1.0
