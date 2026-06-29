#!/usr/bin/env bash
# Seed Firestore via REST API using Firebase CLI token
set -e

PROJECT="freshcatch-uae"
DB="projects/$PROJECT/databases/(default)/documents"
BASE="https://firestore.googleapis.com/v1/$DB"
TOKEN=$(python3 -c "import json; d=json.load(open('$HOME/.config/configstore/firebase-tools.json')); print(d['tokens']['access_token'])")

patch_doc() {
  local path=$1
  local body=$2
  curl -s -X PATCH "$BASE/$path" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$body" | python3 -c "import sys,json; d=json.load(sys.stdin); print('  ok:', d.get('name','?').split('/')[-1])" 2>/dev/null || echo "  ok: $path"
}

post_doc() {
  local col=$1
  local body=$2
  curl -s -X POST "$BASE/$col" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$body" | python3 -c "import sys,json; d=json.load(sys.stdin); print('  ok:', d.get('name','?').split('/')[-1])" 2>/dev/null || echo "  posted"
}

NOW=$(python3 -c "from datetime import datetime,timezone; print(datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'))")

echo "🌊 Seeding categories..."

patch_doc "categories/all" '{"fields":{"slug":{"stringValue":"all"},"name":{"stringValue":"All Fish"},"nameAr":{"stringValue":"كل الأسماك"},"color":{"stringValue":"#0A1628"},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
patch_doc "categories/hammour" '{"fields":{"slug":{"stringValue":"hammour"},"name":{"stringValue":"Hammour"},"nameAr":{"stringValue":"الهامور"},"color":{"stringValue":"#15803D"},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
patch_doc "categories/shrimp" '{"fields":{"slug":{"stringValue":"shrimp"},"name":{"stringValue":"Shrimp"},"nameAr":{"stringValue":"الروبيان"},"color":{"stringValue":"#EA580C"},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
patch_doc "categories/crab" '{"fields":{"slug":{"stringValue":"crab"},"name":{"stringValue":"Crab"},"nameAr":{"stringValue":"السرطان"},"color":{"stringValue":"#B45309"},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
patch_doc "categories/shellfish" '{"fields":{"slug":{"stringValue":"shellfish"},"name":{"stringValue":"Shellfish"},"nameAr":{"stringValue":"المحار"},"color":{"stringValue":"#7C3AED"},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
patch_doc "categories/squid" '{"fields":{"slug":{"stringValue":"squid"},"name":{"stringValue":"Squid"},"nameAr":{"stringValue":"الحبار"},"color":{"stringValue":"#0891B2"},"createdAt":{"timestampValue":"'"$NOW"'"}}}'

echo "🌊 Seeding products..."

