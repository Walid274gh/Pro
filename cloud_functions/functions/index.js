const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

async function sendToUserTokens(collection, userId, payload) {
	const tokensSnap = await db.collection(collection).doc(userId).collection('tokens').get();
	if (tokensSnap.empty) return null;
	const tokens = tokensSnap.docs.map((d) => d.id);
	return admin.messaging().sendMulticast({ tokens, notification: payload });
}

exports.onProposalCreated = functions.firestore
	.document('proposals/{proposalId}')
	.onCreate(async (snap, context) => {
		const data = snap.data();
		const jobId = data.jobId;
		const jobSnap = await db.collection('jobs').doc(jobId).get();
		if (!jobSnap.exists) return null;
		const job = jobSnap.data();
		const clientId = job.clientId;
		// Notify client
		await sendToUserTokens('clients', clientId, {
			title: 'Nouvelle proposition',
			body: 'Un artisan a proposé un prix pour '+(job.title || 'votre demande'),
		});
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
			await sendToUserTokens('workers', workerId, {
				title: 'Proposition acceptée',
				body: 'Le client a accepté votre offre',
			});
			await db.collection('workers').doc(workerId).update({
				'lastAcceptedAt': admin.firestore.FieldValue.serverTimestamp(),
			});
		}
		return null;
	});