import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../controllers/tracking_log_controller.dart';

class TrackingLogChartView extends StatelessWidget {
  const TrackingLogChartView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrackingLogController>();
    final data = controller.getLogCountPerDay();

    final keys = data.keys.toList()..sort();
    final values = keys.map((k) => data[k]!.toDouble()).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Grafik Aktivitas Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                        index < keys.length ? keys[index].substring(5) : ''),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
          barGroups: List.generate(keys.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(toY: values[i], width: 12)],
            );
          }),
        )),
      ),
    );
  }
}
