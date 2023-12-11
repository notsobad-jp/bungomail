import { Controller } from "@hotwired/stimulus"
import { patch } from '@rails/request.js'

export default class extends Controller {
  static values = {
    vapid: String
  }

  async subscribe() {
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
        applicationServerKey: new Uint8Array(atob(this.vapidValue.replace(/_/g, '/').replace(/-/g, '+')).split("").map((char) => char.charCodeAt(0)))
      })
      await this.updateSubscription(subscription.toJSON());
      alert("通知設定が完了しました！")
      location.reload();
    } catch (error) {
      console.error('Failed to subscribe push notification:', error);
      alert("通知設定に失敗しました。。")
      return;
    }
  }

  async unsubscribe() {
    const serviceWorkerRegistration = await navigator.serviceWorker.ready;
    const subscription = await serviceWorkerRegistration.pushManager.getSubscription();
    if(subscription) {
      await subscription.unsubscribe();
    }

    const params = {
      endpoint: null,
      p256dh: null,
      auth: null
    }
    await this.updateSubscription(params);
    alert("通知設定を解除しました！")
    location.reload();
  }

  async updateSubscription(params) {
    await patch('/user', {
      body: JSON.stringify(params)
    })
  }
}
