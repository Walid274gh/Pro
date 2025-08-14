import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/localization/app_localizations.dart';
import 'package:flutter/widgets.dart';

void main() {
	test('AppLocalizations returns FR by default when key missing', () {
		const loc = AppLocalizations(Locale('ar'));
		expect(loc.t('no_jobs').isNotEmpty, true);
		expect(loc.t('unknown_key'), 'unknown_key');
	});
}