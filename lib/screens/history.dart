import 'package:flutter/widgets.dart';
import 'package:product_manager/notifiers/history/history_notifier.dart';
import 'package:product_manager/notifiers/history/inherited_history.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late HistoryNotifier _historyNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _historyNotifier = InheritedHistory.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        for (final history in _historyNotifier.listHistory)
          Text(history.data.toString())
      ],
    );
  }
}
