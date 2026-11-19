import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/api/api.dart';
import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';

class ActivityMetricView extends StatefulWidget {
  final String metric;
  final String deviceName;
  final MetricTrend? initialTrend;
  final VoidCallback onBack;

  const ActivityMetricView({
    super.key,
    required this.metric,
    required this.deviceName,
    this.initialTrend,
    required this.onBack,
  });

  @override
  State<ActivityMetricView> createState() => _ActivityMetricViewState();
}

class _ActivityMetricViewState extends State<ActivityMetricView> {
  String _selectedPeriod = 'day';
  late DateTime _anchorDate;
  MetricTrend? _trend;
  bool _isLoading = false;

  final List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final Map<String, String> _metricTitles = {
    'spo2': 'SpO₂',
    'steps': 'Steps',
    'heart-rate': 'Heart Rate',
    'sleep': 'Sleep',
  };

  final List<Map<String, String>> _periods = [
    {'id': 'day', 'label': 'Day'},
    {'id': 'week', 'label': 'Week'},
    {'id': 'month', 'label': 'Month'},
    {'id': 'year', 'label': 'Year'},
  ];

  @override
  void initState() {
    super.initState();
    _anchorDate = DateTime.now();
    _trend = widget.initialTrend;
    if (_trend == null) {
      _loadTrend();
    }
  }

