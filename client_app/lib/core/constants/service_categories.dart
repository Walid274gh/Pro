/// Enumeration des catégories de services avec libellé FR et emoji.
/// Utilisé côté domaine pour typage fort et conversion simple.
enum ServiceCategory {
	plumbing('Plomberie', '🔧'),
	electricity('Électricité', '⚡'),
	cleaning('Nettoyage', '🧽'),
	delivery('Livraison', '📦'),
	painting('Peinture', '🎨'),
	applianceRepair('Réparation électroménager', '🔨'),
	masonry('Maçonnerie', '🧱'),
	airConditioning('Climatisation', '❄️'),
	babysitting('Baby-sitting', '👶'),
	privateLessons('Cours particuliers', '📚');

	final String labelFr;
	final String emoji;
	const ServiceCategory(this.labelFr, this.emoji);

	String get key => name; // stable key for persistence

	static ServiceCategory fromKey(String key) {
		return ServiceCategory.values.firstWhere(
			(e) => e.name == key,
			orElse: () => ServiceCategory.cleaning,
		);
	}
}