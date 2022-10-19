import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:byte_extensions/byte_extensions.dart';

void main() {
  group('integer extensions', () {
    test('identity', () {
      var sut = 0xFEDCBA98765432;
      expect(sut.asBytes().asInt(type: IntType.uint64), sut);
      expect(sut.asBytes().asInt(type: IntType.int64), sut);

      sut = 0x98765432;
      expect(sut.asBytes(type: IntType.int32).asInt(type: IntType.uint32), sut);
      expect(sut.asBytes(type: IntType.int32).asInt(type: IntType.int32),
          sut.toSigned(32));

      sut = 0x9832;
      expect(sut.asBytes(type: IntType.int16).asInt(type: IntType.uint16), sut);
      expect(sut.asBytes(type: IntType.int16).asInt(type: IntType.int16),
          sut.toSigned(16));

      sut = 0x98;
      expect(sut.asBytes(type: IntType.int8).asInt(type: IntType.uint8), sut);
      expect(sut.asBytes(type: IntType.int8).asInt(type: IntType.int8),
          sut.toSigned(8));
    });

    group('asBytes', () {
      test('converts 64-bit int', () {
        // -81985529216486896
        expect(
          0xFEDCBA9876543210.asBytes(endian: Endian.big, type: IntType.int64),
          [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10],
        );
        expect(
          0xFEDCBA9876543210
              .asBytes(endian: Endian.little, type: IntType.int64),
          [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE],
        );
      });

      test('64-bit boundaries', () {
        expect(
          9223372036854775807.asBytes(endian: Endian.big, type: IntType.int64),
          [0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF],
        );

        expect(
          (-9223372036854775808)
              .asBytes(endian: Endian.big, type: IntType.int64),
          [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        );
      });

      test('converts 32-bit int', () {
        expect(
          0xFEDCBA9876543210.asBytes(endian: Endian.big, type: IntType.int32),
          [0x76, 0x54, 0x32, 0x10],
        );
        expect(
          0xFEDCBA9876543210
              .asBytes(endian: Endian.little, type: IntType.int32),
          [0x10, 0x32, 0x54, 0x76],
        );
      });

      test('32-bit boundaries', () {
        expect(
          2147483647.asBytes(endian: Endian.big, type: IntType.int32),
          [0x7F, 0xFF, 0xFF, 0xFF],
        );

        expect(
          (-2147483648).asBytes(endian: Endian.big, type: IntType.int32),
          [0x80, 0x00, 0x00, 0x00],
        );
      });

      test('converts 16-bit int', () {
        expect(
          0xFEDCBA9876543210.asBytes(endian: Endian.big, type: IntType.int16),
          [0x32, 0x10],
        );
        expect(
          0xFEDCBA9876543210
              .asBytes(endian: Endian.little, type: IntType.int16),
          [0x10, 0x32],
        );
      });

      test('16-bit boundaries', () {
        expect(
          32767.asBytes(endian: Endian.big, type: IntType.int16),
          [0x7F, 0xFF],
        );

        expect(
          (-32768).asBytes(endian: Endian.big, type: IntType.int16),
          [0x80, 0x00],
        );
      });

      test('converts 8-bit int', () {
        expect(
          0xFEDCBA9876543210.asBytes(endian: Endian.big, type: IntType.int8),
          [0x10],
        );
        expect(
          0xFEDCBA9876543210.asBytes(endian: Endian.little, type: IntType.int8),
          [0x10],
        );
      });

      test('8-bit boundaries', () {
        expect(
          127.asBytes(endian: Endian.big, type: IntType.int8),
          [0x7F],
        );

        expect(
          (-128).asBytes(endian: Endian.big, type: IntType.int8),
          [0x80],
        );
      });
    });
  });

  group('list<int> extensions', () {
    group('asInt', () {
      test('byte value is out of range or negative', () {
        expect(
          [256, 256].asInt(),
          0xFFFF,
        );
        expect(
          [0x10, 256, 0x50].asInt(endian: Endian.big, type: IntType.uint64),
          0x10FF50,
        );
        expect(
          [0x10, 300, 0x50].asInt(endian: Endian.big, type: IntType.uint64),
          0x10FF50,
        );

        expect(
          [0x10, -256, 0x50].asInt(endian: Endian.big, type: IntType.uint64),
          0x100050,
        );
        expect(
          [0x10, -300, 0x50].asInt(endian: Endian.big, type: IntType.uint64),
          0x100050,
        );

        expect(
          [0x10, -1, 0x50].asInt(endian: Endian.big, type: IntType.uint64),
          0x100050,
        );
        expect(
          [0x10, -255, 0x50].asInt(endian: Endian.big, type: IntType.uint64),
          0x100050,
        );
      });

      test('converts 64-bit int', () {
        expect(<int>[].asInt(type: IntType.int64), 0);

        // Test truncation
        expect(
          [0xFF, 0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]
              .asInt(endian: Endian.big, type: IntType.int64),
          -81985529216486896,
        );
        expect(
          [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE, 0xFF]
              .asInt(endian: Endian.little, type: IntType.int64),
          -81985529216486896,
        );

        // Test padding
        expect(
          [0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]
              .asInt(endian: Endian.big, type: IntType.int64),
          62129658859368976,
        );
        expect(
          [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC]
              .asInt(endian: Endian.little, type: IntType.int64),
          62129658859368976,
        );
      });

      test('converts 64-bit unsigned int', () {
        // Dart doesn't have a real Uint64, so it's the same and Int64
        expect(
          [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]
              .asInt(endian: Endian.big, type: IntType.uint64),
          -81985529216486896,
        );
        expect(
          [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]
              .asInt(endian: Endian.little, type: IntType.uint64),
          -81985529216486896,
        );
      });

      test('64-bit boundaries', () {
        expect(
          [0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
              .asInt(endian: Endian.big, type: IntType.int64),
          9223372036854775807,
        );
        expect(
          [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F]
              .asInt(endian: Endian.little, type: IntType.int64),
          9223372036854775807,
        );

        expect(
          [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
              .asInt(endian: Endian.big, type: IntType.int64),
          -9223372036854775808,
        );
        expect(
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80]
              .asInt(endian: Endian.little, type: IntType.uint64),
          -9223372036854775808,
        );
      });

      test('coverts 32-bit int', () {
        expect(<int>[].asInt(type: IntType.int32), 0);

        // Test truncation
        expect(
          [0x98, 0x76, 0x54, 0x32, 0x10]
              .asInt(endian: Endian.big, type: IntType.int32),
          1985229328,
        );
        expect(
          [0x10, 0x32, 0x54, 0x98, 0x76]
              .asInt(endian: Endian.little, type: IntType.int32),
          -1739312624,
        );

        // Test padding
        // Because of the padding, the MSB is 0 instead of the 1 from 0x9
        expect(
          [0x98, 0x32, 0x10].asInt(endian: Endian.big, type: IntType.int32),
          9974288,
        );
        expect(
          [0x10, 0x32, 0x98].asInt(endian: Endian.little, type: IntType.int32),
          9974288,
        );
      });

      test('converts 32-bit unsigned integer', () {
        // Test truncation
        expect(
          [0x98, 0x76, 0x54, 0x32, 0x10]
              .asInt(endian: Endian.big, type: IntType.uint32),
          1985229328,
        );
        expect(
          [0x10, 0x32, 0x54, 0x98, 0x76]
              .asInt(endian: Endian.little, type: IntType.uint32),
          2555654672,
        );

        // Test padding
        // Because of the padding, the MSB is 0 instead of the 1 from 0x9
        expect(
          [0x98, 0x32, 0x10].asInt(endian: Endian.big, type: IntType.uint32),
          9974288,
        );
      });

      test('32-bit boundaries', () {
        expect(
          [0x7F, 0xFF, 0xFF, 0xFF]
              .asInt(endian: Endian.big, type: IntType.int32),
          2147483647,
        );
        expect(
          [0x7F, 0xFF, 0xFF, 0xFF]
              .asInt(endian: Endian.big, type: IntType.uint32),
          2147483647,
        );

        expect(
          [0x80, 0x00, 0x00, 0x00]
              .asInt(endian: Endian.big, type: IntType.int32),
          -2147483648,
        );
        expect(
          [0x80, 0x00, 0x00, 0x00]
              .asInt(endian: Endian.big, type: IntType.uint32),
          2147483648,
        );
      });

      test('converts 16-bit int', () {
        expect(<int>[].asInt(type: IntType.int16), 0);

        // Test truncation
        expect(
          [0x54, 0x32, 0x10].asInt(endian: Endian.big, type: IntType.int16),
          12816,
        );
        expect(
          [0x10, 0x98, 0x76].asInt(endian: Endian.little, type: IntType.int16),
          -26608,
        );

        // Test padding
        // Because of the padding, the MSB is 0 instead of the 1 from 0x9
        expect(
          [0x98].asInt(endian: Endian.big, type: IntType.int16),
          152,
        );
        expect(
          [0x98].asInt(endian: Endian.little, type: IntType.int16),
          152,
        );
      });

      test('converts 16-bit unsigned int', () {
        // Test truncation
        expect(
          [0x54, 0x32, 0x10].asInt(endian: Endian.big, type: IntType.uint16),
          12816,
        );
        expect(
          [0x10, 0x98, 0x76].asInt(endian: Endian.little, type: IntType.uint16),
          38928,
        );

        // Test padding
        // Because of the padding, the MSB is 0 instead of the 1 from 0x9
        expect(
          [0x98].asInt(endian: Endian.big, type: IntType.uint16),
          152,
        );
      });

      test('16-bit boundaries', () {
        expect(
          [0x7F, 0xFF].asInt(endian: Endian.big, type: IntType.int16),
          32767,
        );
        expect(
          [0x7F, 0xFF].asInt(endian: Endian.big, type: IntType.uint16),
          32767,
        );

        expect(
          [0x80, 0x00].asInt(endian: Endian.big, type: IntType.int16),
          -32768,
        );
        expect(
          [0x80, 0x00].asInt(endian: Endian.big, type: IntType.uint16),
          32768,
        );
      });

      test('converts 8-bit int', () {
        // Test truncation
        expect(
          [0x54, 0x32, 0x10].asInt(endian: Endian.big, type: IntType.int8),
          16,
        );
        expect(
          [0x98, 0x10, 0x76].asInt(endian: Endian.little, type: IntType.int8),
          -104,
        );

        // Test padding
        expect(<int>[].asInt(endian: Endian.big, type: IntType.int8), 0);
        expect(<int>[].asInt(endian: Endian.little, type: IntType.int8), 0);
      });

      test('converts 8-bit unsigned int', () {
        // Test truncation
        expect(
          [0x54, 0x32, 0x10].asInt(endian: Endian.big, type: IntType.uint8),
          16,
        );
        expect(
          [0x98, 0x10, 0x76].asInt(endian: Endian.little, type: IntType.uint8),
          152,
        );

        // Test padding
        expect(<int>[].asInt(endian: Endian.big, type: IntType.uint8), 0);
        expect(<int>[].asInt(endian: Endian.little, type: IntType.uint8), 0);
      });

      test('8-bit boundaries', () {
        expect(
          [0x7F].asInt(endian: Endian.big, type: IntType.int8),
          127,
        );
        expect(
          [0x7F].asInt(endian: Endian.big, type: IntType.uint8),
          127,
        );

        expect(
          [0x80].asInt(endian: Endian.big, type: IntType.int8),
          -128,
        );
        expect(
          [0x80].asInt(endian: Endian.big, type: IntType.uint8),
          128,
        );
      });
    });
  });
}
