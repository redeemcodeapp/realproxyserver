# TERRA BOX Dashboard — starter project

यह शुरुआती प्रोजेक्ट है, पूरा production-ready system नहीं। इसे ऑनलाइन करने से पहले SQL/RLS policies को अपने Supabase project में लागू करके अलग-अलग Admin और Creator accounts से permissions टेस्ट करें।

## क्या मौजूद है
- Creator login और केवल खुद के metrics देखने वाला dashboard
- अलग admin route: `/owner-portal-7f3a` (इसे गुप्त रखना केवल अतिरिक्त layer है; असली सुरक्षा role/RLS है)
- Admin metrics update interface
- Clicks, Downloads, Amount (₹), Withdrawal fields
- Supabase database schema और RLS policies का starter SQL

## अभी जो मैन्युअल सेटअप चाहिए
1. Supabase पर account/project बनाएँ (Free tier quota/idle pause लागू हो सकते हैं).
2. SQL Editor में `supabase.sql` run करें.
3. Supabase Authentication में Admin user create करें. फिर SQL Editor में उसका profile डालें:
   `insert into public.profiles(id,username,role,active) values ('AUTH_USER_UUID','owner','admin',true);`
4. हर Creator को Authentication → Users में add करें, उसके UUID से profile तथा metrics बनाएं:
   `insert into public.profiles(id,username,role,active) values ('CREATOR_AUTH_UUID','creator01','creator',true);`
   `insert into public.metrics(creator_id) values ('CREATOR_AUTH_UUID');`
   Creators को role कभी admin न दें. Creator password उनको सुरक्षित तरीके से साझा करें.
5. `.env.example` को `.env` नाम से copy करके Supabase Project URL और anon/public key भरें. **Service-role secret को frontend में कभी न डालें.**
6. स्थानीय परीक्षण: `npm install`, फिर `npm run dev`.

## Hosting (free tiers, subject to terms/quotas)
Frontend को static host पर deploy करें, जैसे Cloudflare Pages या Netlify; environment variables में `VITE_SUPABASE_URL` और `VITE_SUPABASE_ANON_KEY` set करें. Build command `npm run build`, output folder `dist`.
Supabase Free tier database/auth देता है, लेकिन free project inactivity पर pause हो सकता है और quota सीमाएँ हैं. Custom domain आम तौर पर अलग से खरीदा जाता है; free host subdomain से शुरुआत करें.

## सुरक्षा का महत्वपूर्ण हिस्सा
- Admin URL छिपा होने से अकेले सुरक्षा नहीं मिलती.
- Supabase RLS लागू होना और अलग admin/creator खातों से टेस्ट करना आवश्यक है.
- Admin account पर unique, लंबा password और MFA चालू रखें.
- Admin द्वारा Creator account creation इस starter में अभी Supabase dashboard से manual है; इसे सुरक्षित server-side Edge Function से automate करना अगला चरण होगा. Service-role key केवल server-side secret में रहे.
- यह MVP starter है; live creators/payments के लिए trusted adult/developer द्वारा security review और hosting provider के commercial-use terms जाँचना ज़रूरी है.
