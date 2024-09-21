import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClientWrapper {
  late MqttServerClient client;
  Function(String)? onMessageReceived;

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  bool get isConnected =>
      connectionState == MqttCurrentConnectionState.CONNECTED;

  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
  }

  Future<void> _connectClient() async {
    try {
      print('client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;

      await client.connect('esraa_123', 'Me_br123');
    } on Exception catch (e) {
      print('client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print('client connected');
    } else {
      print(
          'ERROR client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  Future<void> connect() async {
    try {
      print('client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;

      await client.connect('esraa_123', 'Me_br123');
    } on Exception catch (e) {
      print('client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print('client connected');
      _subscribeToAllTopics(); // Subscribe after connecting
    } else {
      print(
          'ERROR client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  void _setupMqttClient() {
    client = MqttServerClient.withPort(
        '3653c25602b04b5fa79a6836417632e7.s1.eu.hivemq.cloud',
        'esraa_123',
        8883);
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.keepAlivePeriod = 60; // Increase from 20 to 60 seconds
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  void _subscribeToAllTopics() {
    subscribeToTopic("firefighter/flame");
    subscribeToTopic("firefighter/smoke");
    subscribeToTopic("firefighter/state");
  }

  void subscribeToTopic(String topicName) {
    if (isConnected) {
      print('Subscribing to the $topicName topic');
      client.subscribe(topicName, MqttQos.atMostOnce);
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        var message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        print('YOU GOT A NEW MESSAGE:');
        print(message);

        if (onMessageReceived != null) {
          onMessageReceived!(message);
        }
      });
    } else {
      print('Cannot subscribe, client not connected.');
    }
  }

  void publishMessage(String topic, String message) {
    if (isConnected) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      print('Publishing message "$message" to topic $topic');
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      print('Cannot publish message, client not connected.');
    }
  }

  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void _onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print('OnConnected client callback - Client connection was successful');
  }
}

enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING,
}

enum MqttSubscriptionState { IDLE, SUBSCRIBED }
