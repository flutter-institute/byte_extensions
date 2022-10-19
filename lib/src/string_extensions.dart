import 'dart:convert';
import 'dart:typed_data';

/// Extension to add `asBytes` handling to string
extension StringToBytesExtension on String {
  /// Convert the string to an unmodifiable byte list using the specifed [encoding].
  /// If, for some reason, you want to manipulate the endianness of the result, then
  /// the [endian] value can be changed to suite your needs.
  Uint8ClampedList asBytes(Encoding encoding, {Endian endian = Endian.big}) {
    var byteList = encoding.encode(this);
    if (endian == Endian.little) {
      byteList = byteList.reversed.toList();
    }
    return Uint8ClampedList.fromList(byteList);
  }
}

/// Extension to add `asString` handling to List<int>
extension IntListToStringExtension on List<int> {
  /// Convert the byte list to a string using the specified [encoding].
  /// If, for some reason, you want to manipulate the endianness of the result, then
  /// the [endian] value can be changed to suite your needs.
  String asString(Encoding encoding, {Endian endian = Endian.big}) {
    return encoding.decode(endian == Endian.little ? reversed.toList() : this);
  }
}
