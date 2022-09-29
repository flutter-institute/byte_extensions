import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:byte_extensions/byte_extensions.dart';

void main() {
  group('integer extensions', () {
    test('identity', () {
      var sut = 0xFEDCBA98765432;
      expect(sut.toBytes().asInt64().toInt().asInt64(), sut);
      expect(sut.toBytes().asInt64().toInt().asUint64(), sut);

      sut = 0x98765432;
      expect(sut.toBytes().asInt32().toInt().asUint32(), sut);
      expect(sut.toBytes().asInt32().toInt().asInt32(), sut.toSigned(32));

      sut = 0x9832;
      expect(sut.toBytes().asInt16().toInt().asUint16(), sut);
      expect(sut.toBytes().asInt16().toInt().asInt16(), sut.toSigned(16));

      sut = 0x98;
      expect(sut.toBytes().asInt8().toInt().asUint8(), sut);
      expect(sut.toBytes().asInt8().toInt().asInt8(), sut.toSigned(8));
    });

    group('toBytes', () {
      test('converts 64-bit int', () {
        // -81985529216486896
        expect(
          0xFEDCBA9876543210.toBytes(Endian.big).asInt64(),
          [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10],
        );
        expect(
          0xFEDCBA9876543210.toBytes(Endian.little).asInt64(),
          [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE],
        );
      });

      test('64-bit boundaries', () {
        expect(
          9223372036854775807.toBytes(Endian.big).asInt64(),
          [0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF],
        );

        expect(
          (-9223372036854775808).toBytes(Endian.big).asInt64(),
          [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        );
      });

      test('converts 32-bit int', () {
        expect(
          0xFEDCBA9876543210.toBytes(Endian.big).asInt32(),
          [0x76, 0x54, 0x32, 0x10],
        );
        expect(
          0xFEDCBA9876543210.toBytes(Endian.little).asInt32(),
          [0x10, 0x32, 0x54, 0x76],
        );
      });

      test('32-bit boundaries', () {
        expect(
          2147483647.toBytes(Endian.big).asInt32(),
          [0x7F, 0xFF, 0xFF, 0xFF],
        );

        expect(
          (-2147483648).toBytes(Endian.big).asInt32(),
          [0x80, 0x00, 0x00, 0x00],
        );
      });

      test('converts 16-bit int', () {
        expect(
          0xFEDCBA9876543210.toBytes(Endian.big).asInt16(),
          [0x32, 0x10],
        );
        expect(
          0xFEDCBA9876543210.toBytes(Endian.little).asInt16(),
          [0x10, 0x32],
        );
      });

      test('16-bit boundaries', () {
        expect(
          32767.toBytes(Endian.big).asInt16(),
          [0x7F, 0xFF],
        );

        expect(
          (-32768).toBytes(Endian.big).asInt16(),
          [0x80, 0x00],
        );
      });

      test('converts 8-bit int', () {
        expect(
          0xFEDCBA9876543210.toBytes(Endian.big).asInt8(),
          [0x10],
        );
        expect(
          0xFEDCBA9876543210.toBytes(Endian.little).asInt8(),
          [0x10],
        );
      });

      test('8-bit boundaries', () {
        expect(
          127.toBytes(Endian.big).asInt8(),
          [0x7F],
        );

        expect(
          (-128).toBytes(Endian.big).asInt8(),
          [0x80],
        );
      });
    });
  });

  group('list<int> extensions', () {
    group('toInt', () {
      test('byte value is out of range or negative', () {
        expect(
          [256, 256].toInt().asUint64(),
          0,
        );
        expect(
          [0x10, 256, 0x50].toInt(Endian.big).asUint64(),
          0x100050,
        );
        expect(
          [0x10, 300, 0x50].toInt(Endian.big).asUint64(),
          0x102C50,
        );

        expect(
          [0x10, -256, 0x50].toInt(Endian.big).asUint64(),
          0x100050,
        );
        expect(
          [0x10, -300, 0x50].toInt(Endian.big).asUint64(),
          0x10D450,
        );

        expect(
          [0x10, -1, 0x50].toInt(Endian.big).asUint64(),
          0x10FF50,
        );
        expect(
          [0x10, -255, 0x50].toInt(Endian.big).asUint64(),
          0x100150,
        );
      });

      test('converts 64-bit int', () {
        expect(<int>[].toInt().asInt64(), 0);

        // Test truncation
        expect(
          [0xFF, 0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]
              .toInt(Endian.big)
              .asInt64(),
          -81985529216486896,
        );
        expect(
          [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE, 0xFF]
              .toInt(Endian.little)
              .asInt64(),
          -81985529216486896,
        );

        // Test padding
        expect(
          [0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]
              .toInt(Endian.big)
              .asInt64(),
          62129658859368976,
        );
        expect(
          [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC]
              .toInt(Endian.little)
              .asInt64(),
          62129658859368976,
        );
      });

      test('converts 64-bit unsigned int', () {
        // Dart doesn't have a real Uint64, so it's the same and Int64
        expect(
          [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]
              .toInt(Endian.big)
              .asUint64(),
          -81985529216486896,
        );
        expect(
          [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]
              .toInt(Endian.little)
              .asUint64(),
          -81985529216486896,
        );
      });

      test('64-bit boundaries', () {
        expect(
          [0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
              .toInt(Endian.big)
              .asInt64(),
          9223372036854775807,
        );
        expect(
          [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F]
              .toInt(Endian.little)
              .asUint64(),
          9223372036854775807,
        );

        expect(
          [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
              .toInt(Endian.big)
              .asInt64(),
          -9223372036854775808,
        );
        expect(
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80]
              .toInt(Endian.little)
              .asUint64(),
          -9223372036854775808,
        );
      });

      test('coverts 32-bit int', () {
        expect(<int>[].toInt().asInt32(), 0);

        // Test truncation
        expect(
          [0x98, 0x76, 0x54, 0x32, 0x10].toInt(Endian.big).asInt32(),
          1985229328,
        );
        expect(
          [0x10, 0x32, 0x54, 0x98, 0x76].toInt(Endian.little).asInt32(),
          -1739312624,
        );

        // Test padding
        // Because of the padding, the MSB is 0 instead of the 1 from 0x9
        expect(
          [0x98, 0x32, 0x10].toInt(Endian.big).asInt32(),
          9974288,
        );
        expect(
          [0x10, 0x32, 0x98].toInt(Endian.little).asInt32(),
          9974288,
        );
      });

      test('converts 32-bit unsigned integer', () {
        // Test truncation
        expect(
          [0x98, 0x76, 0x54, 0x32, 0x10].toInt(Endian.big).asUint32(),
          1985229328,
        );
        expect(
          [0x10, 0x32, 0x54, 0x98, 0x76].toInt(Endian.little).asUint32(),
          2555654672,
        );

        // Test padding
        // Because of the padding, the MSB is 0 instead of the 1 from 0x9
        expect(
          [0x98, 0x32, 0x10].toInt(Endian.big).asUint32(),
          9974288,
        );
      });

      test('32-bit boundaries', () {
        expect(
          [0x7F, 0xFF, 0xFF, 0xFF].toInt(Endian.big).asInt32(),
          2147483647,
        );
        expect(
          [0x7F, 0xFF, 0xFF, 0xFF].toInt(Endian.big).asUint32(),
          2147483647,
        );

        expect(
          [0x80, 0x00, 0x00, 0x00].toInt(Endian.big).asInt32(),
          -2147483648,
        );
        expect(
          [0x80, 0x00, 0x00, 0x00].toInt(Endian.big).asUint32(),
          2147483648,
        );
      });

      test('converts 16-bit int', () {
        expect(<int>[].toInt().asInt16(), 0);

        // Test truncation
        expect(
          [0x54, 0x32, 0x10].toInt(Endian.big).asInt16(),
          12816,
        );
        expect(
          [0x10, 0x98, 0x76].toInt(Endian.little).asInt16(),
          -26608,
        );

        // Test padding
        // Because of the padding, the MSB is 0 instead of the 1 from 0x9
        expect(
          [0x98].toInt(Endian.big).asInt16(),
          152,
        );
        expect(
          [0x98].toInt(Endian.little).asInt16(),
          152,
        );
      });

      test('converts 16-bit unsigned int', () {
        // Test truncation
        expect(
          [0x54, 0x32, 0x10].toInt(Endian.big).asUint16(),
          12816,
        );
        expect(
          [0x10, 0x98, 0x76].toInt(Endian.little).asUint16(),
          38928,
        );

        // Test padding
        // Because of the padding, the MSB is 0 instead of the 1 from 0x9
        expect(
          [0x98].toInt(Endian.big).asUint16(),
          152,
        );
      });

      test('16-bit boundaries', () {
        expect(
          [0x7F, 0xFF].toInt(Endian.big).asInt16(),
          32767,
        );
        expect(
          [0x7F, 0xFF].toInt(Endian.big).asUint16(),
          32767,
        );

        expect(
          [0x80, 0x00].toInt(Endian.big).asInt16(),
          -32768,
        );
        expect(
          [0x80, 0x00].toInt(Endian.big).asUint16(),
          32768,
        );
      });

      test('converts 8-bit int', () {
        // Test truncation
        expect(
          [0x54, 0x32, 0x10].toInt(Endian.big).asInt8(),
          16,
        );
        expect(
          [0x98, 0x10, 0x76].toInt(Endian.little).asInt8(),
          -104,
        );

        // Test padding
        expect(<int>[].toInt(Endian.big).asInt8(), 0);
        expect(<int>[].toInt(Endian.little).asInt8(), 0);
      });

      test('converts 8-bit unsigned int', () {
        // Test truncation
        expect(
          [0x54, 0x32, 0x10].toInt(Endian.big).asUint8(),
          16,
        );
        expect(
          [0x98, 0x10, 0x76].toInt(Endian.little).asUint8(),
          152,
        );

        // Test padding
        expect(<int>[].toInt(Endian.big).asUint8(), 0);
        expect(<int>[].toInt(Endian.little).asUint8(), 0);
      });

      test('8-bit boundaries', () {
        expect(
          [0x7F].toInt(Endian.big).asInt8(),
          127,
        );
        expect(
          [0x7F].toInt(Endian.big).asUint8(),
          127,
        );

        expect(
          [0x80].toInt(Endian.big).asInt8(),
          -128,
        );
        expect(
          [0x80].toInt(Endian.big).asUint8(),
          128,
        );
      });
    });
  });
}
