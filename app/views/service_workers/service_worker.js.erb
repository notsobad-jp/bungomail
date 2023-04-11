self.addEventListener('install', function (e) {
  console.log('ServiceWorker install')
});

self.addEventListener('activate', function (e) {
  console.log('ServiceWorker activate')
});

self.addEventListener('push', (event) => {
  const data = JSON.parse(event.data.text());
  const title = data["title"]
  const options = { body: data["body"], icon: data["icon"], data: data["url"] };
  event.waitUntil(self.registration.showNotification(title, options));
  console.log('Webpush received')
});

self.addEventListener('notificationclick', (event) => {
  console.log("Webpush clicked")
  const url = event.notification.data
  event.notification.close();
  clients.openWindow(url);
}, false);
