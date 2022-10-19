import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:byte_extensions/byte_extensions.dart';

void main() {
  group('string extensions', () {
    test('identity', () {
      var sut = 'system under test';
      expect(sut.asBytes(utf8).asString(utf8), sut);
      expect(sut.asBytes(latin1).asString(latin1), sut);
      expect(sut.asBytes(ascii).asString(ascii), sut);
    });

    group('ut8', () {
      test('simple ascii string', () {
        expect('abcd'.asBytes(utf8), [0x61, 0x62, 0x63, 0x64]);
        expect('abcd'.asBytes(utf8, endian: Endian.little),
            [0x64, 0x63, 0x62, 0x61]);
      });

      test('extended character set', () {
        expect('\u0300\u0180\u0107\u010F'.asBytes(utf8),
            [0xCC, 0x80, 0xC6, 0x80, 0xC4, 0x87, 0xC4, 0x8F]);
        expect('\u0300\u0180\u0107\u010F'.asBytes(utf8, endian: Endian.little),
            [0x8F, 0xC4, 0x87, 0xC4, 0x80, 0xC6, 0x80, 0xCC]);
      });
    });

    group('latin1', () {
      test('simple ascii string', () {
        expect('abcd'.asBytes(latin1), [0x61, 0x62, 0x63, 0x64]);
        expect('abcd'.asBytes(latin1, endian: Endian.little),
            [0x64, 0x63, 0x62, 0x61]);
      });

      test('extended character set', () {
        expect('\xC0\xC7\xD0\xC9'.asBytes(latin1), [0xC0, 0xC7, 0xD0, 0xC9]);
        expect('\xC0\xC7\xD0\xC9'.asBytes(latin1, endian: Endian.little),
            [0xC9, 0xD0, 0xC7, 0xC0]);
      });

      test('invalid character', () {
        expect(
            () => '\u0300\u0180'.asBytes(latin1),
            throwsA((e) =>
                e is ArgumentError &&
                e.message.contains('Contains invalid characters')));
      });
    });

    group('ascii', () {
      test('simple ascii string', () {
        expect('abcd'.asBytes(ascii), [0x61, 0x62, 0x63, 0x64]);
        expect('abcd'.asBytes(ascii, endian: Endian.little),
            [0x64, 0x63, 0x62, 0x61]);
      });

      test('extended character set', () {
        expect(
            () => '\x83\xE1\x80\xEB'.asBytes(ascii),
            throwsA((e) =>
                e is ArgumentError &&
                e.message.contains('Contains invalid characters')));
      });
    });

    group('custom', () {
      final encoder = CustomCodec();

      test('simple ascii string', () {
        expect('zyx'.asBytes(encoder), [0x61, 0x62, 0x63]);
        expect(
            'zyx'.asBytes(encoder, endian: Endian.little), [0x63, 0x62, 0x61]);
      });
    });
  });

  group('list<int> extension', () {
    group('utf8', () {
      test('simple ascii string', () {
        expect([0x61, 0x62, 0x63, 0x64].asString(utf8), 'abcd');
        expect([0x64, 0x63, 0x62, 0x61].asString(utf8, endian: Endian.little),
            'abcd');
      });

      test('extended character set', () {
        expect([0xCC, 0x80, 0xC6, 0x80, 0xC4, 0x87, 0xC4, 0x8F].asString(utf8),
            '\u0300\u0180\u0107\u010F');
        expect(
            [0x8F, 0xC4, 0x87, 0xC4, 0x80, 0xC6, 0x80, 0xCC]
                .asString(utf8, endian: Endian.little),
            '\u0300\u0180\u0107\u010F');
      });
    });

    group('latin1', () {
      test('simple ascii string', () {
        expect([0x61, 0x62, 0x63, 0x64].asString(latin1), 'abcd');
        expect([0x64, 0x63, 0x62, 0x61].asString(latin1, endian: Endian.little),
            'abcd');
      });

      test('extended character set', () {
        expect([0xC0, 0xC7, 0xD0, 0xC9].asString(latin1), '\xC0\xC7\xD0\xC9');
        expect([0xC9, 0xD0, 0xC7, 0xC0].asString(latin1, endian: Endian.little),
            '\xC0\xC7\xD0\xC9');
      });

      test('invalid character', () {
        expect(
            () => [0x300, 0x180].asString(latin1),
            throwsA((e) =>
                e is FormatException &&
                e.message.contains('Invalid value in input')));
      });
    });

    group('ascii', () {
      test('simple ascii string', () {
        expect([0x61, 0x62, 0x63, 0x64].asString(ascii), 'abcd');
        expect([0x64, 0x63, 0x62, 0x61].asString(ascii, endian: Endian.little),
            'abcd');
      });

      test('extended character set', () {
        expect(
            () => [0x83, 0xE1, 0x80, 0xEB].asString(ascii),
            throwsA((e) =>
                e is FormatException &&
                e.message.contains('Invalid value in input')));
      });
    });

    group('custom', () {
      final encoder = CustomCodec();

      test('simple ascii string', () {
        expect([1, 2, 3].asString(encoder), 'abc');
        expect([1, 2, 3].asString(encoder, endian: Endian.little), 'abc');
      });
    });
  });
}

class CustomCodec extends Encoding {
  @override
  Converter<List<int>, String> get decoder => CustomConverter();

  @override
  Converter<String, List<int>> get encoder => CustomDecoder();

  @override
  String get name => 'custom';
}

class CustomConverter extends Converter<List<int>, String> {
  @override
  String convert(List<int> input) {
    final buff = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      buff.write(String.fromCharCode((0x61 + i) % 0x7A));
    }
    return buff.toString();
  }
}

class CustomDecoder extends Converter<String, List<int>> {
  @override
  List<int> convert(String input) {
    final result = <int>[];
    for (int i = 0; i < input.length; i++) {
      result.add((0x61 + i) % 0x7A);
    }
    return result;
  }
}
