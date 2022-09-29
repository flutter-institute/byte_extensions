import 'dart:typed_data';

/// Actually do the truncating. No bounds checking, assumed valid.
List<int> _doEndianTruncate(
    List<int> data, int size, int maxLength, Endian endian) {
  final offset = endian == Endian.little ? 0 : size - maxLength;
  return data.sublist(offset, offset + maxLength);
}

/// Actually do the padding. No bound checking, assumed valid.
List<int> _doEndianPadding(
    List<int> data, int size, int maxLength, Endian endian) {
  final padding = List.filled(maxLength - size, 0);
  return endian == Endian.little
      ? ([
          ...data,
          ...padding,
        ])
      : ([
          ...padding,
          ...data,
        ]);
}

/// Force a list to the given [length] by either padding or truncated the
/// most significant bytes according to the given [endian]
List<int> endianFixedLength(List<int> data, int length, Endian endian) {
  final size = data.length;
  if (size < length) {
    // Pad
    return _doEndianPadding(data, size, length, endian);
  } else if (size > length) {
    // Truncate
    return _doEndianTruncate(data, size, length, endian);
  }
  // No action required
  return data;
}

/// Pad the most significant bytes with 0x00 to [maxLength]
/// Big Endian is padded on the left, and Little Endian is padded on the right.
/// Returns a new list that is properly padded.
List<int> endianPad(List<int> data, int maxLength, Endian endian) {
  final size = data.length;
  return (size < maxLength)
      ? _doEndianPadding(data, size, maxLength, endian)
      : data;
}

/// Truncate the most significant bytes so we only have [maxLength] bytes left.
/// Big Endian is truncated on the left, and Little Endian is truncated on the right.
/// Returns a new list that is properly truncated.
List<int> endianTruncate(List<int> data, int maxLength, Endian endian) {
  final size = data.length;
  return (size > maxLength)
      ? _doEndianTruncate(data, size, maxLength, endian)
      : data;
}
