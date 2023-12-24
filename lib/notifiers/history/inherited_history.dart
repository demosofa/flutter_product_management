import 'package:flutter/cupertino.dart';
import 'package:product_manager/notifiers/history/history_notifier.dart';

class InheritedHistory extends InheritedNotifier<HistoryNotifier> {
  const InheritedHistory(
      {super.key,
      required super.child,
      required HistoryNotifier historyNotifier})
      : super(notifier: historyNotifier);

  @override
  bool updateShouldNotify(InheritedHistory oldHistory) {
    return true;
  }

  static HistoryNotifier? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedHistory>()?.notifier;

  static HistoryNotifier of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No InheritedHistory found in context');
    return result!;
  }
}
