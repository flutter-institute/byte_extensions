import 'dart:typed_data';

import 'package:byte_extensions/src/helpers.dart';

// This code heavily based on https://github.com/dart-lang/sdk/issues/32803#issuecomment-387405784
// but with added endian handling

/// A BigInt representing 256
final _b256 = BigInt.from(256);

/// Extension to add our `toBytes` handling to BigInt
extension BigIntToBytesExtension on BigInt {
  /// Convert a BigInt to bytes with respect to Endianness of [endian].
  /// If [maxBytes] is set, then it will ensure the result is fixed length such that:
  /// 1) If the [maxBytes] is less than our number of bytes, the more significant bytes are truncated.
  /// 2) If the [maxBytes] is greater than our number of bytes, the more significant bytes are set to 0x00.
  Uint8ClampedList toBytes([Endian endian = Endian.big, int? maxBytes]) {
    // Negative numbers?

    final bytes = (bitLength + 7) >> 3; // How many bytes are in the final list
    final parsed = Uint8List(bytes); // Our result

    // Break the big int into individual bytes.
    // This conversion results in little endian ordering.
    var number = this;
    for (int i = 0; i < bytes; i++) {
      parsed[i] = number.remainder(_b256).toInt();
      number = number >> 8;
    }

    // Strip any leading 0's, since they're extraneous at this point
    var result = parsed.skipWhile((value) => value == 0x00).toList();
    // Reverse the list if we want big endian order
    if (endian == Endian.big) {
      result = result.reversed.toList();
    }

    // Truncate or pad as needed
    if (maxBytes != null) {
      result = endianFixedLength(result, maxBytes, endian);
    }

    // Result into a new list
    return Uint8ClampedList.fromList(result);
  }
}

/// Extension to add our `toBigInt` handling to List<int>
extension IntListToBigIntExtension on List<int> {
  /// Convert a list of bytes to a BigInt. Endianness can be changed by passing [endian].
  BigInt toBigInt([Endian endian = Endian.big]) {
    // binary search conversion to convert 4-bytes at a time
    BigInt read(int start, int end) {
      if (end - start <= 4) {
        int result = 0;
        if (endian == Endian.little) {
          for (int i = end - 1; i >= start; i--) {
            result = result * 256 + this[i];
          }
        } else {
          for (int i = start; i < end; i++) {
            result = result * 256 + this[i];
          }
        }
        return BigInt.from(result);
      }
      int mid = start + ((end - start) >> 1);
      var front = read(start, mid);
      var back = read(mid, end);
      if (endian == Endian.little) {
        // Move the back bits to the left
        back <<= ((mid - start) * 8);
      } else {
        // Move the front bits to the left
        front <<= ((end - mid) * 8);
      }
      final result = front + back;
      return result;
    }

    return read(0, length);
  }
}
