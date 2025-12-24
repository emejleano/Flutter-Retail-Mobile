import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/utils/date_formatter.dart';
import 'dart:math' as math;

class SalesLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> labels;
  final String? title;
  final double? height;

  const SalesLineChart({
    super.key,
    required this.spots,
    required this.labels,
    this.title,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive height based on screen width
        final chartHeight =
            height ?? (constraints.maxWidth > 600 ? 250.0 : 180.0);

        final maxY = spots.isEmpty
            ? 0.0
            : spots.map((s) => s.y).fold<double>(0.0, (a, b) => a > b ? a : b);

        double niceNum(double range, {required bool round}) {
          if (range <= 0) return 1;
          final exponent = (range == 0) ? 0.0 : (math.log(range) / math.ln10);
          final expFloor = exponent.floorToDouble();
          final fraction = range / math.pow(10, expFloor);

          double niceFraction;
          if (round) {
            if (fraction < 1.5) {
              niceFraction = 1;
            } else if (fraction < 3) {
              niceFraction = 2;
            } else if (fraction < 7) {
              niceFraction = 5;
            } else {
              niceFraction = 10;
            }
          } else {
            if (fraction <= 1) {
              niceFraction = 1;
            } else if (fraction <= 2) {
              niceFraction = 2;
            } else if (fraction <= 5) {
              niceFraction = 5;
            } else {
              niceFraction = 10;
            }
          }

          return niceFraction * math.pow(10, expFloor);
        }

        double niceTick(double max, {int targetTicks = 5}) {
          if (max <= 0) return 1;
          final range = niceNum(max, round: false);
          final tick = niceNum(range / (targetTicks - 1), round: true);
          return tick <= 0 ? 1 : tick;
        }

        final yInterval = niceTick(maxY, targetTicks: 5);
        final paddedMaxY = maxY <= 0
            ? 1.0
            : (maxY / yInterval).ceil() * yInterval;

        final labelStep = labels.length <= 6
            ? 1
            : (labels.length / (constraints.maxWidth > 600 ? 10 : 6)).ceil();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(
              height: chartHeight,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: paddedMaxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: theme.dividerColor, strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= labels.length) {
                            return const SizedBox.shrink();
                          }

                          if (index % labelStep != 0 &&
                              index != labels.length - 1) {
                            return const SizedBox.shrink();
                          }

                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(
                              labels[index],
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 56,
                        interval: yInterval,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            DateFormatter.formatCompactNumber(value),
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.25,
                      color: primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            primary.withValues(alpha: 0.18),
                            primary.withValues(alpha: 0.00),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => theme.cardColor,
                      tooltipRoundedRadius: 10,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final i = spot.x.toInt();
                          final label = (i >= 0 && i < labels.length)
                              ? labels[i]
                              : '';
                          return LineTooltipItem(
                            label.isEmpty ? '' : '$label\n',
                            TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text: DateFormatter.formatCurrency(spot.y),
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
