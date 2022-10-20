import 'dart:async';
import 'dart:typed_data';

import 'enums.dart';
import 'integer_extensions.dart';
import 'double_extensions.dart';
import 'bigint_extensions.dart';

typedef _Transformer<T> = T Function(List<int> buffer);

/// Class to do all the logic of transforming an int stream into a properly
/// sized List<int> to convert into one of our managed types
abstract class _BaseByteStreamTransformer<T>
    implements StreamTransformer<int, T> {
  _BaseByteStreamTransformer(
      this.endian, this.bytesPerElement, this._transformer,
      {bool sync = false, this.cancelOnError = false}) {
    _controller = StreamController<T>(
      sync: sync,
      onListen: _onListen,
      onCancel: _onCancel,
      onPause: _onPause,
      onResume: _onResume,
    );
  }

  _BaseByteStreamTransformer.broadcast(
      this.endian, this.bytesPerElement, this._transformer,
      {bool sync = false, this.cancelOnError = false}) {
    _controller = StreamController<T>.broadcast(
      sync: sync,
      onListen: _onListen,
      onCancel: _onCancel,
    );
  }

  final List<int> _buffer = [];
  final Endian endian;
  final int bytesPerElement;
  final bool cancelOnError;

  final _Transformer<T> _transformer;
  late final StreamController<T> _controller;

  Stream<int>? _stream;
  StreamSubscription<int>? _subscription;

  /** Stream Internals */

  /// Handle stream subscription
  void _onListen() {
    if (_subscription != null) {
      _onCancel();
    }

    _subscription = _stream?.listen(
      _onData,
      onError: _controller.addError,
      onDone: _controller.close,
      cancelOnError: cancelOnError,
    );
  }

  /// Cancel subscription
  void _onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Pause subscription for non-broadcast streams
  void _onPause() {
    _subscription?.pause();
  }

  /// Resume subscription for non-broadcast streams
  void _onResume() {
    _subscription?.resume();
  }

  /** Transformation */

  /// Receive new data from the parent stream
  ///
  /// Buffer the data until we have enough to emit and int,
  /// then parse and emit said int
  void _onData(int data) {
    _buffer.add(data);
    if (_buffer.length == bytesPerElement) {
      _controller.add(_transformer(_buffer));
      _buffer.clear();
    }
  }

  @override
  Stream<T> bind(Stream<int> stream) {
    _buffer.clear();
    _stream = stream;
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    throw UnsupportedError('Cannot cast this stream');
  }
}

/// Create a transformer to convert a byte array to an int
_Transformer<int> _intTransformer(Endian endian, IntType type) =>
    (List<int> buffer) => buffer.asInt(endian: endian, type: type);

/// Transform a byte stream into an integer stream
class IntegerByteStreamTransformer extends _BaseByteStreamTransformer<int> {
  IntegerByteStreamTransformer(Endian endian, this.type,
      {bool sync = false, bool cancelOnError = false})
      : super(
          endian,
          type.bytesPerElement,
          _intTransformer(endian, type),
          sync: sync,
          cancelOnError: cancelOnError,
        );

  IntegerByteStreamTransformer.broadcast(Endian endian, this.type,
      {bool sync = false, bool cancelOnError = false})
      : super.broadcast(
          endian,
          type.bytesPerElement,
          _intTransformer(endian, type),
          sync: sync,
          cancelOnError: cancelOnError,
        );

  final IntType type;
}

/// Create a transformer to convert a byte array to a double
_Transformer<double> _doubleTransformer(Endian endian, Precision precision) =>
    (List<int> buffer) => buffer.asDouble(endian: endian, precision: precision);

/// Transform a byte stream into a stream of doubles
class DoubleByteStreamTransformer extends _BaseByteStreamTransformer<double> {
  DoubleByteStreamTransformer(Endian endian, this.precision,
      {bool sync = false, bool cancelOnError = false})
      : super(
          endian,
          precision.bytesPerElement,
          _doubleTransformer(endian, precision),
          sync: sync,
          cancelOnError: cancelOnError,
        );

  DoubleByteStreamTransformer.broadcast(Endian endian, this.precision,
      {bool sync = false, bool cancelOnError = false})
      : super.broadcast(
          endian,
          precision.bytesPerElement,
          _doubleTransformer(endian, precision),
          sync: sync,
          cancelOnError: cancelOnError,
        );

  final Precision precision;
}

/// Create a transformer to convert a byte array to a BigInt
_Transformer<BigInt> _bigIntTransformer(Endian endian, bool signed) =>
    (List<int> buffer) => buffer.asBigInt(endian: endian, signed: signed);

/// Transform a byte stream into a stream of BigInts
class BigIntByteStreamTransformer extends _BaseByteStreamTransformer<BigInt> {
  BigIntByteStreamTransformer(Endian endian, int bytesPerElement,
      {bool signed = false, bool sync = false, bool cancelOnError = false})
      : super(
          endian,
          bytesPerElement,
          _bigIntTransformer(endian, signed),
          sync: sync,
          cancelOnError: cancelOnError,
        );

  BigIntByteStreamTransformer.broadcast(Endian endian, int bytesPerElement,
      {bool signed = false, bool sync = false, bool cancelOnError = false})
      : super.broadcast(
          endian,
          bytesPerElement,
          _bigIntTransformer(endian, signed),
          sync: sync,
          cancelOnError: cancelOnError,
        );
}
