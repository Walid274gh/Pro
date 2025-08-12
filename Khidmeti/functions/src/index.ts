import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const fcm = admin.messaging();

async function sendToTopic(topic: string, title: string, body: string, data: Record<string, string> = {}) {
  await fcm.send({
    topic,
    notification: { title, body },
    data,
    android: { priority: 'high' },
    apns: { payload: { aps: { contentAvailable: true } } },
  });
}

async function sendToTokens(tokens: string[], title: string, body: string, data: Record<string, string> = {}) {
  if (!tokens.length) return;
  await fcm.sendEachForMulticast({ tokens, notification: { title, body }, data, android: { priority: 'high' } });
}

export const notifyNewRequest = functions.https.onCall(async (req, context) => {
  const requestId = req.requestId as string;
  const cellIds = (req.cellIds as string[]) || [];
  if (!requestId || !Array.isArray(cellIds)) throw new functions.https.HttpsError('invalid-argument', 'Invalid args');

  const title = 'Nouvelle demande près de chez vous';
  const body = 'Un utilisateur a publié une nouvelle demande.';
  const data = { type: 'new_request', requestId };

  await Promise.all(cellIds.map((c) => sendToTopic(`geo_${c}`, title, body, data)));
  return { ok: true };
});

export const notifyRequestAssigned = functions.https.onCall(async (req, context) => {
  const requestId = req.requestId as string;
  const userUid = req.userUid as string;
  const workerUid = req.workerUid as string;
  if (!requestId || !userUid || !workerUid) throw new functions.https.HttpsError('invalid-argument', 'Invalid args');

  const profSnap = await admin.firestore().collection('profiles').doc(userUid).get();
  const tokens: string[] = (profSnap.get('fcmTokens') as string[]) || [];
  const title = 'Votre demande a été acceptée';
  const body = 'Un travailleur a accepté votre demande.';
  const data = { type: 'assigned', requestId, workerUid };
  await sendToTokens(tokens, title, body, data);
  return { ok: true };
});

export const notifyRequestCompleted = functions.https.onCall(async (req, context) => {
  const requestId = req.requestId as string;
  const userUid = req.userUid as string;
  if (!requestId || !userUid) throw new functions.https.HttpsError('invalid-argument', 'Invalid args');

  const profSnap = await admin.firestore().collection('profiles').doc(userUid).get();
  const tokens: string[] = (profSnap.get('fcmTokens') as string[]) || [];
  const title = 'Demande terminée';
  const body = 'Votre demande est marquée comme terminée.';
  const data = { type: 'completed', requestId };
  await sendToTokens(tokens, title, body, data);
  return { ok: true };
});