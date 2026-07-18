import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout(
      {super.key,
      required this.compact,
      required this.expanded,
      this.breakpoint = 900});
  final Widget compact;
  final Widget expanded;
  final double breakpoint;
  @override
  Widget build(BuildContext context) =>
      MediaQuery.sizeOf(context).width < breakpoint ? compact : expanded;
}
