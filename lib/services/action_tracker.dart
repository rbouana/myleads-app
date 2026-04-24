import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../models/interaction.dart';
import 'database_service.dart';

/// Tracks user actions that send them out of the app (call, SMS, WhatsApp,
/// email) so the app can infer a successful interaction.
///
/// Flow:
/// 1. [ContactActions] calls [markPendingAction] right before launching the
///    external URL scheme.
/// 2. If the OS then sends the app to the background for ≥ [thresholdMs]
///    milliseconds, we assume the user actually opened the external app
///    and completed (or attempted) the action — so on resume we persist
///    an [Interaction] row for the current contact.
/// 3. If the app comes back faster than the threshold (e.g. the user
///    cancelled the dialog), no interaction is logged.
///
/// This is the closest signal we have from a Flutter app without
/// requesting platform-specific call-log / SMS-log permissions.
class ActionTracker with WidgetsBindingObserver {
  ActionTracker._();

  static final ActionTracker _instance = ActionTracker._();
  static const int thresholdMs = 10 * 1000; // 10 seconds

  static const _uuid = Uuid();

  // Pending action awaiting a background→resume transition.
  static String? _pendingContactId;
  static String? _pendingType;
  static DateTime? _pausedAt;

  static bool _initialized = false;

  /// Attach the tracker to the Flutter binding. Safe to call more than once.
  static void init() {
    if (_initialized) return;
    WidgetsBinding.instance.addObserver(_instance);
    _initialized = true;
  }

  /// Called by [ContactActions] before launching an external URL.
  /// [type] must be one of 'call', 'sms', 'whatsapp', 'email'.
  static void markPendingAction(String contactId, String type) {
    _pendingContactId = contactId;
    _pendingType = type;
    // Do not set _pausedAt here; we wait for the real paused callback.
  }

  static void _clearPending() {
    _pendingContactId = null;
    _pendingType = null;
    _pausedAt = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _pausedAt ??= DateTime.now();
        break;
      case AppLifecycleState.resumed:
        _onResume();
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _onResume() async {
    final pausedAt = _pausedAt;
    final contactId = _pendingContactId;
    final type = _pendingType;
    if (pausedAt == null || contactId == null || type == null) {
      _clearPending();
      return;
    }
    final gap = DateTime.now().difference(pausedAt).inMilliseconds;
    _clearPending();
    if (gap < thresholdMs) return;

    // Persist the interaction. Best-effort — don't crash the app on DB errors.
    try {
      await DatabaseService.insertInteraction(
        Interaction(
          id: _uuid.v4(),
          contactId: contactId,
          type: type,
          content: _contentFor(type, gap),
        ),
      );
    } catch (_) {
      // Swallow — tracking is opportunistic.
    }
  }

  static String _contentFor(String type, int gapMs) {
    final seconds = (gapMs / 1000).round();
    switch (type) {
      case 'call':
        return 'Appel sortant (durée ≈ ${seconds}s)';
      case 'sms':
        return 'SMS envoyé';
      case 'whatsapp':
        return 'Message WhatsApp envoyé';
      case 'email':
        return 'Email envoyé';
      default:
        return 'Action $type (${seconds}s)';
    }
  }
}
