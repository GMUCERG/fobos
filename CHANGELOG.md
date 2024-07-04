# Changelog

All notable changes to this project will be documented in this file.

## [3.0.1]
### Notes
This release fixes several small bugs and enhances usability.

### Added

- [CHANGELOG.md](CHANGELOG.md)
- MTDs of each key byte are now written into a file, they don't have to be guessed from graphs anymore

### Changed

- Substantial documentation updates and improvements
- Power calibration works again (was working on beta versions of FOBOS 3)
- Updated fobosTVGen to handle more FIFOs
- XILINX_XRT environment variable on Pynq was not set correctly
- Pynq install script now detects which Pynq board it is running on
- FOBOS can now set fixed amplification on the amplifier of the FOBOS Shield using ADC_hilo
- Improved Makefile for building the Pynq overlay for Pynq-Z1 and Pynq-Z2, and different revisions of the FOBOS Shield

### Removed
- Nothing.

## [3.0.0] 
Initial release.

[3.0.1]: https://github.com/GMUCERG/FOBOS/compare/v3.0.0...v3.0.1
[3.0.0]: https://github.com/GMUCERG/FOBOS/releases/tag/v3.0.0
