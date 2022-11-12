# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Map for generated lines in code to the block that generated it.
  - Accompanying context menu item.
- Migrated to VSCode CustomTextDocument from CustomDocument.

### Fixed

- Generation of arithmetic and comparison operators.
- Duplicate categories for libraries.

## [0.1.1]

### Added

- Help messages for blocks

### Changed

- Styling of table editor modals

## [0.1.0] - *2022-11-05*

### Added

- [Changelog](https://github.com/house-of-abbey/scratch_vhdl/blob/main/scratch-vhdl-vscode/CHANGELOG.md)
- Github community standards.
- Entity templates
- Table editor for ports, signals, constants and aliases.

## [0.0.8] - *2022-11-01*

### Added

- Zooming to Blockly workspace.
- All dependency for process.
- Inter-file backpack through VSCode globalState.

### Changed

- Moved literals to new literals category.
- Changed Math category to Operations.

### Fixed

- Report block not having connections.
- Stopped generation of new erroneous signal called `item`.

## [0.0.6] - *2022-10-27*

### Fixed

- Environment for OpenVSX in gh-actions.

## [0.0.5] - *2022-10-25*

### Added

- VSCode custom file nesting for metadata files.
- Context menus in Blockly (with custom colour scheme support).
- Safer Uri generation for finding meta files.

## [0.0.4] - *2022-10-24*

### Added

- Aliases and constants and generation for aliases and constants.
- More tests for examples.

## [0.0.3] - *2022-10-24*

### Added

- Custom colour scheme, generated from VSCode.
- Generation of created signals as VHDL code.
- Generation of imported libraries.

## [0.0.1] - *2022-10-22*

### Added

- The VSCode extension which runs blockly in a webview.
- Created the push message based communication between Blockly and VSCode.
- Added most of the necessary blocks for writing code.
- Rudimentary code generation (enough for button_driven).
- Continuous integration for OpenVSX and gh-releases using gh-actions.

[Unreleased]: https://github.com/house-of-abbey/scratch_vhdl/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/house-of-abbey/scratch_vhdl/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/house-of-abbey/scratch_vhdl/compare/v0.0.8...v0.1.0
[0.0.8]: https://github.com/house-of-abbey/scratch_vhdl/compare/v0.0.7...v0.0.8
<!-- [0.0.7]: https://github.com/house-of-abbey/scratch_vhdl/compare/v0.0.6...v0.0.7 -->
[0.0.6]: https://github.com/house-of-abbey/scratch_vhdl/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/house-of-abbey/scratch_vhdl/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/house-of-abbey/scratch_vhdl/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/house-of-abbey/scratch_vhdl/compare/v0.0.2...v0.0.3
<!-- [0.0.2]: https://github.com/house-of-abbey/scratch_vhdl/compare/v0.0.1...v0.0.2 -->
[0.0.1]: https://github.com/house-of-abbey/scratch_vhdl/releases/tag/v0.0.1
