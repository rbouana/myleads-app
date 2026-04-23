import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/reminder.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/reminders_provider.dart';
import '../reminders/reminder_detail_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(remindersProvider);
    final items = <Reminder>[
      ...state.lateReminders,
      ...state.todayReminders,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: items.isEmpty
            ? _buildEmpty()
            : RefreshIndicator(
                onRefresh: () => ref.read(remindersProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _NotificationCard(reminder: items[i]),
                ),
              ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.notifications_off_outlined,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('Aucune notification',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          const Text('Vos rappels du jour et en retard apparaitront ici.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMid)),
        ],
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final Reminder reminder;
  const _NotificationCard({required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLate = reminder.isLate;
    final accent = isLate ? AppColors.hot : AppColors.primary;

    IconData actionIcon;
    switch (reminder.toDoAction) {
      case 'sms':
        actionIcon = Icons.sms_rounded;
        break;
      case 'whatsapp':
        actionIcon = Icons.chat_rounded;
        break;
      case 'email':
        actionIcon = Icons.email_rounded;
        break;
      default:
        actionIcon = Icons.phone_rounded;
    }

    final contacts = ref.watch(contactsProvider).contacts;
    final linked =
        contacts.where((c) => reminder.contactIds.contains(c.id)).toList();
    final contactLabel = linked.isEmpty
        ? 'Contact supprime'
        : linked.length == 1
            ? linked.first.fullName
            : '${linked.first.fullName} +${linked.length - 1}';

    final dateLabel = DateFormat('dd MMM HH:mm').format(reminder.startDateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProviderScope(
                parent: ProviderScope.containerOf(context),
                child: ReminderDetailScreen(reminderId: reminder.id),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(actionIcon, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isLate ? 'En retard' : "Aujourd'hui",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(dateLabel,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textMid)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reminder.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded,
                              size: 12, color: AppColors.textLight),
                          const SizedBox(width: 3),
                          Expanded(
                              child: Text(contactLabel,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMid))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
