const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('http://localhost:8080/', { waitUntil: 'load' });

  const initial = await page.evaluate(() => {
    const v = document.querySelector('video');
    return { muted: v.muted, paused: v.paused, title: document.title };
  });

  if (!initial.muted) {
    throw new Error(`expected video to start muted, got muted=${initial.muted}`);
  }
  if (initial.paused) {
    throw new Error('expected video to be autoplaying immediately, but it is paused');
  }
  if (initial.title !== 'Loading...') {
    throw new Error(`expected initial title "Loading...", got "${initial.title}"`);
  }

  await page.mouse.move(100, 100);
  await page.waitForTimeout(250);

  const after = await page.evaluate(() => {
    const v = document.querySelector('video');
    return { muted: v.muted, paused: v.paused, title: document.title };
  });

  if (after.muted) {
    throw new Error('expected video to unmute after mouse movement, but it is still muted');
  }
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
