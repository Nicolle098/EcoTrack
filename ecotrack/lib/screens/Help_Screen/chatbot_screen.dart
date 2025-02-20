import 'package:flutter/material.dart';
import 'chatbot_client.dart'; // Import the ChatbotClient

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _chatController = TextEditingController();
  final _chatClient = ChatbotClient(
    projectId: 'ecotrack-3679b',
    agentId: '83b15404-4bc1-4827-9be9-e892b14fd523',
    location: 'global',
  );

  List<String> _messages = [];

  void _sendMessage() async {
    final message = _chatController.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add('You: $message');
    });

    final response = await _chatClient.sendMessage('1', message);
    print(response);
    setState(() {
      _messages.add('Bot: $response');
    });

    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 207, 197),
      appBar: AppBar(
        title: const Text(
          'Chatbot',
          style: TextStyle(
            fontSize: 24, 
            fontFamily: 'Roboto', 
            fontWeight: FontWeight.bold, 
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 195, 207, 197), 
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _messages[index],
                    style: const TextStyle(
                      fontSize: 18, 
                      fontFamily: 'Roboto', 
                      color: Colors.black, 
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: const TextStyle(color: Colors.white), 
                      filled: true,
                      fillColor: const Color.fromARGB(255, 128, 126, 126), 
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white), 
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white), 
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}