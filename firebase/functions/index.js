const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const kFcmTokensCollection = "fcm_tokens";
const kPushNotificationsCollection = "ff_push_notifications";
const firestore = admin.firestore();

const kPushNotificationRuntimeOpts = {
  timeoutSeconds: 540,
  memory: "2GB",
};

exports.addFcmToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    return "Failed: Unauthenticated calls are not allowed.";
  }
  const userDocPath = data.userDocPath;
  const fcmToken = data.fcmToken;
  const deviceType = data.deviceType;
  if (
    typeof userDocPath === "undefined" ||
    typeof fcmToken === "undefined" ||
    typeof deviceType === "undefined" ||
    userDocPath.split("/").length <= 1 ||
    fcmToken.length === 0 ||
    deviceType.length === 0
  ) {
    return "Invalid arguments encoutered when adding FCM token.";
  }
  if (context.auth.uid != userDocPath.split("/")[1]) {
    return "Failed: Authenticated user doesn't match user provided.";
  }
  const existingTokens = await firestore
    .collectionGroup(kFcmTokensCollection)
    .where("fcm_token", "==", fcmToken)
    .get();
  var userAlreadyHasToken = false;
  for (var doc of existingTokens.docs) {
    const user = doc.ref.parent.parent;
    if (user.path != userDocPath) {
      // Should never have the same FCM token associated with multiple users.
      await doc.ref.delete();
    } else {
      userAlreadyHasToken = true;
    }
  }
  if (userAlreadyHasToken) {
    return "FCM token already exists for this user. Ignoring...";
  }
  await getUserFcmTokensCollection(userDocPath).doc().set({
    fcm_token: fcmToken,
    device_type: deviceType,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  return "Successfully added FCM token!";
});

exports.sendPushNotificationsTrigger = functions
  .runWith(kPushNotificationRuntimeOpts)
  .firestore.document(`${kPushNotificationsCollection}/{id}`)
  .onCreate(async (snapshot, _) => {
    try {
      // Ignore scheduled push notifications on create
      const scheduledTime = snapshot.data().scheduled_time || "";
      if (scheduledTime) {
        return;
      }

      await sendPushNotifications(snapshot);
    } catch (e) {
      console.log(`Error: ${e}`);
      await snapshot.ref.update({ status: "failed", error: `${e}` });
    }
  });

async function sendPushNotifications(snapshot) {
  const notificationData = snapshot.data();
  const title = notificationData.notification_title || "";
  const body = notificationData.notification_text || "";
  const imageUrl = notificationData.notification_image_url || "";
  const sound = notificationData.notification_sound || "";
  const parameterData = notificationData.parameter_data || "";
  const targetAudience = notificationData.target_audience || "";
  const initialPageName = notificationData.initial_page_name || "";
  const userRefsStr = notificationData.user_refs || "";
  const batchIndex = notificationData.batch_index || 0;
  const numBatches = notificationData.num_batches || 0;
  const status = notificationData.status || "";

  if (status !== "" && status !== "started") {
    console.log(`Already processed ${snapshot.ref.path}. Skipping...`);
    return;
  }

  if (title === "" || body === "") {
    await snapshot.ref.update({ status: "failed" });
    return;
  }

  const userRefs = userRefsStr === "" ? [] : userRefsStr.trim().split(",");
  var tokens = new Set();
  if (userRefsStr) {
    for (var userRef of userRefs) {
      const userTokens = await firestore
        .doc(userRef)
        .collection(kFcmTokensCollection)
        .get();
      userTokens.docs.forEach((token) => {
        if (typeof token.data().fcm_token !== undefined) {
          tokens.add(token.data().fcm_token);
        }
      });
    }
  } else {
    var userTokensQuery = firestore.collectionGroup(kFcmTokensCollection);
    // Handle batched push notifications by splitting tokens up by document
    // id.
    if (numBatches > 0) {
      userTokensQuery = userTokensQuery
        .orderBy(admin.firestore.FieldPath.documentId())
        .startAt(getDocIdBound(batchIndex, numBatches))
        .endBefore(getDocIdBound(batchIndex + 1, numBatches));
    }
    const userTokens = await userTokensQuery.get();
    userTokens.docs.forEach((token) => {
      const data = token.data();
      const audienceMatches =
        targetAudience === "All" || data.device_type === targetAudience;
      if (audienceMatches || typeof data.fcm_token !== undefined) {
        tokens.add(data.fcm_token);
      }
    });
  }

  const tokensArr = Array.from(tokens);
  var messageBatches = [];
  for (let i = 0; i < tokensArr.length; i += 500) {
    const tokensBatch = tokensArr.slice(i, Math.min(i + 500, tokensArr.length));
    const messages = {
      notification: {
        title,
        body,
        ...(imageUrl && { imageUrl: imageUrl }),
      },
      data: {
        initialPageName,
        parameterData,
      },
      android: {
        notification: {
          ...(sound && { sound: sound }),
        },
      },
      apns: {
        payload: {
          aps: {
            ...(sound && { sound: sound }),
          },
        },
      },
      tokens: tokensBatch,
    };
    messageBatches.push(messages);
  }

  var numSent = 0;
  await Promise.all(
    messageBatches.map(async (messages) => {
      const response = await admin.messaging().sendMulticast(messages);
      numSent += response.successCount;
    }),
  );

  await snapshot.ref.update({ status: "succeeded", num_sent: numSent });
}

function getUserFcmTokensCollection(userDocPath) {
  return firestore.doc(userDocPath).collection(kFcmTokensCollection);
}

