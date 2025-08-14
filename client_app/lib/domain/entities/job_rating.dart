class JobRating {
	final String jobId;
	final String clientId;
	final String workerId;
	final int stars; // 1..5
	final String? comment;
	final List<String> qualityTags;
	final List<String> mediaUrls;
	final DateTime createdAt;

	const JobRating({
		required this.jobId,
		required this.clientId,
		required this.workerId,
		required this.stars,
		this.comment,
		this.qualityTags = const <String>[],
		this.mediaUrls = const <String>[],
		required this.createdAt,
	});
}