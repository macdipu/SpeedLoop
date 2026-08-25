import 'dart:async';

class OrderedAsyncQueue {
  OrderedAsyncQueue({this.onError});

  final void Function(Object error, StackTrace stackTrace)? onError;
  Future<void> _tail = Future<void>.value();
  bool _sealed = false;
  Object? _firstError;

  bool get hasError => _firstError != null;
  Object? get firstError => _firstError;

  void add(Future<void> Function() operation) {
    if (_sealed) throw StateError('The write queue is sealed.');
    _tail = _tail.then((_) async {
      try {
        await operation();
      } catch (error, stackTrace) {
        _firstError ??= error;
        onError?.call(error, stackTrace);
      }
    });
  }

  void seal() => _sealed = true;

  Future<void> flush({bool throwOnError = false}) async {
    await _tail;
    if (throwOnError && _firstError != null) {
      throw OrderedAsyncQueueException(_firstError!);
    }
  }
}

class OrderedAsyncQueueException implements Exception {
  const OrderedAsyncQueueException(this.cause);

  final Object cause;

  @override
  String toString() => 'An ordered asynchronous operation failed: $cause';
}
