/**
 * Form backend configuration
 *
 * Formspree (recommended for static hosting):
 * 1. Create a form at https://formspree.io
 * 2. Replace YOUR_FORM_ID below with your form ID (e.g. "xpwzgkqj")
 * 3. Or set VITE_FORMSPREE_ID in a .env file (never commit secrets)
 */
export const FORMSPREE_ID =
  import.meta.env.VITE_FORMSPREE_ID || 'YOUR_FORM_ID';

export const FORMSPREE_ENDPOINT = `https://formspree.io/f/${FORMSPREE_ID}`;

/**
 * Optional Firebase Web config — only after you add a Web app in Firebase Console
 * for project map-dev-19fb0. Android/iOS configs alone are not enough for the JS SDK.
 * Leave null until you paste real web credentials.
 */
export const FIREBASE_WEB_CONFIG = null;
/* Example once you have a Web app:
export const FIREBASE_WEB_CONFIG = {
  apiKey: '...',
  authDomain: 'map-dev-19fb0.firebaseapp.com',
  projectId: 'map-dev-19fb0',
  storageBucket: 'map-dev-19fb0.firebasestorage.app',
  messagingSenderId: '539706215164',
  appId: '1:539706215164:web:YOUR_WEB_APP_ID',
};
*/
