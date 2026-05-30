import 'package:flutter/material.dart';
import '../models/exercise.dart';

class AddExerciseScreen extends StatefulWidget {
  final List<String> allExercises;
  final List<String> customExercises;
  final Map<String, List<Exercise>> existingExercises;
  final String selectedDay;

  const AddExerciseScreen({
    super.key,
    required this.allExercises,
    required this.customExercises,
    required this.existingExercises,
    required this.selectedDay,
  });

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  List<String> _filteredSuggestions = [];
  bool _showSuggestions = false;
  bool _showSetRepForm = false;
  bool _exerciseSelected = false; // Hareket seçildi mi kontrolü

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_filterSuggestions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _filterSuggestions() {
    // Eğer bir hareket seçildiyse önerileri gösterme
    if (_exerciseSelected) {
      return;
    }

    final query = _nameController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredSuggestions = [];
        _showSuggestions = false;
        _exerciseSelected = false;
      });
      return;
    }

    // Tam eşleşme kontrolü
    final exactMatch = widget.allExercises.any(
      (ex) => ex.toLowerCase() == query,
    );

    setState(() {
      // Eğer tam eşleşme varsa önerileri gösterme
      if (exactMatch) {
        _filteredSuggestions = [];
        _showSuggestions = false;
        _showSetRepForm = true;
        _exerciseSelected = true;
      } else {
        _filteredSuggestions =
            widget.allExercises
                .where(
                  (ex) =>
                      ex.toLowerCase().contains(query) &&
                      ex.toLowerCase() != query,
                )
                .take(8)
                .toList();
        _showSuggestions = _filteredSuggestions.isNotEmpty;
        _showSetRepForm = false;
        _exerciseSelected = false;
      }
    });
  }

  void _selectExercise(String exerciseName) {
    setState(() {
      _nameController.text = exerciseName;
      _showSuggestions = false;
      _showSetRepForm = true;
      _exerciseSelected = true; // Hareket seçildi olarak işaretle
    });
    // Listener'ı geçici olarak kaldır, sonra tekrar ekle
    _nameController.removeListener(_filterSuggestions);
    _nameController.addListener(_filterSuggestions);
  }

  void _addExercise() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hareket ismi gerekli')));
      return;
    }

    String targetReps = _targetController.text.trim();
    if (_setsController.text.isNotEmpty && _repsController.text.isNotEmpty) {
      targetReps = '${_setsController.text}x${_repsController.text}';
    } else if (targetReps.isEmpty &&
        (_setsController.text.isNotEmpty || _repsController.text.isNotEmpty)) {
      targetReps = '${_setsController.text}x${_repsController.text}';
    }

    // Mevcut egzersizlerden son log'u ve ID'yi bul
    String? lastLog;
    String? existingId;
    for (var exercises in widget.existingExercises.values) {
      final existing = exercises.firstWhere(
        (ex) => ex.name.toLowerCase() == name.toLowerCase(),
        orElse: () => Exercise(id: '', name: '', targetReps: ''),
      );
      if (existing.id.isNotEmpty) {
        lastLog = existing.lastLog;
        existingId = existing.id; // Var olan ID'yi kullan
        break;
      }
    }

    // Eğer aynı hareket başka günde varsa, aynı ID'yi kullan
    final exercise = Exercise(
      id: existingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      targetReps: targetReps,
      lastLog: lastLog,
      assignedDays: [widget.selectedDay], // Şu anda seçili günle başla
    );

    Navigator.pop(context, exercise);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDarkMode ? const Color(0xFF27272a) : Colors.white;
    final inputBorderColor =
        isDarkMode ? Colors.grey[800] : const Color(0xFFD1D5DB);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF111827);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Egzersiz Ekle'),
        backgroundColor: isDarkMode ? const Color(0xFF18181b) : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hareket ismi
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Hareket İsmi',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                hintText: 'Listeden seçin veya manuel olarak yazın',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: inputBorderColor ?? Colors.grey,
                  ),
                ),
                filled: true,
                fillColor: inputFillColor,
              ),
              onChanged: (value) {
                // Kullanıcı yazdığında, eğer seçili hareket varsa ve değişiklik yapıldıysa seçimi sıfırla
                if (_exerciseSelected) {
                  // Seçili hareketin ismini kontrol et
                  final selectedName =
                      _nameController.text.trim().toLowerCase();
                  final currentValue = value.trim().toLowerCase();

                  // Eğer kullanıcı seçili hareketten farklı bir şey yazıyorsa
                  if (currentValue != selectedName &&
                      !widget.allExercises.any(
                        (ex) => ex.toLowerCase() == currentValue,
                      )) {
                    setState(() {
                      _exerciseSelected = false;
                    });
                  }
                }
              },
              onTap: () {
                if (_nameController.text.isNotEmpty && !_exerciseSelected) {
                  setState(() {
                    _showSuggestions = _filteredSuggestions.isNotEmpty;
                  });
                }
              },
            ),

            // Öneriler
            if (_showSuggestions && _filteredSuggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: inputBorderColor ?? Colors.grey),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _filteredSuggestions[index],
                        style: TextStyle(color: textColor),
                      ),
                      onTap: () => _selectExercise(_filteredSuggestions[index]),
                    );
                  },
                ),
              ),

            // Set ve Tekrar Formu - HER ZAMAN GÖSTERİL
            if (_nameController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _setsController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Set Sayısı',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        hintText: '3',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[600]!),
                        ),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Tekrar Sayısı',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        hintText: '10',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[600]!),
                        ),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10b981), // emerald-500
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      shadowColor: const Color(0xFF10b981).withOpacity(0.5),
                    ),
                    child: const Text(
                      'Ekle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('İptal'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
