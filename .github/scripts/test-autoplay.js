const playwright = require('playwright');

const CONFIG = {
  error: { overlaySelector: '#site-error', clickSelector: '#site-error button', initialTitle: 'Internal Server Error' },
  loading: { overlaySelector: '#loading-screen', clickSelector: 'body', initialTitle: 'Loading...' }
};

const overlayType = process.argv[2];
if (!CONFIG[overlayType]) {
  throw new Error(`usage: node test-autoplay.js <${Object.keys(CONFIG).join('|')}> [chromium|firefox|webkit], got "${overlayType}"`);
}
const { overlaySelector, clickSelector, initialTitle } = CONFIG[overlayType];
const cookieSelector = '#cookie-banner';

const browserType = process.argv[3] || 'chromium';
if (!playwright[browserType]) {
  throw new Error(`unknown browser engine "${browserType}", expected chromium, firefox, or webkit`);
}

async function waitFor(page, predicate, { timeout = 5000, interval = 100 } = {}) {
  const start = Date.now();
  while (Date.now() - start < timeout) {
    if (await page.evaluate(predicate)) return true;
    await page.waitForTimeout(interval);
  }
  return false;
}

(async () => {
  const browser = await playwright[browserType].launch();
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
  // The <title> tag is static HTML and always starts as PRE_TITLE
  // ("Loading..." by default) regardless of which state actually gets
  // picked - the page JS has to override it to match, or the tab title
  // says "Loading..." over a page that's showing a 500 error.
  if (initial.title !== initialTitle) {
    throw new Error(`expected initial title "${initialTitle}" for ${overlayType}, got "${initial.title}"`);
  }
  if (!initial.overlayVisible) {
    throw new Error(`expected the ${overlayType} overlay to be visible, but it wasn't`);
  }
  // The cookie banner is site chrome, not a page state - it should always
  // be there regardless of which page state (loading/error) is showing.
  if (!initial.cookieVisible) {
    throw new Error(`expected the cookie banner to be visible alongside ${overlayType}, but it wasn't`);
  }

  // Let the muted autoplay run for a few seconds before clicking, so
  // currentTime has clearly moved past the intro - this is the whole
  // point of the check below: a real visitor rarely clicks instantly,
  // and the payoff should still start from the beginning regardless of
  // how long the decoy held their attention.
  await page.waitForTimeout(3000);
  const beforeClickTime = await page.evaluate(() => document.getElementById('video').currentTime);
  if (beforeClickTime < 1) {
    throw new Error(`expected currentTime to have advanced past 1s after 3s of muted autoplay, got ${beforeClickTime}`);
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
      currentTime: v.currentTime,
      title: document.title,
      overlayVisible: overlay ? !overlay.classList.contains('hidden') : null,
      cookieVisible: cookie ? !cookie.classList.contains('hidden') : null
    };
  }, { sel: overlaySelector, cookieSel: cookieSelector });

  if (after.paused) {
    throw new Error('expected video to still be playing after unmuting');
  }
  // The whole point of a rickroll is the intro - a visitor who takes a
  // while to click shouldn't hear the song mid-way through instead.
  if (after.currentTime >= 1) {
    throw new Error(`expected video to restart from the beginning on reveal, but currentTime was ${after.currentTime}s right after clicking (was ${beforeClickTime}s before)`);
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

  console.log(`OK (${browserType}): ${overlayType} overlay + cookie banner shown, video autoplays muted, and clicking unmutes + hides both`);
  await browser.close();
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
