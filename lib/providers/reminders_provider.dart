import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';
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

  void _loadReminders() {
    final reminders = StorageService.getAllReminders();
    if (reminders.isEmpty) {
      _seedDemoData();
    } else {
      state = state.copyWith(reminders: reminders);
    }
  }

  void _seedDemoData() {
    final now = DateTime.now();
    final demoReminders = [
      Reminder(
        id: _uuid.v4(),
        contactId: '',
        title: 'Envoyer proposition commerciale',
        description: 'Karen Ambassa - GreenTech Cameroon',
        dueDate: DateTime(now.year, now.month, now.day, 10, 0),
        priority: 'urgent',
      ),
      Reminder(
        id: _uuid.v4(),
        contactId: '',
        title: 'Relance après meeting',
        description: 'Mike Investor - TechFund Africa',
        dueDate: DateTime(now.year, now.month, now.day, 14, 30),
        priority: 'soon',
      ),
      Reminder(
        id: _uuid.v4(),
        contactId: '',
        title: 'Démo technique',
        description: 'Thomas Matouke - Digitech Solutions',
        dueDate: DateTime(now.year, now.month, now.day, 17, 0),
        priority: 'later',
      ),
      Reminder(
        id: _uuid.v4(),
        contactId: '',
        title: 'Suivi projet digital',
        description: 'Sophie Nguema - MediaCorp Gabon',
        dueDate: now.subtract(const Duration(days: 1)),
        priority: 'urgent',
      ),
      Reminder(
        id: _uuid.v4(),
        contactId: '',
        title: 'Contrat à finaliser',
        description: 'Pierre Onana - SNCI',
        dueDate: now.subtract(const Duration(days: 2)),
        priority: 'urgent',
      ),
    ];

    for (final r in demoReminders) {
      StorageService.saveReminder(r);
    }
    state = state.copyWith(reminders: demoReminders);
  }

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  Future<void> addReminder(Reminder reminder) async {
    final newReminder = reminder.copyWith(id: _uuid.v4());
    await StorageService.saveReminder(newReminder);
    state = state.copyWith(
      reminders: [...state.reminders, newReminder],
    );
  }

  Future<void> completeReminder(String id) async {
    final updated = state.reminders.map((r) {
      if (r.id == id) {
        final completed = r.copyWith(isCompleted: true);
        StorageService.saveReminder(completed);
        return completed;
      }
      return r;
    }).toList();
    state = state.copyWith(reminders: updated);
  }

  Future<void> deleteReminder(String id) async {
    await StorageService.deleteReminder(id);
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
