class SubscriptionPlan {
	final String id; // trial, monthly, yearly
	final int priceDa;
	final int months;
	const SubscriptionPlan(this.id, this.priceDa, this.months);

	static const SubscriptionPlan trial = SubscriptionPlan('trial', 0, 6);
	static const SubscriptionPlan monthly = SubscriptionPlan('monthly', 1000, 1);
	static const SubscriptionPlan yearly = SubscriptionPlan('yearly', 10000, 12);

	static SubscriptionPlan fromId(String id) {
		switch (id) {
			case 'monthly':
				return monthly;
			case 'yearly':
				return yearly;
			default:
				return trial;
		}
	}
}

class PaymentRecord {
	final String paymentId;
	final int amountDa;
	final DateTime paidAt;
	final String method; // card, ccp, cash, etc.

	const PaymentRecord({
		required this.paymentId,
		required this.amountDa,
		required this.paidAt,
		required this.method,
	});
}

class Subscription {
	final String workerId;
	final String documentHash;
	final SubscriptionPlan currentPlan;
	final DateTime trialEndDate;
	final bool hasUsedTrial;
	final List<PaymentRecord> payments;

	const Subscription({
		required this.workerId,
		required this.documentHash,
		required this.currentPlan,
		required this.trialEndDate,
		required this.hasUsedTrial,
		this.payments = const <PaymentRecord>[],
	});
}