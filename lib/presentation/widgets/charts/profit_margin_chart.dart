import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/utils/date_formatter.dart';

class ProfitMarginChart extends StatelessWidget {
  final Map<String, double> data;
  final String? title;
  final double? height;
  
  const ProfitMarginChart({
    super.key,
    required this.data,
    this.title,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = data.entries.toList();
    final accent = theme.colorScheme.secondary;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing
        final chartHeight = height ?? (constraints.maxWidth > 600 ? 220.0 : 160.0);
        final barWidth = constraints.maxWidth > 600 ? 36.0 : 24.0;

        final maxValue = entries.isEmpty
            ? 0.0
            : entries
                .map((e) => e.value)
                .fold<double>(0.0, (a, b) => a > b ? a : b);

        final safeMaxY = maxValue > 0 ? (maxValue * 1.2) : 0.1;
        final labelStep = entries.length <= 4
            ? 1
            : (entries.length / (constraints.maxWidth > 600 ? 8 : 5)).ceil();

        double intervalFor(double value) {
          if (value <= 0) return 0.05;
          final raw = value / 4;
          // round to 0.01
          return (raw * 100).round() / 100;
        }
        
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
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
                  maxY: safeMaxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => theme.cardColor,
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${entries[group.x].key}\n',
                      TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: DateFormatter.formatPercentage(rod.toY),
                          style: TextStyle(
                                color: accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
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
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                          if (index < 0 || index >= entries.length) {
                            return const SizedBox.shrink();
                          }

                          if (index % labelStep != 0 && index != entries.length - 1) {
                            return const SizedBox.shrink();
                          }

                          final label = entries[index].key;
                          final shortLabel = label.length > 10
                              ? '${label.substring(0, 10)}…'
                              : label;

                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Transform.rotate(
                              angle: -0.6,
                              child: Text(
                                shortLabel,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                    },
                        reservedSize: constraints.maxWidth > 600 ? 56 : 66,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                        interval: intervalFor(safeMaxY),
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value * 100).round()}%',
                        style: theme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                    horizontalInterval: intervalFor(safeMaxY),
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.dividerColor,
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: entries.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: item.value,
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 179),
                          accent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: barWidth,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
          ],
        );
      },
    );
  }
}
