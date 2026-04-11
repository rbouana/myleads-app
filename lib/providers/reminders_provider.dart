import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

const _uuid = Uuid();

class RemindersState {
  final List<Reminder> reminders;
  final String activeTab; // 'today', 'overdue', 'week'

  const RemindersState({
    this.reminders = const [],
    this.activeTab = 'today',
  });

  List<Reminder> get todayReminders =>
      reminders.where((r) => r.isToday && !r.isCompleted).toList();

  List<Reminder> get overdueReminders =>
      reminders.where((r) => r.isOverdue).toList();

  List<Reminder> get weekReminders =>
      reminders.where((r) => r.isThisWeek && !r.isCompleted).toList();

  List<Reminder> get completedReminders =>
      reminders.where((r) => r.isCompleted).toList();

  List<Reminder> get activeReminders {
    switch (activeTab) {
      case 'today':
        return todayReminders;
      case 'overdue':
        return overdueReminders;
      case 'week':
        return weekReminders;
      default:
        return todayReminders;
    }
  }

  RemindersState copyWith({
    List<Reminder>? reminders,
    String? activeTab,
  }) {
    return RemindersState(
      reminders: reminders ?? this.reminders,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

class RemindersNotifier extends StateNotifier<RemindersState> {
  RemindersNotifier() : super(const RemindersState()) {
    _loadReminders();
  }

  String get _ownerId => StorageService.currentUserId;

  Future<void> _loadReminders() async {
    if (_ownerId.isEmpty) {
      state = state.copyWith(reminders: []);
      return;
    }
    final reminders = await StorageService.getAllReminders();
    if (reminders.isEmpty) {
      await _seedDemoData();
    } else {
      state = state.copyWith(reminders: reminders);
    }
  }

  Future<void> reload() => _loadReminders();

  Future<void> _seedDemoData() async {
    final ownerId = _ownerId;
    if (ownerId.isEmpty) return;
    final now = DateTime.now();
    final demoReminders = [
      Reminder(
        id: _uuid.v4(),
        ownerId: ownerId,
        contactId: '',
        title: 'Envoyer proposition commerciale',
        description: 'Karen Ambassa - GreenTech Cameroon',
        dueDate: DateTime(now.year, now.month, now.day, 10, 0),
        priority: 'urgent',
      ),
      Reminder(
        id: _uuid.v4(),
        ownerId: ownerId,
        contactId: '',
        title: 'Relance après meeting',
        description: 'Mike Investor - TechFund Africa',
        dueDate: DateTime(now.year, now.month, now.day, 14, 30),
        priority: 'soon',
      ),
      Reminder(
        id: _uuid.v4(),
        ownerId: ownerId,
        contactId: '',
        title: 'Démo technique',
        description: 'Thomas Matouke - Digitech Solutions',
        dueDate: DateTime(now.year, now.month, now.day, 17, 0),
        priority: 'later',
      ),
    ];

    for (final r in demoReminders) {
      await DatabaseService.insertReminder(r);
    }
    state = state.copyWith(reminders: demoReminders);
  }

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  Future<void> addReminder(Reminder reminder) async {
    final newReminder = reminder.copyWith(
      id: _uuid.v4(),
      ownerId: _ownerId,
    );
    await DatabaseService.insertReminder(newReminder);
    state = state.copyWith(
      reminders: [...state.reminders, newReminder],
    );
  }

  Future<void> completeReminder(String id) async {
    final updated = <Reminder>[];
    for (final r in state.reminders) {
      if (r.id == id) {
        final done = r.copyWith(isCompleted: true);
        await DatabaseService.updateReminder(done);
        updated.add(done);
      } else {
        updated.add(r);
      }
    }
    state = state.copyWith(reminders: updated);
  }

  Future<void> deleteReminder(String id) async {
    await DatabaseService.deleteReminder(id);
    state = state.copyWith(
      reminders: state.reminders.where((r) => r.id != id).toList(),
    );
  }

  List<Reminder> getRemindersForContact(String contactId) {
    return state.reminders
        .where((r) => r.contactId == contactId && !r.isCompleted)
        .toList();
  }
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  return RemindersNotifier();
});
