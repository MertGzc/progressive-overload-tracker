import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../models/user.dart';
import '../models/training_program.dart';

class StorageService {
  static const String _workoutsKey = 'workout_tracker_workouts';
  static const String _customExercisesKey = 'workout_tracker_custom_exercises';
  static const String _usersKey = 'workout_tracker_users';
  static const String _currentUserKey = 'workout_tracker_current_user';
  static const String _trainingProgramsKey =
      'workout_tracker_training_programs';

  // ============= USER AUTHENTICATION =============

  // Kullanıcı kaydı
  Future<bool> registerUser(
    String username,
    String password,
    String role,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Kullanıcı adı zaten var mı kontrol et
      final usersJson = prefs.getString(_usersKey);
      List<User> users = [];

      if (usersJson != null) {
        final List<dynamic> data = json.decode(usersJson);
        users =
            data.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();

        if (users.any((u) => u.username == username)) {
          return false; // Kullanıcı adı zaten var
        }
      }

      // Yeni kullanıcı oluştur
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        password: password,
        role: role,
        createdAt: DateTime.now(),
      );

      users.add(newUser);

      // Kullanıcıları kaydet
      final usersData = users.map((u) => u.toJson()).toList();
      await prefs.setString(_usersKey, json.encode(usersData));

      // Giriş yap
      await prefs.setString(_currentUserKey, json.encode(newUser.toJson()));

      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  // Kullanıcı girişi
  Future<User?> loginUser(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        return null;
      }

      final List<dynamic> data = json.decode(usersJson);
      final users =
          data.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();

      final user = users.firstWhere(
        (u) => u.username == username && u.password == password,
        orElse:
            () => User(
              id: '',
              username: '',
              password: '',
              role: '',
              createdAt: DateTime.now(),
            ),
      );

      if (user.id.isEmpty) {
        return null;
      }

      // Mevcut kullanıcıyı kaydet
      await prefs.setString(_currentUserKey, json.encode(user.toJson()));

