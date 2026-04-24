/**
 * Vercel serverless function: WooCommerce Order → Firestore sync
 * Webhook: WooCommerce "Order created" / "Order completed"
 * Expects: FIREBASE_SERVICE_ACCOUNT_JSON in Vercel env (full JSON string of service account key)
 */

const admin = require('firebase-admin');

function getFirestore() {
  if (admin.apps.length > 0) {
    return admin.firestore();
  }
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!raw || typeof raw !== 'string') {
    throw new Error('FIREBASE_SERVICE_ACCOUNT_JSON is not set or invalid');
  }
  let cred;
  try {
    cred = JSON.parse(raw);
  } catch (e) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT_JSON is not valid JSON');
  }
  admin.initializeApp({ credential: admin.credential.cert(cred) });
  return admin.firestore();
}

function parseBody(req) {
  const contentType = (req.headers['content-type'] || '').toLowerCase();
  if (contentType.includes('application/json') && typeof req.body === 'object' && req.body !== null) {
    return req.body;
  }
  if (typeof req.body === 'string') {
    try {
      return JSON.parse(req.body);
    } catch {
      return null;
    }
  }
  return null;
}

module.exports = async function handler(req, res) {
  res.setHeader('Content-Type', 'application/json');

  if (req.method !== 'POST') {
    res.status(400).json({
      success: false,
      message: 'Method not allowed. Use POST.',
    });
    return;
  }

  const body = parseBody(req);
  if (!body) {
    res.status(400).json({
      success: false,
      message: 'Invalid or missing JSON body.',
    });
    return;
  }

  const billingEmail = body.billing?.email || body.billing_email;
  if (!billingEmail || typeof billingEmail !== 'string') {
    res.status(400).json({
      success: false,
      message: 'Missing billing.email or billing_email in request body.',
    });
    return;
  }

  const lineItems = body.line_items;
  if (!Array.isArray(lineItems) || lineItems.length === 0) {
    res.status(400).json({
      success: false,
      message: 'Missing or empty line_items array.',
    });
    return;
  }

  const plansToAdd = [];
  for (const item of lineItems) {
    const productId = item.product_id;
    const productName = item.name ?? item.product_name ?? '';
    if (productId == null) continue;
    plansToAdd.push({
      planId: String(productId),
      planTitle: String(productName),
    });
  }

  if (plansToAdd.length === 0) {
    res.status(400).json({
      success: false,
      message: 'No valid line_items with product_id found.',
    });
    return;
  }

  let db;
  try {
    db = getFirestore();
  } catch (err) {
    console.error('Firebase init error:', err.message);
    res.status(500).json({
      success: false,
      message: 'Server configuration error: ' + (err.message || 'Failed to initialize Firebase'),
    });
    return;
  }

  const usersRef = db.collection('users');
  const userPurchasesRef = db.collection('user_purchases');
  const normalizedEmail = (billingEmail || '').trim().toLowerCase();
  if (!normalizedEmail) {
    res.status(400).json({
      success: false,
      message: 'Billing email is empty after normalization.',
    });
    return;
  }

  try {
    let purchaseDocId = null;
    let isPlaceholder = false;

    // 1) Existing app user: find by normalized email (or emailLower if set)
    const userByEmail = await usersRef.where('email', '==', normalizedEmail).limit(1).get();
    if (!userByEmail.empty) {
      purchaseDocId = userByEmail.docs[0].id;
    }
    if (!purchaseDocId) {
      const userByEmailLower = await usersRef.where('emailLower', '==', normalizedEmail).limit(1).get();
      if (!userByEmailLower.empty) {
        purchaseDocId = userByEmailLower.docs[0].id;
      }
    }

    // 2) Existing user_purchases doc keyed by email (doc ID = email)
    if (!purchaseDocId) {
      const byDocId = await userPurchasesRef.doc(normalizedEmail).get();
      if (byDocId.exists) {
        purchaseDocId = normalizedEmail;
      }
    }

    // 3) Existing user_purchases doc with email field matching (e.g. doc id is UID but email stored)
    if (!purchaseDocId) {
      const byEmailField = await userPurchasesRef.where('email', '==', normalizedEmail).limit(1).get();
      if (!byEmailField.empty) {
        purchaseDocId = byEmailField.docs[0].id;
      }
    }

    // 4) No existing record: create placeholder user and use its ID
    if (!purchaseDocId) {
      const newUserRef = usersRef.doc();
      await newUserRef.set({
        email: normalizedEmail,
        emailLower: normalizedEmail,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        isPlaceholder: true,
      });
      purchaseDocId = newUserRef.id;
      isPlaceholder = true;
    }

    const plansRef = userPurchasesRef.doc(purchaseDocId).collection('plans');
    const batch = db.batch();

    for (const plan of plansToAdd) {
      const planRef = plansRef.doc();
      batch.set(planRef, {
        planId: plan.planId,
        planTitle: plan.planTitle,
        purchasedAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'active',
      });
    }

    // Optional: ensure user_purchases doc has email for future lookups (merge)
    const purchaseDocRef = userPurchasesRef.doc(purchaseDocId);
    batch.set(purchaseDocRef, {
      email: normalizedEmail,
      lastPurchaseAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    await batch.commit();

    res.status(200).json({
      success: true,
      message: isPlaceholder ? 'Placeholder user created and purchase saved.' : 'user_purchases updated; plans appended.',
      email: normalizedEmail,
      purchaseDocId,
      isPlaceholder,
      plansAdded: plansToAdd.length,
    });
  } catch (err) {
    console.error('Firestore error:', err);
    res.status(500).json({
      success: false,
      message: 'Database error: ' + (err.message || 'Unknown error'),
    });
  }
};
