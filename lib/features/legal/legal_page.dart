import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/localization.dart';

enum LegalDocument { terms, privacy }

class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key});
  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    children: [
      for (final document in LegalDocument.values)
        TextButton(
          key: ValueKey('legal-${document.name}'),
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => LegalPage(document: document)),
          ),
          child: Text(
            document == LegalDocument.terms
                ? context.l10n.termsOfUse
                : context.l10n.privacyPolicy,
          ),
        ),
    ],
  );
}

/// Documents are bundled, readable offline, and require no vault access.
class LegalPage extends StatefulWidget {
  const LegalPage({super.key, required this.document});
  final LegalDocument document;
  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  String? _language;
  Future<Map<String, dynamic>>? _document;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).toLanguageTag();
    if (_language == language) return;
    _language = language;
    _document = _load(language);
  }

  Future<Map<String, dynamic>> _load(String language) async =>
      jsonDecode(await rootBundle.loadString('assets/legal/$language.json'))
          as Map<String, dynamic>;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.document == LegalDocument.terms
            ? context.l10n.termsOfUse
            : context.l10n.privacyPolicy,
      ),
    ),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _document,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.legalLoadError),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final document = data[widget.document.name] as Map<String, dynamic>;
        return SelectionArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.legalUpdated(data['date'] as String),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),
                      for (final section in document['sections'] as List) ...[
                        Text(
                          section['title'] as String,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(section['body'] as String),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
