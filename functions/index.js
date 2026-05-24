const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

async function getTargetAdminDocs(filterKey) {
  const snapshot = await admin.firestore().collection("admins").get();

  return snapshot.docs.filter((doc) => {
    const data = doc.data() || {};
    const desktopEnabled = data.desktopNotificationsEnabled !== false;
    const filterEnabled = data[filterKey] !== false;
    const token = data.webFcmToken || "";
    return desktopEnabled && filterEnabled && token;
  });
}

async function sendWebPushToAdmins({
  title,
  body,
  data,
  filterKey,
}) {
  const adminDocs = await getTargetAdminDocs(filterKey);

  if (adminDocs.length === 0) {
    console.log("No admin web tokens found.");
    return;
  }

  const messages = adminDocs.map((doc) => {
    const adminData = doc.data() || {};

    return {
      token: adminData.webFcmToken,
      data: {
        title: String(title || "New notification"),
        body: String(body || ""),
        ...Object.fromEntries(
          Object.entries(data || {}).map(([key, value]) => [
            key,
            value == null ? "" : String(value),
          ]),
        ),
        click_action: "/",
      },
    };
  });

  const response = await admin.messaging().sendEach(messages);
  console.log("Admin web push sent:", response);
}

exports.sendNotificationToUser = onDocumentCreated(
    "notifications/{notificationId}",
    async (event) => {
      try {
        const snapshot = event.data;
        if (!snapshot) return;

        const data = snapshot.data();

        const title = data.title || "New Notification";
        const body = data.body || "";
        const userId = data.userId;

        if (!userId) {
          console.log("No userId found.");
          return;
        }

        const userDoc = await admin
            .firestore()
            .collection("users")
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          console.log("User document not found.");
          return;
        }

        const userData = userDoc.data();
        const token = userData?.fcmToken;

        if (!token) {
          console.log("No FCM token found for user:", userId);
          return;
        }

        const message = {
          token: token,
          notification: {
            title: title,
            body: body,
          },
          android: {
            priority: "high",
            notification: {
              channelId: "high_importance_channel",
              sound: "default",
            },
          },
          data: {
            screen: "notifications",
            type: "single_user_notification",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        };

        const response = await admin.messaging().send(message);
        console.log("Successfully sent notification to user:", response);
      } catch (error) {
        console.error("Error sending notification to user:", error);
      }
    },
);

exports.sendBroadcastNotification = onDocumentCreated(
    "broadcast_notifications/{notificationId}",
    async (event) => {
      try {
        const snapshot = event.data;
        if (!snapshot) return;

        const data = snapshot.data();

        const title = data.title || "Broadcast Notification";
        const body = data.body || "";

        const message = {
          topic: "all-users",
          notification: {
            title: title,
            body: body,
          },
          android: {
            priority: "high",
            notification: {
              channelId: "high_importance_channel",
              sound: "default",
            },
          },
          data: {
            screen: "notifications",
            type: "broadcast_notification",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        };

        const response = await admin.messaging().send(message);
        console.log("Successfully sent broadcast notification:", response);
      } catch (error) {
        console.error("Error sending broadcast notification:", error);
      }
    },
);

exports.createAdminNotificationOnSupportEscalation = onDocumentUpdated(
    "support_conversations/{conversationId}",
    async (event) => {
      try {
        const beforeData = event.data?.before?.data();
        const afterData = event.data?.after?.data();

        if (!beforeData || !afterData) {
          console.log("Missing before/after data.");
          return;
        }

        const beforeStatus = beforeData.status || "";
        const afterStatus = afterData.status || "";

        if (beforeStatus === afterStatus) {
          return;
        }

        if (afterStatus !== "waiting_admin") {
          return;
        }

        if (afterData.isDeleted === true) {
          return;
        }

        const conversationId = event.params.conversationId;
        const userId = afterData.userId || "";
        const userName = afterData.userName || "Unknown User";
        const orderId = afterData.orderId || "";
        const orderNumber = afterData.orderNumber || "";
        const issueTitle = afterData.issueTitle || "Support request";

        let body = `${userName} needs help`;
        if (orderNumber) {
          body += ` with order #${orderNumber}`;
        }

        await admin.firestore().collection("admin_notifications").add({
          type: "support_escalated",
          title: "New support case",
          body: body,
          conversationId: conversationId,
          orderId: orderId,
          userId: userId,
          userName: userName,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          source: "support_chat",
          targetStatus: "waiting_admin",
          issueTitle: issueTitle,
        });

        await sendWebPushToAdmins({
          title: "New support case",
          body: body,
          filterKey: "supportNotificationsEnabled",
          data: {
            type: "support_escalated",
            conversationId: conversationId,
            orderId: orderId,
            userId: userId,
            userName: userName,
            source: "support_chat",
            targetStatus: "waiting_admin",
            issueTitle: issueTitle,
          },
        });

        console.log(
            "Admin notification created for escalated conversation:",
            conversationId,
        );
      } catch (error) {
        console.error(
            "Error creating admin notification on support escalation:",
            error,
        );
      }
    },
);

exports.createAdminNotificationOnNewOrder = onDocumentCreated(
    "orders/{orderId}",
    async (event) => {
      try {
        const snapshot = event.data;
        if (!snapshot) return;

        const data = snapshot.data();
        const orderId = event.params.orderId;

        const userId = data.userId || "";
        const orderNumber = data.orderId || orderId;
        const total = Number(data.total || 0);

        let userName = "Unknown User";
        if (userId) {
          const userDoc = await admin
              .firestore()
              .collection("users")
              .doc(userId)
              .get();

          if (userDoc.exists) {
            const userData = userDoc.data() || {};
            userName = userData.name || userData.fullName || "Unknown User";
          }
        }

        const body = `${userName} placed order #${orderNumber} - EGP ${total}`;

        await admin.firestore().collection("admin_notifications").add({
          type: "new_order",
          title: "New order placed",
          body: body,
          conversationId: "",
          orderId: orderId,
          userId: userId,
          userName: userName,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          source: "orders",
          targetStatus: "pending",
          issueTitle: "",
        });

        await sendWebPushToAdmins({
          title: "New order placed",
          body: body,
          filterKey: "orderNotificationsEnabled",
          data: {
            type: "new_order",
            conversationId: "",
            orderId: orderId,
            userId: userId,
            userName: userName,
            source: "orders",
            targetStatus: "pending",
            issueTitle: "",
          },
        });

        console.log("Admin notification created for new order:", orderId);
      } catch (error) {
        console.error("Error creating admin notification on new order:", error);
      }
    },
);