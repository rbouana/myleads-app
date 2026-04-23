/// Extracts contact fields from raw OCR text.
///
/// Handles both business cards (name, email, phone, job title, company)
/// and handwritten / typed notes that carry extra project context
/// (source, project/budget pairs, tags, free-form notes).
///
/// Extraction strategy:
///   1. Regex sweep for email, phone, website.
///   2. Keyword-prefixed lines ("Projet:", "Budget:", "Source:", "Tags:",
///      "Notes:"…) pull out business context. French + English keywords
///      are supported.
///   3. Remaining lines are classified as name / title / company using
///      job-title keyword heuristics.
class OcrParser {
  OcrParser._();

  static Map<String, String> parse(String rawText) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final result = <String, String>{};

    String? email;
    String? phone;
    String? website;
    final leftover = <String>[];
    final tags = <String>[];
    final notes = <String>[];
    int projectIdx = 1;

    for (final line in lines) {
      // ── 1. Regex extractors ─────────────────────────────────────────────
      final emailMatch = RegExp(
              r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}')
          .firstMatch(line);
      if (emailMatch != null && email == null) {
        email = emailMatch.group(0);
        continue;
      }

      final phoneMatch = RegExp(
        r'(?:\+?\d{1,3}[\s\-.]?)?\(?\d{2,4}\)?[\s\-.]?\d{2,4}[\s\-.]?\d{2,4}[\s\-.]?\d{0,4}',
      ).firstMatch(line);
      if (phoneMatch != null) {
        final digits =
            phoneMatch.group(0)!.replaceAll(RegExp(r'[^\d+]'), '');
        if (digits.length >= 8 && phone == null) {
          phone = phoneMatch.group(0)!.trim();
          if (line.replaceAll(phoneMatch.group(0)!, '').trim().length < 3) {
            continue;
          }
        }
      }

      if (RegExp(r'www\.|https?://', caseSensitive: false).hasMatch(line)) {
        website ??= line;
        continue;
      }

      // ── 2. Keyword-prefixed fields ─────────────────────────────────────
      final kv = _matchKeyValue(line);
      if (kv != null) {
        final key = kv.$1;
        final value = kv.$2;

        // Source / lead origin
        if (RegExp(r'^(source|origine|via|referred by|referral|refere|referre)$',
                caseSensitive: false)
            .hasMatch(key)) {
          result['source'] = value;
          continue;
        }

        // Project (1..N)
        if (RegExp(r'^(projet|project)\s*(\d+)?$', caseSensitive: false)
            .hasMatch(key)) {
          final m = RegExp(r'(\d+)').firstMatch(key);
          final idx = m != null ? int.parse(m.group(0)!) : projectIdx++;
          if (idx == 1 || idx == 2) {
            result['project$idx'] = value;
          }
          continue;
        }

        // Budget (1..N)
        if (RegExp(r'^(budget|cout|coût|montant|price|prix)\s*(\d+)?$',
                caseSensitive: false)
            .hasMatch(key)) {
          final m = RegExp(r'(\d+)').firstMatch(key);
          final idx = m != null ? int.parse(m.group(0)!) : 1;
          if (idx == 1 || idx == 2) {
            result['project${idx}Budget'] = value;
          }
          continue;
        }

        // Tags (comma/semicolon separated)
        if (RegExp(r'^(tags?|etiquettes?|labels?)$', caseSensitive: false)
            .hasMatch(key)) {
          tags.addAll(value
              .split(RegExp(r'[,;]'))
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty));
          continue;
        }

        // Notes
        if (RegExp(r'^(notes?|remarques?|commentaires?|comments?)$',
                caseSensitive: false)
            .hasMatch(key)) {
          notes.add(value);
          continue;
        }

        // Job title explicit
        if (RegExp(r'^(poste|fonction|title|role)$', caseSensitive: false)
            .hasMatch(key)) {
          result.putIfAbsent('jobTitle', () => value);
          continue;
        }

        // Company explicit
        if (RegExp(r'^(entreprise|societe|société|company|organisation)$',
                caseSensitive: false)
            .hasMatch(key)) {
          result.putIfAbsent('company', () => value);
          continue;
        }
      }

      // Hashtag-style tags anywhere in the line
      final hashtagMatches =
          RegExp(r'#([\p{L}\p{N}_\-]+)', unicode: true).allMatches(line);
      if (hashtagMatches.isNotEmpty) {
        for (final m in hashtagMatches) {
          tags.add(m.group(1)!);
        }
        final stripped =
            line.replaceAll(RegExp(r'#([\p{L}\p{N}_\-]+)', unicode: true), '')
                .trim();
        if (stripped.isEmpty) continue;
      }

      // Skip obvious address lines
      if (RegExp(r'\b(rue|avenue|boulevard|bp|boîte|cedex|street|road|box)\b',
              caseSensitive: false)
          .hasMatch(line)) {
        continue;
      }
      if (RegExp(r'\b\d{4,6}\b').hasMatch(line) && line.length > 15) {
        continue;
      }

      leftover.add(line);
    }

    if (email != null) result['email'] = email;
    if (phone != null) result['phone'] = phone;

    // ── 3. Name / title / company from leftover lines ────────────────────
    if (leftover.isNotEmpty) {
      final name = leftover[0];
      final parts = name.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        result['firstName'] = parts.first;
        result['lastName'] = parts.sublist(1).join(' ');
      } else {
        result['lastName'] = name;
      }
    }

    final titleKeywords = RegExp(
      r'\b(ceo|cto|cfo|coo|cmo|directeur|directrice|manager|head|chef|responsable|ingenieur|ingénieur|engineer|consultant|partner|founder|president|président|associate|analyst|developer|designer|vp|vice)\b',
      caseSensitive: false,
    );

    for (var i = 1; i < leftover.length; i++) {
      final line = leftover[i];
      if (titleKeywords.hasMatch(line)) {
        result.putIfAbsent('jobTitle', () => line);
      } else {
        result.putIfAbsent('company', () => line);
      }
    }

    if (!result.containsKey('jobTitle') && leftover.length > 2) {
      for (var i = 1; i < leftover.length; i++) {
        if (leftover[i] != result['company']) {
          result['jobTitle'] = leftover[i];
          break;
        }
      }
    }

    if (tags.isNotEmpty) {
      // Deduplicate preserving order.
      final seen = <String>{};
      final uniq = tags.where((t) => seen.add(t.toLowerCase())).toList();
      result['tags'] = uniq.join(',');
    }
    if (notes.isNotEmpty) result['notes'] = notes.join('\n');

    return result;
  }

  /// Split "Key: value" or "Key - value" into the two sides.
  /// Returns null if the line doesn't look like a labelled field.
  static (String, String)? _matchKeyValue(String line) {
    final m = RegExp(r'^([\p{L}][\p{L}\p{N}\s\-]{0,30}?)\s*[:\-]\s*(.+)$',
            unicode: true)
        .firstMatch(line);
    if (m == null) return null;
    final key = m.group(1)!.trim();
    final value = m.group(2)!.trim();
    if (value.isEmpty) return null;
    return (key, value);
  }
}
