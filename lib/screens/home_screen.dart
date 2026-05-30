import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/user.dart';
import '../models/training_program.dart';
import '../services/storage_service.dart';
import '../data/popular_exercises.dart';
import 'exercise_detail_screen.dart';
import 'add_exercise_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final List<String> _days = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  String _selectedDay = 'Pazartesi';
  Map<String, List<Exercise>> _workouts = {};
  List<String> _customExercises = [];
  bool _isLoading = true;

  User? _currentUser;
  TrainingProgram? _activeTrainerProgram;
  bool _showingTrainerProgram = false;

  @override
  void initState() {
    super.initState();
    _setTodayDay();
    _loadData();
  }

  void _setTodayDay() {
    final today = DateTime.now();
    final dayOfWeek = today.weekday; // 1=Pazartesi, 7=Pazar

    const weekDays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    if (dayOfWeek >= 1 && dayOfWeek <= 7) {
      _selectedDay = weekDays[dayOfWeek - 1];
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Mevcut kullanıcıyı getir
    final currentUser = await _storageService.getCurrentUser();

    // Antrenör tarafından yazılan programları kontrol et
    TrainingProgram? activeProgram;
    if (currentUser != null) {
      final programs = await _storageService.getUserTrainingPrograms(
        currentUser.id,
      );
      if (programs.isNotEmpty) {
        activeProgram = programs.first; // İlk aktif programı seç
      }
    }

    // Local storage'dan veri yükle
    final workouts = await _storageService.loadWorkouts();
    final customExercises = await _storageService.loadCustomExercises();

    setState(() {
      _currentUser = currentUser;
      _activeTrainerProgram = activeProgram;

      // Antrenör programı varsa onu göster, yoksa kendi workout'ları göster
      if (activeProgram != null) {
        _workouts = activeProgram.exercises;
        _showingTrainerProgram = true;
      } else {
        _workouts = workouts;
        _showingTrainerProgram = false;
      }

      _customExercises = customExercises;
      _isLoading = false;
    });
  }

  // Async kaydetme - UI'ı bloklamaz
  void _saveWorkouts() {
    _storageService.saveWorkouts(_workouts).catchError((error) {
      print('Error saving workouts: $error');
      return false;
    });
  }

  void _exportData() {
    // Tüm verileri JSON formatında hazırla
    final Map<String, dynamic> allData = {
      'exportDate': DateTime.now().toString(),
      'workouts': {},
      'customExercises': _customExercises,
    };

    // Tüm antrenmanları dönüştür
    _workouts.forEach((day, exercises) {
      allData['workouts'][day] =
          exercises.map((e) {
            return {
              'id': e.id,
              'name': e.name,
              'targetReps': e.targetReps,
              'lastLog': e.lastLog,
              'assignedDays': e.assignedDays,
              'history': e.history?.map((log) => log.toJson()).toList() ?? [],
            };
          }).toList();
    });

    // JSON stringine dönüştür
    final jsonString = _formatJson(allData);

    // İçeriği göster
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF18181b),
          title: const Text(
            'Verileri Dışa Aktar',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: SelectableText(
              jsonString,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Kapat', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _copyToClipboard(jsonString);
                Navigator.pop(context);
              },
              child: const Text(
                'Kopyala',
                style: TextStyle(color: Color(0xFF10b981)),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatJson(Map<String, dynamic> data) {
    // Güzel formatlı JSON oluştur
    StringBuffer buffer = StringBuffer();
    _formatJsonHelper(data, buffer, 0);
    return buffer.toString();
  }

  void _formatJsonHelper(dynamic data, StringBuffer buffer, int indent) {
    final indentStr = '  ' * indent;
    final nextIndentStr = '  ' * (indent + 1);

    if (data is Map) {
      buffer.write('{\n');
      final entries = data.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        final e = entries[i];
        buffer.write('$nextIndentStr"${e.key}": ');
        _formatJsonHelper(e.value, buffer, indent + 1);
        if (i < entries.length - 1) buffer.write(',');
        buffer.write('\n');
      }
      buffer.write('$indentStr}');
    } else if (data is List) {
      if (data.isEmpty) {
        buffer.write('[]');
      } else {
        buffer.write('[\n');
        for (int i = 0; i < data.length; i++) {
          buffer.write(nextIndentStr);
          _formatJsonHelper(data[i], buffer, indent + 1);
          if (i < data.length - 1) buffer.write(',');
          buffer.write('\n');
        }
        buffer.write('$indentStr]');
      }
    } else if (data is String) {
      buffer.write('"${data.replaceAll('"', '\\"')}"');
    } else if (data is num || data is bool) {
      buffer.write(data.toString());
    } else if (data == null) {
      buffer.write('null');
    }
  }

  void _copyToClipboard(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verileri klipborduna kopyalandı!'),
        backgroundColor: Color(0xFF10b981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _addExercise(Exercise exercise) async {
    if (_workouts[_selectedDay] == null) {
      _workouts[_selectedDay] = [];
    }

    // Aynı isimde hareket başka günde var mı diye kontrol et
    Exercise? existingExercise;
    String? existingExerciseId;

    _workouts.forEach((day, exercises) {
      if (day != _selectedDay) {
        // Diğer günleri kontrol et
        final found = exercises.firstWhere(
          (ex) => ex.name.toLowerCase() == exercise.name.toLowerCase(),
          orElse: () => Exercise(id: '', name: '', targetReps: ''),
        );
        if (found.id.isNotEmpty) {
          existingExercise = found;
          existingExerciseId = found.id;
        }
      }
    });

    // Eğer aynı hareketi başka günde görüp bul varsa, aynı ID'yi kullan
    final exerciseToAdd =
        existingExercise != null
            ? Exercise(
              id: existingExerciseId!,
              name: exercise.name,
              targetReps: exercise.targetReps,
              lastLog: existingExercise!.lastLog,
              history: existingExercise!.history,
              assignedDays: [
                ...(existingExercise!.assignedDays ?? []),
                _selectedDay,
              ],
            )
            : exercise;

    _workouts[_selectedDay]!.add(exerciseToAdd);

    setState(() {}); // Sadece UI'ı güncelle

    // Eğer aynı hareketi başka günlerde de güncelle
    if (existingExercise != null) {
      await _storageService.updateExerciseAcrossAllDays(
        _workouts,
        existingExerciseId!,
        exerciseToAdd,
      );
    }

    // Kaydetmeyi arka planda yap
    _saveWorkouts();
  }

  Future<void> _deleteExercise(String exerciseId) async {
    _workouts[_selectedDay]?.removeWhere((ex) => ex.id == exerciseId);

    setState(() {}); // Sadece UI'ı güncelle

    // Tüm günlerden sil
    await _storageService.deleteExerciseAcrossAllDays(_workouts, exerciseId);
    _saveWorkouts();
  }

  Future<void> _updateExercise(Exercise updatedExercise) async {
    final index = _workouts[_selectedDay]?.indexWhere(
      (ex) => ex.id == updatedExercise.id,
    );
    if (index != null && index >= 0) {
      // Tüm günleri al - bu harekete atanmış tüm günler
      final allDays = <String>{};
      _workouts.forEach((day, exercises) {
        if (exercises.any((ex) => ex.id == updatedExercise.id)) {
          allDays.add(day);
        }
      });

      final exerciseWithDays = Exercise(
        id: updatedExercise.id,
        name: updatedExercise.name,
        targetReps: updatedExercise.targetReps,
        lastLog: updatedExercise.lastLog,
        history: updatedExercise.history,
        assignedDays: allDays.toList(),
      );

      _workouts[_selectedDay]![index] = exerciseWithDays;

      // Aynı exercise'i TÜÜN diğer günlerde de güncelle
      await _storageService.updateExerciseAcrossAllDays(
        _workouts,
        updatedExercise.id,
        exerciseWithDays,
      );

      // Verileri storage'a kaydet
      await _storageService.saveWorkouts(_workouts);

      // UI'ı güncelle - tüm günleri yenile
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayExercises = _workouts[_selectedDay] ?? [];
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              color: const Color(0xFF10b981),
              size: isMobile ? 20 : 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Antrenman Takip',
              style: TextStyle(fontSize: isMobile ? 18 : 20),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF18181b),
        actions: [
          if (_currentUser != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _currentUser!.username,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
            tooltip: 'İstatistikler',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
            tooltip: 'Verileri İndir',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Verileri yenile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _storageService.logoutUser();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Antrenör programı gösteriliyor uyarısı
                  if (_showingTrainerProgram)
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[900]?.withOpacity(0.3),
                        border: Border.all(color: Colors.orange[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange[400]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Antrenör Programı Görüntüleniyor',
                                  style: TextStyle(
                                    color: Colors.orange[400],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_activeTrainerProgram != null)
                                  Text(
                                    '${_activeTrainerProgram!.programName}',
                                    style: TextStyle(
                                      color: Colors.orange[300],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Gün seçici
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: _days.length,
                      itemBuilder: (context, index) {
                        final day = _days[index];
                        final isSelected = day == _selectedDay;
                        final exerciseCount = _workouts[day]?.length ?? 0;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDay = day;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFF10b981)
                                      : const Color(0xFF27272a),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? const Color(0xFF10b981)
                                        : Colors.transparent,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day.substring(0, 3),
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.grey[400],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$exerciseCount egz',
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white70
                                            : Colors.grey[400],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Seçili günün egzersizleri
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181b),
                        borderRadius: BorderRadius.circular(12),
                        border: null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_selectedDay Antrenmanı',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF10b981),
                                ),
                              ),
                              if (!_showingTrainerProgram)
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AddExerciseScreen(
                                              allExercises: [
                                                ...popularExercises,
                                                ..._customExercises,
                                              ],
                                              customExercises: _customExercises,
                                              existingExercises: _workouts,
                                              selectedDay: _selectedDay,
                                            ),
                                      ),
                                    );

                                    if (result != null && result is Exercise) {
                                      await _addExercise(result);

                                      // Custom exercise eklenmişse listeyi güncelle
                                      if (!popularExercises.contains(
                                            result.name,
                                          ) &&
                                          !_customExercises.contains(
                                            result.name,
                                          )) {
                                        setState(() {
                                          _customExercises.add(result.name);
                                        });
                                        await _storageService
                                            .saveCustomExercises(
                                              _customExercises,
                                            );
                                      }
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Egzersiz Ekle',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF10b981,
                                    ), // emerald-500
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor: const Color(
                                      0xFF10b981,
                                    ).withOpacity(0.5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Egzersiz listesi
                          Expanded(
                            child:
                                selectedDayExercises.isEmpty
                                    ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.fitness_center,
                                            size: 64,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Bu güne henüz egzersiz eklenmemiş',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : ReorderableListView(
                                      buildDefaultDragHandles: false,
                                      onReorder: (oldIndex, newIndex) {
                                        setState(() {
                                          final item = selectedDayExercises
                                              .removeAt(oldIndex);
                                          selectedDayExercises.insert(
                                            newIndex,
                                            item,
                                          );
                                          _workouts[_selectedDay] =
                                              selectedDayExercises;
                                        });
                                        _saveWorkouts();
                                      },
                                      children: List.generate(
                                        selectedDayExercises.length,
                                        (index) {
                                          final exercise =
                                              selectedDayExercises[index];
                                          return _ExerciseListItem(
                                            key: ValueKey(exercise.id),
                                            index: index,
                                            exercise: exercise,
                                            isMobile: isMobile,
                                            onTap: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          ExerciseDetailScreen(
                                                            exercise: exercise,
                                                            day: _selectedDay,
                                                          ),
                                                ),
                                              );

                                              if (result != null &&
                                                  result is Exercise) {
                                                await _updateExercise(result);
                                              }
                                            },
                                            onDelete:
                                                () => _deleteExercise(
                                                  exercise.id,
                                                ),
                                          );
                                        },
                                      ),
                                    ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                'Mert Gezici tarafından yapıldı',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

// Ayrı widget - rebuild optimizasyonu için
class _ExerciseListItem extends StatelessWidget {
  final int index;
  final Exercise exercise;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isMobile;

  const _ExerciseListItem({
    super.key,
    required this.index,
    required this.exercise,
    required this.onTap,
    required this.onDelete,
    this.isMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;
    const subtitleColor = Colors.grey;

    return Card(
      color: const Color(0xFF27272a),
      margin: EdgeInsets.only(bottom: isMobile ? 6 : 8),
      elevation: 2,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 16,
            vertical: isMobile ? 12 : 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // (Removed left drag handle — will show on the right only)
              // Harekete ve son verisi - ortada
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İsim + Hedef
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: exercise.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: isMobile ? 15 : 17,
                            ),
                          ),
                          if (exercise.targetReps.isNotEmpty)
                            TextSpan(
                              text: ' (${exercise.targetReps})',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: const Color(0xFF10b981),
                                fontSize: isMobile ? 13 : 15,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Son antrenman verisi
                    if (exercise.lastLog != null) ...[
                      SizedBox(height: isMobile ? 6 : 8),
                      Text(
                        'Son: ${exercise.lastLog}',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: isMobile ? 12 : 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Sağ taraf: delete (X) ve drag handle (taşıma) — sadece sağda göster
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Tooltip(
                        message: 'Sil',
                        child: IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.red[400],
                            size: isMobile ? 22 : 24,
                          ),
                          onPressed: onDelete,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red[900]?.withOpacity(0.2),
                            padding: EdgeInsets.zero,
                          ),
                          constraints: const BoxConstraints.expand(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: ReorderableDragStartListener(
                          index: index,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            child: Icon(
                              Icons.drag_handle,
                              color: Colors.grey[600],
                              size: isMobile ? 22 : 26,
                            ),
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
      ),
    );
  }
}
