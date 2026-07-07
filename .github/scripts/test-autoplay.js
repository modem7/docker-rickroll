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

  if (!page.url().endsWith('/video.mp4')) {
    throw new Error(`expected to be redirected straight to /video.mp4, ended up at ${page.url()}`);
  }

  // Autoplay isn't instantaneous - the browser needs a moment to buffer
  // before playback actually begins, so poll rather than checking once.
  const startedPlaying = await waitFor(page, () => {
    const v = document.querySelector('video');
    return !!v && !v.paused;
  });
  if (!startedPlaying) {
    throw new Error('expected video to start playing within 5s, but it never left the paused state');
  }

  const state = await page.evaluate(() => {
    const v = document.querySelector('video');
    return { muted: v.muted, paused: v.paused };
  });
  if (state.muted) {
    throw new Error('expected the video to be playing WITH sound with zero interaction, but it is muted');
  }
  if (state.paused) {
    throw new Error('expected the video to still be playing');
  }

  console.log('OK: video autoplays with sound immediately, no interaction required');
  await browser.close();
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
