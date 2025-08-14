const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.onProposalCreated = functions.firestore
	.document('proposals/{proposalId}')
	.onCreate(async (snap, context) => {
		const data = snap.data();
		const jobId = data.jobId;
		const jobSnap = await db.collection('jobs').doc(jobId).get();
		if (!jobSnap.exists) return null;
		const job = jobSnap.data();
		const clientId = job.clientId;
		// Here you would send a push notification to the client using FCM tokens
		// kept on clients/{clientId}/tokens
		return db.collection('clients').doc(clientId).update({
			'lastProposalAt': admin.firestore.FieldValue.serverTimestamp(),
		});
	});

exports.onJobAccepted = functions.firestore
	.document('jobs/{jobId}')
	.onUpdate(async (change, context) => {
		const before = change.before.data();
		const after = change.after.data();
		if (before.status === 'open' && after.status === 'accepted') {
			const workerId = after.acceptedWorkerId;
			if (!workerId) return null;
			// notify worker about acceptance
			await db.collection('workers').doc(workerId).update({
				'lastAcceptedAt': admin.firestore.FieldValue.serverTimestamp(),
			});
		}
		return null;
	});