import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
	final Locale locale;
	const AppLocalizations(this.locale);

	static const supportedLocales = [Locale('fr'), Locale('en'), Locale('ar')];
	static const localizationsDelegates = [
		GlobalMaterialLocalizations.delegate,
		GlobalWidgetsLocalizations.delegate,
		GlobalCupertinoLocalizations.delegate,
	];

	static final Map<String, Map<String, String>> _values = {
		'fr': {
			'no_jobs': 'Aucun travail',
			'no_conversations': 'Aucune conversation',
			'no_proposals': 'Aucune proposition'
		},
		'en': {
			'no_jobs': 'No jobs',
			'no_conversations': 'No conversations',
			'no_proposals': 'No proposals'
		},
		'ar': {
			'no_jobs': 'لا توجد أعمال',
			'no_conversations': 'لا توجد محادثات',
			'no_proposals': 'لا توجد عروض'
		},
	};

	String t(String key) => _values[locale.languageCode]?[key] ?? _values['fr']![key] ?? key;
}