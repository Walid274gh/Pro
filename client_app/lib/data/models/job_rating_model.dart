import '../../domain/entities/job_rating.dart';

class JobRatingModel extends JobRating {
	const JobRatingModel({
		required super.jobId,
		required super.clientId,
		required super.workerId,
		required super.stars,
		super.comment,
		super.qualityTags = const <String>[],
		super.mediaUrls = const <String>[],
		required super.createdAt,
	});

	Map<String, dynamic> toMap() {
		return {
			'jobId': jobId,
			'clientId': clientId,
			'workerId': workerId,
			'stars': stars,
			'comment': comment,
			'qualityTags': qualityTags,
			'mediaUrls': mediaUrls,
			'createdAt': createdAt.millisecondsSinceEpoch,
		};
	}

	factory JobRatingModel.fromMap(Map<String, dynamic> map) {
		return JobRatingModel(
			jobId: map['jobId'] as String,
			clientId: map['clientId'] as String,
			workerId: map['workerId'] as String,
			stars: (map['stars'] as num).toInt(),
			comment: map['comment'] as String?,
			qualityTags: _parseStringList(map['qualityTags']),
			mediaUrls: _parseStringList(map['mediaUrls']),
			createdAt: _parseDate(map['createdAt']),
		);
	}

	static List<String> _parseStringList(dynamic value) {
		if (value is List) return value.map((e) => e.toString()).toList();
		return const <String>[];
	}

	static DateTime _parseDate(dynamic v) {
		if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
		if (v is String) {
			final d = DateTime.tryParse(v);
			if (d != null) return d;
		}
		return DateTime.fromMillisecondsSinceEpoch(0);
	}
}