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
    placeholder_contact: 'e.g. hello@example.com',
    label_phone: 'Phone Number',
    placeholder_phone: 'e.g. +1 234 567 8900',
    submit: 'Send request',
    success_title: 'Request received',
    success_text:
      'Thanks — the MAP.DEV team will review {app} and get back to you.',
    another_request: 'Submit another request',
    footer_tag: 'Innovative Software Solutions',
    error_requester_name: 'Name is required.',
    error_app_name: 'App name is required.',
    error_app_description: 'App description is required.',
    error_app_description_short:
      'Please add a bit more detail (at least a short sentence).',
    error_contact_req: 'Email is required.',
    error_contact: 'Enter a valid email.',
    error_phone: 'Phone number is required.',
    error_submit: 'Submission failed. Please try again.',
    error_generic: 'Something went wrong. Please try again.',
    info_mailto:
      'Form backend not connected yet. Opening your email client as a temporary fallback…',
    tech_stack_title: 'Tech Stack',
    features_title: 'Why Choose Us',
    feature_1_title: 'Quality',
    feature_1_desc: 'Top-tier code and performance.',
    feature_2_title: 'Security',
    feature_2_desc: 'Built with safety as a priority.',
    feature_3_title: 'Low Cost',
    feature_3_desc: 'Affordable, scalable solutions.',
    feature_4_title: 'Expert Team',
    feature_4_desc: 'Experienced industry professionals.',
  },
  ckb: {
    document_title: 'MAP.DEV — ئەوەی لە خەیاڵتە بیکە بە ڕاستی',
    meta_description:
      'MAP.DEV — ئەوەی لە خەیاڵتە بیکە بە ڕاستی. داوای دروستکردنی ئەپلیکەیشنی تایبەت بکە لەلایەن تیمەکەمانەوە.',
    skip_link: 'بڕۆ بۆ فۆڕمی داواکاری',
    lang_aria: 'زمان',
    logo_alt: 'لۆگۆی MAP.DEV — هێمای Mی قیبلەنما لەگەڵ دەستی ڕۆبۆت و چیپ',
    hero_eyebrow: 'ئەوەی لە خەیاڵتە بیکە بە ڕاستی',
    hero_tagline:
      'کوالتی و سکویریتی و کەمی نرخ وە بە تیمی شارەزا کار دەکەین',
    hero_cta: 'داواکردنی ئەپ',
    request_title: 'داواکردنی ئەپ',
    request_lead:
      'پێمان بڵێ چیت پێویستە. پێداچوونەوە بۆ داواکارییەکەت دەکەین و هەنگاوەکانی داهاتووت پێ ڕادەگەیەنین.',
    label_app_name: 'ناوی ئەپلیکەیشن',
    placeholder_app_name: 'بۆ نموونە FleetTrack',
    label_app_description: 'وردەکاریی ئەپلیکەیشن',
    placeholder_app_description:
      'ئەپلیکەیشنەکە چی دەکات؟ بۆ کێ دروست دەکرێت؟ چ تایبەتمەندییەکی گرنگی تێدایە؟',
    label_requester_name: 'ناوەکەت',
    placeholder_optional: 'ناوەکەت بنووسە',
    label_contact: 'ئیمەیڵ',
    placeholder_contact: 'بۆ نموونە: hello@example.com',
    label_phone: 'ژمارەی مۆبایل',
    placeholder_phone: 'بۆ نموونە: ٠٧٥٠١٢٣٤٥٦٧',
    submit: 'ناردنی داواکاری',
    success_title: 'داواکارییەکەت گەیشت',
    success_text:
      'سوپاس — تیمی MAP.DEV پێداچوونەوە بۆ {app} دەکات و لە نزیکترین کاتدا پەیوەندیت پێوە دەکەین.',
    another_request: 'ناردنی داواکارییەکی نوێ',
    footer_tag: 'ئەوەی لە خەیاڵتە بیکە بە ڕاستی',
    error_requester_name: 'نووسینی ناو پێویستە.',
    error_app_name: 'نووسینی ناوی ئەپلیکەیشن پێویستە.',
    error_app_description: 'نووسینی وردەکاریی ئەپلیکەیشن پێویستە.',
    error_app_description_short:
      'تکایە وردەکاری زیاتر بنووسە (لانیکەم ڕستەیەکی کورت).',
    error_contact_req: 'نووسینی ئیمەیڵ پێویستە.',
    error_contact: 'ئیمەیڵێکی دروست بنووسە.',
    error_phone: 'نووسینی ژمارەی مۆبایل پێویستە.',
    error_submit: 'ناردنەکە سەرکەوتوو نەبوو. تکایە دووبارە هەوڵ بدەرەوە.',
    error_generic: 'هەڵەیەک ڕوویدا. تکایە دووبارە هەوڵ بدەرەوە.',
    info_mailto:
      'فۆڕمەکە هێشتا نەبەستراوەتەوە. وەک چارەسەرێکی کاتی، ئیمەیڵەکەت دەکرێتەوە بۆ ناردنی داواکارییەکە...',
    tech_stack_title: 'تەکنەلۆژیاکان',
    features_title: 'بۆچی ئێمە هەڵدەبژێریت',
    feature_1_title: 'کوالێتی',
    feature_1_desc: 'باشترین ئاستی کۆد و خێرایی.',
    feature_2_title: 'سکویریتی',
    feature_2_desc: 'بە لەبەرچاوگرتنی ئاسایش دروستکراوە.',
    feature_3_title: 'کەمی نرخ',
    feature_3_desc: 'گونجاو، بۆ هەموو قەبارەیەک.',
    feature_4_title: 'تیمی شارەزا',
    feature_4_desc: 'پڕۆفیشناڵ و خاوەن ئەزموون.',
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
    label_contact: 'البريد الإلكتروني',
    placeholder_contact: 'مثال: hello@example.com',
    label_phone: 'رقم الهاتف',
    placeholder_phone: 'مثال: 07501234567',
    submit: 'إرسال الطلب',
    success_title: 'تم استلام الطلب',
    success_text:
      'شكراً — سيراجع فريق MAP.DEV {app} ويتواصل معك.',
    another_request: 'إرسال طلب آخر',
    footer_tag: 'حلول برمجية مبتكرة',
    error_requester_name: 'الاسم مطلوب.',
    error_app_name: 'اسم التطبيق مطلوب.',
    error_app_description: 'وصف التطبيق مطلوب.',
    error_app_description_short:
      'يرجى إضافة مزيد من التفاصيل (جملة قصيرة على الأقل).',
    error_contact_req: 'البريد الإلكتروني مطلوب.',
    error_contact: 'أدخل بريداً صالحاً.',
    error_phone: 'رقم الهاتف مطلوب.',
    error_submit: 'فشل الإرسال. يرجى المحاولة مرة أخرى.',
    error_generic: 'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
    info_mailto:
      'لم يُوصَل نموذج الإرسال بعد. جارٍ فتح برنامج البريد كحل مؤقت…',
    tech_stack_title: 'التقنيات المستخدمة',
    features_title: 'لماذا تختارنا',
    feature_1_title: 'الجودة',
    feature_1_desc: 'أفضل أداء وكود برمجي.',
    feature_2_title: 'الأمان',
    feature_2_desc: 'مبني مع وضع الأمان كأولوية.',
    feature_3_title: 'تكلفة منخفضة',
    feature_3_desc: 'حلول اقتصادية وقابلة للتطوير.',
    feature_4_title: 'فريق خبير',
    feature_4_desc: 'محترفون وذوو خبرة عالية.',
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