function getDocIdBound(index, numBatches) {
  if (index <= 0) {
    return "userDetails/(";
  }
  if (index >= numBatches) {
    return "userDetails/}";
  }
  const numUidChars = 62;
  const twoCharOptions = Math.pow(numUidChars, 2);

  var twoCharIdx = (index * twoCharOptions) / numBatches;
  var firstCharIdx = Math.floor(twoCharIdx / numUidChars);
  var secondCharIdx = Math.floor(twoCharIdx % numUidChars);
  const firstChar = getCharForIndex(firstCharIdx);
  const secondChar = getCharForIndex(secondCharIdx);
  return "userDetails/" + firstChar + secondChar;
}

function getCharForIndex(charIdx) {
  if (charIdx < 10) {
    return String.fromCharCode(charIdx + "0".charCodeAt(0));
  } else if (charIdx < 36) {
    return String.fromCharCode("A".charCodeAt(0) + charIdx - 10);
  } else {
    return String.fromCharCode("a".charCodeAt(0) + charIdx - 36);
  }
}
const Mux = require("@mux/mux-node");

const kTokenId = "47b50cd4-4a74-4eee-8bd6-cdcbfee9cdc4";
const kTokenSecret =
  "oEQkbVJysm19jlkY3UwkMFmRnK+Kk8A72eWBWbxW1Rqd212ON0YXt++5Be5FVtrk5w3A6z6xtYY";

const { Video } = new Mux(kTokenId, kTokenSecret);

exports.createLiveStream = functions.https.onCall(async (data, context) => {
  try {
    const response = await Video.LiveStreams.create({
      latency_mode: data.latency_mode || "standard",
      playback_policy: "public",
      new_asset_settings: { playback_policy: "public" },
    });
    return response;
  } catch (err) {
    console.error(
      `Unable to start the live stream ${context.auth.uid}. 
          Error ${err}`,
    );
    throw new functions.https.HttpsError(
      "aborted",
      "Could not create live stream",
    );
  }
});

exports.retrieveLiveStreams = functions.https.onCall(async (data, context) => {
  try {
    const liveStreams = await Video.LiveStreams.list();
    const responseList = liveStreams.map((liveStream) => ({
      id: liveStream.id,
      status: liveStream.status,
      playback_ids: liveStream.playback_ids,
      created_at: liveStream.created_at,
    }));
    return responseList;
  } catch (err) {
    console.error(
      `Unable to retrieve live streams. 
          Error ${err}`,
    );
    throw new functions.https.HttpsError(
      "aborted",
      "Could not retrieve live streams",
    );
  }
});

exports.retrieveLiveStream = functions.https.onCall(async (data, context) => {
  try {
    const liveStreamId = data.liveStreamId;
    const liveStream = await Video.LiveStreams.get(liveStreamId);
    return liveStream;
  } catch (err) {
    console.error(
      `Unable to retrieve live stream, id: ${data.liveStreamId}. 
          Error ${err}`,
    );
    throw new functions.https.HttpsError(
      "aborted",
      "Could not retrieve live stream",
    );
  }
});

exports.deleteLiveStream = functions.https.onCall(async (data, context) => {
  try {
    const liveStreamId = data.liveStreamId;
    const response = await Video.LiveStreams.del(liveStreamId);
    return response;
  } catch (err) {
    console.error(
      `Unable to delete live stream, id: ${data.liveStreamId}. 
        Error ${err}`,
    );
    throw new functions.https.HttpsError(
      "aborted",
      "Could not delete live stream",
    );
  }
});
exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  let userRef = firestore.doc("userDetails/" + user.uid);
});
const OneSignal = require("@onesignal/node-onesignal");

const kUserKey = "ODJjMzBlYWYtZmZlNC00YWVmLTg1MGYtOGYwYmRmNWI2ODFm";
const kAPIKey = "YzYyMzE2YjMtZDYyNS00NDkxLWJlYTItNDkwYTFkM2I3YzVl";

const configuration = OneSignal.createConfiguration({
  userKey: kUserKey,
  appKey: kAPIKey,
});
const client = new OneSignal.DefaultApi(configuration);
const user = new OneSignal.User();

exports.addUser = functions.https.onCall(async (data, context) => {
  if (context.auth.uid != data.user_id) {
    return "Unauthenticated calls are not allowed.";
  }
  try {
    user.identity = {
      external_id: data.user_id,
    };
    user.properties = {
      tags: data.tags,
    };
    user.subscriptions = data.subscriptions;
    const createdUser = await client.createUser(
      "acc4c892-1a76-4130-9ccf-a50aa27f8140",
      user,
    );
    if (createdUser.identity["onesignal_id"] == null) {
      throw new functions.https.HttpsError(
        "aborted",
        "Could not create OneSignal user",
      );
    }
    return createdUser;
  } catch (err) {
    console.error(
      `Unable to create user ${context.auth.uid}.
            Error ${err}`,
    );
    throw new functions.https.HttpsError(
      "aborted",
      "Could not create OneSignal user",
    );
  }
});

exports.deleteUser = functions.https.onCall(async (data, context) => {
  if (context.auth.uid != data.user_id) {
    return "Unauthenticated calls are not allowed.";
  }
  try {
    await client.deleteUser(
      "acc4c892-1a76-4130-9ccf-a50aa27f8140",
      "external_id",
      data.user_id,
    );
    return "User deleted";
  } catch (err) {
    console.error(
      `Unable to delete user ${context.auth.uid}.
            Error ${err}`,
    );
    throw new functions.https.HttpsError(
      "aborted",
      "Could not delete OneSignal user",
    );
  }
});
