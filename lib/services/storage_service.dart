import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact.dart';
import '../models/reminder.dart';
import '../models/interaction.dart';

class StorageService {
  static const String contactsBox = 'contacts';
  static const String remindersBox = 'reminders';
  static const String interactionsBox = 'interactions';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ContactAdapter());
    Hive.registerAdapter(ReminderAdapter());
    Hive.registerAdapter(InteractionAdapter());

    await Hive.openBox<Contact>(contactsBox);
    await Hive.openBox<Reminder>(remindersBox);
    await Hive.openBox<Interaction>(interactionsBox);
    await Hive.openBox(settingsBox);
  }

  // Contacts
  static Box<Contact> get contactsStore => Hive.box<Contact>(contactsBox);

  static List<Contact> getAllContacts() => contactsStore.values.toList();

  static Future<void> saveContact(Contact contact) async {
    await contactsStore.put(contact.id, contact);
  }

  static Future<void> deleteContact(String id) async {
    await contactsStore.delete(id);
  }

  static Contact? getContact(String id) => contactsStore.get(id);

  // Reminders
  static Box<Reminder> get remindersStore => Hive.box<Reminder>(remindersBox);

  static List<Reminder> getAllReminders() => remindersStore.values.toList();

  static Future<void> saveReminder(Reminder reminder) async {
    await remindersStore.put(reminder.id, reminder);
  }

  static Future<void> deleteReminder(String id) async {
    await remindersStore.delete(id);
  }

  // Interactions
  static Box<Interaction> get interactionsStore =>
      Hive.box<Interaction>(interactionsBox);

  static List<Interaction> getInteractionsForContact(String contactId) {
    return interactionsStore.values
        .where((i) => i.contactId == contactId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> saveInteraction(Interaction interaction) async {
    await interactionsStore.put(interaction.id, interaction);
  }

  // Settings
  static Box get settingsStore => Hive.box(settingsBox);

  static bool get isLoggedIn => settingsStore.get('isLoggedIn', defaultValue: false);
  static set isLoggedIn(bool value) => settingsStore.put('isLoggedIn', value);

  static String get userName => settingsStore.get('userName', defaultValue: 'Régis Bouana');
  static set userName(String value) => settingsStore.put('userName', value);

  static String get userEmail => settingsStore.get('userEmail', defaultValue: 'regis@debouana.com');
  static set userEmail(String value) => settingsStore.put('userEmail', value);

  static bool get hasCompletedOnboarding =>
      settingsStore.get('hasCompletedOnboarding', defaultValue: false);
  static set hasCompletedOnboarding(bool value) =>
      settingsStore.put('hasCompletedOnboarding', value);

  static String get userPlan => settingsStore.get('userPlan', defaultValue: 'free');
  static set userPlan(String value) => settingsStore.put('userPlan', value);
}
