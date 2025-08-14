/// Enumeration of service categories with French label and emoji.
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

	String get key => name;

	static ServiceCategory fromKey(String key) {
		return ServiceCategory.values.firstWhere(
			(e) => e.name == key,
			orElse: () => ServiceCategory.cleaning,
		);
	}
}