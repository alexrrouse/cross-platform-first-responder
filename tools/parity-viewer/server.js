const express = require("express");
const path = require("path");
const fs = require("fs");

const app = express();
const PORT = process.env.PORT || 3474;

// Resolve project root (two levels up from tools/parity-viewer/)
const PROJECT_ROOT = path.resolve(__dirname, "../..");

// Default snapshot directories — override with env vars
const IOS_SNAPSHOT_DIR =
  process.env.IOS_SNAPSHOTS ||
  path.join(PROJECT_ROOT, "ios/TandemEMTTests/__Snapshots__");
const ANDROID_SNAPSHOT_DIR =
  process.env.ANDROID_SNAPSHOTS ||
  path.join(PROJECT_ROOT, "android/app/src/test/snapshots");

const IMAGE_EXTENSIONS = new Set([".png", ".jpg", ".jpeg", ".webp"]);

app.use(express.static(path.join(__dirname, "public")));

// Serve snapshot images from both platform directories
app.use("/snapshots/ios", express.static(IOS_SNAPSHOT_DIR));
app.use("/snapshots/android", express.static(ANDROID_SNAPSHOT_DIR));

/**
 * Recursively collect image files from a directory.
 * Returns paths relative to the base directory.
 */
function collectImages(dir, base = dir) {
  const results = [];
  if (!fs.existsSync(dir)) return results;

  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results.push(...collectImages(fullPath, base));
    } else if (IMAGE_EXTENSIONS.has(path.extname(entry.name).toLowerCase())) {
      results.push(path.relative(base, fullPath));
    }
  }
  return results;
}

/**
 * Normalize a snapshot filename for matching across platforms.
 * Strips directory prefixes, extensions, and common platform suffixes.
 */
function normalizeKey(relativePath) {
  const basename = path.basename(relativePath, path.extname(relativePath));
  // Strip common platform-specific suffixes/prefixes
  return basename
    .replace(/[-_]?(ios|android|iPhone|iPad|pixel|device)[-_]?/gi, "")
    .replace(/[-_]?\d+x\d+/g, "") // strip resolution suffixes like _375x812
    .replace(/[-_]+/g, "_")
    .replace(/^_|_$/g, "")
    .toLowerCase();
}

/**
 * GET /api/snapshots
 * Returns paired and unpaired snapshots for the sidebar.
 */
app.get("/api/snapshots", (_req, res) => {
  const iosImages = collectImages(IOS_SNAPSHOT_DIR);
  const androidImages = collectImages(ANDROID_SNAPSHOT_DIR);

  // Build lookup maps by normalized key
  const iosMap = new Map();
  for (const img of iosImages) {
    iosMap.set(normalizeKey(img), img);
  }
  const androidMap = new Map();
  for (const img of androidImages) {
    androidMap.set(normalizeKey(img), img);
  }

  // Collect all unique keys
  const allKeys = new Set([...iosMap.keys(), ...androidMap.keys()]);
  const pairs = [];

  for (const key of [...allKeys].sort()) {
    const iosFile = iosMap.get(key) || null;
    const androidFile = androidMap.get(key) || null;
    pairs.push({
      key,
      label: iosFile || androidFile,
      ios: iosFile ? `/snapshots/ios/${iosFile}` : null,
      android: androidFile ? `/snapshots/android/${androidFile}` : null,
    });
  }

  res.json({
    iosDir: IOS_SNAPSHOT_DIR,
    androidDir: ANDROID_SNAPSHOT_DIR,
    iosCount: iosImages.length,
    androidCount: androidImages.length,
    pairedCount: pairs.filter((p) => p.ios && p.android).length,
    pairs,
  });
});

/**
 * GET /api/config
 * Returns the current configuration.
 */
app.get("/api/config", (_req, res) => {
  res.json({
    iosDir: IOS_SNAPSHOT_DIR,
    androidDir: ANDROID_SNAPSHOT_DIR,
    projectRoot: PROJECT_ROOT,
  });
});

app.listen(PORT, () => {
  console.log(`\n  🔍 Parity Viewer running at http://localhost:${PORT}\n`);
  console.log(`  iOS snapshots:     ${IOS_SNAPSHOT_DIR}`);
  console.log(`  Android snapshots: ${ANDROID_SNAPSHOT_DIR}`);
  console.log(
    `\n  Override paths with IOS_SNAPSHOTS and ANDROID_SNAPSHOTS env vars.\n`
  );
});
