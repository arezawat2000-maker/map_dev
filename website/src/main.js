import { initI18n, t, renderSuccessText } from './i18n.js';

initI18n();

const form = document.getElementById('app-form');
const formShell = document.getElementById('form-shell');
const success = document.getElementById('success');
const anotherBtn = document.getElementById('another-request');
const submitBtn = document.getElementById('submit-btn');
const formStatus = document.getElementById('form-status');

const fields = {
  appName: document.getElementById('app-name'),
  appDescription: document.getElementById('app-description'),
  requesterName: document.getElementById('requester-name'),
  contact: document.getElementById('contact'),
  phoneNumber: document.getElementById('phone-number'),
};

function clearErrors() {
  form.querySelectorAll('.field').forEach((el) => el.classList.remove('is-invalid'));
  form.querySelectorAll('.field__error').forEach((el) => {
    el.hidden = true;
    el.textContent = '';
  });
  formStatus.hidden = true;
  formStatus.textContent = '';
  formStatus.className = 'form-status';
}

function showFieldError(input, message) {
  const field = input.closest('.field');
  const error = document.getElementById(`${input.id}-error`);
  field?.classList.add('is-invalid');
  if (error) {
    error.hidden = false;
    error.textContent = message;
  }
}

function showStatus(message, type = 'error') {
  formStatus.hidden = false;
  formStatus.textContent = message;
  formStatus.className = `form-status is-${type}`;
}

function isValidEmail(value) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

function validate() {
  clearErrors();
  let ok = true;

  const name = fields.appName.value.trim();
  const description = fields.appDescription.value.trim();
  const requesterName = fields.requesterName.value.trim();
  const contact = fields.contact.value.trim();
  const phoneNumber = fields.phoneNumber.value.trim();

  if (!name) {
    showFieldError(fields.appName, t('error_app_name'));
    ok = false;
  }

  if (!description) {
    showFieldError(fields.appDescription, t('error_app_description'));
    ok = false;
  } else if (description.length < 12) {
    showFieldError(fields.appDescription, t('error_app_description_short'));
    ok = false;
  }

  if (!requesterName) {
    showFieldError(fields.requesterName, t('error_requester_name'));
    ok = false;
  }

  if (!contact) {
    showFieldError(fields.contact, t('error_contact_req'));
    ok = false;
  } else if (!isValidEmail(contact)) {
    showFieldError(fields.contact, t('error_contact'));
    ok = false;
  }

  if (!phoneNumber) {
    showFieldError(fields.phoneNumber, t('error_phone'));
    ok = false;
  }

  return ok;
}

async function submitToFirebase(payload) {
  const response = await fetch('https://map-dev-19fb0-default-rtdb.firebaseio.com/requests.json', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      ...payload,
      timestamp: new Date().toISOString()
    }),
  });

  if (!response.ok) {
    throw new Error(t('error_submit'));
  }
}

function showSuccess(appName) {
  form.hidden = true;
  success.hidden = false;
  renderSuccessText(appName);
  formShell.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function resetToForm() {
  success.hidden = true;
  form.hidden = false;
  form.reset();
  clearErrors();
  fields.appName.focus();
}

form?.addEventListener('submit', async (event) => {
  event.preventDefault();
  if (!validate()) {
    const firstInvalid = form.querySelector('.field.is-invalid input, .field.is-invalid textarea');
    firstInvalid?.focus();
    return;
  }

  const payload = {
    app_name: fields.appName.value.trim(),
    app_description: fields.appDescription.value.trim(),
    requester_name: fields.requesterName.value.trim(),
    contact: fields.contact.value.trim(),
    phone_number: fields.phoneNumber.value.trim(),
  };

  submitBtn.classList.add('is-loading');
  submitBtn.setAttribute('aria-busy', 'true');

  try {
    await submitToFirebase(payload);
    showSuccess(payload.app_name);
  } catch (err) {
    showStatus(err.message || t('error_generic'));
  } finally {
    submitBtn.classList.remove('is-loading');
    submitBtn.removeAttribute('aria-busy');
  }
});

anotherBtn?.addEventListener('click', resetToForm);

// Clear field error as the user edits
['appName', 'appDescription', 'requesterName', 'contact', 'phoneNumber'].forEach((key) => {
  fields[key]?.addEventListener('input', () => {
    const field = fields[key].closest('.field');
    const error = document.getElementById(`${fields[key].id}-error`);
    field?.classList.remove('is-invalid');
    if (error) {
      error.hidden = true;
      error.textContent = '';
    }
  });
});

// Typing effect
const typingCode = document.getElementById('typing-code');
const codeStrings = [
  'Initializing MAP.DEV...',
  'function buildApp() {\n  return innovation;\n}',
  'Connecting to mainframe...',
  'Deploying secure scalable solutions...',
  'mapDev.innovate(idea).launch();'
];
let stringIndex = 0;
let charIndex = 0;
let isDeleting = false;

function typeCode() {
  if (!typingCode) return;
  
  const currentString = codeStrings[stringIndex];
  
  if (isDeleting) {
    typingCode.textContent = currentString.substring(0, charIndex - 1);
    charIndex--;
    
    if (charIndex === 0) {
      isDeleting = false;
      stringIndex = (stringIndex + 1) % codeStrings.length;
      setTimeout(typeCode, 500); // Wait before typing next
    } else {
      setTimeout(typeCode, 20); // Fast delete
    }
  } else {
    typingCode.textContent = currentString.substring(0, charIndex + 1);
    charIndex++;
    
    if (charIndex === currentString.length) {
      isDeleting = true;
      // If it's a code block, add some raw highlighting class logic if needed, but plain text works well for cycling.
      setTimeout(typeCode, 2000); // Wait before deleting
    } else {
      setTimeout(typeCode, Math.random() * 40 + 40);
    }
  }
}

// Background terminal log effect
const bgTerminal = document.getElementById('bg-terminal');
const logLines = [
  '[OK] Core system booted.',
  'Load balancer configuring... 100%',
  'Connecting to cluster node #4...',
  'Syncing global state.',
  'Map.dev runtime v4.2 active.',
  'Compiling assets...',
  '[WARN] Trace variance detected (ignored).',
  'Security check: Passed.',
  'Routing incoming connections.',
  'Ready to build.'
];

function addTerminalLog() {
  if (!bgTerminal) return;
  const line = document.createElement('div');
  line.textContent = logLines[Math.floor(Math.random() * logLines.length)];
  bgTerminal.appendChild(line);
  
  if (bgTerminal.childElementCount > 15) {
    bgTerminal.removeChild(bgTerminal.firstChild);
  }
  
  setTimeout(addTerminalLog, Math.random() * 2000 + 500);
}

// Start effects
setTimeout(typeCode, 1000);
setTimeout(addTerminalLog, 500);
