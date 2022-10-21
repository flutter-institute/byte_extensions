[![Codemagic build status](https://api.codemagic.io/apps/635325804fab5561a16a6d79/635325804fab5561a16a6d78/status_badge.svg)](https://codemagic.io/apps/635325804fab5561a16a6d79/635325804fab5561a16a6d78/latest_build)

[![Pub Version](https://img.shields.io/pub/v/byte_extensions)](https://pub.dev/packages/byte_extensions)

This package provides some helpful extensions for common types to convert them to and from their byte equivalents.

## Features

This extension helps you easily convert int, double, and BigInt types into their various byte representations while controlling endianness.

For integer types, the extension support converting to the signed or unsigned bytes as a 64-, 32-, 16-, or 8-bit number.

For the double type, the extension supports converting to the IEEE-754 floating point values as a 64-bit double precision or 32-bit single precision number.

This exension also adds some helpers to make it a little faster to encode strings into their byte forms for a given encoding.
