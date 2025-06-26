import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import serviceAccount from './serviceAccountKey.json' assert { type: 'json' };

initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

await (async () => {
  try {
    const snap = await db.collection('vehicles').get();
    const batch = db.batch();

    snap.forEach((doc) => {
      const data = doc.data();
      if (!Object.prototype.hasOwnProperty.call(data, 'active')) {
        batch.update(doc.ref, { active: true });
      }
    });

    await batch.commit();
    console.log('✅ Campo "active: true" añadido donde faltaba');
  } catch (error) {
    console.error('❌ Error updating documents:', error);
  }
})();
