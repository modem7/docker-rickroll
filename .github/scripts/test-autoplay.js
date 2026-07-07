const { chromium } = require('playwright');

const CONFIG = {
  error: { overlaySelector: '#site-error', clickSelector: '#site-error button' },
  loading: { overlaySelector: '#loading-screen', clickSelector: 'body' }
};

const overlayType = process.argv[2];
if (!CONFIG[overlayType]) {
  throw new Error(`usage: node test-autoplay.js <${Object.keys(CONFIG).join('|')}>, got "${overlayType}"`);
}
const { overlaySelector, clickSelector } = CONFIG[overlayType];
const cookieSelector = '#cookie-banner';

async function waitFor(page, predicate, { timeout = 5000, interval = 100 } = {}) {
  const start = Date.now();
  while (Date.now() - start < timeout) {
    if (await page.evaluate(predicate)) return true;
    await page.waitForTimeout(interval);
  }
  return false;
}

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('http://localhost:8080/', { waitUntil: 'load' });

  // Autoplay isn't instantaneous - the browser needs a moment to buffer
  // before playback actually begins, so poll rather than checking once.
  const startedPlaying = await waitFor(page, () => {
    const v = document.getElementById('video');
    return !!v && !v.paused;
  });
  if (!startedPlaying) {
    throw new Error('expected video to start autoplaying (muted) within 5s, but it never left the paused state');
  }

  const initial = await page.evaluate(({ sel, cookieSel }) => {
    const v = document.getElementById('video');
    const overlay = document.querySelector(sel);
    const cookie = document.querySelector(cookieSel);
    return {
      muted: v.muted,
      title: document.title,
      overlayVisible: overlay ? !overlay.classList.contains('hidden') : null,
      cookieVisible: cookie ? !cookie.classList.contains('hidden') : null
    };
  }, { sel: overlaySelector, cookieSel: cookieSelector });

  if (!initial.muted) {
    throw new Error(`expected video to start muted, got muted=${initial.muted}`);
  }
  if (initial.title !== 'Loading...') {
    throw new Error(`expected initial title "Loading...", got "${initial.title}"`);
  }
  if (!initial.overlayVisible) {
    throw new Error(`expected the ${overlayType} overlay to be visible, but it wasn't`);
  }
  // The cookie banner is site chrome, not a page state - it should always
  // be there regardless of which page state (loading/error) is showing.
  if (!initial.cookieVisible) {
    throw new Error(`expected the cookie banner to be visible alongside ${overlayType}, but it wasn't`);
  }

  await page.click(clickSelector);

  const unmuted = await waitFor(page, () => {
    const v = document.getElementById('video');
    return !!v && !v.muted;
  });
  if (!unmuted) {
    throw new Error('expected video to unmute after clicking within 5s, but it is still muted');
  }

  const after = await page.evaluate(({ sel, cookieSel }) => {
    const v = document.getElementById('video');
    const overlay = document.querySelector(sel);
    const cookie = document.querySelector(cookieSel);
    return {
      paused: v.paused,
      title: document.title,
      overlayVisible: overlay ? !overlay.classList.contains('hidden') : null,
      cookieVisible: cookie ? !cookie.classList.contains('hidden') : null
    };
  }, { sel: overlaySelector, cookieSel: cookieSelector });

  if (after.paused) {
    throw new Error('expected video to still be playing after unmuting');
  }
  if (after.title !== 'Rickroll') {
    throw new Error(`expected title "Rickroll" after interaction, got "${after.title}"`);
  }
  if (after.overlayVisible) {
    throw new Error(`expected the ${overlayType} overlay to be hidden after clicking, but it is still visible`);
  }
  if (after.cookieVisible) {
    throw new Error('expected the cookie banner to be hidden after clicking, but it is still visible');
  }

  console.log(`OK: ${overlayType} overlay + cookie banner shown, video autoplays muted, and clicking unmutes + hides both`);
  await browser.close();
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
