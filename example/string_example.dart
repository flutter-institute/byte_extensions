import 'dart:convert';

import 'package:byte_extensions/byte_extensions.dart';

void main() {
  /** UTF-8 conversions */
  // use `endian: Endian.little` for little endian conversion

  // ascii values: [0x61, 0x62, 0x63, 0x64]
  'abcd'.asBytes(utf8);
  // extended characters: [0xCC, 0x80, 0xC6, 0x80, 0xC4, 0x87, 0xC4, 0x8F]
  '\u0300\u0180\u0107\u010F'.asBytes(utf8);

  /** latin1 conversions */
  // use `endian: Endian.little` for little endian conversion

  // ascii values: [0x61, 0x62, 0x63, 0x64]
  'abcd'.asBytes(latin1);
  // extended characters: [0xC0, 0xC7, 0xD0, 0xC9]
  '\xC0\xC7\xD0\xC9'.asBytes(latin1);

  /** ascii conversions */
  // use `endian: Endian.little` for little endian conversion

  // ascii values: [0x61, 0x62, 0x63, 0x64]
  'abcd'.asBytes(ascii);
  // Also has endian support for byte order
}
