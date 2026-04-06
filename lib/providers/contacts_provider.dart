import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/contact.dart';
import '../models/interaction.dart';
import '../services/storage_service.dart';

const _uuid = Uuid();

class ContactsState {
  final List<Contact> contacts;
  final String searchQuery;
  final String activeFilter;
  final bool isLoading;

  const ContactsState({
    this.contacts = const [],
    this.searchQuery = '',
    this.activeFilter = 'all',
    this.isLoading = false,
  });

  List<Contact> get filteredContacts {
    var filtered = List<Contact>.from(contacts);

    // Apply status/tag filter
    if (activeFilter != 'all') {
      filtered = filtered.where((c) {
        if (c.status == activeFilter) return true;
        return c.tags.any(
            (t) => t.toLowerCase() == activeFilter.toLowerCase());
      }).toList();
    }

    // Apply search
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((c) {
        return c.fullName.toLowerCase().contains(q) ||
            (c.company?.toLowerCase().contains(q) ?? false) ||
            (c.jobTitle?.toLowerCase().contains(q) ?? false) ||
            c.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    // Sort: hot first, then by date
    filtered.sort((a, b) {
      const priority = {'hot': 0, 'warm': 1, 'cold': 2};
      final cmp = (priority[a.status] ?? 2).compareTo(priority[b.status] ?? 2);
      if (cmp != 0) return cmp;
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  int get totalContacts => contacts.length;
  int get hotLeads => contacts.where((c) => c.status == 'hot').length;
  int get warmLeads => contacts.where((c) => c.status == 'warm').length;
  int get coldLeads => contacts.where((c) => c.status == 'cold').length;

  ContactsState copyWith({
    List<Contact>? contacts,
    String? searchQuery,
    String? activeFilter,
    bool? isLoading,
  }) {
    return ContactsState(
      contacts: contacts ?? this.contacts,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ContactsNotifier extends StateNotifier<ContactsState> {
  ContactsNotifier() : super(const ContactsState()) {
    _loadContacts();
  }

  void _loadContacts() {
    final contacts = StorageService.getAllContacts();
    if (contacts.isEmpty) {
      _seedDemoData();
    } else {
      state = state.copyWith(contacts: contacts);
    }
  }

  void _seedDemoData() {
    final demoContacts = [
      Contact(
        id: _uuid.v4(),
        firstName: 'Karen',
        lastName: 'Ambassa',
        jobTitle: 'CEO',
        company: 'GreenTech Cameroon',
        phone: '+237 6 99 88 77 66',
        email: 'karen@greentech.cm',
        source: 'Salon Luxembourg 2026',
        project: 'Partenariat Tech',
        notes: 'Rencontrée au salon Luxembourg. Très intéressée par un partenariat technologique. Budget confirmé.',
        tags: ['Tech', 'CEO', 'Event'],
        status: 'hot',
        avatarColor: '0xFFE74C3C',
        captureMethod: 'scan',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Contact(
        id: _uuid.v4(),
        firstName: 'Mike',
        lastName: 'Investor',
        jobTitle: 'Partner',
        company: 'TechFund Africa',
        phone: '+352 621 123 456',
        email: 'mike@techfund.africa',
        source: 'Networking Event',
        project: 'Investissement Seed',
        notes: 'Intéressé par le financement de startups tech en Afrique centrale.',
        tags: ['Finance', 'Partner', 'Investor'],
        status: 'warm',
        avatarColor: '0xFFF39C12',
        captureMethod: 'qr',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Contact(
        id: _uuid.v4(),
        firstName: 'Thomas',
        lastName: 'Matouke',
        jobTitle: 'CTO',
        company: 'Digitech Solutions',
        phone: '+237 6 55 44 33 22',
        email: 'thomas@digitech.cm',
        source: 'Conférence IT',
        project: 'Intégration API',
        tags: ['Tech', 'CTO'],
        status: 'hot',
        avatarColor: '0xFFD4AF37',
        captureMethod: 'scan',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Contact(
        id: _uuid.v4(),
        firstName: 'Sophie',
        lastName: 'Nguema',
        jobTitle: 'Directrice Générale',
        company: 'MediaCorp Gabon',
        phone: '+241 7 12 34 56',
        email: 'sophie@mediacorp.ga',
        source: 'Salon Digital',
        tags: ['Media', 'Event'],
        status: 'warm',
        avatarColor: '0xFF8E44AD',
        captureMethod: 'manual',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Contact(
        id: _uuid.v4(),
        firstName: 'Pierre',
        lastName: 'Onana',
        jobTitle: 'Directeur Commercial',
        company: 'SNCI',
        phone: '+237 6 77 66 55 44',
        email: 'pierre.onana@snci.cm',
        project: 'Contrat B2B',
        tags: ['B2B', 'Priority'],
        status: 'hot',
        avatarColor: '0xFF2C3E50',
        captureMethod: 'nfc',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Contact(
        id: _uuid.v4(),
        firstName: 'Albright',
        lastName: 'Munki',
        jobTitle: 'Web Developer',
        company: 'De Bouana',
        phone: '+237 6 88 77 66 55',
        email: 'albright@debouana.com',
        tags: ['Tech', 'Team'],
        status: 'cold',
        avatarColor: '0xFF27AE60',
        captureMethod: 'manual',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Contact(
        id: _uuid.v4(),
        firstName: 'Sundar',
        lastName: 'Pichai',
        jobTitle: 'CEO',
        company: 'Google / Alphabet',
        email: 'contact@google.com',
        source: 'Conférence I/O',
        tags: ['Tech', 'CEO'],
        status: 'warm',
        avatarColor: '0xFF4285F4',
        captureMethod: 'qr',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Contact(
        id: _uuid.v4(),
        firstName: 'Strive',
        lastName: 'Masiyiwa',
        jobTitle: 'Founder',
        company: 'Econet',
        tags: ['Telecom', 'Investor'],
        status: 'cold',
        avatarColor: '0xFF1ABC9C',
        captureMethod: 'manual',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Contact(
        id: _uuid.v4(),
        firstName: 'Aiman',
        lastName: 'Ezzat',
        jobTitle: 'CEO',
        company: 'Capgemini',
        email: 'contact@capgemini.com',
        tags: ['Consulting', 'Tech'],
        status: 'warm',
        avatarColor: '0xFF34495E',
        captureMethod: 'scan',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Contact(
        id: _uuid.v4(),
        firstName: 'Youssouf',
        lastName: 'Labarang',
        jobTitle: 'Directeur IT',
        company: 'Ministère Finance',
        phone: '+237 6 33 22 11 00',
        source: 'Forum Gouvernemental',
        tags: ['Gov', 'IT'],
        status: 'hot',
        avatarColor: '0xFFE67E22',
        captureMethod: 'scan',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    for (final contact in demoContacts) {
      StorageService.saveContact(contact);
    }

    // Seed some interactions for Karen
    final karenId = demoContacts[0].id;
    final interactions = [
      Interaction(
        id: _uuid.v4(),
        contactId: karenId,
        type: 'meeting',
        content: 'Rencontre au Salon Luxembourg',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Interaction(
        id: _uuid.v4(),
        contactId: karenId,
        type: 'call',
        content: 'Appel de suivi - 15 min',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Interaction(
        id: _uuid.v4(),
        contactId: karenId,
        type: 'email',
        content: 'Email de proposition envoyé',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    for (final interaction in interactions) {
      StorageService.saveInteraction(interaction);
    }

    state = state.copyWith(contacts: demoContacts);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<Contact> addContact(Contact contact) async {
    final newContact = contact.copyWith(id: _uuid.v4());
    await StorageService.saveContact(newContact);
    state = state.copyWith(
      contacts: [...state.contacts, newContact],
    );
    return newContact;
  }

  Future<void> updateContact(Contact contact) async {
    await StorageService.saveContact(contact);
    final updated = state.contacts.map((c) {
      return c.id == contact.id ? contact : c;
    }).toList();
    state = state.copyWith(contacts: updated);
  }

  Future<void> deleteContact(String id) async {
    await StorageService.deleteContact(id);
    state = state.copyWith(
      contacts: state.contacts.where((c) => c.id != id).toList(),
    );
  }

  Future<void> addInteraction(Interaction interaction) async {
    await StorageService.saveInteraction(interaction);
    // Update last contact date
    final contact = state.contacts.firstWhere(
      (c) => c.id == interaction.contactId,
      orElse: () => throw Exception('Contact not found'),
    );
    await updateContact(
      contact.copyWith(lastContactDate: DateTime.now()),
    );
  }

  List<Interaction> getInteractions(String contactId) {
    return StorageService.getInteractionsForContact(contactId);
  }
}

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  return ContactsNotifier();
});

// Derived providers
final hotLeadsProvider = Provider<List<Contact>>((ref) {
  final contacts = ref.watch(contactsProvider).contacts;
  return contacts.where((c) => c.status == 'hot').toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final contactByIdProvider =
    Provider.family<Contact?, String>((ref, id) {
  final contacts = ref.watch(contactsProvider).contacts;
  try {
    return contacts.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});