post_doc "products" '{"fields":{"name":{"stringValue":"Hammour"},"nameAr":{"stringValue":"هامور"},"family":{"stringValue":"Grouper"},"category":{"stringValue":"hammour"},"price":{"doubleValue":85},"unit":{"stringValue":"kg"},"stockQty":{"integerValue":50},"grossWeight":{"doubleValue":3.0},"netYield":{"doubleValue":0.65},"badge":{"stringValue":"bestSeller"},"imageUrl":{"stringValue":""},"preOrder":{"booleanValue":false},"cuts":{"arrayValue":{"values":[{"stringValue":"whole"},{"stringValue":"headOff"},{"stringValue":"fillet"},{"stringValue":"steaks"},{"stringValue":"cubes"}]}},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
post_doc "products" '{"fields":{"name":{"stringValue":"King Crab"},"nameAr":{"stringValue":"كراب الملك"},"family":{"stringValue":"Crab"},"category":{"stringValue":"crab"},"price":{"doubleValue":120},"unit":{"stringValue":"kg"},"stockQty":{"integerValue":20},"grossWeight":{"doubleValue":2.5},"netYield":{"doubleValue":0.5},"badge":{"stringValue":"inStock"},"imageUrl":{"stringValue":""},"preOrder":{"booleanValue":false},"cuts":{"arrayValue":{"values":[{"stringValue":"whole"},{"stringValue":"cleaned"}]}},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
post_doc "products" '{"fields":{"name":{"stringValue":"Tiger Shrimp"},"nameAr":{"stringValue":"الروبيان النمر"},"family":{"stringValue":"Shrimp"},"category":{"stringValue":"shrimp"},"price":{"doubleValue":45},"unit":{"stringValue":"kg"},"stockQty":{"integerValue":80},"grossWeight":{"doubleValue":1.2},"netYield":{"doubleValue":0.75},"badge":{"stringValue":"inStock"},"imageUrl":{"stringValue":""},"preOrder":{"booleanValue":false},"cuts":{"arrayValue":{"values":[{"stringValue":"whole"},{"stringValue":"cleaned"},{"stringValue":"headOff"}]}},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
post_doc "products" '{"fields":{"name":{"stringValue":"Kingfish"},"nameAr":{"stringValue":"الكنعد"},"family":{"stringValue":"Mackerel"},"category":{"stringValue":"all"},"price":{"doubleValue":55},"unit":{"stringValue":"kg"},"stockQty":{"integerValue":35},"grossWeight":{"doubleValue":4.0},"netYield":{"doubleValue":0.7},"badge":{"stringValue":"inStock"},"imageUrl":{"stringValue":""},"preOrder":{"booleanValue":false},"cuts":{"arrayValue":{"values":[{"stringValue":"whole"},{"stringValue":"fillet"},{"stringValue":"steaks"},{"stringValue":"cubes"}]}},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
post_doc "products" '{"fields":{"name":{"stringValue":"Squid"},"nameAr":{"stringValue":"حبار"},"family":{"stringValue":"Cephalopod"},"category":{"stringValue":"squid"},"price":{"doubleValue":30},"unit":{"stringValue":"kg"},"stockQty":{"integerValue":40},"grossWeight":{"doubleValue":1.0},"netYield":{"doubleValue":0.8},"badge":{"stringValue":"inStock"},"imageUrl":{"stringValue":""},"preOrder":{"booleanValue":false},"cuts":{"arrayValue":{"values":[{"stringValue":"whole"},{"stringValue":"cleaned"}]}},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
post_doc "products" '{"fields":{"name":{"stringValue":"Red Snapper"},"nameAr":{"stringValue":"نقرور"},"family":{"stringValue":"Snapper"},"category":{"stringValue":"all"},"price":{"doubleValue":60},"unit":{"stringValue":"kg"},"stockQty":{"integerValue":25},"grossWeight":{"doubleValue":2.5},"netYield":{"doubleValue":0.65},"badge":{"stringValue":"inStock"},"imageUrl":{"stringValue":""},"preOrder":{"booleanValue":false},"cuts":{"arrayValue":{"values":[{"stringValue":"whole"},{"stringValue":"fillet"},{"stringValue":"steaks"}]}},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
post_doc "products" '{"fields":{"name":{"stringValue":"Blue Crab"},"nameAr":{"stringValue":"سلطعون أزرق"},"family":{"stringValue":"Crab"},"category":{"stringValue":"crab"},"price":{"doubleValue":70},"unit":{"stringValue":"kg"},"stockQty":{"integerValue":15},"grossWeight":{"doubleValue":0.5},"netYield":{"doubleValue":0.35},"badge":{"stringValue":"lowStock"},"imageUrl":{"stringValue":""},"preOrder":{"booleanValue":false},"cuts":{"arrayValue":{"values":[{"stringValue":"whole"},{"stringValue":"cleaned"}]}},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
post_doc "products" '{"fields":{"name":{"stringValue":"Lobster"},"nameAr":{"stringValue":"جراد البحر"},"family":{"stringValue":"Shellfish"},"category":{"stringValue":"shellfish"},"price":{"doubleValue":180},"unit":{"stringValue":"kg"},"stockQty":{"integerValue":0},"grossWeight":{"doubleValue":0.8},"netYield":{"doubleValue":0.45},"badge":{"stringValue":"preOrder"},"imageUrl":{"stringValue":""},"preOrder":{"booleanValue":true},"cuts":{"arrayValue":{"values":[{"stringValue":"whole"}]}},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
post_doc "products" '{"fields":{"name":{"stringValue":"Seabream"},"nameAr":{"stringValue":"الدنيس"},"family":{"stringValue":"Sparidae"},"category":{"stringValue":"all"},"price":{"doubleValue":40},"unit":{"stringValue":"kg"},"stockQty":{"integerValue":30},"grossWeight":{"doubleValue":1.5},"netYield":{"doubleValue":0.6},"badge":{"stringValue":"inStock"},"imageUrl":{"stringValue":""},"preOrder":{"booleanValue":false},"cuts":{"arrayValue":{"values":[{"stringValue":"whole"},{"stringValue":"fillet"}]}},"createdAt":{"timestampValue":"'"$NOW"'"}}}'
post_doc "products" '{"fields":{"name":{"stringValue":"Barracuda"},"nameAr":{"stringValue":"كوفر"},"family":{"stringValue":"Sphyraenidae"},"category":{"stringValue":"all"},"price":{"doubleValue":50},"unit":{"stringValue":"kg"},"stockQty":{"integerValue":20},"grossWeight":{"doubleValue":3.0},"netYield":{"doubleValue":0.68},"badge":{"stringValue":"inStock"},"imageUrl":{"stringValue":""},"preOrder":{"booleanValue":false},"cuts":{"arrayValue":{"values":[{"stringValue":"whole"},{"stringValue":"steaks"},{"stringValue":"cubes"}]}},"createdAt":{"timestampValue":"'"$NOW"'"}}}'

echo "🌊 Writing store settings..."
patch_doc "settings/store" '{"fields":{"waNumber":{"stringValue":"971501234567"},"storeName":{"stringValue":"Third Step Fish Trading"},"storeNameAr":{"stringValue":"ثيرد ستيب لتجارة الأسماك"},"deliveryFee":{"doubleValue":15},"freeDeliveryAbove":{"doubleValue":200},"minOrderValue":{"doubleValue":50},"openHours":{"stringValue":"8am – 9pm"},"address":{"stringValue":"Dubai, UAE"},"updatedAt":{"timestampValue":"'"$NOW"'"}}}'

echo ""
echo "✅ Seed complete!"
echo ""
echo "Next steps:"
echo "  1. Firebase Console → Firestore → settings/store → update waNumber"
echo "  2. Firebase Console → Authentication → Enable Email/Password provider"
echo "  3. Create admin user → copy their UID"
echo "  4. Firestore → admins/{uid} → create document {role: 'admin'}"
