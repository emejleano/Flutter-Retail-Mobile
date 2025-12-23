import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';

class CategoryPieChart extends StatefulWidget {
  final Map<String, double> data;
  final String? title;
  final double? height;
  
  const CategoryPieChart({
    super.key,
    required this.data,
    this.title,
    this.height,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = widget.data.entries.toList();
    final total = widget.data.values.fold(0.0, (a, b) => a + b);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on screen width
        final isWide = constraints.maxWidth > 500;
        final chartSize = widget.height ?? (isWide ? 200.0 : 160.0);
        final pieRadius = isWide ? 55.0 : 45.0;
        final touchedRadius = isWide ? 65.0 : 55.0;
        final centerRadius = isWide ? 45.0 : 35.0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  widget.title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            isWide ? Row(
              children: [
                SizedBox(
                  height: chartSize,
                  width: chartSize,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: centerRadius,
                  sections: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isTouched = index == touchedIndex;
                    final percentage = (item.value / total) * 100;
                    
                    return PieChartSectionData(
                      color: AppTheme.chartColors[index % AppTheme.chartColors.length],
                      value: item.value,
                      title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
                      radius: isTouched ? touchedRadius : pieRadius,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 77),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final color = AppTheme.chartColors[index % AppTheme.chartColors.length];
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.key,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormatter.formatCompactNumber(item.value),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ) : Column(
          // Narrow layout - stack vertically
          children: [
            SizedBox(
              height: chartSize,
              width: chartSize,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: centerRadius,
                  sections: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isTouched = index == touchedIndex;
                    final percentage = (item.value / total) * 100;
                    
                    return PieChartSectionData(
                      color: AppTheme.chartColors[index % AppTheme.chartColors.length],
                      value: item.value,
                      title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
                      radius: isTouched ? touchedRadius : pieRadius,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 77),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: entries.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final color = AppTheme.chartColors[index % AppTheme.chartColors.length];
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.key}: ${DateFormatter.formatCompactNumber(item.value)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
          ],
        );
      },
    );
  }
}
