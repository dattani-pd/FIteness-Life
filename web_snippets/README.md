# Web (WooCommerce) – Fix Packages Page Image Size

Use this to fix the **Packages** product images on **fitnessislife.org** so they have a fixed height (200px), consistent aspect ratio, and rounded corners.

## Where to add the code

### Option 1: WordPress Customizer (recommended)

1. Log in to **WordPress Admin** for fitnessislife.org.
2. Go to **Appearance → Customize**.
3. Open **Additional CSS**.
4. Copy the entire contents of `woocommerce-packages-image-fix.css` and paste it there.
5. Click **Publish**.

### Option 2: Child theme `style.css`

1. In your theme folder (or child theme), open `style.css`.
2. Paste the contents of `woocommerce-packages-image-fix.css` at the end of the file.
3. Save and upload if needed.

### Option 3: Theme or plugin “Custom CSS”

If your theme or a plugin (e.g. “Simple Custom CSS”) has a “Custom CSS” / “Additional CSS” area, paste the same CSS there and save.

---

## What the CSS does

- Sets product **image height to 200px** on the shop/archive (Packages) loop.
- Uses **object-fit: cover** so images fill the area without stretching.
- Applies **border-radius: 12px** for rounded corners.
- Keeps **placeholder/missing images** at the same 200px height.
- Targets standard WooCommerce classes (e.g. `.woocommerce-loop-product__link`, `.attachment-woocommerce_thumbnail`).

If your theme uses different class names for product images, you may need to inspect the Packages page HTML and add or adjust selectors in the CSS file.
