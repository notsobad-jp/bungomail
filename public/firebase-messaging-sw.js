self.addEventListener('install', function (e) {
  console.log('ServiceWorker install');
});

self.addEventListener('activate', function (e) {
  console.log('ServiceWorker activate');
});

self.addEventListener('push', (event) => {
  const data = JSON.parse(event.data.text());
  const title = data["notification"]["title"];
  const options = {
    body: data["notification"]["body"],
    icon: data["notification"]["image"],
    data: {
      url: data["notification"]["click_action"],
    },
  };
  event.waitUntil(self.registration.showNotification(title, options));
  console.log('Webpush received');
});

self.addEventListener('notificationclick', (event) => {
  console.log("Webpush clicked");
  const url = event.notification.data.url;
  event.notification.close();
  clients.openWindow(url);
}, false);
