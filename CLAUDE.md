## Images

Bandwidth is metered on the hosting plan, so new images added under `static/images/` or `content/images/` must be optimized before committing:

```
scripts/optimize-images.sh <path-to-file-or-dir>
```

This caps width at 1440px, strips metadata, and recompresses (JPEG quality 75; PNG quantized to 256 colors unless it looks photographic). Run it on new images specifically, or with no argument to sweep all of `static/images/`.

Lazy-loading (`loading="lazy"`) is already added automatically to every markdown image via `layouts/_default/_markup/render-image.html` — no action needed there.

Cache headers for images/css/js are set in `render.yaml` (long-lived, immutable) — don't rename image files after publishing a post, since that busts the cache for anyone who already loaded the old one and forces a re-download.
