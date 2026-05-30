import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/exercise.dart';
import '../services/storage_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StorageService _storageService = StorageService();
  Map<String, List<Exercise>> _workouts = {};
  int _selectedRange = 7; // Gün cinsinden (7=hafta, 30=ay, 365=yıl)

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final workouts = await _storageService.loadWorkouts();
    setState(() {
      _workouts = workouts;
    });
  }

  // Belirli gün aralığında yapılan antrenmanları say
  Map<DateTime, int> _getWorkoutCountByDate() {
    final Map<DateTime, int> workoutCount = {};
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _selectedRange));

    // Tüm antrenmanları gezip tarihlere göre say
    _workouts.forEach((day, exercises) {
      for (var exercise in exercises) {
        if (exercise.history != null) {
          for (var log in exercise.history!) {
            try {
              final logDate = DateFormat('dd.MM.yyyy').parse(log.date);
              // Eğer tarih range içindeyse say
              if (logDate.isAfter(startDate) &&
                  logDate.isBefore(now.add(const Duration(days: 1)))) {
                final dateOnly = DateTime(
                  logDate.year,
                  logDate.month,
                  logDate.day,
                );
                workoutCount[dateOnly] = (workoutCount[dateOnly] ?? 0) + 1;
              }
            } catch (e) {
              // Tarih parse hatası, atla
            }
          }
        }
      }
    });

    return workoutCount;
  }

  // Bu haftanın antrenman günlerini al
  List<int> _getThisWeekWorkoutDays() {
    final workoutDays = List<int>.filled(7, 0);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    _workouts.forEach((day, exercises) {
      for (var exercise in exercises) {
        if (exercise.history != null) {
          for (var log in exercise.history!) {
            try {
              final logDate = DateFormat('dd.MM.yyyy').parse(log.date);
              final difference = logDate.difference(weekStart).inDays;
              if (difference >= 0 && difference < 7) {
                workoutDays[difference] += 1;
              }
            } catch (e) {
              // Ignore
            }
          }
        }
      }
    });

    return workoutDays;
  }

  // İstatistik kartı oluştur
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF18181b),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutByDate = _getWorkoutCountByDate();
    final thisWeekDays = _getThisWeekWorkoutDays();
    final lastWeekDays = _getLastWeekWorkoutDays();
    final streak = _calculateActivityStreak();

    // Toplam antrenman sayısı
    int totalWorkouts = 0;
    _workouts.forEach((day, exercises) {
      for (var exercise in exercises) {
        totalWorkouts += exercise.history?.length ?? 0;
      }
    });

    // Bu haftanın toplam antrenmanı
    int thisWeekTotal = thisWeekDays.fold(0, (sum, count) => sum + count);

    // En aktif antrenman
    int maxCount = 0;
    final exerciseCounts = <String, int>{};

    _workouts.forEach((day, exercises) {
      for (var exercise in exercises) {
        final count = exercise.history?.length ?? 0;
        exerciseCounts[exercise.name] =
            (exerciseCounts[exercise.name] ?? 0) + count;
        if (count > maxCount) {
          maxCount = count;
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF09090b),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18181b),
        title: const Text('İstatistikler & İlerleme'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İstatistik Kartları
            Row(
              children: [
                _buildStatCard(
                  'Toplam Antrenman',
                  totalWorkouts.toString(),
                  const Color(0xFF10b981),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Bu Hafta',
                  thisWeekTotal.toString(),
                  const Color(0xFF3b82f6),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  'Aktivite Streçi',
                  '$streak gün',
                  const Color(0xFFf59e0b),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Çeşitli Hareket',
                  exerciseCounts.length.toString(),
                  const Color(0xFF8b5cf6),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Aralık Seçici
            Text(
              'Zaman Aralığı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRangeButton('1 Hafta', 7),
                  _buildRangeButton('1 Ay', 30),
                  _buildRangeButton('3 Ay', 90),
                  _buildRangeButton('1 Yıl', 365),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Bu Hafta Bar Grafiği
            Text(
              'Bu Hafta Antrenmanları',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF18181b),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildWeeklyBarChart(thisWeekDays),
            ),
            const SizedBox(height: 32),

            // Haftalık Karşılaştırma Grafiği
            Text(
              'Haftalık Karşılaştırma',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF18181b),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildWeeklyComparisonChart(thisWeekDays, lastWeekDays),
            ),
            const SizedBox(height: 32),

            // Son 30 Günlük Line Chart
            Text(
              'Son ${_selectedRange} Günlük İlerleme',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF18181b),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildLineChart(workoutByDate),
            ),
            const SizedBox(height: 32),

            // Hedefler Bölümü
            Text(
              'Hedefler',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              'Haftada 4 Gün Antrenman',
              thisWeekTotal,
              4,
              const Color(0xFF10b981),
            ),
            const SizedBox(height: 12),
            _buildGoalCard(
              'Aylık 20 Antrenman',
              _getMonthlyWorkoutCount(),
              20,
              const Color(0xFF3b82f6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyComparisonChart(
    List<int> thisWeekDays,
    List<int> lastWeekDays,
  ) {
    final days = ['Pzt', 'Salı', 'Çar', 'Per', 'Cuma', 'Cmt', 'Paz'];
    final maxValue =
        [
          ...thisWeekDays,
          ...lastWeekDays,
        ].reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          maxY: maxValue > 0 ? maxValue + 2 : 5,
          barGroups: List.generate(
            7,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: thisWeekDays[index].toDouble(),
                  color: const Color(0xFF10b981),
                  width: 14,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
                BarChartRodData(
                  toY: lastWeekDays[index].toDouble(),
                  color: const Color(0xFF3b82f6).withOpacity(0.5),
                  width: 14,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[800]!.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildRangeButton(String label, int days) {
    final isSelected = _selectedRange == days;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRange = days;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF10b981) : const Color(0xFF27272a),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF10b981) : Colors.grey[700]!,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart(List<int> weekDays) {
    final days = ['Pzt', 'Salı', 'Çar', 'Per', 'Cuma', 'Cmt', 'Paz'];
    final maxValue =
        weekDays.isEmpty
            ? 1.0
            : weekDays.reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: maxValue > 0 ? maxValue + 2 : 5,
          barGroups: List.generate(
            7,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: weekDays[index].toDouble(),
                  color: const Color(0xFF10b981),
                  width: 28,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[800]!.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildLineChart(Map<DateTime, int> workoutByDate) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _selectedRange));

    // Tüm günler için veri hazırla (eksik günler 0 değeri alır)
    final Map<DateTime, int> completeData = {};
    for (int i = 0; i <= _selectedRange; i++) {
      final date = startDate.add(Duration(days: i));
      completeData[date] =
          workoutByDate[DateTime(date.year, date.month, date.day)] ?? 0;
    }

    final maxValue =
        completeData.values.isEmpty
            ? 1.0
            : completeData.values.reduce((a, b) => a > b ? a : b).toDouble();

    final spots =
        completeData.entries.toList().asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
        }).toList();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          maxY: maxValue > 0 ? maxValue + 1 : 5,
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF3b82f6),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color:
                        spot.y > 0
                            ? const Color(0xFF10b981)
                            : Colors.grey[700]!,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF3b82f6).withOpacity(0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (_selectedRange / 4).ceil().toDouble(),
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < completeData.length) {
                    final date = completeData.keys.toList()[value.toInt()];
                    return Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[800]!.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // Aktivite Streç hesapla (ard arda antrenman günü)
  int _calculateActivityStreak() {
    final now = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final dateKey = DateTime(checkDate.year, checkDate.month, checkDate.day);

      bool hasWorkout = false;
      _workouts.forEach((day, exercises) {
        for (var exercise in exercises) {
          if (exercise.history != null) {
            for (var log in exercise.history!) {
              try {
                final logDate = DateFormat('dd.MM.yyyy').parse(log.date);
                if (DateTime(
                  logDate.year,
                  logDate.month,
                  logDate.day,
                ).isAtSameMomentAs(dateKey)) {
                  hasWorkout = true;
                }
              } catch (e) {
                // Ignore
              }
            }
          }
        }
      });

      if (hasWorkout) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // Bu hafta vs geçen hafta karşılaştırması
  List<int> _getLastWeekWorkoutDays() {
    final workoutDays = List<int>.filled(7, 0);
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    _workouts.forEach((day, exercises) {
      for (var exercise in exercises) {
        if (exercise.history != null) {
          for (var log in exercise.history!) {
            try {
              final logDate = DateFormat('dd.MM.yyyy').parse(log.date);
              final difference = logDate.difference(lastWeekStart).inDays;
              if (difference >= 0 && difference < 7) {
                workoutDays[difference] += 1;
              }
            } catch (e) {
              // Ignore
            }
          }
        }
      }
    });

    return workoutDays;
  }

  Widget _buildGoalCard(String goalName, int current, int target, Color color) {
    final progress = (current / target).clamp(0.0, 1.0);
    final percentage = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18181b),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goalName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$current/$target',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '%$percentage Tamamlandı',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  int _getMonthlyWorkoutCount() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    int count = 0;
    _workouts.forEach((day, exercises) {
      for (var exercise in exercises) {
        if (exercise.history != null) {
          for (var log in exercise.history!) {
            try {
              final logDate = DateFormat('dd.MM.yyyy').parse(log.date);
              if (logDate.isAfter(
                    monthStart.subtract(const Duration(days: 1)),
                  ) &&
                  logDate.isBefore(now.add(const Duration(days: 1)))) {
                count++;
              }
            } catch (e) {
              // Ignore
            }
          }
        }
      }
    });

    return count;
  }
}
