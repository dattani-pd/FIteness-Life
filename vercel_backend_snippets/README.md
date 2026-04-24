# Vercel backend snippets for Fitness is Life

Copy these into your **stripe-backend** (or main backend) Vercel project so the app can call them.

## Send welcome email (Resend)

After a user successfully purchases a plan, the Flutter app calls:

`POST https://stripe-backend-sigma.vercel.app/api/send-welcome-email`  
Body: `{ "email": "customer@example.com", "planTitle": "12 Weeks Transformation" }`

**Email is always sent TO the customer (receiver = buyer's email).** Sender is the "from" address below.

### Setup

1. **Add the route**  
   Copy `send-welcome-email.js` into your Vercel project’s `api` folder as:
   - `api/send-welcome-email.js`  
   So the route is `/api/send-welcome-email`.

2. **Resend API key**  
   - In [Resend.com](https://resend.com) get your API key.  
   - In Vercel: Project → **Settings** → **Environment Variables** add:
     - Name: `RESEND_API_KEY`  
     - Value: `re_xxxx` (your key)  
   - Redeploy so the function sees the new variable.

3. **Why 403 / "Testing domain restriction"?**  
   With `from: onboarding@resend.dev`, Resend **only allows sending to the email that owns your Resend account**. Any other recipient (e.g. dattanipd@gmail.com if that’s not the account email) gets **403 Forbidden** and no email is delivered.

   **Option A – Quick test:**  
   Sign in to Resend with the same email that should receive the welcome email (e.g. dattanipd@gmail.com). Then `onboarding@resend.dev` can send to that address.

   **Option B – Send to any customer (recommended for production):**  
   - In Resend: **Domains** → add and verify your domain (e.g. fitnessislife.org).  
   - In Vercel: add env var `RESEND_FROM_EMAIL` = e.g. `welcome@fitnessislife.org` (must use your verified domain).  
   - Redeploy. The function will use this “from” address and Resend will allow sending to any recipient.

4. **Use pdraghu1c@gmail.com for now (no domain):**  
   In Vercel → Environment Variables add:
   - **Name:** `RESEND_OVERRIDE_TO`  
   - **Value:** `pdraghu1c@gmail.com`  
   All welcome emails will be sent to this address so you receive them (Resend allows it because it’s your account email). The subject line will include “(customer: buyer@email.com)” so you know who bought. When you verify a domain later, remove `RESEND_OVERRIDE_TO` and set `RESEND_FROM_EMAIL` to send to real customers.

5. **Sender “from”**  
   The snippet uses `onboarding@resend.dev` by default. To use your own domain, add and verify it in Resend, set `RESEND_FROM_EMAIL` in Vercel as above, and redeploy.

After this, when a user completes a purchase in the app, the app will call this endpoint and the customer will receive the welcome email.

## Why am I not receiving the email?

1. **Check the app console (Debug)**  
   After a test purchase, look for:
   - `Welcome email SKIPPED: user has no email` → The logged-in user has no email in Firebase Auth (e.g. phone sign-in). Use an account that has an email, or add email in Firebase Console → Authentication → Users.
   - `Welcome email failed: status=404` → The route is not deployed. Add `api/send-welcome-email.js` to your Vercel project and redeploy.
   - `Welcome email failed: status=500` → Backend error. Set `RESEND_API_KEY` in Vercel → Project → Settings → Environment Variables and redeploy.
   - `Welcome email request error: ...` → Network/URL issue. Confirm the app’s `backendUrl` matches your Vercel URL and the device has internet.

2. **Resend dashboard**  
   In Resend.com → Logs, check if the email was sent or if there’s an error (e.g. invalid API key, domain not verified).

3. **Spam folder**  
   With `from: onboarding@resend.dev`, some inboxes may put the first email in spam. Check spam/junk.
