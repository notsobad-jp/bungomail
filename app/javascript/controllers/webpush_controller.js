import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    vapid: String
  }

  async subscribe(event) {
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      alert("申し訳ありませんがお使いのブラウザではプッシュ通知がサポートされていないようです。。")
      return;
    }

    try {
      const permission = await Notification.requestPermission();
      if (permission !== 'granted') {
        alert("プッシュ通知がブロックされています。ブラウザの設定でプッシュ通知を許可してください。")
        return;
      }

      const serviceWorkerRegistration = await navigator.serviceWorker.ready;
      const subscription = await serviceWorkerRegistration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: new Uint8Array(this.vapidValue)
      })
      const response = await sendSubscriptionToServer(subscription.toJSON());
      console.log(response.status + ':' + response.statusText);
      alert("通知設定が完了しました！")
      location.reload();
    } catch (error) {
      console.error('Failed to subscribe push notification:', error);
      alert("通知設定に失敗しました。。")
      return;
    }
  }

  unsubscribe(event) {
    console.log("unsubscribe")
  }

  sendSubscriptionToServer() {
    return;
  }
}