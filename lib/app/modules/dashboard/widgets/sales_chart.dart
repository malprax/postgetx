import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SalesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(),
            rightTitles: AxisTitles(),
            topTitles: AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  return Text(data[index]['day']);
                },
              ),
            ),
          ),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                  toY: data[i]['total'].toDouble(), color: Colors.blue)
            ]);
          }),
        ),
      ),
    );
  }
}
