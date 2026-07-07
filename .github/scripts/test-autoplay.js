const { chromium } = require('playwright');

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
    const v = document.querySelector('video');
    return !!v && !v.paused;
  });
  if (!startedPlaying) {
    throw new Error('expected video to start autoplaying (muted) within 5s, but it never left the paused state');
  }

  const initial = await page.evaluate(() => {
    const v = document.querySelector('video');
    return { muted: v.muted, title: document.title };
  });
  if (!initial.muted) {
    throw new Error(`expected video to start muted, got muted=${initial.muted}`);
  }
  if (initial.title !== 'Loading...') {
    throw new Error(`expected initial title "Loading...", got "${initial.title}"`);
  }

  await page.mouse.move(100, 100);

  const unmuted = await waitFor(page, () => {
    const v = document.querySelector('video');
    return !!v && !v.muted;
  });
  if (!unmuted) {
    throw new Error('expected video to unmute after mouse movement within 5s, but it is still muted');
  }

  const after = await page.evaluate(() => {
    const v = document.querySelector('video');
    return { paused: v.paused, title: document.title };
  });
  if (after.paused) {
    throw new Error('expected video to still be playing after unmuting');
  }
  if (after.title !== 'Rickroll') {
    throw new Error(`expected title "Rickroll" after interaction, got "${after.title}"`);
  }

  console.log('OK: video autoplays muted and unmutes on first interaction');
  await browser.close();
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
