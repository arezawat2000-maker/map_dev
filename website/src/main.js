import { FORMSPREE_ENDPOINT, FORMSPREE_ID } from './config.js';

const form = document.getElementById('app-form');
const formShell = document.getElementById('form-shell');
const success = document.getElementById('success');
const successAppName = document.getElementById('success-app-name');
const anotherBtn = document.getElementById('another-request');
const submitBtn = document.getElementById('submit-btn');
const formStatus = document.getElementById('form-status');

const fields = {
  appName: document.getElementById('app-name'),
  appDescription: document.getElementById('app-description'),
  requesterName: document.getElementById('requester-name'),
  contact: document.getElementById('contact'),
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
  const contact = fields.contact.value.trim();

  if (!name) {
    showFieldError(fields.appName, 'App name is required.');
    ok = false;
  }

  if (!description) {
    showFieldError(fields.appDescription, 'App description is required.');
    ok = false;
  } else if (description.length < 12) {
    showFieldError(
      fields.appDescription,
      'Please add a bit more detail (at least a short sentence).'
    );
    ok = false;
  }

  if (contact && contact.includes('@') && !isValidEmail(contact)) {
    showFieldError(fields.contact, 'Enter a valid email, or a phone / handle without @.');
    ok = false;
  }

  return ok;
}

function mailtoFallback(payload) {
  const subject = encodeURIComponent(`App request: ${payload.app_name}`);
  const body = encodeURIComponent(
    [
      `App name: ${payload.app_name}`,
      '',
      'Description:',
      payload.app_description,
      '',
      `Requester: ${payload.requester_name || '(not provided)'}`,
      `Contact: ${payload.contact || '(not provided)'}`,
    ].join('\n')
  );
  window.location.href = `mailto:hello@map.dev?subject=${subject}&body=${body}`;
}

function isFormspreeConfigured() {
  return FORMSPREE_ID && FORMSPREE_ID !== 'YOUR_FORM_ID';
}

async function submitToFormspree(payload) {
  const response = await fetch(FORMSPREE_ENDPOINT, {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      ...payload,
      _subject: `MAP.DEV app request: ${payload.app_name}`,
    }),
  });

  const data = await response.json().catch(() => ({}));

  if (!response.ok) {
    const message =
      data?.errors?.map((e) => e.message).join(' ') ||
      data?.error ||
      'Submission failed. Please try again.';
    throw new Error(message);
  }
}

function showSuccess(appName) {
  form.hidden = true;
  success.hidden = false;
  successAppName.textContent = appName;
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
  };

  submitBtn.classList.add('is-loading');
  submitBtn.setAttribute('aria-busy', 'true');

  try {
    if (isFormspreeConfigured()) {
      await submitToFormspree(payload);
      showSuccess(payload.app_name);
    } else {
      showStatus(
        'Form backend not connected yet. Opening your email client as a temporary fallback…',
        'info'
      );
      mailtoFallback(payload);
      // Still show success so the UX is complete during local demos
      window.setTimeout(() => showSuccess(payload.app_name), 600);
    }
  } catch (err) {
    showStatus(err.message || 'Something went wrong. Please try again.');
  } finally {
    submitBtn.classList.remove('is-loading');
    submitBtn.removeAttribute('aria-busy');
  }
});

anotherBtn?.addEventListener('click', resetToForm);

// Clear field error as the user edits
['appName', 'appDescription', 'contact'].forEach((key) => {
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
