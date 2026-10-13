import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A clock provider that emits the current local DateTime and ticks every 30 seconds.
/// Automatically cancels its periodic timer when disposed.
final clockProvider =
    NotifierProvider<ClockNotifier, DateTime>(ClockNotifier.new);

class ClockNotifier extends Notifier<DateTime> {
  Timer? _timer;

  @override
  DateTime build() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      state = DateTime.now();
    });

    ref.onDispose(() {
      _timer?.cancel();
    });

    return DateTime.now();
  }
}
