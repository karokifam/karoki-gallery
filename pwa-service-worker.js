// PWA Service Worker for Karoki Gallery
// This service worker provides caching strategies and offline support

const cacheName = "karoki-gallery-v1";
const urlsToCache = [
  "/",
  "/index.html",
  "/manifest.json",
  "/favicon.png",
  "/flutter_bootstrap.js",
  "/flutter.js",
];

// Install event - cache essential files
self.addEventListener("install", (event) => {
  console.log("Service Worker installing...");
  event.waitUntil(
    caches
      .open(cacheName)
      .then((cache) => {
        console.log("Caching essential files");
        return cache.addAll(urlsToCache);
      })
      .then(() => self.skipWaiting()),
  );
});

// Activate event - clean up old caches
self.addEventListener("activate", (event) => {
  console.log("Service Worker activating...");
  event.waitUntil(
    caches
      .keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cache) => {
            if (cache !== cacheName) {
              console.log("Deleting old cache:", cache);
              return caches.delete(cache);
            }
          }),
        );
      })
      .then(() => self.clients.claim()),
  );
});

// Fetch event - serve from cache, fallback to network
self.addEventListener("fetch", (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip cross-origin requests
  if (url.origin !== location.origin) {
    return;
  }

  // Network first for API calls, cache first for assets
  if (request.method !== "GET") {
    return;
  }

  if (url.pathname.startsWith("/api/") || url.pathname.startsWith("/assets/")) {
    // Network first strategy for API and assets
    event.respondWith(
      fetch(request)
        .then((response) => {
          // Cache successful responses
          if (response.ok) {
            const responseToCache = response.clone();
            caches.open(cacheName).then((cache) => {
              cache.put(request, responseToCache);
            });
          }
          return response;
        })
        .catch(() => {
          // Fall back to cache
          return caches.match(request).then(
            (response) =>
              response ||
              new Response("Offline - resource not available", {
                status: 503,
                statusText: "Service Unavailable",
                headers: new Headers({
                  "Content-Type": "text/plain",
                }),
              }),
          );
        }),
    );
  } else {
    // Cache first strategy for HTML, CSS, JS
    event.respondWith(
      caches
        .match(request)
        .then((response) => {
          if (response) {
            return response;
          }
          return fetch(request).then((response) => {
            // Don't cache non-successful responses
            if (
              !response ||
              response.status !== 200 ||
              response.type !== "basic"
            ) {
              return response;
            }
            const responseToCache = response.clone();
            caches.open(cacheName).then((cache) => {
              cache.put(request, responseToCache);
            });
            return response;
          });
        })
        .catch(() => {
          // Return a fallback page if offline
          return caches.match("/index.html");
        }),
    );
  }
});

// Handle messages from clients
self.addEventListener("message", (event) => {
  if (event.data && event.data.type === "SKIP_WAITING") {
    self.skipWaiting();
  }
});
