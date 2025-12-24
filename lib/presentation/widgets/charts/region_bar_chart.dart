import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';

class RegionBarChart extends StatelessWidget {
  final Map<String, double> data;
  final String? title;
  final double? height;
  
  const RegionBarChart({
    super.key,
    required this.data,
    this.title,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = data.entries.toList();
    final maxValue = data.values.fold(0.0, (a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive height based on screen width
        final chartHeight = height ?? (constraints.maxWidth > 600 ? 250.0 : 180.0);
        // Responsive bar width
        final barWidth = constraints.maxWidth > 600 ? 28.0 : 20.0;
        final labelStep = entries.length <= 4
            ? 1
            : (entries.length / (constraints.maxWidth > 600 ? 8 : 5)).ceil();

        if (entries.isEmpty) {
          return SizedBox(
            height: chartHeight,
            child: Center(
              child: Text(
                'No region data',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }

        final safeMaxY = maxValue > 0 ? maxValue * 1.2 : 1.0;
        final safeInterval = maxValue > 0 ? (maxValue / 4) : 1.0;
        
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
                          text: DateFormatter.formatCurrency(rod.toY),
                          style: TextStyle(
                            color: AppTheme.chartColors[group.x % AppTheme.chartColors.length],
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
                      final shortLabel = label.length > 12
                          ? '${label.substring(0, 12)}…'
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
                    reservedSize: 50,
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
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: safeInterval,
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
                      color: AppTheme.chartColors[index % AppTheme.chartColors.length],
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
