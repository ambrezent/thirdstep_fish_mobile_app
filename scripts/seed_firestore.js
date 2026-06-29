/**
 * Seed Firestore with initial categories, products, and store settings.
 * Run from project root: node scripts/seed_firestore.js
 * Uses Application Default Credentials (firebase CLI login).
 * Prereq: npm install firebase-admin  (in the scripts dir or globally)
 */

const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: 'freshcatch-uae',
});

const db = admin.firestore();
const now = admin.firestore.Timestamp.now();

const categories = [
  { slug: 'all',       name: 'All Fish',    nameAr: 'كل الأسماك',  color: '#0A1628' },
  { slug: 'hammour',   name: 'Hammour',     nameAr: 'الهامور',     color: '#15803D' },
  { slug: 'shrimp',    name: 'Shrimp',      nameAr: 'الروبيان',    color: '#EA580C' },
  { slug: 'crab',      name: 'Crab',        nameAr: 'السرطان',     color: '#B45309' },
  { slug: 'shellfish', name: 'Shellfish',   nameAr: 'المحار',      color: '#7C3AED' },
  { slug: 'squid',     name: 'Squid',       nameAr: 'الحبار',      color: '#0891B2' },
];

const products = [
  { name: 'Hammour',      nameAr: 'هامور',             family: 'Grouper',      category: 'hammour',   price: 85,  unit: 'kg', stockQty: 50, grossWeight: 3.0, netYield: 0.65, badge: 'bestSeller', imageUrl: '', preOrder: false, cuts: ['whole','headOff','fillet','steaks','cubes'] },
  { name: 'King Crab',    nameAr: 'كراب الملك',         family: 'Crab',         category: 'crab',      price: 120, unit: 'kg', stockQty: 20, grossWeight: 2.5, netYield: 0.50, badge: 'inStock',    imageUrl: '', preOrder: false, cuts: ['whole','cleaned'] },
  { name: 'Tiger Shrimp', nameAr: 'الروبيان النمر',     family: 'Shrimp',       category: 'shrimp',    price: 45,  unit: 'kg', stockQty: 80, grossWeight: 1.2, netYield: 0.75, badge: 'inStock',    imageUrl: '', preOrder: false, cuts: ['whole','cleaned','headOff'] },
  { name: 'Kingfish',     nameAr: 'الكنعد',             family: 'Mackerel',     category: 'all',       price: 55,  unit: 'kg', stockQty: 35, grossWeight: 4.0, netYield: 0.70, badge: 'inStock',    imageUrl: '', preOrder: false, cuts: ['whole','fillet','steaks','cubes'] },
  { name: 'Squid',        nameAr: 'حبار',               family: 'Cephalopod',   category: 'squid',     price: 30,  unit: 'kg', stockQty: 40, grossWeight: 1.0, netYield: 0.80, badge: 'inStock',    imageUrl: '', preOrder: false, cuts: ['whole','cleaned'] },
  { name: 'Red Snapper',  nameAr: 'نقرور',              family: 'Snapper',      category: 'all',       price: 60,  unit: 'kg', stockQty: 25, grossWeight: 2.5, netYield: 0.65, badge: 'inStock',    imageUrl: '', preOrder: false, cuts: ['whole','fillet','steaks'] },
  { name: 'Blue Crab',    nameAr: 'سلطعون أزرق',        family: 'Crab',         category: 'crab',      price: 70,  unit: 'kg', stockQty: 15, grossWeight: 0.5, netYield: 0.35, badge: 'lowStock',   imageUrl: '', preOrder: false, cuts: ['whole','cleaned'] },
  { name: 'Lobster',      nameAr: 'جراد البحر',          family: 'Shellfish',    category: 'shellfish', price: 180, unit: 'kg', stockQty: 0,  grossWeight: 0.8, netYield: 0.45, badge: 'preOrder',   imageUrl: '', preOrder: true,  cuts: ['whole'] },
  { name: 'Seabream',     nameAr: 'الدنيس',             family: 'Sparidae',     category: 'all',       price: 40,  unit: 'kg', stockQty: 30, grossWeight: 1.5, netYield: 0.60, badge: 'inStock',    imageUrl: '', preOrder: false, cuts: ['whole','fillet'] },
  { name: 'Barracuda',    nameAr: 'كوفر',               family: 'Sphyraenidae', category: 'all',       price: 50,  unit: 'kg', stockQty: 20, grossWeight: 3.0, netYield: 0.68, badge: 'inStock',    imageUrl: '', preOrder: false, cuts: ['whole','steaks','cubes'] },
];

const storeSettings = {
  waNumber: '971501234567',           // ← replace with real WhatsApp number
  storeName: 'Third Step Fish Trading',
  storeNameAr: 'ثيرد ستيب لتجارة الأسماك',
  deliveryFee: 15,
  freeDeliveryAbove: 200,
  minOrderValue: 50,
  deliveryWindows: ['9am–12pm', '12pm–3pm', '3pm–6pm', '6pm–9pm'],
  openHours: '8am – 9pm',
  address: 'Dubai, UAE',
  updatedAt: now,
};

async function seed() {
  console.log('\n🌊 Seeding Firestore for freshcatch-uae...\n');

  // Categories (use slug as doc ID for stable references)
  const catBatch = db.batch();
  for (const cat of categories) {
    catBatch.set(db.collection('categories').doc(cat.slug), { ...cat, createdAt: now });
  }
  await catBatch.commit();
  console.log(`  ✅ ${categories.length} categories written`);

  // Products
  const prodBatch = db.batch();
  for (const p of products) {
    prodBatch.set(db.collection('products').doc(), { ...p, createdAt: now });
  }
  await prodBatch.commit();
  console.log(`  ✅ ${products.length} products written`);

  // Store settings
  await db.collection('settings').doc('store').set(storeSettings);
  console.log('  ✅ settings/store written');

  console.log('\n✅ Done! Next steps:');
  console.log('  1. Go to Firebase Console → Firestore → settings/store');
  console.log('  2. Update waNumber with your real WhatsApp number (e.g. 971501234567)');
  console.log('  3. Go to Authentication → Add admin user email');
  console.log('  4. Add that user UID to the "admins" collection');
  process.exit(0);
}

seed().catch(err => { console.error(err); process.exit(1); });