  String _formatDateKey(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool get _canShiftForward {
    final today = DateTime.now();
    final todayKey = _formatDateKey(today);
    final anchorKey = _formatDateKey(_anchorDate);
    return anchorKey.compareTo(todayKey) < 0;
  }

  String _getPeriodLabel() {
    final anchor = _anchorDate;
    switch (_selectedPeriod) {
      case 'day':
        return '${anchor.day} ${_monthNames[anchor.month - 1]} ${anchor.year}';
      case 'week':
        final start = anchor.subtract(const Duration(days: 6));
        return '${start.day} ${_monthNames[start.month - 1]} – ${anchor.day} ${_monthNames[anchor.month - 1]} ${anchor.year}';
      case 'month':
        final start = anchor.subtract(const Duration(days: 29));
        return '${start.day} ${_monthNames[start.month - 1]} – ${anchor.day} ${_monthNames[anchor.month - 1]} ${anchor.year}';
      case 'year':
        final startMonthIndex = (anchor.month % 12);
        final startYear = anchor.year - 1;
        return '${_monthNames[startMonthIndex]} $startYear – ${_monthNames[anchor.month - 1]} ${anchor.year}';
      default:
        return '${anchor.day} ${_monthNames[anchor.month - 1]} ${anchor.year}';
    }
  }

  void _shiftAnchor(int direction) {
    if (direction > 0 && !_canShiftForward) return;

    DateTime next;
    switch (_selectedPeriod) {
      case 'day':
        next = _anchorDate.add(Duration(days: direction));
        break;
      case 'week':
        next = _anchorDate.add(Duration(days: 7 * direction));
        break;
      case 'month':
        next = _anchorDate.add(Duration(days: 30 * direction));
        break;
      case 'year':
        next = DateTime(_anchorDate.year + direction, _anchorDate.month, _anchorDate.day);
        break;
      default:
        next = _anchorDate.add(Duration(days: direction));
    }

    final today = DateTime.now();
    if (next.isAfter(today)) {
      next = today;
    }

    setState(() {
      _anchorDate = next;
    });

    _loadTrend();
  }

  Future<void> _loadTrend() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.instance.getWearableMetricTrend(
        metric: widget.metric,
        period: _selectedPeriod,
        anchorDate: _formatDateKey(_anchorDate),
      );
      if (res != null && mounted) {
        setState(() => _trend = res);
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _metricTitles[widget.metric] ?? widget.metric;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.onBack,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.chevronLeft,
                    size: 18,
                    color: ColorValues.mutedForeground,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Back to activities',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: ColorValues.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: ColorValues.foreground,
              letterSpacing: -0.3,
            ),
          ),
          if (widget.deviceName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              widget.deviceName,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: ColorValues.mutedForeground,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorValues.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ColorValues.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodTabs(),
                const SizedBox(height: 18),
                _buildDateNavigator(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildChartSection(),
                const SizedBox(height: 16),
                _buildLegend(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: _periods.map((item) {
          final id = item['id']!;
          final label = item['label']!;
          final isSelected = _selectedPeriod == id;

          return Expanded(
            child: InkWell(
              onTap: () {
                if (_selectedPeriod != id) {
                  setState(() => _selectedPeriod = id);
                  _loadTrend();
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? ColorValues.foreground : ColorValues.mutedForeground,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => _shiftAnchor(-1),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorValues.border),
            ),
            alignment: Alignment.center,
            child: const Icon(
              LucideIcons.chevronLeft,
              size: 16,
              color: ColorValues.foreground,
            ),
          ),
        ),
        Text(
          _getPeriodLabel(),
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: ColorValues.foreground,
          ),
        ),
        InkWell(
          onTap: _canShiftForward ? () => _shiftAnchor(1) : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _canShiftForward ? ColorValues.border : ColorValues.border.withValues(alpha: 0.5),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: _canShiftForward ? ColorValues.foreground : ColorValues.mutedForeground.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final stats = _trend?.stats ?? [];

    if (stats.isEmpty) {
      final defaultHeadline = _trend?.headline;
      if (defaultHeadline != null) {
        return _buildStatItem(defaultHeadline.value, defaultHeadline.unit, defaultHeadline.label);
      }
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 36,
      runSpacing: 14,
      children: stats.map((stat) {
        return _buildStatItem(stat.value, stat.unit, stat.label);
      }).toList(),
    );
  }

  String _translateStatLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('rata-rata spo') || lower.contains('average spo')) return 'Average SpO₂';
    if (lower.contains('rentang spo') || lower.contains('range spo')) return 'SpO₂ Range';
    if (lower.contains('rata-rata harian') || lower.contains('daily average')) return 'Daily Average';
    if (lower.contains('total langkah') || lower.contains('total steps')) return 'Total Steps';
    if (lower.contains('rentang denyut') || lower.contains('heart rate range')) return 'Heart Rate Range';
    if (lower.contains('istirahat') || lower.contains('resting')) return 'Resting Heart Rate';
    if (lower.contains('tidur malam') || lower.contains('night sleep')) return 'Average Night Sleep';
    if (lower.contains('tidur siang') || lower.contains('nap')) return 'Average Nap Sleep';
    return label;
  }

  String _translateUnit(String unit) {
    final lower = unit.toLowerCase();
    if (lower == 'langkah') return 'steps';
    if (lower == 'mnt') return 'min';
    if (lower == 'j') return 'h';
    return unit;
  }

  String _translateValue(String value) {
    return value
        .replaceAll(' mnt', ' min')
        .replaceAll('mnt', 'm')
        .replaceAll(' j ', 'h ')
        .replaceAll(' j', 'h');
  }

  Widget _buildStatItem(String value, String unit, String label) {
    final displayVal = _translateValue(value);
    final displayUnit = _translateUnit(unit);
    final displayLabel = _translateStatLabel(label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              displayVal,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: ColorValues.foreground,
                letterSpacing: -0.5,
              ),
            ),
            if (displayUnit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                displayUnit,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorValues.mutedForeground,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          displayLabel,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: ColorValues.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    final points = _trend?.points ?? [];

    return SizedBox(
      height: 230,
      width: double.infinity,
      child: _isLoading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: ColorValues.primary),
              ),
            )
          : CustomPaint(
              size: const Size(double.infinity, 230),
              painter: _DetailedWearableChartPainter(
                metric: widget.metric,
                period: _selectedPeriod,
                points: points,
              ),
            ),
    );
  }

  Widget _buildLegend() {
    if (widget.metric == 'spo2') {
      return Row(
        children: [
          _buildLegendItem(const Color(0xFFEF4444), '< 70%'),
          const SizedBox(width: 16),
          _buildLegendItem(const Color(0xFFF59E0B), '70%–89%'),
          const SizedBox(width: 16),
          _buildLegendItem(const Color(0xFF10B981), '90%–100%'),
        ],
      );
    }

    if (widget.metric == 'sleep' && _selectedPeriod == 'day') {
      return Row(
        children: [
          _buildLegendItem(const Color(0xFF0284C7), 'Deep'),
          const SizedBox(width: 14),
          _buildLegendItem(const Color(0xFF06B6D4), 'Light'),
          const SizedBox(width: 14),
          _buildLegendItem(const Color(0xFF818CF8), 'REM'),
          const SizedBox(width: 14),
          _buildLegendItem(const Color(0xFFF59E0B), 'Awake'),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: ColorValues.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _DetailedWearableChartPainter extends CustomPainter {
  final String metric;
  final String period;
  final List<TrendPoint> points;

  _DetailedWearableChartPainter({
    required this.metric,
    required this.period,
    required this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (metric == 'heart-rate' && period == 'day') {
      _paintHeartRateDayAreaChart(canvas, size);
      return;
    }

    _paintBarChart(canvas, size);
  }

  void _paintHeartRateDayAreaChart(Canvas canvas, Size size) {
    const leftMargin = 32.0;
    const bottomMargin = 26.0;
    final chartWidth = size.width - leftMargin;
    final chartHeight = size.height - bottomMargin;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    final textStyle = GoogleFonts.poppins(
      fontSize: 11,
      color: const Color(0xFF94A3B8),
      fontWeight: FontWeight.w400,
    );

    final yTicks = [40, 60, 80, 100, 120];
    for (final tick in yTicks) {
      final y = chartHeight - ((tick - 40) / 80.0 * chartHeight);
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width, y), gridPaint);

      final span = TextSpan(text: '$tick', style: textStyle);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final validPoints = points.where((p) => p.value != null).toList();
    if (validPoints.isEmpty) return;

    final count = points.length;
    final stepX = chartWidth / (count > 1 ? count - 1 : 1);

    final linePath = Path();
    final fillPath = Path();
    bool hasStarted = false;
    Offset? firstPt;
    Offset? lastPt;

    for (int i = 0; i < count; i++) {
      final p = points[i];
      if (p.value == null) continue;

      final x = leftMargin + i * stepX;
      final val = p.value!.toDouble().clamp(40.0, 140.0);
      final y = chartHeight - ((val - 40) / 80.0 * chartHeight);
      final pt = Offset(x, y);

      if (!hasStarted) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, y);
        firstPt = pt;
        hasStarted = true;
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      lastPt = pt;
    }

    if (firstPt != null && lastPt != null) {
      fillPath.lineTo(lastPt.dx, chartHeight);
      fillPath.lineTo(firstPt.dx, chartHeight);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x4DEF4444),
            Color(0x00EF4444),
          ],
        ).createShader(Rect.fromLTWH(leftMargin, 0, chartWidth, chartHeight));

      canvas.drawPath(fillPath, fillPaint);

      final linePaint = Paint()
        ..color = const Color(0xFFEF4444)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(linePath, linePaint);
    }

    for (int i = 0; i < count; i += 6) {
      final x = leftMargin + i * stepX;
      final label = points[i].label;
      final span = TextSpan(text: label, style: textStyle);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartHeight + 6));
    }
  }

  void _paintBarChart(Canvas canvas, Size size) {
    const leftMargin = 32.0;
    const bottomMargin = 26.0;
    final chartWidth = size.width - leftMargin;
    final chartHeight = size.height - bottomMargin;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    final textStyle = GoogleFonts.poppins(
      fontSize: 11,
      color: const Color(0xFF94A3B8),
      fontWeight: FontWeight.w400,
    );

    List<double> yTicks;
    double minY;
    double maxY;

    if (metric == 'spo2') {
      yTicks = [85, 90, 95, 100];
      minY = 85;
      maxY = 100;
    } else if (metric == 'sleep') {
      final maxVal = points.map((p) => p.value?.toDouble() ?? 0.0).fold(0.0, math.max);
      final roundedMax = ((maxVal / 60).ceil() * 60.0).clamp(180.0, 600.0);
      minY = 0;
      maxY = roundedMax;
      yTicks = [0, maxY / 2, maxY];
    } else {
      final maxVal = points.map((p) => p.value?.toDouble() ?? 0.0).fold(0.0, math.max);
      final upper = maxVal > 0 ? (maxVal * 1.25) : 1000.0;
      final step = (upper / 3).ceilToDouble();
      minY = 0;
      maxY = step * 3;
      yTicks = [0, step, step * 2, maxY];
    }

    for (final tick in yTicks) {
      final normalized = (tick - minY) / (maxY - minY);
      final y = chartHeight - (normalized * chartHeight);
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width, y), gridPaint);

      String tickText = '${tick.toInt()}';
      if (metric == 'sleep') {
        tickText = '${(tick / 60).round()} h';
      }

      final span = TextSpan(text: tickText, style: textStyle);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final count = points.length;
    if (count == 0) return;

    final availableWidthPerItem = chartWidth / count;
    final maxBarWidth = metric == 'spo2' ? 48.0 : metric == 'sleep' && period == 'day' ? 44.0 : 36.0;
    final barWidth = math.min(availableWidthPerItem * 0.65, maxBarWidth);

    final sleepColors = {
      'deep': const Color(0xFF0284C7),
      'light': const Color(0xFF06B6D4),
      'rem': const Color(0xFF818CF8),
      'awake': const Color(0xFFF59E0B),
    };

    for (int i = 0; i < count; i++) {
      final p = points[i];
      final val = p.value?.toDouble();
      if (val == null) continue;

      final centerX = leftMargin + (i + 0.5) * availableWidthPerItem;
      final normalized = ((val - minY) / (maxY - minY)).clamp(0.0, 1.0);
      final barH = normalized * chartHeight;
      final topY = chartHeight - barH;

      Color barColor;
      if (metric == 'spo2') {
        if (val < 70) {
          barColor = const Color(0xFFEF4444);
        } else if (val < 90) {
          barColor = const Color(0xFFF59E0B);
        } else {
          barColor = const Color(0xFF10B981);
        }
      } else if (metric == 'sleep' && period == 'day') {
        barColor = sleepColors[p.key] ?? const Color(0xFF0284C7);
      } else if (metric == 'heart-rate') {
        barColor = const Color(0xFFEF4444);
      } else {
        barColor = const Color(0xFF0284C7);
      }

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(centerX - barWidth / 2, topY, barWidth, barH),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );

      final barPaint = Paint()..color = barColor;
      canvas.drawRRect(rrect, barPaint);

      bool showLabel = true;
      if (count > 10) {
        final step = (count / 6).ceil();
        showLabel = (i % step == 0) || (i == count - 1);
      }

      if (showLabel) {
        final span = TextSpan(text: p.label, style: textStyle);
        final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(centerX - tp.width / 2, chartHeight + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DetailedWearableChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.metric != metric ||
        oldDelegate.period != period;
  }
}

