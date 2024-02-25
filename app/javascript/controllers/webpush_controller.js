import { Controller } from "@hotwired/stimulus"
import { patch } from '@rails/request.js'
import { initializeApp } from "@firebase/app";
import { getMessaging, getToken } from "@firebase/messaging";


const firebaseConfig = {
  apiKey: "AIzaSyB7Xm2bc55ZXm0t9gRSYQjP9BQ0CsGAZYk",
  authDomain: "bungomail-stg.firebaseapp.com",
  projectId: "bungomail-stg",
  storageBucket: "bungomail-stg.appspot.com",
  messagingSenderId: "265749222801",
  appId: "1:265749222801:web:d7624233427a22e60af630"
};
const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);

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

      const token = await getToken(messaging, {vapidKey: this.vapidValue});
      await this.updateSubscription({token: token});
      alert("通知設定が完了しました！")
      location.reload();
    } catch (error) {
      console.error('Failed to subscribe push notification:', error);
      alert("通知設定に失敗しました。。")
      return;
    }
  }

  async unsubscribe() {
    await this.updateSubscription({token: null});
    alert("通知設定を解除しました！")
    location.reload();
  }

  async updateSubscription(params) {
    await patch('/user', {
      body: JSON.stringify(params)
    })
  }
}
