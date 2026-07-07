const { chromium } = require('playwright');

// A 16:9 video with object-fit: cover looks fine on a wide desktop
// viewport, but on a narrow/portrait one (basically any phone) it has
// to scale up so far to cover the height that it ends up extremely
// cropped/zoomed in. Confirms the aspect-ratio media query correctly
// switches to contain on narrow viewports and leaves desktop alone.
(async () => {
  const browser = await chromium.launch();

  const mobilePage = await browser.newPage({ viewport: { width: 375, height: 812 } });
  await mobilePage.goto('http://localhost:8080/', { waitUntil: 'load' });
  const mobileFit = await mobilePage.evaluate(() => {
    const v = document.getElementById('video');
    return getComputedStyle(v).objectFit;
  });
  if (mobileFit !== 'contain') {
    throw new Error(`expected object-fit: contain on a narrow/portrait viewport (375x812), got "${mobileFit}"`);
  }
  await mobilePage.close();

  const desktopPage = await browser.newPage({ viewport: { width: 1280, height: 800 } });
  await desktopPage.goto('http://localhost:8080/', { waitUntil: 'load' });
  const desktopFit = await desktopPage.evaluate(() => {
    const v = document.getElementById('video');
    return getComputedStyle(v).objectFit;
  });
  if (desktopFit !== 'cover') {
    throw new Error(`expected object-fit: cover on a wide desktop viewport (1280x800), got "${desktopFit}"`);
  }
  await desktopPage.close();

  console.log('OK: object-fit is contain on narrow/portrait viewports and cover on wide desktop ones');
  await browser.close();
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
