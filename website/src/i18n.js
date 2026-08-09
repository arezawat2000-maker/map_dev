/**
 * MAP.DEV marketing site i18n
 * Languages: English (en), Central Kurdish / Sorani (ckb), Arabic (ar)
 */

const STORAGE_KEY = 'map-dev-lang';

export const locales = {
  en: { dir: 'ltr', htmlLang: 'en', label: 'English' },
  ckb: { dir: 'rtl', htmlLang: 'ckb', label: 'کوردی' },
  ar: { dir: 'rtl', htmlLang: 'ar', label: 'عربی' },
};

const dictionaries = {
  en: {
    document_title: 'MAP.DEV — Innovative Software Solutions',
    meta_description:
      'MAP.DEV — Innovative software solutions. Request a custom app built with our team.',
    skip_link: 'Skip to request form',
    lang_aria: 'Language',
    logo_alt: 'MAP.DEV logo — compass M emblem with robotic hands and microchip',
    hero_eyebrow: 'INNOVATIVE SOFTWARE SOLUTIONS',
    hero_tagline: 'We build focused, high-impact apps with a team that ships.',
    hero_cta: 'Request an App',
    request_title: 'Request an App',
    request_lead:
      'Tell us what you need. We will review your brief and reply with next steps.',
    label_app_name: 'App name',
    placeholder_app_name: 'e.g. FleetTrack',
    label_app_description: 'App description',
    placeholder_app_description:
      'What should the app do? Who is it for? Any must-have features?',
    label_requester_name: 'Your name',
    placeholder_optional: 'Optional',
    label_contact: 'Email / contact',
    placeholder_contact: 'Optional — so we can reply',
    submit: 'Send request',
    success_title: 'Request received',
    success_text:
      'Thanks — the MAP.DEV team will review {app} and get back to you.',
    another_request: 'Submit another request',
    footer_tag: 'Innovative Software Solutions',
    error_app_name: 'App name is required.',
    error_app_description: 'App description is required.',
    error_app_description_short:
      'Please add a bit more detail (at least a short sentence).',
    error_contact: 'Enter a valid email, or a phone / handle without @.',
    error_submit: 'Submission failed. Please try again.',
    error_generic: 'Something went wrong. Please try again.',
    info_mailto:
      'Form backend not connected yet. Opening your email client as a temporary fallback…',
  },
  ckb: {
    document_title: 'MAP.DEV — چارەسەری نەرمی نوێخوازانە',
    meta_description:
      'MAP.DEV — چارەسەری نەرمی نوێخوازانە. داوای ئەپی تایبەت بکە کە تیمەکەمان بۆت دروست دەکات.',
    skip_link: 'بڕۆ بۆ فۆڕمی داواکاری',
    lang_aria: 'زمان',
    logo_alt: 'لۆگۆی MAP.DEV — هێمای Mی قوڵبنما لەگەڵ دەستی ڕۆبۆت و چیپ',
    hero_eyebrow: 'چارەسەری نەرمی نوێخوازانە',
    hero_tagline:
      'ئێمە ئەپی تایبەت و کاریگەر دروست دەکەین لەگەڵ تیمێک کە کار دەکات و دەیگەیەنێت.',
    hero_cta: 'داوای ئەپ بکە',
    request_title: 'داوای ئەپ',
    request_lead:
      'پێمان بڵێ چیت پێویستە. داواکارییەکەت پێداچوونەوە دەکەین و هەنگاوەکانی دواتر دەنێرینەوە.',
    label_app_name: 'ناوی ئەپ',
    placeholder_app_name: 'بۆ نموونە FleetTrack',
    label_app_description: 'وەسفی ئەپ',
    placeholder_app_description:
      'ئەپەکە چی بکات؟ بۆ کێیە؟ چ تایبەتمەندییەکی پێویستە؟',
    label_requester_name: 'ناوەکەت',
    placeholder_optional: 'ئارەزوومەندانە',
    label_contact: 'ئیمەیڵ / پەیوەندی',
    placeholder_contact: 'ئارەزوومەندانە — بۆ ئەوەی وەڵام بدەینەوە',
    submit: 'ناردنی داواکاری',
    success_title: 'داواکاری وەرگیرا',
    success_text:
      'سوپاس — تیمی MAP.DEV پێداچوونەوە بە {app} دەکات و دەگەڕێتەوە لای تۆ.',
    another_request: 'داواکارییەکی تر بنێرە',
    footer_tag: 'بەرزترین کوالێتی ',
    error_app_name: 'ناوی ئەپ پێویستە.',
    error_app_description: 'وەسفی ئەپ پێویستە.',
    error_app_description_short:
      'تکایە وردەکاری زیاتر بنووسە (لانیکەم ڕستەیەکی کورت).',
    error_contact: 'ئیمەیڵێکی دروست بنووسە، یان ژمارە / هەژمارێک بەبێ @.',
    error_submit: 'ناردن سەرکەوتوو نەبوو. تکایە دووبارە هەوڵ بدە.',
    error_generic: 'شتێک هەڵە ڕوویدا. تکایە دووبارە هەوڵ بدە.',
    info_mailto:
      'پشتەوەی فۆڕم هێشتا پەیوەست نەکراوە. کڕیاری ئیمەیڵەکەت وەک چارەسەری کاتی دەکرێتەوە…',
  },
  ar: {
    document_title: 'MAP.DEV — حلول برمجية مبتكرة',
    meta_description:
      'MAP.DEV — حلول برمجية مبتكرة. اطلب تطبيقاً مخصصاً يبنيه فريقنا.',
    skip_link: 'انتقل إلى نموذج الطلب',
    lang_aria: 'اللغة',
    logo_alt: 'شعار MAP.DEV — رمز M البوصلة مع أيدي روبوتية وشريحة',
    hero_eyebrow: 'حلول برمجية مبتكرة',
    hero_tagline:
      'نبني تطبيقات مركّزة وعالية الأثر مع فريق ينجز ويُسلّم.',
    hero_cta: 'اطلب تطبيقاً',
    request_title: 'اطلب تطبيقاً',
    request_lead:
      'أخبرنا بما تحتاجه. سنراجع ملخصك ونرد عليك بالخطوات التالية.',
    label_app_name: 'اسم التطبيق',
    placeholder_app_name: 'مثال: FleetTrack',
    label_app_description: 'وصف التطبيق',
    placeholder_app_description:
      'ماذا يجب أن يفعل التطبيق؟ لمن هو؟ ما الميزات الأساسية؟',
    label_requester_name: 'اسمك',
    placeholder_optional: 'اختياري',
    label_contact: 'البريد / وسيلة التواصل',
    placeholder_contact: 'اختياري — لنتواصل معك',
    submit: 'إرسال الطلب',
    success_title: 'تم استلام الطلب',
    success_text:
      'شكراً — سيراجع فريق MAP.DEV {app} ويتواصل معك.',
    another_request: 'إرسال طلب آخر',
    footer_tag: 'حلول برمجية مبتكرة',
    error_app_name: 'اسم التطبيق مطلوب.',
    error_app_description: 'وصف التطبيق مطلوب.',
    error_app_description_short:
      'يرجى إضافة مزيد من التفاصيل (جملة قصيرة على الأقل).',
    error_contact: 'أدخل بريداً صالحاً، أو هاتفاً / حساباً بدون @.',
    error_submit: 'فشل الإرسال. يرجى المحاولة مرة أخرى.',
    error_generic: 'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
    info_mailto:
      'لم يُوصَل نموذج الإرسال بعد. جارٍ فتح برنامج البريد كحل مؤقت…',
  },
};

