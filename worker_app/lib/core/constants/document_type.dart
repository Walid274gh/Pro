/// Types de documents d'identité pris en charge pour la vérification.
enum DocumentType {
	idCard('Carte d\'identité'),
	drivingLicense('Permis de conduire'),
	passport('Passeport');

	final String labelFr;
	const DocumentType(this.labelFr);

	String get key => name;

	static DocumentType fromKey(String key) {
		return DocumentType.values.firstWhere(
			(e) => e.name == key,
			orElse: () => DocumentType.idCard,
		);
	}
}