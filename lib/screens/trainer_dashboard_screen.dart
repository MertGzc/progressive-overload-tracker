import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/training_program.dart';
import '../services/storage_service.dart';
import 'trainer_write_program_screen.dart';

class TrainerDashboardScreen extends StatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  final StorageService _storageService = StorageService();

  User? _currentTrainer;
  List<User> _allUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final currentUser = await _storageService.getCurrentUser();
    final allUsers = await _storageService.getAllUsers();

    if (mounted) {
      setState(() {
        _currentTrainer = currentUser;
        // Kendisi hariç diğer tüm kullanıcıları göster (role'u ne olursa olsun)
        _allUsers = allUsers.where((u) => u.id != currentUser?.id).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrenör Paneli'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                _currentTrainer?.username ?? 'Antrenör',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _storageService.logoutUser();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _allUsers.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz kullanıcı yok',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allUsers.length,
                itemBuilder: (context, index) {
                  final user = _allUsers[index];
                  return UserCard(
                    user: user,
                    trainer: _currentTrainer!,
                    onProgramWritten: _loadData,
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class UserCard extends StatefulWidget {
  final User user;
  final User trainer;
  final VoidCallback onProgramWritten;

  const UserCard({
    super.key,
    required this.user,
    required this.trainer,
    required this.onProgramWritten,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  final StorageService _storageService = StorageService();

  List<TrainingProgram> _userPrograms = [];
  bool _isExpanded = false;
  bool _isLoadingPrograms = false;

  @override
  void initState() {
    super.initState();
    _loadUserPrograms();
  }

  Future<void> _loadUserPrograms() async {
    setState(() => _isLoadingPrograms = true);

    final programs = await _storageService.getUserTrainingPrograms(
      widget.user.id,
    );

    if (mounted) {
      setState(() {
        _userPrograms = programs;
        _isLoadingPrograms = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(widget.user.username[0].toUpperCase()),
            ),
            title: Text(widget.user.username),
            subtitle: Text(
              'Rol: ${widget.user.role == 'trainer' ? 'Antrenör' : 'Kullanıcı'}',
              style: TextStyle(
                color:
                    widget.user.role == 'trainer'
                        ? Colors.orange
                        : Colors.grey[400],
              ),
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (_isExpanded && _userPrograms.isEmpty) {
                    _loadUserPrograms();
                  }
                });
              },
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yazılan Programlar',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (_isLoadingPrograms)
                        const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_userPrograms.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () {
                            final program = _userPrograms.first;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => TrainerWriteProgramScreen(
                                      user: widget.user,
                                      trainer: widget.trainer,
                                      program: program,
                                      onProgramSaved: () {
                                        widget.onProgramWritten();
                                        _loadUserPrograms();
                                      },
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Program Düzenle'),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => TrainerWriteProgramScreen(
                                      user: widget.user,
                                      trainer: widget.trainer,
                                      onProgramSaved: () {
                                        widget.onProgramWritten();
                                        _loadUserPrograms();
                                      },
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Program Yaz'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingPrograms)
                    const Center(child: CircularProgressIndicator())
                  else if (_userPrograms.isEmpty)
                    Text(
                      'Henüz program yazılmadı',
                      style: TextStyle(color: Colors.grey[500]),
                    )
                  else
                    Column(
                      children:
                          _userPrograms.map((program) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[600]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    program.programName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${program.exercises.length} gün, ${program.exercises.values.fold<int>(0, (sum, exList) => sum + exList.length)} egzersiz',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
