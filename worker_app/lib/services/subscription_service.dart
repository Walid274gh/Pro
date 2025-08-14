import '../domain/entities/subscription.dart';
import '../domain/repositories/subscription_repository.dart';

abstract class SubscriptionService {
	Future<Subscription> getOrCreate(String workerId, String documentHash);
	Future<void> changePlan(String workerId, SubscriptionPlan plan);
	Future<void> recordPayment(String workerId, PaymentRecord payment);
	Stream<Subscription?> watchSubscription(String workerId);
}

class SubscriptionServiceImpl implements SubscriptionService {
	final SubscriptionRepository _repository;
	SubscriptionServiceImpl(this._repository);

	@override
	Future<Subscription> getOrCreate(String workerId, String documentHash) => _repository.getOrCreate(workerId, documentHash);

	@override
	Future<void> changePlan(String workerId, SubscriptionPlan plan) => _repository.changePlan(workerId, plan);

	@override
	Future<void> recordPayment(String workerId, PaymentRecord payment) => _repository.recordPayment(workerId, payment);

	@override
	Stream<Subscription?> watchSubscription(String workerId) => _repository.watchSubscription(workerId);
}