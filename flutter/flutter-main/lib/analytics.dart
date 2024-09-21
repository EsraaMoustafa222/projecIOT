import 'package:car_fire_fighter/MQTT.dart';
import 'package:flutter/material.dart';

class AnalyticScreen extends StatefulWidget {
  @override
  _AnalyticScreenState createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  final MQTTClientWrapper mqttClientWrapper = MQTTClientWrapper();
  
  // Storing received messages
  List<String> _messages = [];
  
  // Initial states for flame, smoke, and robot
  String flameStatus = "No data";
  String smokeStatus = "No data";
  String robotState = "Idle";

  @override
  void initState() {
    super.initState();
    // Prepare MQTT and subscribe to topics
    mqttClientWrapper.prepareMqttClient();
    mqttClientWrapper.onMessageReceived = _onMessageReceived;
    _subscribeToAllTopics(); // Subscribe to required topics
  }

  void _subscribeToAllTopics() {
    mqttClientWrapper.subscribeToTopic("firefighter/flame");
    mqttClientWrapper.subscribeToTopic("firefighter/smoke");
    mqttClientWrapper.subscribeToTopic("firefighter/state");
  }

  void _onMessageReceived(String message) {
    // Add the message to the list and update the UI
    setState(() {
      _messages.add(message);
      
      // Parsing messages based on their content
      if (message.contains('L:') && message.contains('M:') && message.contains('R:')) {
        flameStatus = message; // Flame sensor data
      } else if (message.contains(RegExp(r'^\d+$'))) {
        smokeStatus = message; // Smoke sensor data
      } else {
        robotState = message;  // Robot state
      }
    });
    print('Message received: $message');
  }

  Widget _buildDataCard(String title, String value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 217, 185, 183),
        title: Text('Robot Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2, // Display 2 cards per row
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: [
              _buildDataCard('Flame Sensor Status', flameStatus),
              _buildDataCard('Smoke Sensor Status', smokeStatus),
              _buildDataCard('Robot State', robotState),
            ],
          ),
        ),
      ),
    );
  }
}
