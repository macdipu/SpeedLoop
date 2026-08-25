import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:speedloop/core/services/ordered_async_queue.dart';

void main() {
  test('serializes rapid writes and flush waits for delayed work', () async {
    final queue = OrderedAsyncQueue();
    final order = <int>[];
    final gate = Completer<void>();
    queue.add(() async {
      await gate.future;
      order.add(1);
    });
    queue.add(() async => order.add(2));
    queue.add(() async => order.add(3));

    var flushed = false;
    final flush = queue.flush().then((_) => flushed = true);
    await Future<void>.delayed(Duration.zero);
    expect(flushed, isFalse);
    gate.complete();
    await flush;
    expect(order, [1, 2, 3]);
  });

  test('captures a failed insert without blocking later writes', () async {
    final errors = <Object>[];
    final queue = OrderedAsyncQueue(onError: (error, _) => errors.add(error));
    final order = <int>[];
    queue.add(() async => throw StateError('insert failed'));
    queue.add(() async => order.add(2));
    queue.seal();
    await queue.flush();

    expect(queue.hasError, isTrue);
    expect(errors, hasLength(1));
    expect(order, [2]);
    expect(() => queue.add(() async {}), throwsStateError);
    await expectLater(
      queue.flush(throwOnError: true),
      throwsA(isA<OrderedAsyncQueueException>()),
    );
  });
}
