/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require('firebase-admin');

admin.initializeApp();

exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

exports.messageTest = onRequest((request, response) => {
  const registrationToken = '<REGISTRATION_TOKEN>';
  const title = 'File uploaded.';
  const body = 'File uploaded to Firebase Storage.';

  const message = {
    notification: {
      title: title,
      body: body
    },
    webpush: {
      headers: {
        TTL: "60"
      },
      notification: {
        icon: 'https://bungomail.com/assets/images/logo_text.png',
        click_action: 'https://bungomail.com'
      }
    },
    token: registrationToken
  };

  return admin.messaging().send(message)
    .then((response) => {
      console.log('Successfully sent message:', response);
      return Promise.resolve(response);
    })
    .catch((error) => {
      console.log('Error sending message:', error);
      return Promise.reject(error);
    });
});
