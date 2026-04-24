/**
 * Vercel serverless function: send welcome email after plan purchase (Resend).
 *
 * Add this to your stripe-backend Vercel project:
 *   - If you have an "api" folder: save as api/send-welcome-email.js
 *   - URL will be: https://your-project.vercel.app/api/send-welcome-email
 *
 * Environment Variables (Vercel → Settings → Environment Variables):
 *   RESEND_API_KEY = re_xxxx (required, from Resend.com dashboard)
 *   RESEND_FROM_EMAIL = optional. If set, use this verified domain email as From. If not set, uses onboarding@resend.dev (Resend testing — can only send TO your account email).
 *   RESEND_OVERRIDE_TO = optional. Reply-To (e.g. pdraghu1c@gmail.com). When From = onboarding@resend.dev, From display is "Fitness is Life" only (Resend rejects gmail.com in From). To = customer. Set RESEND_FROM_EMAIL (verified domain) for delivery to customer.
 *
 * Request: POST with JSON body { "email": "user@example.com", "planTitle": "12 Weeks Transformation", "price": 19.99 }
 * To = always customer (ખરીદનાર). From = Fitness is Life <onboarding@resend.dev>. Reply-To = RESEND_OVERRIDE_TO. For delivery to customer, verify domain + set RESEND_FROM_EMAIL.
 */

const RESEND_API_URL = 'https://api.resend.com/emails';

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  const apiKey = process.env.RESEND_API_KEY;
  if (!apiKey) {
    console.error('RESEND_API_KEY is not set in Vercel environment');
    res.status(500).json({ error: 'Email service not configured' });
    return;
  }

  // From = onboarding@resend.dev (no domain verify). From display = "Fitness is Life" only — Resend rejects gmail.com in From.
  const fromAddress = (process.env.RESEND_FROM_EMAIL || 'onboarding@resend.dev').trim();
  const overrideAddr = (process.env.RESEND_OVERRIDE_TO || '').trim();
  const isResendDev = fromAddress.includes('resend.dev');

  const { email, planTitle, price } = req.body || {};
  if (!email || typeof email !== 'string' || !email.trim()) {
    res.status(400).json({ error: 'Missing or invalid email' });
    return;
  }

  const to = email.trim();
  const title = (planTitle && typeof planTitle === 'string') ? planTitle.trim() : 'Your Plan';
  const priceNum = typeof price === 'number' ? price : (typeof price === 'string' ? parseFloat(price) : NaN);
  const hasPrice = !isNaN(priceNum) && priceNum >= 0;
  const priceStr = hasPrice ? `$${priceNum.toFixed(2)}` : '—';
  const namePart = to.includes('@') ? to.split('@')[0].replace(/[._0-9]+/g, ' ').trim() : '';
  const displayName = namePart ? namePart.charAt(0).toUpperCase() + namePart.slice(1) : 'there';

  // To = customer (ખરીદનાર). Sender = Fitness is Life <onboarding@resend.dev> — તમને સender ગમે તે ચાલે.
  const sendTo = to;
  const fromDisplay = isResendDev ? 'Fitness is Life' : (overrideAddr || 'Fitness is Life');
  const fromValue = `"${fromDisplay}" <${fromAddress}>`;

  const html = `
    <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; background: #fff;">
      <div style="background: #6B46C1; color: #fff; padding: 20px 24px; text-align: center;">
        <h1 style="margin: 0; font-size: 22px; font-weight: 600;">Thanks for shopping with us</h1>
      </div>
      <div style="padding: 24px;">
        <p style="margin: 0 0 12px; font-size: 16px; color: #1a1a1a;">Hi ${escapeHtml(displayName)},</p>
        <p style="margin: 0 0 16px; font-size: 16px; color: #333;">We have finished processing your order.</p>
        <p style="margin: 0 0 20px; font-size: 14px; color: #555;">Your plan is now active. Open the app to start your workouts.</p>
        <table style="width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 14px;">
          <thead>
            <tr style="background: #f5f5f5;">
              <th style="text-align: left; padding: 12px; border: 1px solid #e0e0e0;">Product</th>
              <th style="text-align: center; padding: 12px; border: 1px solid #e0e0e0;">Quantity</th>
              <th style="text-align: right; padding: 12px; border: 1px solid #e0e0e0;">Price</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style="padding: 12px; border: 1px solid #e0e0e0;">${escapeHtml(title)}</td>
              <td style="text-align: center; padding: 12px; border: 1px solid #e0e0e0;">1</td>
              <td style="text-align: right; padding: 12px; border: 1px solid #e0e0e0;">${escapeHtml(priceStr)}</td>
            </tr>
          </tbody>
        </table>
        <p style="margin: 8px 0 0; font-size: 14px; color: #333;"><strong>Subtotal:</strong> ${escapeHtml(priceStr)}</p>
        <p style="margin: 4px 0 0; font-size: 14px; color: #333;"><strong>Total:</strong> ${escapeHtml(priceStr)}</p>
        <p style="margin: 24px 0 0; font-size: 13px; color: #666;">— Fitness is Life Team</p>
      </div>
    </div>
  `;

  try {
    const replyToAddr = (process.env.RESEND_OVERRIDE_TO || '').trim();
    const payload = {
      from: fromValue,
      to: [sendTo],
      subject: `Welcome! Your plan "${title}" is active`,
      html,
    };
    if (replyToAddr) payload.reply_to = replyToAddr;

    const response = await fetch(RESEND_API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    const data = await response.json().catch(() => ({}));

    if (!response.ok) {
      console.error('Resend API error:', response.status, data);
      if (response.status === 403) {
        console.error('Resend 403: Verify a domain at resend.com/domains and set RESEND_FROM_EMAIL to an email on that domain.');
        res.status(403).json({
          error: 'Email not sent: Resend requires a verified domain to send to customers.',
          hint: 'Verify a domain at resend.com/domains, then set RESEND_FROM_EMAIL (e.g. noreply@yourdomain.com) in Vercel.',
          resend: data,
        });
        return;
      }
      res.status(response.status).json(data);
      return;
    }

    res.status(200).json({ success: true, id: data.id });
  } catch (err) {
    console.error('Send welcome email error:', err);
    res.status(500).json({ error: 'Failed to send email' });
  }
}

function escapeHtml(text) {
  if (!text) return '';
  const map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
  return text.replace(/[&<>"']/g, (c) => map[c]);
}
