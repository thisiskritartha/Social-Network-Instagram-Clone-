const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onCreateFollowers = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    //1) Create followed User Post ref
    const followedUserPostsRef = admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("userPosts");

    //2) Create following user timeline ref
    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts");

    //3) Get followed User post
    const querySnapshot = await followedUserPostsRef.get();

    //4) Add each user post to following user timeline
    querySnapshot.forEach((doc) => {
      if (!doc.exists) {
        const postId = doc.id;
        const postData = doc.data();
        timelinePostsRef.doc(postId).set(postData);
      }
    });
  });

exports.onDeleteFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onDelete(async (snapshot, context) => {
    console.log("Follower Deleted", snapshot.id);

    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("ownerId", "==", userId);

    const querySnapshot = await timelinePostsRef.get();
    querySnapshot.forEach((doc) => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });
  });

//When post is created, add post to timeline of each follower(of post owner)
exports.onCreatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onCreate(async (snapshot, context) => {
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    //1) Get all the followers of the post who made the post
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();

    //2) Add the new post to each follower's timeline
    querySnapshot.forEach((doc) => {
      const followerId = doc.id;

      admin.firestore
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .set(postCreated);
    });
  });

exports.onUpdate = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onUpdate(async (change, context) => {
    const postUpdated = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    //1) Get all the followers of the post who made the post
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();

    //2) Update each post to each follower's timeline
    querySnapshot.forEach((doc) => {
      const followerId = doc.id;

      admin.firestore
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then((doc) => {
          if (doc.exists) {
            doc.ref.update(postUpdated);
          }
        });
    });
  });

exports.onDeletePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;

    //1) Get all the followers of the post who made the post
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();

    //2) Delete each post to each follower's timeline
    querySnapshot.forEach((doc) => {
      const followerId = doc.id;
      admin.firestore
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then((doc) => {
          if (doc.exists) {
            doc.ref.delete();
          }
        });
    });
  });

exports.onCreateActivityFeedItem = functions.firestore
  .document("/feed/{userId}/feedItems/{activityFeedItem}")
  .onCreate(async (snapshot, context) => {
    //1) Get user connected to feed
    const userId = context.params.userId;

    const userRef = admin.firestore().doc(`users/${userId}`);
    const doc = await userRef.get();

    //2) Once we have user, check if they have notification token. Send Notification if they have token
    const androidNotificationToken = doc.data().androidNotificationToken;
    const createdActivityFeedItem = snapshot.data();

    if (androidNotificationToken) {
      //send Notification
      sendNotification(androidNotificationToken, createdActivityFeedItem);
    } else {
      console.log("No token for User, cannot send Notification.");
    }

    function sendNotification(androidNotificationToken, activityFeedItem) {
      let body;

      //3) switch body value based off of Notification type
      switch (activityFeedItem.type) {
        case "comment":
          body = `${activityFeedItem.username} replied: ${activityFeedItem.commentData}.`;
          break;

        case "like":
          body = `${activityFeedItem.username} liked your post.`;
          break;

        case "follow":
          body = `${activityFeedItem.username} started following you.`;
          break;

        default:
          break;
      }

      //4) Create message for push notification
      const message = {
        Notification: { body },
        token: androidNotificationToken,
        data: { recipient: userId },
      };

      //5) Send message with admin.messaging()
      admin.messaging.send(message).then(response => {
        //Response is a message Id string
        console.log('Successfully sent message', response);
      }).catch(e => {
        console.log('Error sending message', e);
      })
    }
  });
