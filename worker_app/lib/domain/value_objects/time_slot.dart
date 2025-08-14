/// Represents a time window within a day in minutes since midnight.
class TimeSlot {
	final int startMinutes;
	final int endMinutes;

	const TimeSlot({required this.startMinutes, required this.endMinutes})
			: assert(startMinutes >= 0 && startMinutes < 24 * 60),
				assert(endMinutes > 0 && endMinutes <= 24 * 60),
				assert(endMinutes > startMinutes);

	bool get isValid =>
		startMinutes >= 0 && endMinutes <= 24 * 60 && endMinutes > startMinutes;

	TimeSlot copyWith({int? startMinutes, int? endMinutes}) {
		return TimeSlot(
			startMinutes: startMinutes ?? this.startMinutes,
			endMinutes: endMinutes ?? this.endMinutes,
		);
	}

	Map<String, dynamic> toJson() => {
		'start': startMinutes,
		'end': endMinutes,
	};

	factory TimeSlot.fromJson(Map<String, dynamic> json) {
		return TimeSlot(
			startMinutes: (json['start'] as num).toInt(),
			endMinutes: (json['end'] as num).toInt(),
		);
	}

	String format() => _formatMinutes(startMinutes)+' - '+_formatMinutes(endMinutes);

	static String _formatMinutes(int minutes) {
		final int h = minutes ~/ 60;
		final int m = minutes % 60;
		final String hs = h.toString().padLeft(2, '0');
		final String ms = m.toString().padLeft(2, '0');
		return hs+':'+ms;
	}

	@override
	int get hashCode => Object.hash(startMinutes, endMinutes);

	@override
	bool operator ==(Object other) =>
		other is TimeSlot &&
			other.startMinutes == startMinutes &&
			other.endMinutes == endMinutes;

	@override
	String toString() => 'TimeSlot('+format()+')';
}