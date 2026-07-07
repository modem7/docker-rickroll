const { chromium } = require('playwright');

// A 16:9 video with object-fit: cover looks fine on a wide desktop
// viewport, but on a narrow/portrait one (basically any phone) it has
// to scale up so far to cover the height that it ends up extremely
// cropped/zoomed in. Confirms the aspect-ratio media query correctly
// switches to contain on narrow/portrait viewports and leaves
// cover in place everywhere from small desktop windows up to 4K.
const VIEWPORTS = [
  { name: 'mobile portrait', width: 375, height: 812, expected: 'contain' },
  { name: 'tablet portrait', width: 768, height: 1024, expected: 'contain' },
  { name: 'tablet landscape', width: 1024, height: 768, expected: 'cover' },
  { name: 'small desktop', width: 1280, height: 800, expected: 'cover' },
  { name: '1080p desktop', width: 1920, height: 1080, expected: 'cover' },
  { name: '4K desktop', width: 3840, height: 2160, expected: 'cover' }
];

(async () => {
  const browser = await chromium.launch();

  for (const { name, width, height, expected } of VIEWPORTS) {
    const page = await browser.newPage({ viewport: { width, height } });
    await page.goto('http://localhost:8080/', { waitUntil: 'load' });
    const fit = await page.evaluate(() => {
      const v = document.getElementById('video');
      return getComputedStyle(v).objectFit;
    });
    await page.close();

    if (fit !== expected) {
      throw new Error(`${name} (${width}x${height}): expected object-fit: ${expected}, got "${fit}"`);
    }
    console.log(`OK: ${name} (${width}x${height}) -> object-fit: ${fit}`);
  }

  await browser.close();
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
