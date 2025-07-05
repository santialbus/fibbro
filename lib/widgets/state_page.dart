import 'package:flutter/material.dart';
import '../widgets/stage_app_bar.dart';

class StagePage extends StatefulWidget {
  final String stageName;
  final List<String> dates;
  final String festivalId;

  const StagePage({
    super.key,
    required this.stageName,
    required this.dates,
    required this.festivalId,
  });

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  int selectedDateIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StageAppBar(
        stage: widget.stageName,
        dates: widget.dates,
        currentIndex: selectedDateIndex,
        onDateChanged: (i) => setState(() => selectedDateIndex = i),
      ),
      body: Center(
        child: Text(
          'Escenario: ${widget.stageName}\nFecha: ${widget.dates[selectedDateIndex]}',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
