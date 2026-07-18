# Retail POS Demo deployment

## Build

From the repository root:

```bash
bash tools/build_demo_web.sh
```

Upload only the contents of `build/web/`. Do not upload `lib/`, tests, local
configuration, or the repository itself.

Suggested VPS destination:

```text
/var/www/retail-pos-demo
```

## Nginx

1. Copy `deployment/nginx/retail-pos-demo.conf` to `/etc/nginx/sites-available/`.
2. Change `server_name` if a different demo subdomain is used.
3. Enable it with a symlink in `/etc/nginx/sites-enabled/`.
4. Run `nginx -t`, then reload Nginx.

The configuration preserves static files, avoids caching `index.html`, applies
long-lived caching to fingerprinted/static assets, enables gzip, and routes
unknown application paths back to `index.html`.

## HTTPS

- Cloudflare: enable proxied DNS and Full (strict) TLS after installing an origin certificate.
- Let's Encrypt: point DNS at the VPS, then use Certbot's Nginx installer.

Never expose the origin without a valid certificate once public traffic starts.

## Verification

- Open `/`, complete a transaction, refresh, and verify it remains in history.
- Change theme, refresh, and verify the preference remains.
- Open a nested route directly and refresh it; Nginx should return `index.html`.
- Confirm browser developer tools show no failed asset requests or console errors.

## Browser storage reset

Use **Demo Settings → Reset Demo Data** for a safe application reset. To erase
all local preferences too, clear site data for the demo origin in browser
settings. Hive Web uses origin-scoped browser storage.

## Rollback

Keep the previous `build/web` directory as a timestamped release. To roll back,
switch `/var/www/retail-pos-demo` to the previous release (or restore its files),
then reload Nginx. Because `index.html` is not aggressively cached, visitors
receive the rollback promptly.
