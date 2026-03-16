const CACHE = 'prestart-v4';

// App shell — local files
const LOCAL_ASSETS = [
  '/',
  '/index.html',
  '/dashboard.html',
  '/manifest.json'
];

// CDN scripts the app needs to run
const CDN_ASSETS = [
  'https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js',
  'https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.2.0/umd/react-dom.production.min.js',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.50.0/dist/umd/supabase.min.js'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c =>
      c.addAll([...LOCAL_ASSETS, ...CDN_ASSETS])
    )
  );
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);

  // Supabase API — always network, never cache
  if (url.hostname.includes('supabase.co')) return;

  // Everything else — cache first, fall back to network and cache result
  e.respondWith(
    caches.match(e.request).then(cached => {
      if (cached) return cached;
      return fetch(e.request).then(res => {
        if (res && res.status === 200 && (res.type === 'basic' || res.type === 'cors')) {
          const clone = res.clone();
          caches.open(CACHE).then(c => c.put(e.request, clone));
        }
        return res;
      }).catch(() => {
        // If fetch fails and nothing cached, return offline page
        if (e.request.destination === 'document') {
          return caches.match('/index.html');
        }
      });
    })
  );
});
