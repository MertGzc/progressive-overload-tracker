import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/exercise.dart';
import '../utils/helpers.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  final String day;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.day,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late Exercise _exercise;
  bool _expanded = false;
  bool _historyExpanded = false;
  bool _logFormExpanded = false;

  final TextEditingController _weightController = TextEditingController();
  final List<TextEditingController> _setControllers = [];

  @override
  void initState() {
    super.initState();
    _exercise = widget.exercise;
    _initializeControllers();
  }

  void _initializeControllers() {
    final setCount = getSetCountFromTarget(_exercise.targetReps);
    for (int i = 0; i < setCount; i++) {
      _setControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    for (var controller in _setControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveLog() {
    try {
      print('_saveLog çağrıldı'); // Debug
      final rawWeight = _weightController.text.trim();
      final weight = normalizeWeight(rawWeight);
      final sets =
          _setControllers
              .map((c) => c.text.trim())
              .where((s) => s.isNotEmpty)
              .toList();

      print('Weight: $weight, Sets: $sets, Set count: ${sets.length}'); // Debug

      if (rawWeight.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen ağırlık girin'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (sets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen en az bir set girin'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final logString = '${weight}kg - ${sets.join('/')}';
      final now = DateTime.now();
      // Manuel tarih formatlama - locale hatası önlemek için
      final day = now.day.toString().padLeft(2, '0');
      final month = now.month.toString().padLeft(2, '0');
      final year = now.year.toString();
      final dateString = '$day.$month.$year';

      final newLog = LogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: dateString,
        weight: weight,
        sets: sets,
        day: widget.day,
      );

      setState(() {
        final history = List<LogEntry>.from(_exercise.history ?? []);
        history.insert(0, newLog);
        _exercise = Exercise(
          id: _exercise.id,
          name: _exercise.name,
          targetReps: _exercise.targetReps,
          lastLog: logString,
          history: history,
          assignedDays: _exercise.assignedDays,
        );

        // Cache'i temizle
        _cachedSortedHistory = null;
        _cachedExercise = null;

        // Geçmiş antrenmanları otomatik aç
        _historyExpanded = true;

        // Inputları temizle
        _weightController.clear();
        for (var controller in _setControllers) {
          controller.clear();
        }
      });

      print('Log kaydedildi: $logString'); // Debug

      // Başarı mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Antrenman kaydedildi! $logString'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Hata _saveLog: $e'); // Debug
      print('Stack trace: $stackTrace'); // Debug
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showEditExerciseDialog() {
    int newSetCount = getSetCountFromTarget(_exercise.targetReps);

    // Extract a single "rep" number from targetReps (eg. from "3x10" -> "10").
    String _extractRepPart(String target) {
      final lower = target.toLowerCase();
      // split on 'x' or multiplication sign
      if (lower.contains('x') || lower.contains('×')) {
        final parts = lower.split(RegExp(r'[x×]'));
        if (parts.length > 1) return parts[1].trim();
      }
      // fallback: first numeric sequence
      final m = RegExp(r'\d+').firstMatch(target);
      return m != null ? m.group(0)! : target;
    }

    final initialRepsText = _extractRepPart(_exercise.targetReps);
    final repsController = TextEditingController(text: initialRepsText);
    int? numericReps = int.tryParse(initialRepsText);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF18181b),
              title: const Text(
                'Egzersizi Düzenle',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Set Sayısı:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (newSetCount > 1) newSetCount--;
                          });
                        },
                        icon: const Icon(Icons.remove, color: Colors.white),
                      ),
                      Text(
                        '$newSetCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            newSetCount++;
                          });
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tekrar Sayısı:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  // Row with - button, editable TextField, and + button.
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            // Initialize numericReps from typed value if null
                            if (numericReps == null) {
                              numericReps =
                                  int.tryParse(repsController.text.trim()) ?? 0;
                            }
                            if (numericReps! > 0)
                              numericReps = numericReps! - 1;
                            repsController.text = numericReps.toString();
                          });
                        },
                        icon: const Icon(Icons.remove, color: Colors.white),
                      ),
                      Expanded(
                        child: TextField(
                          controller: repsController,
                          readOnly: true,
                          showCursor: false,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'örn: 8-12, 10, 8/6/4',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[600]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[600]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF10b981),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (numericReps == null) {
                              numericReps =
                                  int.tryParse(repsController.text.trim()) ?? 0;
                            }
                            numericReps = numericReps! + 1;
                            repsController.text = numericReps.toString();
                          });
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    repsController.dispose();
                  },
                  child: const Text(
                    'İptal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final newReps = repsController.text.trim();
                    if (newReps.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tekrar sayısı boş olamaz'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // targetReps'i set sayısı + rep sayısı ile oluştur
                    final updatedTargetReps = '$newSetCount${'x'}$newReps';

                    // Parent state'i güncelle
                    this.setState(() {
                      _exercise = Exercise(
                        id: _exercise.id,
                        name: _exercise.name,
                        targetReps: updatedTargetReps,
                        lastLog: _exercise.lastLog,
                        history: _exercise.history,
                        assignedDays: _exercise.assignedDays,
                      );

                      // Controller'ları yenile
                      for (var controller in _setControllers) {
                        controller.dispose();
                      }
                      _setControllers.clear();
                      _initializeControllers();
                    });

                    Navigator.pop(context);
                    repsController.dispose();
                  },
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(color: Color(0xFF10b981)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<LogEntry>? _cachedSortedHistory;
  Exercise? _cachedExercise;

  List<LogEntry> _getSortedHistory() {
    // Cache kontrolü - sadece exercise değiştiyse yeniden sırala
    if (_cachedSortedHistory != null && _cachedExercise == _exercise) {
      return _cachedSortedHistory!;
    }

    final history = _exercise.history ?? [];
    final sorted = List<LogEntry>.from(history)..sort((a, b) {
      try {
        final dateA = _parseDate(a.date);
        final dateB = _parseDate(b.date);
        if (dateB.isAtSameMomentAs(dateA)) {
          return int.parse(b.id).compareTo(int.parse(a.id));
        }
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    _cachedSortedHistory = sorted;
    _cachedExercise = _exercise;
    return sorted;
  }

  // Ağırlık grafiği verilerini hazırla
  Map<String, dynamic> _getWeightChartData() {
    final sortedHistory = _getSortedHistory();
    if (sortedHistory.isEmpty) {
      return {
        'spots': <FlSpot>[],
        'maxWeight': 0.0,
        'minWeight': 0.0,
        'dates': <String>[],
        'progressIndicators': <String>[],
      };
    }

    // Son 15 antrenmanı al (eski sırada)
    final displayHistory =
        sortedHistory.length > 15
            ? sortedHistory.sublist(0, 15).reversed.toList()
            : sortedHistory.reversed.toList();

    final spots = <FlSpot>[];
    final dates = <String>[];
    final progressIndicators = <String>[];
    double? maxWeight;
    double? minWeight;

    for (int i = 0; i < displayHistory.length; i++) {
      final log = displayHistory[i];
      final weight = parseWeight(log.weight);

      spots.add(FlSpot(i.toDouble(), weight));
      dates.add(log.date);

      // İlerleme göstergesi hesapla
      String indicator = '';
      if (i > 0) {
        final prevLog = displayHistory[i - 1];
        final prevWeight = parseWeight(prevLog.weight);

        // Önceki antrenmanın toplam tekrarını hesapla
        double prevTotalReps = 0;
        for (var set in prevLog.sets) {
          prevTotalReps += double.tryParse(set) ?? 0.0;
        }

        // Mevcut antrenmanın toplam tekrarını hesapla
        double currentTotalReps = 0;
        for (var set in log.sets) {
          currentTotalReps += double.tryParse(set) ?? 0.0;
        }

        final weightDiff = weight - prevWeight;
        final repsDiff = currentTotalReps - prevTotalReps;

        // Ağırlık arttı ve tekrar azaldıysa göster
        if (weightDiff > 0 && repsDiff < 0) {
          indicator =
              '+${weightDiff.toStringAsFixed(1)}kg\n${repsDiff.toInt()} tekrar';
        }
      }
      progressIndicators.add(indicator);

      if (maxWeight == null || weight > maxWeight) maxWeight = weight;
      if (minWeight == null || weight < minWeight) minWeight = weight;
    }

    return {
      'spots': spots,
      'maxWeight': maxWeight ?? 0.0,
      'minWeight': minWeight ?? 0.0,
      'dates': dates,
      'progressIndicators': progressIndicators,
    };
  }

  // Tekrar grafiği verilerini hazırla
  Map<String, dynamic> _getRepsChartData() {
    final sortedHistory = _getSortedHistory();
    if (sortedHistory.isEmpty) {
      return {'groups': <BarChartGroupData>[], 'dates': <String>[]};
    }

    // Son 15 antrenmanı al (eski sırada)
    final displayHistory =
        sortedHistory.length > 15
            ? sortedHistory.sublist(0, 15).reversed.toList()
            : sortedHistory.reversed.toList();

    final groups = <BarChartGroupData>[];
    final dates = <String>[];

    for (int i = 0; i < displayHistory.length; i++) {
      final log = displayHistory[i];
      final sets = log.sets;

      // Her setin tekrar sayılarını toplam tekrarları hesapla
      double totalReps = 0;
      for (var set in sets) {
        final reps = double.tryParse(set) ?? 0.0;
        totalReps += reps;
      }

      // Bar rengini belirle - eğer ağırlık arttı ve tekrar azaldıysa sarı yap
      Color barColor = const Color(0xFF10b981); // Varsayılan yeşil
      if (i > 0) {
        final prevLog = displayHistory[i - 1];
        final prevWeight = parseWeight(prevLog.weight);
        final currentWeight = parseWeight(log.weight);

        // Önceki antrenmanın toplam tekrarını hesapla
        double prevTotalReps = 0;
        for (var set in prevLog.sets) {
          prevTotalReps += double.tryParse(set) ?? 0.0;
        }

        final weightDiff = currentWeight - prevWeight;
        final repsDiff = totalReps - prevTotalReps;

        // Ağırlık arttı ve tekrar azaldıysa sarı yap
        if (weightDiff > 0 && repsDiff < 0) {
          barColor = const Color(0xFFf59e0b); // Sarı/amber
        }
      }

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalReps,
              color: barColor,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      dates.add(log.date);
    }

    return {'groups': groups, 'dates': dates};
  }

  // Ağırlık trendi grafiği
  Widget _buildWeightChart() {
    final data = _getWeightChartData();
    final spots = data['spots'] as List<FlSpot>;
    final dates = data['dates'] as List<String>;

    if (spots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF27272a),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Color(0xFF10b981),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ağırlık Trendi (Güç Gelişimim)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: true),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < dates.length) {
                            final date = dates[index];
                            final parts = date.split('.');
                            return Text(
                              '${parts[0]}.${parts[1]}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()} kg',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF10b981),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final progressIndicators =
                              data['progressIndicators'] as List<String>;
                          final hasProgress =
                              index < progressIndicators.length &&
                              progressIndicators[index].isNotEmpty;

                          return FlDotCirclePainter(
                            radius: hasProgress ? 6 : 4,
                            color:
                                hasProgress
                                    ? const Color(0xFFf59e0b)
                                    : const Color(0xFF10b981),
                            strokeWidth: hasProgress ? 2 : 1,
                            strokeColor:
                                hasProgress
                                    ? const Color(0xFFf59e0b).withOpacity(0.5)
                                    : const Color(0xFF10b981).withOpacity(0.5),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF10b981).withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.spotIndex;
                          final progressIndicators =
                              data['progressIndicators'] as List<String>;
                          final weight = spot.y;
                          final date = index < dates.length ? dates[index] : '';

                          String tooltipText =
                              '${date}\n${weight.toStringAsFixed(1)} kg';

                          if (index < progressIndicators.length &&
                              progressIndicators[index].isNotEmpty) {
                            tooltipText += '\n${progressIndicators[index]}';
                          }

                          return LineTooltipItem(
                            tooltipText,
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'En Yüksek',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '${data['maxWeight'].toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        color: Color(0xFF10b981),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'En Düşük',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '${data['minWeight'].toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10b981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trending_up, color: Color(0xFF10b981), size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Harika! Ağırlık artışı = Güç artışı! 🎯',
                    style: TextStyle(
                      color: Color(0xFF10b981),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFf59e0b).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb, color: Color(0xFFf59e0b), size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Turuncu noktalar: Ağırlık ↑ & Tekrar ↓ = Gelişim! 🏆',
                    style: TextStyle(
                      color: Color(0xFFf59e0b),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tekrar trendi grafiği
  Widget _buildRepsChart() {
    final data = _getRepsChartData();
    final groups = data['groups'] as List<BarChartGroupData>;
    final dates = data['dates'] as List<String>;

    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFF27272a),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Color(0xFF10b981), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Tekrar Sayıları (Gelişim Göstergesi)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '💪 Ağırlık artışı ile tekrar düşüşü normaldir - bu gelişiminizdir!',
              style: TextStyle(
                color: Color(0xFF10b981),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      groups.isEmpty
                          ? 10
                          : (groups
                                  .map(
                                    (g) =>
                                        g.barRods.isNotEmpty
                                            ? g.barRods[0].toY
                                            : 0,
                                  )
                                  .reduce((a, b) => a > b ? a : b) *
                              1.2),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < dates.length) {
                            final date = dates[index];
                            final parts = date.split('.');
                            return Text(
                              '${parts[0]}.${parts[1]}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  barGroups: groups,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10b981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF10b981).withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, color: Color(0xFF10b981), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '💪 Ağırlık arttıkça tekrar sayısının düşmesi normal ve istenilen bir durumdur. Bu, kaslarınızın güçlendiğinin ve gelişiminizin devam ettiğinin göstergesidir!',
                      style: TextStyle(
                        color: Color(0xFF10b981),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFf59e0b).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFf59e0b).withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.trending_up, color: Color(0xFFf59e0b), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🟡 Sarı çubuklar: Ağırlık arttığı için tekrar sayısı azalmış = Güç gelişimi! 💪',
                      style: TextStyle(
                        color: Color(0xFFf59e0b),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('ExerciseDetailScreen build çağrıldı'); // Debug
    final setCount = getSetCountFromTarget(_exercise.targetReps);
    final sortedHistory = _getSortedHistory();

    return Scaffold(
      appBar: AppBar(
        title: Text(_exercise.name),
        backgroundColor: const Color(0xFF18181b),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditExerciseDialog();
            },
            tooltip: 'Set ve Tekrar Sayısını Düzenle',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _exercise);
            },
            tooltip: 'Değişiklikleri Kaydet ve Geri Dön',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Egzersiz bilgileri
            Card(
              color: const Color(0xFF27272a),
              elevation: 2,
              shadowColor: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: _exercise.name,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (_exercise.targetReps.isNotEmpty)
                                        TextSpan(
                                          text: ' (${_exercise.targetReps})',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFF10b981),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (!_expanded && _exercise.lastLog != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Son: ${_exercise.lastLog}',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            _expanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),

                      if (_expanded) ...[
                        const SizedBox(height: 16),
                        // Hedef zaten başlıkta gösterildiğinden burada gösterilmeyecek
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // --- GRAFİKLER ---
            if (sortedHistory.isNotEmpty) ...[
              _buildWeightChart(),
              _buildRepsChart(),
            ],

            // Geçmiş antrenmanlar
            if (sortedHistory.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFF27272a),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _historyExpanded = !_historyExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.history,
                                  color: Color(0xFF10b981),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Geçmiş Antrenmanlar (${sortedHistory.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              _historyExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_historyExpanded)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: sortedHistory.length,
                          itemExtent: null, // Dinamik yükseklik
                          cacheExtent: 300, // Cache boyutu
                          itemBuilder: (context, index) {
                            final log = sortedHistory[index];
                            final previousLog =
                                index < sortedHistory.length - 1
                                    ? sortedHistory[index + 1]
                                    : null;
                            final logMap = {
                              'id': log.id,
                              'date': log.date,
                              'weight': log.weight,
                              'sets': log.sets,
                              'day': log.day,
                            };
                            final prevLogMap =
                                previousLog != null
                                    ? {
                                      'id': previousLog.id,
                                      'date': previousLog.date,
                                      'weight': previousLog.weight,
                                      'sets': previousLog.sets,
                                      'day': previousLog.day,
                                    }
                                    : null;
                            final progress = calculateProgress(
                              logMap,
                              prevLogMap,
                            );

                            return _buildLogCard(logMap, progress);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // Log ekleme formu
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFF27272a),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form başlığı - tıklanabilir
                  InkWell(
                    onTap: () {
                      setState(() {
                        _logFormExpanded = !_logFormExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.add_circle,
                                color: Color(0xFF10b981),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Yeni Antrenman Kaydı',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            _logFormExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Form alanları - açılıp kapanabilir
                  if (_logFormExpanded)
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181b),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF27272a),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _weightController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Ağırlık (kg)',
                              labelStyle: const TextStyle(
                                color: Color(0xFFa3a3a3),
                              ),
                              filled: true,
                              fillColor: Colors.grey[800],
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[600]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF10b981),
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(setCount, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TextField(
                                controller: _setControllers[index],
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Set ${index + 1}',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFFa3a3a3),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[800],
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[600]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF10b981),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                print('Kaydet butonu tıklandı'); // Debug
                                _saveLog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10b981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 4,
                                shadowColor: const Color(
                                  0xFF10b981,
                                ).withOpacity(0.5),
                              ),
                              child: const Text(
                                'Kaydet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(
    Map<String, dynamic> log,
    Map<String, dynamic>? progress,
  ) {
    final sets = log['sets'] as List;
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF18181b),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF27272a), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log['date'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (getWeekNumber(log['date'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        getWeekNumber(log['date'] ?? ''),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: const Color(0xFF27272a),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editLog(log);
                  } else if (value == 'delete') {
                    _deleteLog(log);
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Düzenle',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Setler: ${sets.join(' / ')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${normalizeWeight(log['weight'].toString())}kg',
                style: const TextStyle(
                  color: Color(0xFF10b981),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (progress['weightDiff'] != null &&
                    progress['weightDiff'] != 0)
                  Text(
                    'Ağırlık: ${progress['weightImproved'] ? '+' : ''}${progress['weightDiff'].toStringAsFixed(1)}kg',
                    style: TextStyle(
                      color:
                          progress['weightImproved']
                              ? Colors.green
                              : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                if (progress['setDiffs'] != null &&
                    progress['setDiffs'].isNotEmpty)
                  Text(
                    'Tekrar: ${(progress['setDiffs'] as List).map((d) => '${d > 0 ? '+' : ''}$d').join(' / ')}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  DateTime _parseDate(String dateString) {
    try {
      final parts = dateString.split('.');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      // ignore
    }
    return DateTime.now();
  }

  void _editLog(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) {
        final weightController = TextEditingController(text: log['weight']);
        final setControllers = <TextEditingController>[];
        final sets = log['sets'] as List;
        final isDialogDarkMode =
            Theme.of(context).brightness == Brightness.dark;

        for (var set in sets) {
          setControllers.add(TextEditingController(text: set.toString()));
        }

        return AlertDialog(
          backgroundColor:
              isDialogDarkMode ? const Color(0xFF18181b) : Colors.white,
          title: Text(
            'Antrenmanı Düzenle',
            style: TextStyle(
              color: isDialogDarkMode ? Colors.white : const Color(0xFF111827),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  style: TextStyle(
                    color:
                        isDialogDarkMode
                            ? Colors.white
                            : const Color(0xFF111827),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Ağırlık (kg)',
                    labelStyle: TextStyle(
                      color:
                          isDialogDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            isDialogDarkMode
                                ? Colors.grey[700]!
                                : const Color(0xFFD1D5DB),
                      ),
                    ),
                    filled: true,
                    fillColor:
                        isDialogDarkMode
                            ? const Color(0xFF27272a)
                            : Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ...List.generate(setControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: setControllers[index],
                      style: TextStyle(
                        color:
                            isDialogDarkMode
                                ? Colors.white
                                : const Color(0xFF111827),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Set ${index + 1}',
                        labelStyle: TextStyle(
                          color:
                              isDialogDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                isDialogDarkMode
                                    ? Colors.grey[700]!
                                    : const Color(0xFFD1D5DB),
                          ),
                        ),
                        filled: true,
                        fillColor:
                            isDialogDarkMode
                                ? const Color(0xFF27272a)
                                : Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10b981),
              ),
              onPressed: () {
                final newWeight = normalizeWeight(weightController.text.trim());
                final newSets =
                    setControllers
                        .map((c) => c.text.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();

                if (newWeight.isEmpty || newSets.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen tüm alanları doldurun'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Log'u güncelle
                final updatedHistory =
                    _exercise.history?.map((h) {
                      if (h.id == log['id']) {
                        return LogEntry(
                          id: h.id,
                          date: h.date,
                          weight: newWeight,
                          sets: newSets,
                          day: h.day,
                        );
                      }
                      return h;
                    }).toList();

                setState(() {
                  _exercise = Exercise(
                    id: _exercise.id,
                    name: _exercise.name,
                    targetReps: _exercise.targetReps,
                    lastLog: _exercise.lastLog,
                    history: updatedHistory,
                    assignedDays: _exercise.assignedDays,
                  );
                  _cachedSortedHistory = null;
                  _cachedExercise = null;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Antrenman güncellendi'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Kaydet',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteLog(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF18181b),
            title: const Text(
              'Antrenmanı Sil?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Bu antrenman kaydı silinecek. İşlem geri alınamaz.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'İptal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    _exercise = Exercise(
                      id: _exercise.id,
                      name: _exercise.name,
                      targetReps: _exercise.targetReps,
                      lastLog: _exercise.lastLog,
                      history:
                          _exercise.history
                              ?.where((h) => h.id != log['id'])
                              .toList(),
                      assignedDays: _exercise.assignedDays,
                    );
                    _cachedSortedHistory = null;
                    _cachedExercise = null;
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Antrenman silindi'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Sil', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}
