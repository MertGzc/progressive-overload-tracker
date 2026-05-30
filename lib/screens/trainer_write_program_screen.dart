import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/training_program.dart';
import '../models/exercise.dart';
import '../services/storage_service.dart';
import '../data/popular_exercises.dart';

class TrainerWriteProgramScreen extends StatefulWidget {
  final User user;
  final User trainer;
  final TrainingProgram? program;
  final VoidCallback onProgramSaved;

  const TrainerWriteProgramScreen({
    super.key,
    required this.user,
    required this.trainer,
    this.program,
    required this.onProgramSaved,
  });

  @override
  State<TrainerWriteProgramScreen> createState() =>
      _TrainerWriteProgramScreenState();
}

class _TrainerWriteProgramScreenState extends State<TrainerWriteProgramScreen> {
  final StorageService _storageService = StorageService();

  late TextEditingController _programNameController;

  final List<String> _days = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  final Map<String, List<Exercise>> _programExercises = {};
  String _selectedDay = 'Pazartesi';
  bool _isSaving = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _programNameController = TextEditingController(
      text: widget.program?.programName ?? '',
    );
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    // Tüm günleri boş liste ile başlat
    for (var day in _days) {
      _programExercises[day] = [];
    }

    if (widget.program != null) {
      _programExercises.addAll(
        widget.program!.exercises.map((day, exercises) {
          return MapEntry(day, exercises.map((exercise) => exercise).toList());
        }),
      );
      _selectedDay = widget.program!.exercises.keys.firstWhere(
        (day) => widget.program!.exercises[day]?.isNotEmpty ?? false,
        orElse: () => _days[0],
      );
    } else {
      _selectedDay = _days[0];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _programNameController.dispose();
    super.dispose();
  }

  void _addExerciseToDay(String dayName, Exercise exercise) {
    setState(() {
      final existingIndex =
          _programExercises[dayName]?.indexWhere((e) => e.id == exercise.id) ??
          -1;

      if (existingIndex == -1) {
        _programExercises[dayName]?.add(exercise);
      } else {
        // Aynı exercise varsa güncelle
        _programExercises[dayName]?[existingIndex] = exercise;
      }
    });
  }

  void _removeExerciseFromDay(String dayName, String exerciseId) {
    setState(() {
      _programExercises[dayName]?.removeWhere((e) => e.id == exerciseId);
    });
  }

  Future<void> _showAddExerciseDialog(String exerciseName) async {
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$exerciseName ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: setsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Set Sayısı',
                  hintText: '3',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tekrar Sayısı',
                  hintText: '10',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final sets = setsController.text.trim();
    final reps = repsController.text.trim();

    if (sets.isEmpty || reps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set ve tekrar değerlerini girin')),
      );
      return;
    }

    final exercise = Exercise(
      id: exerciseName,
      name: exerciseName,
      targetReps: '$sets x $reps',
      lastLog: null,
      history: [],
    );

    _addExerciseToDay(_selectedDay, exercise);
  }

  Future<void> _saveProgram() async {
    if (_programNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Program adı boş olamaz')));
      return;
    }

    // En az bir egzersiz olması gerekli
    final totalExercises = _programExercises.values.fold<int>(
      0,
      (sum, exercises) => sum + exercises.length,
    );

    if (totalExercises == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir egzersiz ekleyin')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final program = TrainingProgram(
      id:
          widget.program?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      trainerId: widget.trainer.id,
      userId: widget.user.id,
      programName: _programNameController.text.trim(),
      exercises: _programExercises,
      createdAt: widget.program?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    final success = await _storageService.saveTrainingProgram(program);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program başarıyla kaydedildi')),
      );
      widget.onProgramSaved();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program kaydedilirken hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.program == null
              ? 'Program Yaz - ${widget.user.username}'
              : 'Program Düzenle - ${widget.user.username}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program Adı
            TextField(
              controller: _programNameController,
              decoration: InputDecoration(
                labelText: 'Program Adı',
                hintText: 'Örn: Başlangıç Programı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Gün Seçici
            Text(
              'Egzersiz Ekle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final day = _days[index];
                  final isSelected = day == _selectedDay;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(day.substring(0, 3)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedDay = day);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Seçili gün için egzersiz ekle
            _buildExerciseSelector(),
            const SizedBox(height: 24),

            // Program özeti
            Text(
              'Program Özeti',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            ..._days.map((day) {
              final exercises = _programExercises[day] ?? [];
              if (exercises.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10b981),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...exercises.map((exercise) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[600]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${exercise.targetReps} tekrar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _removeExerciseFromDay(day, exercise.id);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              );
            }),

            if (_programExercises.values.fold<int>(
                  0,
                  (sum, exercises) => sum + exercises.length,
                ) ==
                0)
              Center(
                child: Text(
                  'Henüz egzersiz eklenmedi',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            const SizedBox(height: 24),

            // Kaydet butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProgram,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b981),
                ),
                child:
                    _isSaving
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Programı Kaydet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSelector() {
    final matchingExercises =
        popularExercises
            .where(
              (name) => name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[600]!),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_selectedDay için egzersiz seçin',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Egzersiz Ara',
              hintText: 'Örn: Squat',
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_searchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Egzersizleri görebilmek için arama kutusuna yazmaya başlayın.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else if (matchingExercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Eşleşen egzersiz bulunamadı. Başka bir kelime ile deneyin.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            Column(
              children:
                  matchingExercises.map((exerciseName) {
                    final isAdded =
                        _programExercises[_selectedDay]?.any(
                          (e) => e.id == exerciseName,
                        ) ??
                        false;

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: ListTile(
                        title: Text(exerciseName),
                        subtitle:
                            isAdded
                                ? const Text(
                                  'Zaten eklendi. Üzerine dokunarak tekrar ekleyebilirsiniz.',
                                )
                                : null,
                        trailing: ElevatedButton(
                          onPressed: () => _showAddExerciseDialog(exerciseName),
                          child: Text(isAdded ? 'Güncelle' : 'Ekle'),
                        ),
                      ),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }
}
