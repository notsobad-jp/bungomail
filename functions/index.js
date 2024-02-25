const logger = require("firebase-functions/logger");
const { onRequest } = require("firebase-functions/v2/https");
const admin = require('firebase-admin');

if (process.env.NODE_ENV === 'production') {
  admin.initializeApp();
} else {
  const serviceAccount = require('./serviceAccountKey.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

exports.subscribeToTopic = onRequest((request, response) => {
  const token = request.query.token;
  const topic = request.query.topic;

  return admin.messaging().subscribeToTopic(token, topic)
    .then((res) => {
      console.log(res)
      return response.send('Successfully subscribed to topic');
    })
    .catch((error) => {
      console.log(error)
      return response.status(500).send('Error subscribing to topic');
    });
});

exports.unsubscribeFromTopic = onRequest((request, response) => {
  const token = request.query.token;
  const topic = request.query.topic;

  return admin.messaging().unsubscribeFromTopic(token, topic)
    .then((res) => {
      console.log(res)
      return response.send('Successfully unsubscribed from topic');
    })
    .catch((error) => {
      console.log(error)
      return response.status(500).send('Error unsubscribing from topic');
    });
});