let currentLang = 'en';
let onLanguageChange = null;

export function t(key) {
  return dictionaries[currentLang]?.[key] ?? dictionaries.en[key] ?? key;
}

export function getLang() {
  return currentLang;
}

export function isRtl() {
  return locales[currentLang]?.dir === 'rtl';
}

export function onLangChange(fn) {
  onLanguageChange = fn;
}

function renderSuccessText(appName) {
  const el = document.querySelector('.success__text');
  if (!el) return;

  const template = t('success_text');
  const parts = template.split('{app}');
  el.replaceChildren();

  if (parts[0]) el.append(document.createTextNode(parts[0]));

  const strong = document.createElement('strong');
  strong.id = 'success-app-name';
  strong.textContent = appName || '';
  el.append(strong);

  if (parts[1]) el.append(document.createTextNode(parts[1]));
}

export function applyTranslations() {
  document.querySelectorAll('[data-i18n]').forEach((el) => {
    const key = el.getAttribute('data-i18n');
    if (key) el.textContent = t(key);
  });

  document.querySelectorAll('[data-i18n-placeholder]').forEach((el) => {
    const key = el.getAttribute('data-i18n-placeholder');
    if (key) el.setAttribute('placeholder', t(key));
  });

  document.querySelectorAll('[data-i18n-aria]').forEach((el) => {
    const key = el.getAttribute('data-i18n-aria');
    if (key) el.setAttribute('aria-label', t(key));
  });

  document.querySelectorAll('[data-i18n-alt]').forEach((el) => {
    const key = el.getAttribute('data-i18n-alt');
    if (key) el.setAttribute('alt', t(key));
  });

  document.title = t('document_title');
  const meta = document.querySelector('meta[name="description"]');
  if (meta) meta.setAttribute('content', t('meta_description'));

  const success = document.getElementById('success');
  const successAppName = document.getElementById('success-app-name');
  if (success && !success.hidden) {
    renderSuccessText(successAppName?.textContent || '');
  }

  document.querySelectorAll('[data-lang]').forEach((btn) => {
    const lang = btn.getAttribute('data-lang');
    const active = lang === currentLang;
    btn.setAttribute('aria-pressed', active ? 'true' : 'false');
    btn.classList.toggle('is-active', active);
  });
}

export function setLanguage(lang) {
  if (!dictionaries[lang]) lang = 'en';
  currentLang = lang;

  try {
    localStorage.setItem(STORAGE_KEY, lang);
  } catch {
    /* private mode / blocked storage */
  }

  const meta = locales[lang];
  const html = document.documentElement;
  html.lang = meta.htmlLang;
  html.dir = meta.dir;
  html.dataset.lang = lang;

  applyTranslations();
  onLanguageChange?.(lang);
}

export function initI18n() {
  let initial = 'en';
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved && dictionaries[saved]) initial = saved;
  } catch {
    /* ignore */
  }

  setLanguage(initial);

  const switcher = document.querySelector('.lang-switcher');
  switcher?.addEventListener('click', (event) => {
    const btn = event.target.closest('[data-lang]');
    if (!btn) return;
    const lang = btn.getAttribute('data-lang');
    if (lang && lang !== currentLang) setLanguage(lang);
  });
}

export { renderSuccessText };