      return user;
    } catch (e) {
      print('Error logging in user: $e');
      return null;
    }
  }

  // Mevcut kullanıcıyı getir
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);

      if (userJson == null) {
        return null;
      }

      final userData = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Çıkış yap
  Future<bool> logoutUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_currentUserKey);
    } catch (e) {
      print('Error logging out user: $e');
      return false;
    }
  }

  // Tüm kullanıcıları getir (Antrenörler için)
  Future<List<User>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        return [];
      }

      final List<dynamic> data = json.decode(usersJson);
      return data.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // ============= TRAINING PROGRAM MANAGEMENT =============

  // Antrenman programı kaydet
  Future<bool> saveTrainingProgram(TrainingProgram program) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List<TrainingProgram> programs = [];
      final programsJson = prefs.getString(_trainingProgramsKey);

      if (programsJson != null) {
        final List<dynamic> data = json.decode(programsJson);
        programs =
            data
                .map((p) => TrainingProgram.fromJson(p as Map<String, dynamic>))
                .toList();
      }

      // Aynı kullanıcı için daha önce yazılmış aktif program varsa, yeni programla değiştir
      programs.removeWhere(
        (p) => p.userId == program.userId && p.id != program.id && p.isActive,
      );

      // Aynı ID'li programı güncelle veya yeni ekle
      final existingIndex = programs.indexWhere((p) => p.id == program.id);
      if (existingIndex >= 0) {
        programs[existingIndex] = program;
      } else {
        programs.add(program);
      }

      final programsData = programs.map((p) => p.toJson()).toList();
      return await prefs.setString(
        _trainingProgramsKey,
        json.encode(programsData),
      );
    } catch (e) {
      print('Error saving training program: $e');
      return false;
    }
  }

  // Kullanıcı için antrenman programlarını getir
  Future<List<TrainingProgram>> getUserTrainingPrograms(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programsJson = prefs.getString(_trainingProgramsKey);

      if (programsJson == null) {
        return [];
      }

      final List<dynamic> data = json.decode(programsJson);
      final programs =
          data
              .map((p) => TrainingProgram.fromJson(p as Map<String, dynamic>))
              .toList();

      // Kullanıcıya atanan programları filtrele
      return programs.where((p) => p.userId == userId && p.isActive).toList();
    } catch (e) {
      print('Error getting user training programs: $e');
      return [];
    }
  }

  // Antrenör tarafından yazılan programları getir
  Future<List<TrainingProgram>> getTrainerPrograms(String trainerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programsJson = prefs.getString(_trainingProgramsKey);

      if (programsJson == null) {
        return [];
      }

      final List<dynamic> data = json.decode(programsJson);
      final programs =
          data
              .map((p) => TrainingProgram.fromJson(p as Map<String, dynamic>))
              .toList();

      return programs.where((p) => p.trainerId == trainerId).toList();
    } catch (e) {
      print('Error getting trainer programs: $e');
      return [];
    }
  }

  // Program sil
  Future<bool> deleteTrainingProgram(String programId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programsJson = prefs.getString(_trainingProgramsKey);

      if (programsJson == null) {
        return false;
      }

      final List<dynamic> data = json.decode(programsJson);
      final programs =
          data
              .map((p) => TrainingProgram.fromJson(p as Map<String, dynamic>))
              .toList();

      programs.removeWhere((p) => p.id == programId);

      final programsData = programs.map((p) => p.toJson()).toList();
      return await prefs.setString(
        _trainingProgramsKey,
        json.encode(programsData),
      );
    } catch (e) {
      print('Error deleting training program: $e');
      return false;
    }
  }

  // ============= WORKOUT METHODS =============

  Future<Map<String, List<Exercise>>> loadWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = prefs.getString(_workoutsKey);

      if (workoutsJson == null) {
        return {};
      }

      final Map<String, dynamic> data = json.decode(workoutsJson);
      final Map<String, List<Exercise>> workouts = {};

      data.forEach((day, exercises) {
        if (exercises is List) {
          workouts[day] =
              exercises.map((ex) {
                final exercise = Exercise.fromJson(ex as Map<String, dynamic>);
                // Migration: assignedDays boşsa, mevcut günü ekle
                if (exercise.assignedDays == null ||
                    exercise.assignedDays!.isEmpty) {
                  return Exercise(
                    id: exercise.id,
                    name: exercise.name,
                    targetReps: exercise.targetReps,
                    lastLog: exercise.lastLog,
                    history: exercise.history,
                    assignedDays: [day],
                  );
                }
                return exercise;
              }).toList();
        }
      });

      return workouts;
    } catch (e) {
      print('Error loading workouts: $e');
      return {};
    }
  }

  // Workout verilerini kaydet
  Future<bool> saveWorkouts(Map<String, List<Exercise>> workouts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> workoutsData = {};

      workouts.forEach((day, exercises) {
        workoutsData[day] = exercises.map((ex) => ex.toJson()).toList();
      });

      final workoutsJson = json.encode(workoutsData);
      return await prefs.setString(_workoutsKey, workoutsJson);
    } catch (e) {
      print('Error saving workouts: $e');
      return false;
    }
  }

  // Custom exercises listesini yükle
  Future<List<String>> loadCustomExercises() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customExercisesJson = prefs.getString(_customExercisesKey);

      if (customExercisesJson == null) {
        return [];
      }

      final List<dynamic> data = json.decode(customExercisesJson);
      return List<String>.from(data);
    } catch (e) {
      print('Error loading custom exercises: $e');
      return [];
    }
  }

  // Custom exercises listesini kaydet
  Future<bool> saveCustomExercises(List<String> customExercises) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customExercisesJson = json.encode(customExercises);
      return await prefs.setString(_customExercisesKey, customExercisesJson);
    } catch (e) {
      print('Error saving custom exercises: $e');
      return false;
    }
  }

  // Tüm verileri temizle (opsiyonel)
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_workoutsKey) &&
          await prefs.remove(_customExercisesKey) &&
          await prefs.remove(_trainingProgramsKey);
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }

  // Aynı exercise'i tüm günlerde güncelle (multi-day sync)
  Future<bool> updateExerciseAcrossAllDays(
    Map<String, List<Exercise>> workouts,
    String exerciseId,
    Exercise updatedExercise,
  ) async {
    try {
      // TÜÜN günlerde bu hareket varsa güncelle
      workouts.forEach((day, exercises) {
        final index = exercises.indexWhere((ex) => ex.id == exerciseId);
        if (index >= 0) {
          // Exercise'i update et
          exercises[index] = Exercise(
            id: updatedExercise.id,
            name: updatedExercise.name,
            targetReps: updatedExercise.targetReps,
            lastLog: updatedExercise.lastLog,
            history: updatedExercise.history,
            assignedDays: updatedExercise.assignedDays ?? [day],
          );
        }
      });

      return await saveWorkouts(workouts);
    } catch (e) {
      print('Error updating exercise across all days: $e');
      return false;
    }
  }

  // Exercise'i sil - tüm günlerden çıkar
  Future<bool> deleteExerciseAcrossAllDays(
    Map<String, List<Exercise>> workouts,
    String exerciseId,
  ) async {
    try {
      // Bütün günleri kontrol et
      workouts.forEach((day, exercises) {
        exercises.removeWhere((ex) => ex.id == exerciseId);
      });

      return await saveWorkouts(workouts);
    } catch (e) {
      print('Error deleting exercise across all days: $e');
      return false;
    }
  }

  // ============= DEFAULT DATA INITIALIZATION =============

  // Varsayılan verileri başlat (ilk çalıştırmada)
  Future<void> initializeDefaultData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final usersJson = prefs.getString(_usersKey);
      final programsJson = prefs.getString(_trainingProgramsKey);
      final workoutsJson = prefs.getString(_workoutsKey);

      User? trainer;
      User? user;
      var hasDefaultUsers = false;

      if (usersJson != null) {
        final List<dynamic> data = json.decode(usersJson);
        final users =
            data.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
        trainer = users.firstWhere(
          (u) => u.username == 'antrenor1' && u.role == 'trainer',
          orElse:
              () => User(
                id: '',
                username: '',
                password: '',
                role: '',
                createdAt: DateTime.now(),
              ),
        );
        user = users.firstWhere(
          (u) => u.username == 'kullanici1' && u.role == 'user',
          orElse:
              () => User(
                id: '',
                username: '',
                password: '',
                role: '',
                createdAt: DateTime.now(),
              ),
        );
        hasDefaultUsers = trainer.id.isNotEmpty && user.id.isNotEmpty;
      }

      if (usersJson == null) {
        trainer = User(
          id: '1',
          username: 'antrenor1',
          password: 'deneme1',
          role: 'trainer',
          createdAt: DateTime.now(),
        );

        user = User(
          id: '2',
          username: 'kullanici1',
          password: 'deneme1',
          role: 'user',
          createdAt: DateTime.now(),
        );

        final users = [trainer, user];
        await prefs.setString(
          _usersKey,
          json.encode(users.map((u) => u.toJson()).toList()),
        );
        hasDefaultUsers = true;
      }

      if (!hasDefaultUsers) {
        return;
      }

      // Only default user accounts are created automatically.
      // Default workouts/programs are not generated anymore.
      return;
    } catch (e) {
      print('Error initializing default data: $e');
    }
  }
}
