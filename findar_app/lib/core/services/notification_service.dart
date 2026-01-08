import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:findar/core/config/api_config.dart';
import 'package:findar/core/services/findar_api_service.dart';
import 'dart:developer' as developer;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Notification event callbacks
  static Function(RemoteMessage)? onMessageCallback;
  static Function(RemoteMessage)? onMessageOpenedAppCallback;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Initialize notification service and setup listeners (call in main.dart)
  static Future<void> initialize() async {
    try {
      _log('Initializing notification service...');

      // Request notification permissions (iOS)
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message (must be a top-level function)
      // This is handled in main.dart as firebaseMessagingBackgroundHandler

      // Handle notification when app is opened from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          _log('App launched from notification: ${message.messageId}');
          onMessageOpenedAppCallback?.call(message);
        }
      });

      // Handle notification when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _log('Notification opened app: ${message.messageId}');
        onMessageOpenedAppCallback?.call(message);
      });

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      _log('FCM Token: $token');

      // Setup token refresh listener
      _setupTokenRefreshListener();
    } catch (e) {
      _logError('Failed to initialize notification service', e);
    }
  }

  /// Initialize local notifications plugin
  static Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _log('Local notification tapped: ${response.payload}');
        },
      );

      _log('Local notifications initialized');
    } catch (e) {
      _logError('Failed to initialize local notifications', e);
    }
  }

  /// Register token refresh listener (call after login)
  static void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _log('FCM Token refreshed: $newToken');
      sendTokenToBackend();
    });
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    _log('Foreground message received: ${message.messageId}');
    _log('Data: ${message.data}');
    _log('Title: ${message.notification?.title}');
    _log('Body: ${message.notification?.body}');

    // Show local notification for foreground message
    _showLocalNotification(
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      payload: message.messageId,
    );

    // Call custom callback
    onMessageCallback?.call(message);
  }

  /// Show local notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'findar_channel',
        'Findar Notifications',
        channelDescription: 'Notifications for Findar app',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      _logError('Failed to show local notification', e);
    }
  }

  /// Subscribe to a single topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      _log('Subscribing to topic: $topic');
      await _firebaseMessaging.subscribeToTopic(topic);
      _log('Subscribed to topic: $topic');
    } catch (e) {
      _logError('Failed to subscribe to topic', e);
    }
  }

  /// Unsubscribe from a single topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      _log('Unsubscribing from topic: $topic');
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _log('Unsubscribed from topic: $topic');
    } catch (e) {
      _logError('Failed to unsubscribe from topic', e);
    }
  }

  /// Subscribe to multiple topics
  static Future<void> subscribeToTopics(List<String> topics) async {
    try {
      _log('Subscribing to topics: $topics');
      for (final topic in topics) {
        await _firebaseMessaging.subscribeToTopic(topic);
        _log('Subscribed to topic: $topic');
      }
    } catch (e) {
      _logError('Failed to subscribe to topics', e);
    }
  }

  /// Unsubscribe from multiple topics
  static Future<void> unsubscribeFromTopics(List<String> topics) async {
    try {
      _log('Unsubscribing from topics: $topics');
      for (final topic in topics) {
        await _firebaseMessaging.unsubscribeFromTopic(topic);
        _log('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      _logError('Failed to unsubscribe from topics', e);
    }
  }

  /// Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      _log('FCM Token retrieved: $token');
      return token;
    } catch (e) {
      _logError('Failed to get FCM token', e);
      return null;
    }
  }

  /// Register device token after user login
  /// Call this method immediately after successful login
  static Future<bool> registerDeviceAfterLogin() async {
    try {
      _log('Registering device after login...');
      return await sendTokenToBackend();
    } catch (e) {
      _logError('Failed to register device after login', e);
      return false;
    }
  }

  /// Send FCM token to backend
  static Future<bool> sendTokenToBackend() async {
    try {
      final token = await getFCMToken();
      if (token == null || token.isEmpty) {
        _logError('Failed to send token', 'Token is null or empty');
        return false;
      }

      _log('Sending FCM token to backend: $token');

      final apiService = FindarApiService();
      final response = await apiService.post(
        ApiConfig.notificationsRegisterDeviceEndpoint,
        body: {
          'token': token,
        },
      );

      if (response is bool && response == true) {
        _log('Token sent to backend successfully');
        return true;
      } else if (response is Map && response['state'] == false) {
        _logError('Backend rejected token', response['message']);
        return false;
      }

      _log('Token registered with backend');
      return true;
    } catch (e) {
      _logError('Failed to send token to backend', e);
      return false;
    }
  }

  /// Remove device token on logout
  /// Call this method when user logs out
  static Future<bool> removeTokenOnLogout() async {
    try {
      _log('Removing device token on logout...');
      final token = await getFCMToken();
      if (token == null || token.isEmpty) {
        _logError('Failed to remove token', 'Token is null or empty');
        return false;
      }

      _log('Removing FCM token from backend: $token');

      final apiService = FindarApiService();
      final response = await apiService.post(
        ApiConfig.notificationsRegisterDeviceEndpoint,
        body: {
          'token': token,
          'action': 'remove',
        },
      );

      if (response is bool && response == true) {
        _log('Token removed from backend successfully');
        return true;
      } else if (response is Map && response['state'] == false) {
        _logError('Backend failed to remove token', response['message']);
        return false;
      }

      _log('Token removed from backend');
      return true;
    } catch (e) {
      _logError('Failed to remove token on logout', e);
      return false;
    }
  }

  /// Sync topics (subscribe to multiple)
  static Future<void> syncTopics(List<String> topics) async {
    await subscribeToTopics(topics);
  }

  /// Clear all topics (unsubscribe from all)
  static Future<void> clearAllTopics() async {
    List<String> topics = {'agency', 'individual'}.toList();
    for (String topic in topics) {
      await unsubscribeFromTopic(topic);
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      _log('All notifications cancelled');
    } catch (e) {
      _logError('Failed to cancel notifications', e);
    }
  }

  /// Enable/disable notifications
  static Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      if (enabled) {
        await _firebaseMessaging.requestPermission();
        _log('Notifications enabled');
      } else {
        await cancelAllNotifications();
        _log('Notifications disabled');
      }
    } catch (e) {
      _logError('Failed to set notification state', e);
    }
  }

  // Logging helpers
  static void _log(String message) {
    developer.log('🔔 NotificationService: $message');
  }

  static void _logError(String message, dynamic error) {
    developer.log('❌ NotificationService: $message - $error',
        error: error, name: 'NotificationService');
  }
}