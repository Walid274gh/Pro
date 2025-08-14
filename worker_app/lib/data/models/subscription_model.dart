import '../../domain/entities/subscription.dart';

class SubscriptionModel extends Subscription {
	const SubscriptionModel({
		required super.workerId,
		required super.documentHash,
		required super.currentPlan,
		required super.trialEndDate,
		required super.hasUsedTrial,
		super.payments = const <PaymentRecord>[],
	});

	Map<String, dynamic> toMap() {
		return {
			'workerId': workerId,
			'documentHash': documentHash,
			'currentPlan': currentPlan.id,
			'trialEndDate': trialEndDate.millisecondsSinceEpoch,
			'hasUsedTrial': hasUsedTrial,
			'payments': payments
				.map((p) => {
					'paymentId': p.paymentId,
					'amountDa': p.amountDa,
					'paidAt': p.paidAt.millisecondsSinceEpoch,
					'method': p.method,
				})
				.toList(),
		};
	}

	factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
		return SubscriptionModel(
			workerId: map['workerId'] as String,
			documentHash: map['documentHash'] as String,
			currentPlan: SubscriptionPlan.fromId(map['currentPlan'] as String),
			trialEndDate: _parseDate(map['trialEndDate']),
			hasUsedTrial: (map['hasUsedTrial'] as bool?) ?? false,
			payments: _parsePayments(map['payments']),
		);
	}

	static List<PaymentRecord> _parsePayments(dynamic list) {
		if (list is List) {
			return list.map((e) {
				final m = Map<String, dynamic>.from(e as Map);
				return PaymentRecord(
					paymentId: m['paymentId'] as String,
					amountDa: (m['amountDa'] as num).toInt(),
					paidAt: _parseDate(m['paidAt']),
					method: m['method'] as String,
				);
			}).toList();
		}
		return const <PaymentRecord>[];
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