'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {
    "adview.html": "ee87009cb232c0f5cdeddba2555b3a95",
    "assets/AssetManifest.bin": "f92e107c0ab98a6e4ed433d67d6c60b1",
    "assets/AssetManifest.bin.json": "93774a527c7923c4067f8aef002d0b61",
    "assets/AssetManifest.json": "ea860751f4a4e6c06b444a0ad79c49ca",
    "assets/FontManifest.json": "fdb16fa5a241f69713c054de19a9ca3f",
    "assets/fonts/MaterialIcons-Regular.otf": "42d5ce8b4a6253b43742e4436a8ed233",
    "assets/images/bored.png": "8990a773768e9080d836034df17095dc",
    "assets/images/g_logo.png": "0f118259ce403274f407f5e982e681c3",
    "assets/images/landing_images/matchqrLogo.png": "96c6f91d27d8a3ee0427cd904510151e",
    "assets/images/ops.png": "528c9085bce093ceaaa6582e8ab3efb1",
    "assets/images/stripe_pay.png": "fd1d6340ed211269f7209c31fc5bffdc",
    "assets/images/tenis.png": "f7b2038c60b21723b113454915bdbf85",
    "assets/images/tenis2.png": "3f7f1112479d207e589b2b0ccf1ca745",
    "assets/NOTICES": "9c0aa70608629d24f13675bacee04a05",
    "assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
    "assets/packages/flutter_credit_card/font/halter.ttf": "4e081134892cd40793ffe67fdc3bed4e",
    "assets/packages/flutter_credit_card/icons/amex.png": "f75cabd609ccde52dfc6eef7b515c547",
    "assets/packages/flutter_credit_card/icons/chip.png": "5728d5ac34dbb1feac78ebfded493d69",
    "assets/packages/flutter_credit_card/icons/discover.png": "62ea19837dd4902e0ae26249afe36f94",
    "assets/packages/flutter_credit_card/icons/elo.png": "ffd639816704b9f20b73815590c67791",
    "assets/packages/flutter_credit_card/icons/hipercard.png": "921660ec64a89da50a7c82e89d56bac9",
    "assets/packages/flutter_credit_card/icons/mastercard.png": "7e386dc6c169e7164bd6f88bffb733c7",
    "assets/packages/flutter_credit_card/icons/rupay.png": "a10fbeeae8d386ee3623e6160133b8a8",
    "assets/packages/flutter_credit_card/icons/unionpay.png": "87176915b4abdb3fcc138d23e4c8a58a",
    "assets/packages/flutter_credit_card/icons/visa.png": "f6301ad368219611958eff9bb815abfe",
    "assets/packages/flutter_signin_button/assets/logos/2.0x/facebook_new.png": "83bf0093719b2db2b16e2839aee1069f",
    "assets/packages/flutter_signin_button/assets/logos/2.0x/google_dark.png": "937022ea241c167c8ce463d2ef7ed105",
    "assets/packages/flutter_signin_button/assets/logos/2.0x/google_light.png": "8f10eb93525f0c0259c5e97271796b3c",
    "assets/packages/flutter_signin_button/assets/logos/3.0x/facebook_new.png": "12531aa3541312b7e5ddd41223fc60cb",
    "assets/packages/flutter_signin_button/assets/logos/3.0x/google_dark.png": "ac553491f0002941159b405c2d37e8c6",
    "assets/packages/flutter_signin_button/assets/logos/3.0x/google_light.png": "fe46d37e7d6a16ecd15d5908a795b4ee",
    "assets/packages/flutter_signin_button/assets/logos/facebook_new.png": "e1dff5c319a9d7898aee817f624336e3",
    "assets/packages/flutter_signin_button/assets/logos/google_dark.png": "c32e2778b1d6552b7b4055e49407036f",
    "assets/packages/flutter_signin_button/assets/logos/google_light.png": "f71e2d0b0a2bc7d1d8ab757194a02cac",
    "assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "b37ae0f14cbc958316fac4635383b6e8",
    "assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "5178af1d278432bec8fc830d50996d6f",
    "assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "aa1ec80f1b30a51d64c72f669c1326a7",
    "assets/packages/share_everywhere/icons/facebook.png": "c22a4ee32b54d42a6f5599a866b84ba8",
    "assets/packages/share_everywhere/icons/linkedin.png": "30c453b7f5fbdb09ea0cb42a5dc7a6e5",
    "assets/packages/share_everywhere/icons/twitter.png": "a4dfaf020789cbf745fa5c916e3a107e",
    "assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
    "assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
    "canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
    "canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
    "canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
    "canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
    "canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
    "canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
    "canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
    "favicon.ico": "398accbbc0a287b37d80a4ad462a0b3b",
    "favicon.png": "5dcef449791fa27946b3d35ad8803796",
    "flutter.js": "59a12ab9d00ae8f8096fffc417b6e84f",
    "icons/favicon.png": "6eb551960a858e270460b79506793f85",
    "icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
    "icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
    "icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
    "icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
    "index.html": "b0348df936d1b49508e44124e7a4e3f8",
    "/": "b0348df936d1b49508e44124e7a4e3f8",
    "main.dart.js": "b43218446a55f86e03f797c581a43c1d",
    "manifest.json": "355cb2056ac967a9454a4a85879fe875",
    "robots.txt": "3c7ac8bc2fe3fcab28624d78ab039a54",
    "sitemap.xml": "ac2b279a3bac1ce1dda43b1022049507",
    "success.html": "b120da295b319b3237b594aaad685b94",
    "version.json": "68f2fac4407384e5613c5d624c9b0fa5"
};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
    "index.html",
    "assets/AssetManifest.json",
    "assets/FontManifest.json"
];

self.addEventListener("install", (event) => {
    self.skipWaiting();
    return event.waitUntil(
        caches.open(TEMP).then((cache) => {
            return cache.addAll(Object.values(RESOURCES));
        })
    );
});

self.addEventListener("activate", function(event) {
    return event.waitUntil(async function() {
        try {
            const contentCache = await caches.open(CACHE_NAME);
            const tempCache = await caches.open(TEMP);
            const manifestCache = await caches.open(MANIFEST);

            const manifest = await manifestCache.match('manifest');
            if (!manifest) {
                await caches.delete(CACHE_NAME);
                await contentCache.addAll(await tempCache.keys());
                await caches.delete(TEMP);
                await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
                return;
            }

            const oldManifest = await manifest.json();
            const origin = self.location.origin;

            for (const request of await contentCache.keys()) {
                const key = request.url.substring(origin.length + 1);
                if (!Object.keys(RESOURCES).includes(key) || RESOURCES[key] !== oldManifest[key]) {
                    await contentCache.delete(request);
                }
            }

            await contentCache.addAll(await tempCache.keys());
            await caches.delete(TEMP);
            await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        } catch (err) {
            console.error('Failed to upgrade service worker:', err);
            await caches.delete(CACHE_NAME);
            await caches.delete(TEMP);
            await caches.delete(MANIFEST);
        }
    }());
});

self.addEventListener("fetch", (event) => {
    if (event.request.method !== 'GET') {
        return;
    }

    const origin = self.location.origin;
    const key = event.request.url.substring(origin.length + 1);

    if (!RESOURCES[key]) {
        return;
    }

    event.respondWith(
        caches.match(event.request).then((response) => {
            return response || fetch(event.request).then((response) => {
                if (response && response.ok) {
                    return caches.open(CACHE_NAME).then((cache) => {
                        cache.put(event.request, response.clone());
                        return response;
                    });
                }
                return response;
            });
        })
    );
});