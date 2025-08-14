import '../entities/subscription.dart';

abstract class SubscriptionRepository {
	Future<Subscription> getOrCreate(String workerId, String documentHash);
	Future<void> changePlan(String workerId, SubscriptionPlan plan);
	Future<void> recordPayment(String workerId, PaymentRecord payment);
	Stream<Subscription?> watchSubscription(String workerId);
}