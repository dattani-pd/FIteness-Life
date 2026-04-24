// functions/index.js
final functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Send notification to ALL users
exports.sendToAllUsers = functions.https.onCall(async (data, context) => {

// Check if caller is admin/trainer
if (!context.auth) {
throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
}

// Optional: Check if user is admin
const userDoc = await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .get();

if (userDoc.data()?.role !== 'admin' && userDoc.data()?.role !== 'trainer') {
throw new functions.https.HttpsError('permission-denied', 'Must be admin or trainer');
}

const { title, body, imageUrl } = data;

// Send to topic
const message = {
notification: {
title: title,
body: body,
imageUrl: imageUrl || null,
},
data: {
click_action: 'FLUTTER_NOTIFICATION_CLICK',
type: 'general',
},
topic: 'all_users', // ✅ This sends to everyone!
};

try {
const response = await admin.messaging().send(message);
console.log('✅ Notification sent successfully:', response);
return { success: true, messageId: response };
} catch (error) {
console.error('❌ Error sending notification:', error);
throw new functions.https.HttpsError('internal', error.message);
}
});

// Send notification to specific user
exports.sendToUser = functions.https.onCall(async (data, context) {

if (!context.auth) {
throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
}

const { userId, title, body } = data;

// Get user's FCM token
const userDoc = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();

const fcmToken = userDoc.data()?.fcmToken;

if (!fcmToken) {
throw new functions.https.HttpsError('not-found', 'User FCM token not found');
}

const message = {
notification: {
title: title,
body: body,
},
token: fcmToken, // ✅ Send to specific device
};

try {
const response = await admin.messaging().send(message);
return { success: true, messageId: response };
} catch (error) {
throw new functions.https.HttpsError('internal', error.message);
}
});