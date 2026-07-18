import 'package:flutter/material.dart';

class MalpraxTable extends StatelessWidget {
  const MalpraxTable({super.key, required this.columns, required this.rows});
  final List<String> columns;
  final List<List<Widget>> rows;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns:
            columns.map((label) => DataColumn(label: Text(label))).toList(),
        rows: rows
            .map((cells) => DataRow(cells: cells.map(DataCell.new).toList()))
            .toList(),
      ));
}
