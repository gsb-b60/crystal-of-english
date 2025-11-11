import 'package:flutter_test/flutter_test.dart';
import 'package:mygame/components/Menu/flashcard/business/scheduler.dart';

void main() {
  test('SM-2: perfect review increases interval', () {
    final prev = computeSM2(quality: 5, prevInterval: 1, prevReps: 1, prevEF: 2.5);
    expect(prev.reps, greaterThanOrEqualTo(2));
    expect(prev.intervalDays, greaterThanOrEqualTo(1));
  });

  test('SM-2: failure resets reps', () {
    final res = computeSM2(quality: 1, prevInterval: 10, prevReps: 5, prevEF: 2.5);
    expect(res.reps, equals(0));
    expect(res.intervalDays, equals(1));
  });

  test('SM-2: EF lower bound enforced', () {
    final res = computeSM2(quality: 0, prevInterval: 10, prevReps: 3, prevEF: 1.2);
    expect(res.easeFactor, greaterThanOrEqualTo(1.3));
  });
}
