import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final Gemini gemini = Gemini.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  List<ChatMessage> messages = [];
  List<Map<String, dynamic>> conversations = [];
  bool isTyping = false;

  // Use FirebaseAuth to get the current user
  final ChatUser currentUser = ChatUser(
    id: FirebaseAuth.instance.currentUser?.uid ?? "0",
    firstName: FirebaseAuth.instance.currentUser?.displayName ?? "User",
  );

  final ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Mr MechaBot",
    profileImage: "https://i.postimg.cc/vHVMFVFh/CareBot.jpg",
  );

  @override
  void initState() {
    super.initState();
    //_loadConversations();

    // Add the initial greeting message
    ChatMessage greetingMessage = ChatMessage(
      user: geminiUser,
      text: "Hi I am Mr MechaBot, how may I assist you today?",
      createdAt: DateTime.now(),
    );
    setState(() {
      messages.insert(0, greetingMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Mr MechaBot"),
        backgroundColor:
            Color.fromARGB(255, 79, 43, 177), // Set AppBar color to cyan
      ),
      drawer: _buildSidebar(),
      body: Column(
        children: [
          Expanded(child: _buildChatUI()),
          if (isTyping)
            _buildTypingIndicator(), // Show typing indicator if needed
          _buildMessageInput(), // Input field for typing messages
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(141, 50, 4, 124),
            ),
            child: Center(
              child: Text(
                'History',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (conversations.isEmpty)
            const ListTile(
              title: Text("No conversations found"),
            ),
          ...conversations
              .map((conversation) => ListTile(
                    title: Text(conversation['date']),
                    onTap: () {
                      _loadConversationMessages(conversation['date']);
                    },
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildChatUI() {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isCurrentUser = message.user.id == currentUser.id;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          child: Align(
            alignment:
                isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: isCurrentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  CircleAvatar(
                    backgroundImage: NetworkImage(geminiUser.profileImage ??
                        'https://i.postimg.cc/vHVMFVFh/CareBot.jpg'),
                  ),
                SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? Colors.cyan
                          : Color(0xFFE4E3E1), // Set color based on user
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(color: Colors.black),
                      softWrap: true, // Ensure text wraps within the container
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 8),
          Text(
            "Mr Mechabot is typing...",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 30),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 0, 32,
                        212), // Set the border color to cyan when focused
                    width: 2.0, // Set the width of the border
                  ),
                ),
              ),
              onSubmitted: (text) {
                _sendMessage(text);
              },
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.send, color: const Color.fromARGB(255, 19, 52, 160)),
            onPressed: () {
              _sendMessage(_messageController.text);
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text, [List<Uint8List>? images]) async {
    if (text.trim().isEmpty && (images == null || images.isEmpty)) return;

    ChatMessage chatMessage = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: text.trim(),
    );

    setState(() {
      messages = [chatMessage, ...messages];
      isTyping = false;
    });

    _messageController.clear();
    _saveMessage(chatMessage);

    try {
      String question = chatMessage.text;

      if (containsMechanicalIssue(question) ||
          (images != null && images.isNotEmpty)) {
        setState(() {
          isTyping = true;
        });

        gemini.streamGenerateContent(question, images: images).listen((event) {
          ChatMessage? lastMessage = messages.firstOrNull;
          if (lastMessage != null && lastMessage.user == geminiUser) {
            lastMessage = messages.removeAt(0);
            String response = event.content?.parts?.fold(
                    "", (previous, current) => "$previous ${current.text}") ??
                "";
            response = _cleanResponseText(response);
            lastMessage.text += response;
            setState(() {
              messages = [lastMessage!, ...messages];
            });

            _saveMessage(lastMessage);
          } else {
            String response = event.content?.parts?.fold(
                    "", (previous, current) => "$previous ${current.text}") ??
                "";
            response = _cleanResponseText(response);
            ChatMessage message = ChatMessage(
              user: geminiUser,
              createdAt: DateTime.now(),
              text: response,
            );
            setState(() {
              messages = [message, ...messages];
            });

            _saveMessage(message);
          }

          setState(() {
            isTyping = false;
          });
        });
      } else {
        ChatMessage responseMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text:
              "Sorry, I can only assist with mechanical-related queries. Please ask a mechanical question.",
        );
        setState(() {
          messages = [responseMessage, ...messages];
        });

        _saveMessage(responseMessage);
      }
    } catch (e) {
      print("Error sending message: $e");
      setState(() {
        isTyping = false;
      });
    }
  }

  String _cleanResponseText(String text) {
    // Replace any stray ** symbols
    text = text.replaceAll(RegExp(r'\*\*'), '');

    // Replace * with bullet points
    text = text.replaceAll(RegExp(r'\*\s'), '• ');

    // Return the cleaned text
    return text;
  }

  void _saveMessage(ChatMessage message) async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      await _firestore.collection('chat').add({
        'name': message.user.firstName,
        'text': message.text,
        'createdAt': message.createdAt.toIso8601String(),
        'conversationId':
            '${message.createdAt.year}-${message.createdAt.month}-${message.createdAt.day}',
        'email': userEmail, // Save the user's email with the message
      });
      print("Message saved to Firestore");
    } catch (e) {
      print("Error saving message: $e");
    }
  }

  void _loadConversations() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      final querySnapshot = await _firestore
          .collection('chat')
          .where('email', isEqualTo: userEmail)
          .orderBy('createdAt')
          .get();

      final groupedMessages = <String, List<Map<String, dynamic>>>{};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final conversationId = data['conversationId'] as String;

        if (!groupedMessages.containsKey(conversationId)) {
          groupedMessages[conversationId] = [];
        }

        groupedMessages[conversationId]?.add({
          'name': data['name'],
          'text': data['text'],
          'createdAt': data['createdAt'],
        });
      }

      final conversations = groupedMessages.keys.map((date) {
        return {
          'date': date,
          'messages': groupedMessages[date],
        };
      }).toList();

      setState(() {
        this.conversations = conversations;
      });
    } catch (e) {
      print("Error loading conversations: $e");
    }
  }

  void _loadConversationMessages(String conversationId) async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      final querySnapshot = await _firestore
          .collection('chat')
          .where('conversationId', isEqualTo: conversationId)
          .where('email', isEqualTo: userEmail)
          .orderBy('createdAt')
          .get();

      final messages = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final user =
            data['name'] == geminiUser.firstName ? geminiUser : currentUser;
        return ChatMessage(
          user: user,
          text: data['text'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
        );
      }).toList();

      setState(() {
        this.messages = messages.reversed.toList();
      });
    } catch (e) {
      print("Error loading conversation messages: $e");
    }
  }
}

bool containsMechanicalIssue(String query) {
  final mechanicalIssuesRemedies = {
    'power seat failure':
        'Check the fuse for the power seat and ensure all connections are secure. If the issue persists, consult a mechanic.',
    'Door handle sticking':
        'Lubricate the door handle mechanism with WD-40 or a similar lubricant. If the problem continues, have the handle checked by a professional.',
    'Tail light bulb failure':
        'Replace the faulty bulb with a new one. If the new bulb does not work, check the fuse and wiring for issues.',
    'Engine noise':
        'Identify the type of noise and check for loose components or damaged parts. Consult a mechanic if the noise persists or is severe.',
    'Engine misfire':
        'Check the spark plugs, ignition coils, and fuel injectors. If the issue continues, seek professional diagnosis and repair.',
    'Engine overheating':
        'Check the coolant level and radiator for leaks. Ensure the thermostat and water pump are functioning properly. Consult a mechanic if the problem persists.',
    'Engine stalling':
        'Inspect the fuel system and air intake for blockages or leaks. Check the idle control valve. Seek professional help if the issue continues.',
    'Engine knocking':
        'Use higher-octane fuel if knocking is due to low octane. Check for issues with the timing or spark plugs. Consult a mechanic if knocking persists.',
    'Engine vibration':
        'Check for unbalanced tires, worn engine mounts, or misaligned components. Have a professional inspect and address any underlying issues.',
    'Engine won\'t start':
        'Check the battery charge, starter motor, and ignition system. Ensure fuel is reaching the engine. If the issue continues, consult a mechanic.',
    'Engine sputtering':
        'Check the fuel system for clogs and inspect the spark plugs, If the problem persists, consult a mechanic for further diagnosis.',
    'Engine power loss':
        'Inspect the air filter, fuel filter, and fuel injectors, Ensure the spark plugs are in good condition, Seek professional help if power loss continues.',
    'Engine surging':
        'Check for issues with the idle control valve or throttle position sensor, Ensure the fuel system is functioning properly, Consult a mechanic if needed.',
    'Engine idling rough':
        'Inspect the spark plugs, ignition coils, and fuel injectors, Check for vacuum leaks, Have a professional diagnose and address the issue.',
    'Engine smoke':
        'Determine the color of the smoke to identify the issue (e.g., blue smoke could indicate oil burning), Check for leaks and consult a mechanic if needed.',
    'Engine shaking':
        'Check the engine mounts and ensure they are not worn or damaged, Inspect for misfiring or unbalanced components, Seek professional help if shaking persists.',
    'Engine ticking':
        'Check the oil level and quality, Inspect the valve lifters and timing components, Consult a mechanic if ticking continues.',
    'Engine overheating warning':
        'Check the coolant level and radiator for leaks, Ensure the thermostat and water pump are functioning properly, Seek professional assistance if the warning persists.',
    'Engine coolant leak':
        'Inspect the coolant hoses, radiator, and water pump for leaks, Replace any damaged components and consult a mechanic if the leak continues.',
    'Engine warning light':
        'Use an OBD-II scanner to diagnose the specific issue, Address the problem according to the error codes and consult a mechanic if necessary.',
    'Engine oil leak':
        'Inspect the oil pan, gaskets, and seals for leaks, Replace any damaged components and consult a mechanic if the leak persists.',
    'Engine hesitation':
        'Check the fuel system, air intake, and ignition system, Ensure there are no blockages or malfunctions, Seek professional help if hesitation continues.',
    'Engine hard start':
        'Inspect the battery, starter motor, and ignition system, Ensure the fuel system is functioning properly, Consult a mechanic if the issue persists.',
    'Engine oil pressure low':
        'Check the oil level and quality, Inspect the oil pump and pressure sending unit, Consult a mechanic if the oil pressure remains low.',
    'Engine rattling':
        'Identify the source of the rattling noise and check for loose components or damaged parts, Seek professional help if the rattling continues.',
    'Engine cuts out':
        'Inspect the fuel system, ignition system, and electrical connections, Consult a mechanic if the engine cuts out intermittently or frequently.',
    'Engine backfire':
        'Check the ignition timing and fuel system, Inspect the spark plugs and ignition coils, Seek professional assistance if backfiring persists.',
    'Engine dies when idling':
        'Inspect the idle control valve and air intake system, Check for vacuum leaks, Consult a mechanic if the engine continues to die at idle.',
    'Engine compression issues':
        'Perform a compression test to identify any issues with the cylinders, Consult a mechanic for further diagnosis and repair if needed.',
    'Engine fuel leak':
        'Inspect the fuel lines, fuel pump, and injectors for leaks, Replace any damaged components and consult a mechanic if the leak persists.',
    'Engine mount broken':
        'Replace the broken engine mount with a new one, Ensure all mounts are properly secured, Consult a mechanic if issues with engine stability continue.',
    'Engine performance drop':
        'Check the air filter, fuel filter, and spark plugs, Inspect the ignition system and fuel injectors, Seek professional help if performance does not improve.',
    'Engine rough running':
        'Inspect the fuel system, air intake, and ignition components, Check for vacuum leaks and ensure proper engine timing, Consult a mechanic if needed.',
    'Engine detonation':
        'Use higher-octane fuel if detonation is due to low octane, Check for timing issues and inspect spark plugs, Seek professional assistance if detonation continues.',
    'Engine sluggishness':
        'Inspect the fuel system, air filter, and ignition system, Ensure the spark plugs and fuel injectors are functioning properly, Consult a mechanic if sluggishness persists.',
    'Engine bearing failure':
        'Check the engine bearings for wear or damage, Replace any faulty bearings and consult a mechanic for further inspection and repair.',
    'Engine timing off':
        'Inspect the timing belt or chain and adjust as necessary, Consult a mechanic if timing issues persist or if you are unsure how to make adjustments.',
    'Engine misalignment':
        'Inspect and align the engine mounts and associated components, Consult a mechanic if misalignment issues persist or affect vehicle performance.',
    'Engine air leak':
        'Check the air intake system for leaks or damaged components, Replace any faulty parts and consult a mechanic if the leak continues.',
    'Engine vacuum leak':
        'Inspect the vacuum lines and connections for leaks, Replace any damaged lines and consult a mechanic if the issue persists.',
    'Engine seals worn':
        'Replace any worn or damaged engine seals, Ensure all seals are properly fitted to prevent leaks, Consult a mechanic if needed.',
    'Engine belt noise':
        'Inspect the drive belts for wear or damage, Replace any noisy or worn belts and ensure proper tension, Seek professional help if noise persists.',
    'Engine excessive noise':
        'Identify the source of the excessive noise and check for loose or damaged components, Consult a mechanic for further diagnosis and repair.',
    'Engine squeaking':
        'Inspect the drive belts and pulleys for wear or damage, Lubricate or replace any squeaking components, Seek professional help if the squeaking continues.',
    'Engine burning oil':
        'Check for oil leaks and inspect the piston rings or valve seals, Consult a mechanic if the engine continues to burn oil or if the issue worsens.',
    'Engine oil sludge':
        'Perform an oil change and clean the oil passages, Use high-quality oil and consult a mechanic if sludge issues persist.',
    'Engine coolant bubbling':
        'Check for issues with the coolant system, such as a faulty radiator cap or air pockets, Consult a mechanic if coolant bubbling continues.',
    'Engine coolant boiling':
        'Check the coolant level and radiator for leaks, Ensure the thermostat and water pump are functioning properly, Consult a mechanic if boiling persists.',
    'Engine intake leak':
        'Inspect the intake manifold and associated gaskets for leaks, Replace any damaged components and consult a mechanic if the leak continues.',
    'Engine surge on acceleration':
        'Check the throttle position sensor and fuel system, Inspect for vacuum leaks or issues with the idle control valve, Seek professional help if surging persists.',
    'Engine whistling noise':
        'Inspect the air intake system and belts for leaks or damage, Replace any faulty components and consult a mechanic if the noise continues.',
    'Engine overheating at idle':
        'Check the coolant level and radiator for blockages, Ensure the cooling fans are working properly, Consult a mechanic if overheating persists.',
    'Engine running rich':
        'Inspect the fuel system and oxygen sensors, Ensure the air-fuel mixture is properly adjusted, Consult a mechanic if the engine continues to run rich.',
    'Engine coolant low':
        'Check for leaks in the coolant system and top up the coolant level, Consult a mechanic if the coolant level drops frequently.',
    'Engine hydraulic failure':
        'Inspect the hydraulic system for leaks or damage, Replace any faulty components and consult a mechanic if hydraulic failure persists.',
    'Engine gasket failure':
        'Replace any damaged or leaking gaskets, Consult a mechanic for further diagnosis and repair if gasket failure continues.',
    'Engine crankshaft issues':
        'Inspect the crankshaft and bearings for wear or damage, Replace any faulty components and consult a mechanic if issues persist.',
    'Engine camshaft issues':
        'Inspect the camshaft and timing components for wear or damage, Replace any faulty parts and consult a mechanic if camshaft issues continue.',
    'Engine overheating on hills':
        'Check the coolant system and radiator for proper function, Ensure the cooling fans are operating correctly, Consult a mechanic if overheating persists.',
    'Engine pinging':
        'Use higher-octane fuel and check for timing issues, Inspect spark plugs and ignition system, Seek professional assistance if pinging continues.',
    'Engine mount failure':
        'Replace the damaged engine mount with a new one, Ensure all mounts are properly secured, Consult a mechanic if engine mount failure persists.',
    'Engine sensor failure':
        'Use an OBD-II scanner to diagnose the specific sensor issue, Replace the faulty sensor and consult a mechanic if sensor failures continue.',
    'Engine throttle issues':
        'Inspect the throttle body and related components for malfunctions, Clean or replace as necessary and consult a mechanic if issues persist.',
    'Engine turbocharger failure':
        'Inspect the turbocharger for damage or wear, Replace any faulty components and consult a mechanic for further diagnosis and repair.',
    'Engine valve tapping':
        'Check the valve clearance and adjust if necessary, Inspect the valve lifters for wear, Consult a mechanic if valve tapping continues.',
    'Engine fuel pump failure':
        'Replace the faulty fuel pump and ensure the fuel system is properly primed, Consult a mechanic if fuel pump issues persist.',
    'Engine air filter clogged':
        'Replace the clogged air filter with a new one, Ensure proper air flow to the engine, Consult a mechanic if the issue continues.',
    'Engine coolant temperature high':
        'Check the coolant level and radiator for blockages, Ensure the thermostat and cooling fans are functioning properly, Consult a mechanic if high temperatures persist.',
    'Engine stalls after start':
        'Inspect the fuel system, idle control valve, and air intake, Consult a mechanic if the engine continues to stall after starting.',
    'Engine idles too fast':
        'Check the idle control valve and adjust as necessary, Inspect for vacuum leaks and consult a mechanic if issues with fast idling persist.',

// TRANSMISSION
    'Transmission slipping':
        'Check and adjust the transmission fluid level, and consult a mechanic if the issue persists.',
    'Transmission leak':
        'Inspect for leaks and replace any damaged seals or gaskets, and consult a mechanic for further inspection.',
    'Transmission won\'t shift':
        'Check the transmission fluid level and condition, and consult a mechanic if the issue persists.',
    'Transmission hard shifting':
        'Check the transmission fluid level and condition, and consult a mechanic if the issue persists.',
    'Transmission noise':
        'Inspect for any loose components or worn parts, and consult a mechanic for further diagnosis.',
    'Transmission overheating':
        'Check the transmission fluid level, ensure the cooling system is functioning properly, and consult a mechanic if needed.',
    'Transmission jerking':
        'Check the transmission fluid level and condition, and consult a mechanic if the issue persists.',
    'Transmission fluid low':
        'Add the appropriate type of transmission fluid and check for any leaks.',
    'Transmission fluid leak':
        'Inspect and replace any damaged seals or gaskets, and consult a mechanic for further inspection.',
    'Transmission fluid dirty':
        'Change the transmission fluid and filter, and consult a mechanic for further maintenance.',
    'Transmission grinding noise':
        'Inspect for worn or damaged components, and consult a mechanic for further diagnosis.',
    'Transmission whine':
        'Check for low fluid levels and worn components, and consult a mechanic if the issue persists.',
    'Transmission failure':
        'Consult a mechanic immediately for a thorough inspection and potential repair or replacement.',
    'Transmission shifting delay':
        'Check the transmission fluid level and condition, and consult a mechanic if the issue persists.',
    'Transmission clunking':
        'Inspect for worn or damaged components, and consult a mechanic for further diagnosis.',
    'Transmission overdrive problems':
        'Check the transmission fluid level and condition, and consult a mechanic if the issue persists.',
    'Transmission won\'t go in gear':
        'Check the clutch system and transmission fluid, and consult a mechanic if the issue persists.',
    'Transmission slipping gears':
        'Check and adjust the transmission fluid level, and consult a mechanic if the issue persists.',
    'Transmission sluggish':
        'Check the transmission fluid level and condition, and consult a mechanic if the issue persists.',
    'Transmission stuck in gear':
        'Inspect the transmission linkage and consult a mechanic for further diagnosis.',
    'Transmission burning smell':
        'Check for leaking transmission fluid and consult a mechanic for a thorough inspection.',
    'Transmission overheating light':
        'Check the transmission fluid level and cooling system, and consult a mechanic if the light remains on.',
    'Transmission solenoid failure':
        'Inspect and replace the faulty solenoid, and consult a mechanic for further diagnosis.',
    'Transmission fluid burnt':
        'Change the transmission fluid and filter, and consult a mechanic if the problem persists.',
    'Transmission whistling noise':
        'Inspect for any loose or worn components, and consult a mechanic for further diagnosis.',
    'Transmission surging':
        'Check the transmission fluid level and condition, and consult a mechanic if the issue persists.',
    'Transmission vibration':
        'Inspect for any damaged mounts or worn components, and consult a mechanic for further diagnosis.',
    'Transmission fluid leak detection':
        'Inspect for leaks and replace any damaged seals or gaskets, and consult a mechanic for further inspection.',
    'Transmission fluid low indicator':
        'Add the appropriate type of transmission fluid and check for any leaks.',
    'Transmission overheating alarm':
        'Check the transmission fluid level and cooling system, and consult a mechanic if the alarm remains on.',
    'Transmission fluid burnt odor':
        'Change the transmission fluid and filter, and consult a mechanic if the odor persists.',
    'Transmission torque converter issues':
        'Inspect and repair or replace the torque converter, and consult a mechanic for further diagnosis.',
    'Transmission jerky acceleration':
        'Check the transmission fluid level and condition, and consult a mechanic if the issue persists.',
    'Transmission reverse gear failure':
        'Inspect the reverse gear mechanism and consult a mechanic for further diagnosis.',
    'Transmission seal leak':
        'Inspect and replace any damaged seals, and consult a mechanic for further inspection.',
    'Transmission shuddering':
        'Check the transmission fluid level and condition, and consult a mechanic if the issue persists.',
    'Transmission fluid check':
        'Regularly check the transmission fluid level and condition, and top up or replace as needed.',
    'Transmission pump failure':
        'Inspect and replace the faulty pump, and consult a mechanic for further diagnosis.',
    'Transmission linkage issues':
        'Inspect and adjust or repair the transmission linkage, and consult a mechanic if the issue persists.',
    'Transmission grinding on shifting':
        'Inspect for worn or damaged components, and consult a mechanic for further diagnosis.',
    'Transmission sensor fault':
        'Inspect and replace the faulty sensor, and consult a mechanic for further diagnosis.',
    'Transmission computer failure':
        'Consult a mechanic for a thorough inspection and potential repair or replacement of the transmission computer.',
    'Transmission clutch slipping':
        'Inspect and replace the clutch as needed, and consult a mechanic for further diagnosis.',
    'Transmission fluid contamination':
        'Change the transmission fluid and filter, and consult a mechanic for further maintenance.',
    'Transmission mount failure':
        'Inspect and replace damaged transmission mounts, and consult a mechanic for further inspection.',
    'Transmission oil change':
        'Regularly change the transmission oil according to manufacturer recommendations.',
    'Transmission synchronizer failure':
        'Inspect and replace the faulty synchronizer, and consult a mechanic for further diagnosis.',
    'Transmission noise at idle':
        'Inspect for any loose or worn components, and consult a mechanic for further diagnosis.',

//ENGINE HEATING
    'Overheating radiator':
        'Check the coolant level and ensure proper radiator function, and consult a mechanic if the issue persists.',
    'Coolant leak':
        'Inspect for leaks in the cooling system and repair any damaged components, and consult a mechanic if needed.',
    'Radiator fan failure':
        'Inspect and replace the faulty radiator fan, and consult a mechanic for further diagnosis.',
    'Thermostat stuck':
        'Replace the stuck thermostat and consult a mechanic if the issue persists.',
    'Coolant boiling':
        'Check the coolant level and cooling system for any issues, and consult a mechanic if the boiling continues.',
    'Coolant temperature high':
        'Check the coolant level and radiator function, and consult a mechanic if the temperature remains high.',
    'Water pump failure':
        'Inspect and replace the faulty water pump, and consult a mechanic for further diagnosis.',
    'Radiator clogged':
        'Flush and clean the radiator, and consult a mechanic if the clogging persists.',
    'Cooling system failure':
        'Inspect the entire cooling system and consult a mechanic for a thorough diagnosis and repair.',
    'Overheating in traffic':
        'Check the cooling system and radiator function, and consult a mechanic if the overheating continues.',
    'Coolant reservoir leak':
        'Inspect and replace the damaged coolant reservoir, and consult a mechanic for further inspection.',
    'Head gasket blown':
        'Consult a mechanic immediately for a thorough inspection and potential head gasket replacement.',
    'Coolant overflow':
        'Check the coolant level and radiator cap, and consult a mechanic if the overflow issue persists.',
    'Radiator hose burst':
        'Replace the burst radiator hose and check for any other cooling system issues.',
    'Heater core leak':
        'Inspect and replace the faulty heater core, and consult a mechanic for further diagnosis.',
    'Overheating warning light':
        'Check the coolant level and cooling system, and consult a mechanic if the warning light remains on.',
    'Coolant level low':
        'Add coolant to the appropriate level and check for any leaks or cooling system issues.',
    'Radiator fan not running':
        'Inspect and replace the faulty radiator fan, and consult a mechanic for further diagnosis.',
    'Thermostat failure':
        'Replace the faulty thermostat and consult a mechanic if the issue persists.',
    'Cooling fan relay issue':
        'Inspect and replace the faulty cooling fan relay, and consult a mechanic for further diagnosis.',
    'Water pump leak':
        'Inspect and replace the leaking water pump, and consult a mechanic for further diagnosis.',
    'Coolant reservoir empty':
        'Add coolant to the reservoir and check for leaks or other cooling system issues.',
    'Overheating while idling':
        'Check the cooling system and radiator function, and consult a mechanic if the overheating persists.',
    'Cooling system pressure loss':
        'Inspect for leaks and ensure the cooling system is properly sealed, and consult a mechanic for further diagnosis.',
    'Radiator cap failure':
        'Inspect and replace the faulty radiator cap, and consult a mechanic if the issue persists.',
    'Overheating at high speeds':
        'Check the cooling system and radiator function, and consult a mechanic if the overheating continues.',
    'Coolant bubbling in reservoir':
        'Check for possible head gasket issues and consult a mechanic for further diagnosis and repair.',
    'Engine temperature gauge high':
        'Check the coolant level and radiator function, and consult a mechanic if the gauge remains high.',
    'Coolant smell':
        'Inspect for leaks and check the cooling system for issues, and consult a mechanic if the smell persists.',

//SUSPENSION
    'Suspension noise':
        'Inspect the suspension components for wear or damage, and consult a mechanic for further diagnosis.',
    'Suspension creaking':
        'Lubricate or replace worn suspension components, and consult a mechanic if the creaking continues.',
    'Suspension squeaking':
        'Inspect and lubricate suspension components, and consult a mechanic if the squeaking persists.',
    'Suspension knocking':
        'Inspect for worn or damaged suspension parts, and consult a mechanic for further diagnosis.',
    'Suspension failure':
        'Consult a mechanic immediately for a thorough inspection and potential repair or replacement.',
    'Suspension bushing wear':
        'Inspect and replace worn suspension bushings, and consult a mechanic for further diagnosis.',
    'Suspension alignment issues':
        'Perform a suspension alignment and consult a mechanic if alignment issues continue.',
    'Suspension sagging':
        'Inspect and replace worn suspension components or springs, and consult a mechanic if the sagging persists.',
    'Suspension uneven ride height':
        'Inspect the suspension system and adjust or replace components as needed, and consult a mechanic if the issue persists.',
    'Suspension squeal':
        'Inspect and lubricate suspension components, and consult a mechanic if the squealing continues.',
    'Suspension bounce':
        'Check the shock absorbers and replace if needed, and consult a mechanic for further diagnosis.',
    'Suspension bottoming out':
        'Inspect and replace worn suspension components, and consult a mechanic if the bottoming out continues.',
    'Suspension stiffness':
        'Inspect the suspension system and adjust or replace components as needed, and consult a mechanic if the stiffness persists.',
    'Suspension rough ride':
        'Check and replace worn suspension components, and consult a mechanic for further diagnosis.',
    'Suspension clunking':
        'Inspect for worn or damaged suspension components, and consult a mechanic for further diagnosis.',
    'Suspension leaking fluid':
        'Inspect and replace any leaking suspension components, and consult a mechanic for further diagnosis.',
    'Suspension rattling':
        'Check for loose or damaged suspension components, and consult a mechanic for further diagnosis.',
    'Suspension squeaky noise':
        'Lubricate or replace worn suspension components, and consult a mechanic if the squeaking persists.',
    'Suspension popping noise':
        'Inspect for worn or damaged suspension parts, and consult a mechanic for further diagnosis.',
    'Suspension grinding noise':
        'Inspect and replace worn or damaged suspension components, and consult a mechanic if the grinding continues.',
    'Suspension loose handling':
        'Check the suspension system for any loose components and consult a mechanic for further diagnosis.',
    'Suspension pulling to one side':
        'Inspect and align the suspension system, and consult a mechanic if the pulling persists.',
    'Suspension wobbling':
        'Inspect for worn or damaged suspension components and consult a mechanic for further diagnosis.',
    'Suspension thudding':
        'Check for worn suspension components and consult a mechanic for further diagnosis.',
    'Suspension play in steering':
        'Inspect the steering and suspension components for wear or damage, and consult a mechanic if the play persists.',
    'Suspension vibration':
        'Inspect and replace worn or damaged suspension components, and consult a mechanic for further diagnosis.',
    'Suspension strut failure':
        'Inspect and replace faulty struts, and consult a mechanic for further diagnosis and repair.',
    'Suspension shock absorber leak':
        'Inspect and replace the leaking shock absorbers, and consult a mechanic for further diagnosis.',
    'Suspension spring failure':
        'Inspect and replace the faulty suspension springs, and consult a mechanic for further diagnosis.',
    'Suspension rebound issues':
        'Check and replace worn suspension components, and consult a mechanic for further diagnosis.',
    'Suspension ride control issues':
        'Inspect the ride control system and replace any faulty components, and consult a mechanic if issues persist.',
    'Suspension height sensor failure':
        'Inspect and replace the faulty height sensor, and consult a mechanic for further diagnosis.',
    'Suspension airbag leak':
        'Inspect and repair or replace the leaking suspension airbags, and consult a mechanic for further diagnosis.',
    'Suspension control arm failure':
        'Inspect and replace the faulty control arms, and consult a mechanic for further diagnosis.',
    'Suspension ball joint wear':
        'Inspect and replace worn ball joints, and consult a mechanic for further diagnosis.',
    'Suspension stabilizer bar issue':
        'Inspect and repair or replace the stabilizer bar, and consult a mechanic for further diagnosis.',
    'Suspension strut mount noise':
        'Inspect and replace the strut mounts, and consult a mechanic for further diagnosis if the noise persists.',
    'Suspension sagging on one side':
        'Inspect and replace worn suspension components, and consult a mechanic for further diagnosis.',
    'Suspension noise over bumps':
        'Inspect and replace worn or damaged suspension components, and consult a mechanic if the noise continues.',
    'Suspension rattling at low speeds':
        'Check for loose or damaged suspension components, and consult a mechanic for further diagnosis.',
    'Suspension worn shocks':
        'Inspect and replace worn shock absorbers, and consult a mechanic for further diagnosis.',
    'Suspension lift kit problems':
        'Inspect and adjust or replace the lift kit components, and consult a mechanic if issues persist.',
    'Suspension uneven tire wear':
        'Inspect and align the suspension system, and consult a mechanic for further diagnosis.',
    'Suspension coil spring noise':
        'Inspect and replace worn coil springs, and consult a mechanic if the noise continues.',
    'Suspension alignment required':
        'Perform a suspension alignment and consult a mechanic if the alignment issues persist.',
    'Suspension anti-roll bar issue':
        'Inspect and repair or replace the anti-roll bar, and consult a mechanic for further diagnosis.',
    'Suspension shock absorber failure':
        'Inspect and replace faulty shock absorbers, and consult a mechanic for further diagnosis.',
    'Suspension torsion bar issue':
        'Inspect and repair or replace the torsion bar, and consult a mechanic for further diagnosis.',
    'Suspension camber misalignment':
        'Perform a camber alignment and consult a mechanic if misalignment issues persist.',
    'Suspension toe misalignment':
        'Perform a toe alignment and consult a mechanic if misalignment issues persist.',
    'Suspension caster misalignment':
        'Perform a caster alignment and consult a mechanic if misalignment issues persist.',
    'Suspension ride height sensor':
        'Inspect and replace the ride height sensor if necessary, and consult a mechanic for further diagnosis.',

//BRAKE
    'Brake squeaking':
        'Inspect and replace worn brake pads, and consult a mechanic if the squeaking persists.',
    'Brake grinding':
        'Inspect and replace worn brake pads or rotors, and consult a mechanic if the grinding continues.',
    'Brake fade':
        'Check the brake fluid level and condition, and consult a mechanic for a brake system inspection and potential service.',
    'Brake pedal spongy':
        'Check and bleed the brake system to remove air, and consult a mechanic if the sponginess persists.',
    'Brake warning light':
        'Check the brake fluid level and system, and consult a mechanic if the warning light remains on.',
    'Brake fluid leak':
        'Inspect and repair any leaks in the brake system, and consult a mechanic for further diagnosis.',
    'Brake pedal vibration':
        'Inspect and replace worn rotors or pads, and consult a mechanic if the vibration persists.',
    'Brake pulling to one side':
        'Inspect the brake calipers and pads for uneven wear, and consult a mechanic for further diagnosis and alignment.',
    'Brake sticking':
        'Inspect and replace any faulty brake components, and consult a mechanic if the sticking continues.',
    'Brake pad wear':
        'Inspect and replace worn brake pads, and consult a mechanic for further brake system maintenance.',
    'Brake rotor warping':
        'Inspect and resurface or replace warped rotors, and consult a mechanic for further diagnosis.',
    'Brake line rust':
        'Inspect and replace rusted brake lines, and consult a mechanic for further brake system maintenance.',
    'Brake hose damage':
        'Inspect and replace damaged brake hoses, and consult a mechanic for further diagnosis and repair.',
    'Brake fluid contamination':
        'Replace the contaminated brake fluid and consult a mechanic for a thorough brake system inspection.',
    'Brake pulsation':
        'Inspect and replace worn rotors or pads, and consult a mechanic if pulsation persists.',
    'Brake noise while stopping':
        'Inspect and replace worn brake pads or rotors, and consult a mechanic if the noise continues.',
    'Brake pedal soft':
        'Check and bleed the brake system to remove air, and consult a mechanic if the softness persists.',
    'Brake fluid low':
        'Add the appropriate brake fluid and check for any leaks in the system.',
    'Brake failure':
        'Consult a mechanic immediately for a thorough inspection and repair of the brake system.',
    'Brake pad replacement':
        'Replace worn brake pads and consult a mechanic for further brake system maintenance.',
    'Brake caliper sticking':
        'Inspect and replace any faulty brake calipers, and consult a mechanic for further diagnosis.',
    'Brake rotor scoring':
        'Inspect and resurface or replace scored rotors, and consult a mechanic for further diagnosis.',
    'Brake drums squealing':
        'Inspect and replace worn brake drum components, and consult a mechanic if the squealing persists.',
    'Brake booster failure':
        'Inspect and replace the faulty brake booster, and consult a mechanic for further diagnosis.',
    'Brake master cylinder leak':
        'Inspect and replace the leaking master cylinder, and consult a mechanic for further diagnosis and repair.',
    'Brake hard pedal':
        'Check the brake booster and master cylinder, and consult a mechanic if the hard pedal persists.',
    'Brake lockup':
        'Inspect the brake system for any malfunctioning components, and consult a mechanic for further diagnosis and repair.',
    'Brake imbalance':
        'Inspect and adjust the brake system to correct any imbalances, and consult a mechanic if the issue persists.',
    'Brake fluid boiling':
        'Inspect the brake fluid for contamination and replace if needed, and consult a mechanic if the boiling continues.',
    'Brake warning on dashboard':
        'Check the brake fluid level and system, and consult a mechanic if the warning remains on.',
    'Brake caliper leak':
        'Inspect and repair or replace the leaking brake caliper, and consult a mechanic for further diagnosis.',
    'Brake pedal stiff':
        'Inspect the brake system for any issues and consult a mechanic for further diagnosis and repair.',
    'Brake squeal at low speeds':
        'Inspect and replace worn brake pads or rotors, and consult a mechanic if the squeal continues.',
    'Brake fluid discoloration':
        'Replace the discolored brake fluid and consult a mechanic for a thorough brake system inspection.',
    'Brake system flush':
        'Perform a brake system flush and consult a mechanic for further maintenance.',
    'Brake anti-lock failure':
        'Inspect and repair or replace the faulty anti-lock braking system components, and consult a mechanic for further diagnosis.',
    'Brake light malfunction':
        'Replace the malfunctioning brake light bulb and check the electrical connections.',
    'Brake hose replacement':
        'Inspect and replace damaged brake hoses, and consult a mechanic for further diagnosis.',
    'Brake dragging':
        'Inspect and replace any faulty brake components, and consult a mechanic if dragging persists.',
    'Brake noise when reversing':
        'Inspect and replace worn brake components, and consult a mechanic if the noise continues.',
    'Brake overheating':
        'Check the brake system for proper function and consult a mechanic if overheating persists.',
    'Brake clicking noise':
        'Inspect and replace worn brake pads or components, and consult a mechanic if the clicking continues.',
    'Brake pad sensor fault':
        'Inspect and replace the faulty brake pad sensor, and consult a mechanic for further diagnosis.',
    'Brake hydraulic leak':
        'Inspect and repair or replace the source of the hydraulic leak, and consult a mechanic for further diagnosis.',
    'Brake air in lines':
        'Bleed the brake system to remove air, and consult a mechanic if the problem persists.',
    'Brake squeal on initial application':
        'Inspect and replace worn brake pads or rotors, and consult a mechanic if the squeal continues.',
    'Brake wear sensor issue':
        'Inspect and replace the faulty brake wear sensor, and consult a mechanic for further diagnosis.',
    'Brake vibration at high speeds':
        'Inspect and replace worn rotors or pads, and consult a mechanic if the vibration persists.',
    'Brake caliper bolt loose':
        'Tighten the loose caliper bolts and inspect for any further issues, and consult a mechanic if needed.',
    'Brake pedal sinks':
        'Check and bleed the brake system to remove air, and consult a mechanic if the problem persists.',
    'Brake disc scoring':
        'Inspect and resurface or replace scored brake discs, and consult a mechanic for further diagnosis.',
    'Brake low vacuum':
        'Inspect the vacuum system and brake booster for any issues, and consult a mechanic if the vacuum is low.',
    'Brake popping sound':
        'Inspect for any loose or damaged brake components, and consult a mechanic for further diagnosis.',
    'Brake scraping noise':
        'Inspect and replace worn brake pads or rotors, and consult a mechanic if the scraping continues.',
    'Brake juddering':
        'Inspect and replace worn brake pads or rotors, and consult a mechanic if the juddering persists.',
    'Brake squeak after rain':
        'Inspect and clean or replace worn brake components, and consult a mechanic if the squeak continues.',

//STEERING
    'Steering wheel vibration':
        'Inspect and balance the wheels, and consult a mechanic for further diagnosis if the vibration persists.',
    'Steering pulling to one side':
        'Check and align the steering system, and consult a mechanic if the pulling continues.',
    'Steering stiffness':
        'Inspect the steering fluid level and system components, and consult a mechanic if the stiffness persists.',
    'Steering wheel play':
        'Inspect and adjust the steering linkage, and consult a mechanic if the play continues.',
    'Steering noise':
        'Inspect the steering system for worn or damaged components, and consult a mechanic if the noise persists.',
    'Steering wheel off-center':
        'Check and align the steering system, and consult a mechanic if the issue continues.',
    'Steering fluid leak':
        'Inspect and repair or replace any leaking steering fluid components, and consult a mechanic for further diagnosis.',
    'Steering wheel binding':
        'Inspect and lubricate the steering components, and consult a mechanic if the binding persists.',
    'Steering loose feel':
        'Inspect and adjust the steering system components, and consult a mechanic for further diagnosis if needed.',
    'Steering jerky':
        'Check the steering fluid level and system components, and consult a mechanic if the jerky movement continues.',
    'Steering rack noise':
        'Inspect and replace any faulty steering rack components, and consult a mechanic for further diagnosis.',
    'Steering wheel hard to turn':
        'Inspect the steering fluid level and system components, and consult a mechanic if the difficulty persists.',
    'Steering column noise':
        'Inspect and lubricate or replace worn steering column components, and consult a mechanic if the noise continues.',
    'Steering wheel shimmy':
        'Inspect and balance the wheels, and consult a mechanic for further diagnosis if the shimmy persists.',
    'Steering pump failure':
        'Inspect and replace the faulty steering pump, and consult a mechanic for further diagnosis and repair.',
    'Steering fluid low':
        'Add the appropriate steering fluid and check for any leaks in the system.',
    'Steering wandering':
        'Inspect and align the steering system, and consult a mechanic if wandering persists.',
    'Steering grinding noise':
        'Inspect and replace worn or damaged steering components, and consult a mechanic if the grinding continues.',
    'Steering wheel clicks':
        'Inspect and lubricate or replace faulty steering components, and consult a mechanic for further diagnosis.',
    'Steering wheel shudder':
        'Inspect and balance the wheels, and consult a mechanic if the shuddering persists.',
    'Steering wheel locks':
        'Inspect and repair the steering lock mechanism, and consult a mechanic if the locking issue continues.',
    'Steering heavy at low speed':
        'Check the steering fluid level and system components, and consult a mechanic if the steering remains heavy.',
    'Steering pump whine':
        'Inspect and replace the faulty steering pump, and consult a mechanic for further diagnosis if the whine continues.',
    'Steering fluid foamy':
        'Inspect and replace the steering fluid, and check for air in the system. Consult a mechanic if the foaming persists.',
    'Steering wheel not returning':
        'Inspect and lubricate the steering components, and consult a mechanic if the wheel does not return to center.',
    'Steering linkage loose':
        'Inspect and tighten the steering linkage components, and consult a mechanic for further diagnosis if needed.',
    'Steering belt slipping':
        'Inspect and replace the slipping steering belt, and consult a mechanic for further diagnosis if the issue persists.',
    'Steering wheel resistance':
        'Inspect and lubricate the steering components, and consult a mechanic if the resistance continues.',
    'Steering wheel shakes on braking':
        'Inspect and balance the wheels, and check the brake system for issues. Consult a mechanic if shaking persists.',
    'Steering sensor failure':
        'Inspect and replace the faulty steering sensor, and consult a mechanic for further diagnosis.',
    'Steering wheel groaning':
        'Inspect the steering fluid level and system components, and consult a mechanic if the groaning continues.',
    'Steering box leak':
        'Inspect and repair or replace the leaking steering box, and consult a mechanic for further diagnosis.',
    'Steering pump squeal':
        'Inspect and replace the faulty steering pump, and consult a mechanic for further diagnosis if the squeal persists.',
    'Steering gear play':
        'Inspect and adjust or replace the steering gear, and consult a mechanic for further diagnosis.',
    'Steering rattles over bumps':
        'Inspect and repair any loose or damaged steering components, and consult a mechanic if rattling continues.',
    'Steering fluid foaming':
        'Inspect and replace the steering fluid, and check for air in the system. Consult a mechanic if foaming persists.',
    'Steering wandering on highway':
        'Inspect and align the steering system, and consult a mechanic if wandering continues on the highway.',
    'Steering alignment off':
        'Perform a steering alignment and consult a mechanic for further adjustments if needed.',
    'Steering fluid brown':
        'Replace the brown steering fluid and consult a mechanic for a thorough inspection of the steering system.',
    'Steering wheel vibrates at high speed':
        'Inspect and balance the wheels, and consult a mechanic if the vibration persists at high speeds.',
    'Steering rack worn':
        'Inspect and replace the worn steering rack, and consult a mechanic for further diagnosis and repair.',
    'Steering column clunk':
        'Inspect and lubricate or replace worn steering column components, and consult a mechanic if the clunking continues.',
    'Steering wheel free play':
        'Inspect and adjust the steering system to reduce free play, and consult a mechanic for further diagnosis.',
    'Steering wheel jerks':
        'Inspect and lubricate the steering components, and consult a mechanic if the jerking persists.',

//ELECTRICAL

    'Alternator belt slipping':
        'Inspect and replace the slipping alternator belt, and consult a mechanic if the issue persists.',
    'Battery low fluid':
        'Add distilled water to the battery if applicable, and consult a mechanic if fluid levels frequently drop.',
    'Electrical control module failure':
        'Replace the faulty electrical control module and inspect related components, and consult a mechanic if the failure recurs.',
    'Electrical wiring burning smell':
        'Inspect and repair or replace the wiring causing the burning smell, and consult a mechanic if the smell persists.',
    'Electrical wiring sparks':
        'Inspect and repair any damaged wiring causing sparks, and consult a mechanic if sparks continue.',
    'Electrical wiring disconnect':
        'Reconnect any disconnected wiring and inspect for damage, and consult a mechanic if disconnections recur.',
    'Electrical relay clicks':
        'Replace any faulty relays that are clicking, and consult a mechanic if clicking continues.',
    'Battery warning light flickering':
        'Inspect and address the cause of the flickering battery warning light, and consult a mechanic if flickering persists.',
    'Electrical system surge':
        'Inspect and repair any components causing electrical system surges, and consult a mechanic if surges continue.',
    'Battery overheating':
        'Inspect and address the cause of battery overheating, and consult a mechanic if overheating persists.',
    'Battery acid leak':
        'Clean up the leaked battery acid, repair or replace the battery, and consult a mechanic if leakage continues.',
    'Electrical sensor fault':
        'Replace the faulty electrical sensor and check related systems, and consult a mechanic if faults persist.',
    'Battery not holding voltage':
        'Replace the battery and inspect the charging system, and consult a mechanic if the issue continues.',
    'Electrical wiring cut':
        'Repair or replace any cut wiring, and consult a mechanic if wiring issues persist.',
    'Electrical grounding corrosion':
        'Clean and repair any corroded grounding connections, and consult a mechanic if corrosion continues.',
    'Alternator voltage fluctuation':
        'Inspect and repair or replace the alternator to stabilize voltage, and consult a mechanic if fluctuations persist.',
    'Battery losing charge in cold':
        'Replace the battery with one rated for colder temperatures and inspect the charging system, and consult a mechanic if the issue persists.',
    'Electrical fuse box melt':
        'Replace the melted fuse box and inspect for underlying issues, and consult a mechanic if melting continues.',
    'Battery cable fray':
        'Replace frayed battery cables, and consult a mechanic if fraying continues.',
    'Electrical relay buzzing':
        'Replace faulty relays that are buzzing, and consult a mechanic if buzzing persists.',
    'Electrical component failure':
        'Identify and replace the failed electrical component, and consult a mechanic if failures recur.',
    'Electrical wiring harness fault':
        'Inspect and repair or replace the faulty wiring harness, and consult a mechanic if issues continue.',
    'Electrical system draining fast':
        'Identify and repair any components causing rapid electrical system drain, and consult a mechanic if the issue persists.',
    'Battery not charging':
        'Inspect the alternator and charging system, and consult a mechanic if the battery continues not to charge.',
    'Battery dead':
        'Jump-start or replace the battery, and consult a mechanic if the problem persists.',
    'Battery drains quickly':
        'Check for electrical parasitic drains and inspect the charging system. Consult a mechanic if the issue continues.',
    'Battery corrosion':
        'Clean the battery terminals and apply corrosion inhibitor. Consult a mechanic if corrosion recurs.',
    'Battery light on':
        'Inspect the battery and charging system, and consult a mechanic if the battery light remains on.',
    'Battery won\'t hold charge':
        'Replace the battery or inspect the charging system. Consult a mechanic if the problem persists.',
    'Electrical short':
        'Inspect and repair the affected wiring or components. Consult a mechanic for further diagnosis.',
    'Electrical system failure':
        'Perform a diagnostic check on the electrical system and consult a mechanic for repairs.',
    'Electrical fuse blown':
        'Replace the blown fuse and inspect the circuit for any underlying issues. Consult a mechanic if fuses blow frequently.',
    'Alternator not charging':
        'Inspect and repair or replace the alternator, and consult a mechanic if charging issues persist.',
    'Alternator noise':
        'Inspect and replace the faulty alternator bearings or components, and consult a mechanic if noise continues.',
    'Alternator belt squeal':
        'Inspect and tighten or replace the alternator belt, and consult a mechanic if squealing persists.',
    'Wiring harness damage':
        'Inspect and repair or replace the damaged wiring harness, and consult a mechanic for further diagnosis.',
    'Electrical relay failure':
        'Inspect and replace the faulty relay, and consult a mechanic for further diagnosis if issues persist.',
    'Battery cables loose':
        'Tighten the battery cables and ensure proper connections. Consult a mechanic if the problem continues.',
    'Battery terminal corrosion':
        'Clean the battery terminals and apply corrosion inhibitor. Consult a mechanic if corrosion recurs.',
    'Electrical circuit failure':
        'Inspect and repair the faulty electrical circuit, and consult a mechanic for further diagnosis.',
    'Electrical parasitic drain':
        'Inspect and repair any electrical components causing parasitic drain. Consult a mechanic if the drain persists.',
    'Electrical wiring short':
        'Inspect and repair the shorted wiring, and consult a mechanic for further diagnosis if needed.',
    'Electrical connector corrosion':
        'Clean or replace corroded electrical connectors, and consult a mechanic if issues persist.',
    'Battery overcharging':
        'Inspect and repair or replace the alternator or voltage regulator. Consult a mechanic if overcharging continues.',
    'Electrical system reset':
        'Perform a reset of the electrical system and consult a mechanic if issues persist.',
    'Electrical grounding issue':
        'Inspect and repair the grounding connections, and consult a mechanic for further diagnosis if needed.',
    'Alternator overcharging':
        'Inspect and repair or replace the alternator or voltage regulator, and consult a mechanic if overcharging continues.',
    'Battery power loss':
        'Inspect and replace the battery or charging system components. Consult a mechanic if power loss persists.',
    'Electrical wiring fray':
        'Inspect and repair or replace frayed wiring, and consult a mechanic for further diagnosis if needed.',
    'Battery drains overnight':
        'Check for electrical parasitic drains and inspect the charging system. Consult a mechanic if the battery drains overnight.',
    'Electrical dim headlights':
        'Inspect and replace the alternator or charging system components, and consult a mechanic if headlights remain dim.',
    'Electrical malfunction light':
        'Perform a diagnostic check on the electrical system and consult a mechanic for repairs.',

//AC
    'A/C expansion valve failure':
        'Replace the faulty A/C expansion valve, and consult a mechanic to ensure proper operation and function.',
    'Heater core flushing':
        'Perform a heater core flush to clear any blockages or contaminants, and consult a mechanic if issues persist.',
    'A/C not cooling evenly':
        'Inspect and repair the A/C system for issues causing uneven cooling, and consult a mechanic if the problem continues.',
    'Heater vent stuck':
        'Repair or replace the stuck heater vent mechanism, and consult a mechanic if the vent continues to malfunction.',
    'A/C low refrigerant pressure':
        'Recharge the A/C system with refrigerant and check for leaks, and consult a mechanic if low pressure issues persist.',
    'Heater switch malfunction':
        'Replace the faulty heater switch, and consult a mechanic to ensure proper installation and function.',
    'A/C system clogging':
        'Inspect and clear any clogs in the A/C system components, and consult a mechanic if clogging continues.',
    'Heater core airlock':
        'Bleed the heater core to remove airlocks, and consult a mechanic if the issue persists.',
    'A/C compressor relay stuck':
        'Replace the faulty A/C compressor relay, and consult a mechanic to ensure proper operation.',
    'Heater knob broken':
        'Replace the broken heater knob, and consult a mechanic if issues with the knob continue.',
    'A/C refrigerant overcharge':
        'Recover excess refrigerant from the A/C system, and consult a mechanic if overcharging issues persist.',
    'Heater fan relay failure':
        'Replace the faulty heater fan relay, and consult a mechanic to ensure proper function.',
    'A/C system vacuum leak':
        'Inspect and repair any vacuum leaks in the A/C system, and consult a mechanic if leaks continue.',
    'Heater air not circulating':
        'Inspect and repair the heater air circulation system, and consult a mechanic if air circulation issues persist.',
    'A/C cabin filter replacement':
        'Replace the cabin air filter, and consult a mechanic to ensure proper installation and function.',
    'Heater air smells burnt':
        'Inspect and repair any issues causing burnt smells in the heater, and consult a mechanic if the smell continues.',
    'A/C idle pressure issues':
        'Inspect and repair the A/C system for idle pressure issues, and consult a mechanic if problems persist.',
    'Heater blowing only hot air':
        'Inspect and repair the heater system to ensure it can blow cool air as well, and consult a mechanic if the issue continues.',
    'A/C hose rupture':
        'Replace the ruptured A/C hose, and consult a mechanic to ensure proper operation and prevent leaks.',
    'Heater not responsive':
        'Inspect and repair the heater control system to address responsiveness issues, and consult a mechanic if problems persist.',
    'A/C system freezing up':
        'Inspect and repair the A/C system to prevent freezing, and consult a mechanic if freezing continues.',
    'Heater duct leak':
        'Repair the leaking heater duct, and consult a mechanic to ensure proper installation and function.',
    'A/C system recharging':
        'Recharge the A/C system with refrigerant and check for leaks, and consult a mechanic if recharging issues persist.',
    'Heater fan intermittent':
        'Inspect and repair the heater fan for intermittent operation, and consult a mechanic if issues continue.',
    'A/C drain line clog':
        'Clear any clogs in the A/C drain line, and consult a mechanic if clogging issues persist.',
    'Heater mode door stuck':
        'Inspect and repair the heater mode door mechanism, and consult a mechanic if the door continues to stick.',
    'A/C fuse replacement':
        'Replace the faulty A/C fuse, and consult a mechanic if fuse issues persist.',
    'Heater control module short':
        'Replace the faulty heater control module, and consult a mechanic to ensure proper installation and function.',
    'A/C line leak detection':
        'Inspect and repair any leaks in the A/C lines, and consult a mechanic if leaks continue.',
    'Heater cable adjustment':
        'Adjust or replace the heater control cable, and consult a mechanic to ensure proper operation.',
    'A/C blowing hot intermittently':
        'Inspect and repair the A/C system to address intermittent hot blowing issues, and consult a mechanic if problems persist.',
    'Heater air temperature drop':
        'Inspect and repair the heater system to address temperature drops, and consult a mechanic if issues continue.',
    'A/C temperature control issue':
        'Inspect and repair the A/C temperature control system, and consult a mechanic if control issues persist.',
    'Heater not turning off':
        'Inspect and repair the heater control system to ensure it turns off properly, and consult a mechanic if issues continue.',
    'A/C hissing from vents':
        'Inspect and repair any issues causing hissing noises from the A/C vents, and consult a mechanic if the noise persists.',
    'Heater air distribution problem':
        'Inspect and repair the heater air distribution system, and consult a mechanic if distribution issues persist.',
    'A/C control panel failure':
        'Replace the faulty A/C control panel, and consult a mechanic to ensure proper installation and operation.',
    'Heater vent not opening':
        'Inspect and repair or replace the heater vent mechanism, and consult a mechanic if the issue persists.',
    'A/C system overpressure':
        'Inspect and repair any issues causing overpressure, and consult a mechanic if the problem continues.',
    'Heater fan speed issues':
        'Check and repair the heater fan speed control and related components, and consult a mechanic if issues persist.',
    'A/C evaporator leak':
        'Repair or replace the leaking A/C evaporator, and recharge the A/C system, and consult a mechanic if the leak continues.',
    'Heater stuck on hot':
        'Inspect and repair or replace the heater control valve or thermostat, and consult a mechanic if the issue continues.',
    'A/C compressor clutch not engaging':
        'Inspect and repair the A/C compressor clutch or related components, and consult a mechanic if the clutch continues not to engage.',
    'Heater blower motor failure':
        'Replace the faulty heater blower motor, and consult a mechanic to ensure proper installation and operation.',
    'A/C cycling on and off':
        'Inspect and repair the A/C system, including the compressor and sensors, and consult a mechanic if cycling continues.',
    'Heater valve stuck':
        'Replace the faulty heater valve, and consult a mechanic to ensure proper operation.',
    'A/C cabin air filter clog':
        'Replace the clogged A/C cabin air filter, and consult a mechanic if the issue persists.',
    'Heater core coolant leak':
        'Repair or replace the leaking heater core and inspect the cooling system, and consult a mechanic if the leak continues.',
    'A/C line freezing':
        'Check and repair any issues causing A/C line freezing, and consult a mechanic if the problem persists.',
    'Heater blower not adjusting':
        'Inspect and repair the heater blower motor or control system, and consult a mechanic if the blower does not adjust properly.',
    'A/C fan not engaging':
        'Inspect and repair the A/C fan or related components, and consult a mechanic if the fan continues not to engage.',
    'Heater core replacement':
        'Replace the faulty heater core, and consult a mechanic to ensure proper installation and function.',
    'A/C control module failure':
        'Replace the faulty A/C control module, and consult a mechanic to ensure proper installation and operation.',
    'Heater duct blockage':
        'Clear any blockages in the heater ducts, and consult a mechanic if duct blockage continues.',
    'A/C noise on startup':
        'Inspect and repair the A/C system for any issues causing noise on startup, and consult a mechanic if the noise persists.',
    'Heater leaking inside cabin':
        'Inspect and repair the source of the heater leak inside the cabin, and consult a mechanic if the issue continues.',
    'A/C fuse blown':
        'Replace the blown A/C fuse and inspect the system for any issues, and consult a mechanic if the fuse continues to blow.',
    'Heater control cable snapped':
        'Replace the snapped heater control cable, and consult a mechanic to ensure proper operation.',
    'A/C relay failure':
        'Replace the faulty A/C relay, and consult a mechanic to ensure proper installation and function.',
    'Heater air flow weak':
        'Inspect and repair the heater fan or related components, and consult a mechanic if air flow remains weak.',
    'A/C compressor seizure':
        'Replace the seized A/C compressor, and consult a mechanic to ensure proper installation and operation.',
    'Heater temperature control failure':
        'Inspect and repair the heater temperature control system, and consult a mechanic if the control continues to fail.',
    'A/C lines sweating':
        'Inspect and repair the A/C lines for any issues causing sweating, and consult a mechanic if the problem persists.',
    'Heater not defrosting':
        'Check and repair the heater and defrosting system components, and consult a mechanic if defrosting issues continue.',
    'A/C making hissing noise':
        'Inspect and repair any issues causing the A/C to make a hissing noise, and consult a mechanic if the noise persists.',
    'Heater stuck on cold':
        'Inspect and repair or replace the heater control valve or thermostat, and consult a mechanic if the heater continues to stay cold.',
    'A/C not blowing cold air':
        'Check and recharge the A/C refrigerant, inspect for leaks, and consult a mechanic if the issue persists.',
    'Heater not working':
        'Inspect and repair the heater components, check the heater core and thermostat, and consult a mechanic if problems continue.',
    'A/C compressor failure':
        'Replace the faulty A/C compressor, and consult a mechanic to ensure proper installation and system functionality.',
    'A/C refrigerant leak':
        'Locate and repair the refrigerant leak, and recharge the A/C system, and consult a mechanic if leaks continue.',
    'Heater core blockage':
        'Flush the heater core to remove blockages, and consult a mechanic if the issue persists.',
    'A/C blowing warm air':
        'Inspect the A/C system for refrigerant levels and leaks, and consult a mechanic if the issue continues.',
    'A/C clutch failure':
        'Replace the faulty A/C clutch, and consult a mechanic to ensure proper installation and operation.',
    'Heater fan not working':
        'Inspect and replace the heater fan or related components, and consult a mechanic if the fan continues to malfunction.',
    'A/C condenser leak':
        'Repair or replace the leaking A/C condenser, and recharge the A/C system, and consult a mechanic if leaks persist.',
    'Heater blowing cold air':
        'Check and repair the heater components, inspect the thermostat and heater core, and consult a mechanic if the issue continues.',
    'A/C fan noise':
        'Inspect and repair or replace the A/C fan, and consult a mechanic if the noise persists.',
    'A/C evaporator blockage':
        'Clear any blockages in the A/C evaporator, and consult a mechanic if the issue continues.',
    'A/C not turning on':
        'Check and repair any electrical issues, inspect the A/C fuse and relay, and consult a mechanic if the problem persists.',
    'Heater control malfunction':
        'Inspect and repair or replace the heater control components, and consult a mechanic if the malfunction continues.',
    'A/C fan speed issues':
        'Inspect and repair the A/C fan or related components, and consult a mechanic if fan speed problems persist.',
    'Heater smells':
        'Inspect and clean the heater system and cabin air filter, and consult a mechanic if unpleasant smells continue.',
    'A/C refrigerant low':
        'Recharge the A/C refrigerant and check for leaks, and consult a mechanic if refrigerant levels continue to drop.',
    'Heater hose leak':
        'Repair or replace the leaking heater hose, and consult a mechanic if the issue persists.',
    'A/C condenser blockage':
        'Clear any blockages in the A/C condenser, and consult a mechanic if the blockage continues.',
    'A/C blower motor failure':
        'Replace the faulty A/C blower motor, and consult a mechanic to ensure proper installation and operation.',
    'Heater control valve failure':
        'Replace the faulty heater control valve, and consult a mechanic if the issue continues.',
    'A/C smells musty':
        'Clean the A/C evaporator and replace the cabin air filter, and consult a mechanic if musty smells persist.',
    'Heater not blowing':
        'Inspect and repair the heater fan and related components, and consult a mechanic if the heater continues not to blow.',
    'A/C compressor noise':
        'Inspect and replace the faulty A/C compressor, and consult a mechanic to address the source of the noise.',
    'Heater core corrosion':
        'Replace the corroded heater core, and consult a mechanic to address the cause of the corrosion.',
    'A/C pressure loss':
        'Inspect and repair any leaks in the A/C system, and recharge the refrigerant, and consult a mechanic if pressure loss continues.',
    'Heater temperature fluctuation':
        'Inspect and repair the heater control system and thermostat, and consult a mechanic if temperature fluctuations persist.',
    'A/C vents not working':
        'Inspect and repair the A/C vent system, and consult a mechanic if the vents continue to malfunction.',
    'Heater air not hot':
        'Check and repair the heater core and thermostat, and consult a mechanic if the heater air remains cold.',
    'A/C condenser fan failure':
        'Replace the faulty A/C condenser fan, and consult a mechanic to ensure proper operation and cooling.',
    'Heater fan noise':
        'Inspect and repair or replace the heater fan, and consult a mechanic if the noise persists.',
    'A/C refrigerant recharge':
        'Recharge the A/C refrigerant, and inspect for leaks, and consult a mechanic if the system continues to lose refrigerant.',
    'Heater core bypass issue':
        'Inspect and repair or replace the heater core bypass valve, and consult a mechanic if the issue continues.',

//MISCELENIOUS
    'Axle shaft clicking':
        'Inspect and replace the damaged axle shaft or CV joint. Consult a mechanic to ensure proper drivetrain function.',
    'Wheel alignment drift':
        'Perform a wheel alignment to correct drift issues. Consult a mechanic if the problem persists after alignment.',
    'Windshield washer pump failure':
        'Replace the faulty windshield washer pump, and consult a mechanic if the problem continues or if there are issues with the washer system.',
    'Head gasket failure':
        'Replace the head gasket and address any related engine damage. Consult a mechanic for a thorough diagnosis and repair.',
    'Valve train noise':
        'Inspect and repair or replace any components in the valve train causing noise, such as lifters or rocker arms. Consult a mechanic for a thorough check.',
    'Piston ring wear':
        'Inspect and replace worn piston rings, and consult a mechanic to address any related engine performance issues.',
    'Turbo wastegate rattle':
        'Inspect and repair or replace the turbo wastegate if rattling. Consult a mechanic for a thorough diagnosis of the turbo system.',
    'Fuel vapor leak':
        'Inspect and repair any sources of fuel vapor leaks, such as fuel lines or connections. Consult a mechanic for a thorough check.',
    'Radiator hose collapse':
        'Replace the collapsed radiator hose, and consult a mechanic to ensure proper cooling system function.',
    'Coolant reservoir crack':
        'Replace the cracked coolant reservoir, and consult a mechanic to ensure proper cooling system function and prevent leaks.',
    'Radiator fan shroud noise':
        'Inspect and repair or replace the radiator fan shroud if noisy. Consult a mechanic if the noise persists or affects cooling performance.',
    'Fog light condensation':
        'Inspect and repair any seals or vents causing condensation in the fog light. Consult a mechanic to ensure proper light function and prevent moisture buildup.',
    'Headlight flickering':
        'Inspect the headlight connections and wiring. Replace any faulty components or bulbs, and consult a mechanic if the flickering persists.',
    'Blower motor failure':
        'Replace the faulty blower motor, and consult a mechanic to ensure proper operation of the HVAC system.',
    'Wiper motor noise':
        'Inspect and repair or replace the noisy wiper motor, and consult a mechanic if the noise continues.',
    'Window regulator failure':
        'Replace the faulty window regulator, and consult a mechanic to ensure smooth operation of the power windows.',
    'Door lock actuator noise':
        'Inspect and replace the noisy door lock actuator, and consult a mechanic if the noise persists or if locking issues continue.',
    'Sunroof leak':
        'Inspect and repair the sunroof seals or drainage system to address the leak, and consult a mechanic for a thorough diagnosis.',
    'Trunk latch sticking':
        'Lubricate or replace the sticking trunk latch, and consult a mechanic if the problem persists.',
    'Fuel door not opening':
        'Inspect and repair the fuel door mechanism or actuator, and consult a mechanic if the issue persists.',
    'Hood latch failure':
        'Inspect and replace the faulty hood latch, and consult a mechanic to ensure proper hood operation and security.',
    'Tire pressure sensor fault':
        'Replace the faulty tire pressure sensor, and consult a mechanic to ensure accurate tire pressure readings and safety.',
    'ABS module failure':
        'Inspect and replace the faulty ABS module, and consult a mechanic to ensure proper anti-lock braking system function.',
    'Oil filter housing leak':
        'Replace the leaking oil filter housing, and consult a mechanic to ensure proper oil filtration and engine performance.',
    'Coolant hose leak':
        'Replace the leaking coolant hose, and consult a mechanic to ensure proper cooling system function and prevent overheating.',
    'Idle air control valve failure':
        'Replace the faulty idle air control valve, and consult a mechanic to ensure proper engine idle and performance.',
    'PCV valve clogging':
        'Inspect and replace the clogged PCV valve, and consult a mechanic to ensure proper engine ventilation and performance.',
    'Exhaust valve ticking':
        'Inspect and repair or replace the exhaust valve if ticking, and consult a mechanic for a thorough diagnosis.',
    'Timing belt slip':
        'Inspect and replace the timing belt if slipping, and consult a mechanic to ensure proper timing and engine performance.',
    'Fuel pump relay click':
        'Inspect and replace the faulty fuel pump relay if clicking, and consult a mechanic to ensure proper fuel delivery.',
    'Cabin air filter clogging':
        'Replace the clogged cabin air filter, and consult a mechanic to ensure proper air flow and HVAC system function.',
    'Oil pan gasket leak':
        'Replace the oil pan gasket to stop the leak, and consult a mechanic to ensure proper sealing and prevent oil loss.',
    'Exhaust manifold gasket blow':
        'Replace the blown exhaust manifold gasket, and consult a mechanic to ensure proper exhaust system function and prevent leaks.',
    'Engine knocking on acceleration':
        'Inspect and repair the engine components, and consult a mechanic to address knocking noises during acceleration.',
    'Radiator cap leak':
        'Replace the leaking radiator cap, and consult a mechanic to ensure proper sealing and pressure maintenance in the cooling system.',
    'Power steering fluid leak':
        'Inspect and repair the source of the power steering fluid leak, and consult a mechanic to ensure proper steering operation.',
    'Power steering pump noise':
        'Inspect and repair or replace the noisy power steering pump, and consult a mechanic to address any underlying issues.',
    'Steering wheel stuck':
        'Inspect and repair the steering system to address the stuck steering wheel, and consult a mechanic for a thorough diagnosis.',
    'Shock absorber leak':
        'Replace the leaking shock absorber, and consult a mechanic to ensure proper suspension performance and safety.',
    'Strut mount noise':
        'Inspect and replace the strut mount if noisy, and consult a mechanic to ensure proper suspension alignment and function.',
    'Differential noise':
        'Inspect and repair the differential to address any unusual noises, and consult a mechanic for a thorough diagnosis.',
    'Driveshaft vibration':
        'Inspect and repair or replace the driveshaft if vibrating, and consult a mechanic to address any underlying issues.',
    'CV joint noise':
        'Inspect and replace the faulty CV joint, and consult a mechanic to ensure proper drivetrain function and safety.',
    'Wheel bearing play':
        'Inspect and replace the wheel bearing if there is play, and consult a mechanic to ensure proper wheel alignment and safety.',
    'Brake rotor warp':
        'Replace or resurface the warped brake rotors, and consult a mechanic to ensure proper braking performance and safety.',
    'Clutch slipping':
        'Inspect and replace the worn clutch, and consult a mechanic to ensure proper clutch function and transmission operation.',
    'Clutch pedal noise':
        'Inspect and repair or replace the components causing noise in the clutch pedal, and consult a mechanic if the noise persists.',
    'Fuel filter clogging':
        'Replace the clogged fuel filter, and consult a mechanic to ensure proper fuel flow and engine performance.',
    'Fuel pump humming':
        'Inspect and replace the faulty fuel pump if humming, and consult a mechanic to ensure proper fuel delivery and engine operation.',
    'Oxygen sensor failure':
        'Replace the faulty oxygen sensor, and consult a mechanic to ensure proper engine emissions and fuel efficiency.',
    'Mass air flow sensor fault':
        'Replace the faulty mass air flow sensor, and consult a mechanic to ensure proper air-fuel mixture and engine performance.',
    'Throttle body sticking':
        'Inspect and clean or replace the sticking throttle body, and consult a mechanic to ensure proper engine acceleration and function.',
    'EGR valve clogging':
        'Inspect and clean or replace the clogged EGR valve, and consult a mechanic to ensure proper exhaust gas recirculation and engine performance.',
    'Turbocharger noise':
        'Inspect and repair or replace the noisy turbocharger, and consult a mechanic to ensure proper turbo operation and performance.',
    'Turbo lag':
        'Inspect and repair any issues causing turbo lag, and consult a mechanic to ensure proper turbocharger performance and responsiveness.',
    'Wastegate failure':
        'Inspect and repair or replace the faulty wastegate, and consult a mechanic to ensure proper turbocharger boost control and performance.',
    'Exhaust drone':
        'Inspect and repair the exhaust system to address drone noise, and consult a mechanic for a thorough diagnosis.',
    'Ignition coil failure':
        'Replace the faulty ignition coil, and consult a mechanic to ensure proper installation and function.',
    'Spark plug fouling':
        'Replace the fouled spark plugs, and check the ignition system for any underlying issues.',
    'Timing belt noise':
        'Inspect and replace the timing belt if necessary, and consult a mechanic to ensure proper installation and tension.',
    'Belt tensioner failure':
        'Replace the faulty belt tensioner, and consult a mechanic to ensure proper belt tension and operation.',
    'Serpentine belt squeal':
        'Inspect and replace the serpentine belt if worn, and check the tensioner and pulleys for issues.',
    'Thermostat stuck closed':
        'Replace the faulty thermostat, and consult a mechanic to ensure proper engine temperature regulation.',
    'Valve cover gasket leak':
        'Replace the valve cover gasket, and consult a mechanic to ensure proper sealing and prevent oil leaks.',
    'Engine ticking noise':
        'Inspect and repair the engine to address ticking noises, and consult a mechanic if the noise persists.',
    'Engine misfire at idle':
        'Inspect and repair the ignition system, fuel system, and engine components to resolve misfire issues at idle.',
    'Engine oil consumption':
        'Inspect and repair any issues causing excessive oil consumption, and consult a mechanic for a thorough diagnosis.',
    'Engine rough idle':
        'Inspect and repair the ignition system, fuel system, and engine components to address rough idle issues.',
    'Engine stalling at stop':
        'Inspect and repair the fuel system, ignition system, and engine components to resolve stalling issues at stops.',
    'Radiator clogging':
        'Flush and clean the radiator to remove clogs, and consult a mechanic if clogging persists.',
    'Camshaft sensor failure':
        'Replace the faulty camshaft sensor, and consult a mechanic to ensure proper engine timing and operation.',
    'Crankshaft sensor fault':
        'Replace the faulty crankshaft sensor, and consult a mechanic to ensure proper engine timing and operation.',
    'Timing chain rattle':
        'Inspect and replace the timing chain if necessary, and consult a mechanic to address any rattling noises.',
    'Oil pressure low':
        'Inspect and repair the oil pressure system, and consult a mechanic to address low oil pressure issues.',
    'Oil pump failure':
        'Replace the faulty oil pump, and consult a mechanic to ensure proper oil circulation and engine protection.',
    'Fuel injector noise':
        'Inspect and repair the fuel injectors if making unusual noises, and consult a mechanic if the issue persists.',
    'Piston slap noise':
        'Inspect and repair the engine to address piston slap noises, and consult a mechanic for a thorough diagnosis.',
    'Crankshaft seal leak':
        'Replace the leaking crankshaft seal, and consult a mechanic to ensure proper sealing and prevent oil leaks.',
    'Timing cover leak':
        'Replace the timing cover gasket or seal, and consult a mechanic to address any leaks and ensure proper sealing.',
  };

  // Define a list of medical keywords including mental health terms and additional issues
  final mechanicalKeywords = {
    //Engine PRoblem
    'Power seat failure',
    'Door handle sticking',
    'Tail light bulb failure',
    'Engine noise',
    'Engine misfire',
    'Engine overheating',
    'Engine stalling',
    'Engine knocking',
    'Engine vibration',
    'Engine won\'t start',
    'Engine sputtering',
    'Engine power loss',
    'Engine surging',
    'Engine idling rough',
    'Engine smoke',
    'Engine shaking',
    'Engine ticking',
    'Engine overheating warning',
    'Engine coolant leak',
    'Engine warning light',
    'Engine oil leak',
    'Engine hesitation',
    'Engine hard start',
    'Engine oil pressure low',
    'Engine rattling',
    'Engine cuts out',
    'Engine backfire',
    'Engine dies when idling',
    'Engine compression issues',
    'Engine fuel leak',
    'Engine mount broken',
    'Engine performance drop',
    'Engine rough running',
    'Engine detonation',
    'Engine sluggishness',
    'Engine bearing failure',
    'Engine timing off',
    'Engine misalignment',
    'Engine air leak',
    'Engine vacuum leak',
    'Engine seals worn',
    'Engine belt noise',
    'Engine excessive noise',
    'Engine squeaking',
    'Engine burning oil',
    'Engine oil sludge',
    'Engine coolant bubbling',
    'Engine coolant boiling',
    'Engine intake leak',
    'Engine surge on acceleration',
    'Engine whistling noise',
    'Engine overheating at idle',
    'Engine running rich',
    'Engine running lean',
    'Engine coolant low',
    'Engine hydraulic failure',
    'Engine gasket failure',
    'Engine crankshaft issues',
    'Engine camshaft issues',
    'Engine overheating on hills',
    'Engine pinging',
    'Engine mount failure',
    'Engine sensor failure',
    'Engine throttle issues',
    'Engine turbocharger failure',
    'Engine valve tapping',
    'Engine fuel pump failure',
    'Engine air filter clogged',
    'Engine coolant temperature high',
    'Engine stalls after start',
    'Engine idles too fast',
    'Engine idles too slow',
    'Engine jerking',
    'Engine abnormal noise',
    'Engine squeal on start',
    'Engine overheating quickly',
    'Engine overheating slowly',
    'Engine oil burning smell',

    // 'Transmission Issues',
    'Transmission slipping',
    'Transmission leak',
    'Transmission won\'t shift',
    'Transmission hard shifting',
    'Transmission noise',
    'Transmission overheating',
    'Transmission jerking',
    'Transmission fluid low',
    'Transmission fluid leak',
    'Transmission fluid dirty',
    'Transmission grinding noise',
    'Transmission whine',
    'Transmission failure',
    'Transmission shifting delay',
    'Transmission clunking',
    'Transmission overdrive problems',
    'Transmission won\'t go in gear',
    'Transmission slipping gears',
    'Transmission sluggish',
    'Transmission stuck in gear',
    'Transmission burning smell',
    'Transmission overheating light',
    'Transmission solenoid failure',
    'Transmission fluid burnt',
    'Transmission whistling noise',
    'Transmission surging',
    'Transmission vibration',
    'Transmission fluid leak detection',
    'Transmission fluid low indicator',
    'Transmission overheating alarm',
    'Transmission fluid burnt odor',
    'Transmission torque converter issues',
    'Transmission jerky acceleration',
    'Transmission reverse gear failure',
    'Transmission seal leak',
    'Transmission shuddering',
    'Transmission fluid check',
    'Transmission pump failure',
    'Transmission linkage issues',
    'Transmission grinding on shifting',
    'Transmission sensor fault',
    'Transmission computer failure',
    'Transmission clutch slipping',
    'Transmission fluid contamination',
    'Transmission mount failure',
    'Transmission oil change',
    'Transmission synchronizer failure',
    'Transmission noise at idle',

    'Transmission shifts hard',
    'Transmission won\'t downshift',
    'Transmission hose leak',
    'Transmission pressure issues',
    'Transmission gear slip',
    'Transmission kick down failure',
    'Transmission gear noise',
    'Transmission erratic shifting',
    'Transmission won\'t upshift',
    'Transmission slipping in drive',
    'Transmission fluid level check',
    'Transmission whining in reverse',
    'Transmission rumbling noise',
    'Transmission gear grind',
    'Transmission control unit failure',
    'Transmission abrupt shift',
    'Transmission solenoid stuck',
    'Transmission module malfunction',
    'Transmission mount wear',
    'Transmission pump noise',
    'Transmission fluid flush',
    'Transmission light on dashboard',

    // 'Engine Overheating',
    'Overheating radiator',
    'Coolant leak',
    'Radiator fan failure',
    'Thermostat stuck',
    'Coolant boiling',
    'Coolant temperature high',
    'Water pump failure',
    'Radiator clogged',
    'Cooling system failure',
    'Overheating in traffic',
    'Coolant reservoir leak',
    'Head gasket blown',
    'Coolant overflow',
    'Radiator hose burst',
    'Heater core leak',
    'Overheating warning light',
    'Coolant level low',
    'Radiator fan not running',
    'Thermostat failure',
    'Cooling fan relay issue',
    'Water pump leak',
    'Coolant reservoir empty',
    'Overheating while idling',
    'Cooling system pressure loss',
    'Radiator cap failure',
    'Overheating at high speeds',
    'Coolant bubbling in reservoir',
    'Engine temperature gauge high',
    'Coolant smell',

    'Heater not blowing hot air',
    'Radiator fins damaged',
    'Engine overheating uphill',
    'Coolant system airlock',
    'Radiator coolant flush',
    'Overheating after coolant change',
    'Coolant mixture incorrect',
    'Radiator coolant contaminated',
    'Water pump noise',
    'Coolant dripping',
    'Radiator fan short circuit',
    'Radiator leak sealant',
    'Coolant loss without leak',
    'Overheating in cold weather',
    'Radiator fan running continuously',
    'Coolant rust',
    'Overheating at highway speeds',
    'Thermostat replacement',
    'Overheating after engine shutoff',
    'Coolant bypass leak',
    'Radiator fluid low',
    'Water pump belt failure',
    'Coolant hose disconnect',
    'Radiator core crack',
    'Cooling system flush',

    //SUSPENSION PROBLEMS
    'Suspension noise',
    'Suspension creaking',
    'Suspension squeaking',
    'Suspension knocking',
    'Suspension failure',
    'Suspension bushing wear',
    'Suspension alignment issues',
    'Suspension sagging',
    'Suspension uneven ride height',
    'Suspension squeal',
    'Suspension bounce',
    'Suspension bottoming out',
    'Suspension stiffness',
    'Suspension rough ride',
    'Suspension clunking',
    'Suspension leaking fluid',
    'Suspension rattling',
    'Suspension squeaky noise',
    'Suspension popping noise',
    'Suspension grinding noise',
    'Suspension loose handling',
    'Suspension pulling to one side',
    'Suspension wobbling',
    'Suspension thudding',
    'Suspension play in steering',
    'Suspension vibration',
    'Suspension strut failure',
    'Suspension shock absorber leak',
    'Suspension spring failure',
    'Suspension rebound issues',
    'Suspension ride control issues',
    'Suspension height sensor failure',
    'Suspension airbag leak',
    'Suspension control arm failure',
    'Suspension ball joint wear',
    'Suspension stabilizer bar issue',
    'Suspension strut mount noise',
    'Suspension sagging on one side',
    'Suspension noise over bumps',
    'Suspension rattling at low speeds',
    'Suspension worn shocks',
    'Suspension lift kit problems',
    'Suspension uneven tire wear',
    'Suspension coil spring noise',
    'Suspension alignment required',
    'Suspension anti-roll bar issue',
    'Suspension shock absorber failure',
    'Suspension torsion bar issue',
    'Suspension camber misalignment',
    'Suspension toe misalignment',
    'Suspension caster misalignment',
    'Suspension ride height sensor',

    'Suspension shock oil leak',
    'Suspension hard on bumps',
    'Suspension creaks on turning',
    'Suspension air compressor failure',
    'Suspension air leak detection',
    'Suspension shock absorber noise',
    'Suspension bushing noise',
    'Suspension loose feeling',
    'Suspension thumping noise',
    'Suspension sway bar failure',
    'Suspension control arm replacement',
    'Suspension harsh ride',
    'Suspension uneven ground clearance',
    'Suspension steering instability',
    'Suspension dampening failure',
    'Suspension deflated air spring',
    'Suspension noise while cornering',
    'Suspension air valve malfunction',
    'Suspension cracked coil spring',
    'Suspension scraping sound',
    'Suspension squeak at low speed',
    'Suspension malfunction light',
    'Suspension excessive roll',
    'Suspension leak in shocks',
    'Suspension loose linkage',
    'Suspension deflated airbag',
    'Suspension noise when braking',
    'Suspension thud on impact',
    'Suspension air suspension leak',
    'Suspension rear sagging',
    'Suspension stiff steering',
    'Suspension failure light',
    'Suspension noise when reversing',
    'Suspension top strut bearing issue',
    'Suspension torsion bar loose',
    'Suspension road noise increase',
    'Suspension clunk over potholes',
    'Suspension bumpy ride',

//BRAKE ISSUES
    'Brake squeaking',
    'Brake grinding',
    'Brake fade',
    'Brake pedal spongy',
    'Brake warning light',
    'Brake fluid leak',
    'Brake pedal vibration',
    'Brake pulling to one side',
    'Brake sticking',
    'Brake pad wear',
    'Brake rotor warping',
    'Brake line rust',
    'Brake hose damage',
    'Brake fluid contamination',
    'Brake pulsation',
    'Brake noise while stopping',
    'Brake pedal soft',
    'Brake fluid low',
    'Brake failure',
    'Brake pad replacement',
    'Brake caliper sticking',
    'Brake rotor scoring',
    'Brake drums squealing',
    'Brake booster failure',
    'Brake master cylinder leak',
    'Brake hard pedal',
    'Brake lockup',
    'Brake imbalance',
    'Brake fluid boiling',
    'Brake warning on dashboard',
    'Brake caliper leak',
    'Brake pedal stiff',
    'Brake squeal at low speeds',
    'Brake fluid discoloration',
    'Brake system flush',
    'Brake anti-lock failure',
    'Brake light malfunction',
    'Brake hose replacement',
    'Brake dragging',
    'Brake noise when reversing',
    'Brake overheating',
    'Brake clicking noise',
    'Brake pad sensor fault',
    'Brake hydraulic leak',
    'Brake air in lines',
    'Brake squeal on initial application',
    'Brake wear sensor issue',
    'Brake vibration at high speeds',
    'Brake caliper bolt loose',
    'Brake pedal sinks',
    'Brake disc scoring',
    'Brake low vacuum',
    'Brake popping sound',
    'Brake scraping noise',
    'Brake juddering',
    'Brake squeak after rain',

    'Brake fluid reservoir crack',
    'Brake soft pedal after bleeding',
    'Brake booster vacuum leak',
    'Brake warning buzzer',
    'Brake pedal travel too long',
    'Brake fluid cap loose',
    'Brake pedal clicks',
    'Brake caliper seized',
    'Brake hose bulging',
    'Brake hard to press',
    'Brake judder under load',
    'Brake pull during braking',
    'Brake lining damage',
    'Brake fluid foaming',
    'Brake squeak in cold weather',
    'Brake binding',
    'Brake pedal vibration when turning',
    'Brake clunking noise',
    'Brake hose collapsed',
    'Brake fluid change',
    'Brake disc rust',
    'Brake sensor false alarm',
    'Brake pulsating under light braking',
    'Brake fluid leak detection',
    'Brake pedal clicking noise',
    'Brake booster whine',
    'Brake soft after sitting',
    'Brake drum out of round',
    'Brake light flickering',
    'Brake fluid evaporation',
    'Brake pad shudder',
    'Brake pedal hissing',
    'Brake squeal when warm',
    'Brake booster noise',
    'Brake groaning',
    'Brake lines spongy',
    'Brake master cylinder replacement',
    'Brake pedal goes to floor',
    'Brake vibration on acceleration',
    'Brake drag when hot',
    'Brake hard on emergency stop',
    'Brake excessive travel',
    'Brake rotor groove',
    'Brake power loss',

//STEERING ISSUES
    'Steering wheel vibration',
    'Steering pulling to one side',
    'Steering stiffness',
    'Steering wheel play',
    'Steering noise',
    'Steering wheel off-center',
    'Steering fluid leak',
    'Steering wheel binding',
    'Steering loose feel',
    'Steering jerky',
    'Steering rack noise',
    'Steering wheel hard to turn',
    'Steering column noise',
    'Steering wheel shimmy',
    'Steering pump failure',
    'Steering fluid low',
    'Steering wandering',
    'Steering grinding noise',
    'Steering wheel clicks',
    'Steering wheel shudder',
    'Steering wheel locks',
    'Steering heavy at low speed',
    'Steering pump whine',
    'Steering fluid foamy',
    'Steering wheel not returning',
    'Steering linkage loose',
    'Steering belt slipping',
    'Steering wheel resistance',
    'Steering wheel shakes on braking',
    'Steering sensor failure',
    'Steering wheel groaning',
    'Steering box leak',
    'Steering pump squeal',
    'Steering gear play',
    'Steering rattles over bumps',
    'Steering fluid foaming',
    'Steering wandering on highway',
    'Steering alignment off',
    'Steering fluid brown',
    'Steering wheel vibrates at high speed',
    'Steering rack worn',
    'Steering column clunk',
    'Steering wheel free play',
    'Steering wheel jerks',
    'Steering system flush',
    'Steering noise when turning',
    'Steering fluid change',
    'Steering hard in one direction',
    'Steering lock malfunction',
    'Steering power loss',
    'Steering wheel thumping',
    'Steering squeaks on full turn',
    'Steering belt tension',
    'Steering response delayed',
    'Steering wheel vibration on cornering',
    'Steering fluid leak detection',
    'Steering column misalignment',
    'Steering motor failure',
    'Steering wheel tight spots',
    'Steering linkages worn',
    'Steering fluid burnt',
    'Steering rack play',
    'Steering sluggishness',
    'Steering juddering'
        'Steering hydraulic leak',
    'Steering wheel creaking',
    'Steering rack leaks',
    'Steering pump overheating',
    'Steering knocking noise',
    'Steering belt squealing',
    'Steering wheel feels loose',
    'Steering wheel rattles',
    'Steering squeaking when turning',
    'Steering gear box issue',
    'Steering wheel stuck',
    'Steering pulling on acceleration',
    'Steering wheel pulsation',
    'Steering pump leak',
    'Steering fluid overheating',
    'Steering wheel stiffness on turns',
    'Steering rack vibration',
    'Steering low-speed wobble',
    'Steering pump cavitation',
    'Steering fluid aeration',
    'Steering wheel excessive vibration',

// 'Battery and Electrical Problems',
    'Battery not charging',
    'Battery dead',
    'Battery drains quickly',
    'Battery corrosion',
    'Battery light on',
    'Battery won\'t hold charge',
    'Electrical short',
    'Electrical system failure',
    'Electrical fuse blown',
    'Alternator not charging',
    'Alternator noise',
    'Alternator belt squeal',
    'Wiring harness damage',
    'Electrical relay failure',
    'Battery cables loose',
    'Battery terminal corrosion',
    'Electrical circuit failure',
    'Electrical parasitic drain',
    'Electrical wiring short',
    'Electrical connector corrosion',
    'Battery overcharging',
    'Electrical system reset',
    'Electrical grounding issue',
    'Alternator overcharging',
    'Battery power loss',
    'Electrical wiring fray',
    'Battery drains overnight',
    'Electrical dim headlights',
    'Electrical malfunction light',
    'Alternator belt slipping',
    'Battery low fluid',
    'Electrical control module failure',
    'Electrical wiring burning smell',
    'Electrical wiring sparks',
    'Electrical wiring disconnect',
    'Electrical relay clicks',
    'Battery warning light flickering',
    'Electrical system surge',
    'Battery overheating',
    'Battery acid leak',
    'Electrical sensor fault',
    'Battery not holding voltage',
    'Electrical wiring cut',
    'Electrical grounding corrosion',
    'Alternator voltage fluctuation',
    'Battery losing charge in cold',
    'Electrical fuse box melt',
    'Battery cable fray',
    'Electrical relay buzzing',
    'Electrical component failure',
    'Electrical wiring harness fault',
    'Electrical system draining fast',
    'Battery power drop',
    'Battery won\'t start car',
    'Electrical flickering lights',
    'Electrical wiring loose',
    'Battery low charge',
    'Alternator bearing noise',
    'Battery sluggish starting',
    'Electrical overload',
    'Electrical fuse loose',
    'Battery jump-start failure',

    'Electrical arcing',
    'Alternator diode failure',
    'Electrical system reset issues',
    'Electrical wiring brittle',
    'Battery voltage drop',
    'Electrical module reset',
    'Battery cables frayed',
    'Electrical circuit burn out',
    'Battery won\'t recharge',
    'Electrical grounding failure',
    'Alternator undercharging',
    'Battery cell damage',
    'Electrical wiring overheated',
    'Battery keeps dying',
    'Electrical system malfunction',
    'Electrical fuse pop',
    'Battery swollen',
    'Electrical sensor disconnect',
    'Alternator output low',
    'Battery electrolyte low',
    'Electrical flickering dashboard',
    'Battery discharging quickly',
    'Electrical gauge issues',
    'Electrical system buzzing',
    'Alternator pulley noise',
    'Battery testing failure',
    'Electrical relay overheating',
    'Electrical switch failure',
    'Battery terminal loose',
    'Electrical system cutting out',
    'Battery cables damaged',
    'Electrical motor failure',
    'Battery acid corrosion',
    'Electrical flickering headlights',
    'Battery voltage irregularity',
    'Electrical component short',
    'Alternator belt noisy',
    'Battery power fluctuating',

// 'Fuel System Issues',
    'Fuel pump failure',
    'Fuel filter clogged',
    'Fuel line leak',
    'Fuel injector failure',
    'Fuel pressure low',
    'Fuel smell in cabin',
    'Fuel tank leak',
    'Fuel pump noise',
    'Fuel pressure regulator fault',
    'Fuel rail issues',
    'Fuel vapor leak',
    'Fuel gauge incorrect',
    'Fuel system blockage',
    'Fuel cap seal failure',
    'Fuel pump relay failure',
    'Fuel injectors clogged',
    'Fuel pump whining',
    'Fuel system airlock',
    'Fuel line rust',
    'Fuel pump not priming',
    'Fuel starvation',
    'Fuel injector misfire',
    'Fuel pump relay clicking',
    'Fuel return line block',
    'Fuel pressure drop',
    'Fuel line bursting',
    'Fuel filter blockage',
    'Fuel gauge malfunction',
    'Fuel pump overheating',
    'Fuel tank sloshing',
    'Fuel leak detection',
    'Fuel line fracture',
    'Fuel pressure sensor fault',
    'Fuel pump wiring short',
    'Fuel injector leak',
    'Fuel system pressure drop',
    'Fuel pump relay buzzing',
    'Fuel line blockage',
    'Fuel pump fuse blow',
    'Fuel pressure fluctuation',
    'Fuel injector pulse issues',
    'Fuel pump humming',
    'Fuel pump fuse blown',
    'Fuel line disconnected',
    'Fuel pump module failure',
    'Fuel tank venting issue',
    'Fuel tank rust',
    'Fuel injector spray issue',
    'Fuel system vapor lock',
    'Fuel rail pressure loss',
    'Fuel pump relay malfunction',
    'Fuel leak under car',
    'Fuel pump intermittent failure',
    'Fuel line wear',
    'Fuel pump not delivering fuel',
    'Fuel injector nozzle clogging',
    'Fuel line pressure drop',
    'Fuel pressure relief valve fault',
    'Fuel pump whistling',
    'Fuel pump relay stuck',
    'Fuel vapor system leak',
    'Fuel tank level sensor fault',
    'Fuel pressure regulator leak',
    'Fuel injector misfire under load',
    'Fuel line kinked',
    'Fuel pump wiring failure',
    'Fuel pump fuse box melt',
    'Fuel rail sensor failure',
    'Fuel pressure sensor false reading',
    'Fuel line blockage detection',
    'Fuel injector stuck open',
    'Fuel filter contamination',
    'Fuel system water contamination',
    'Fuel line corrosion',
    'Fuel pump control module issue',
    'Fuel system check',
    'Fuel pressure regulator sticking',
    'Fuel tank overflow',
    'Fuel injector leaking fuel',
    'Fuel pump priming failure',
    'Fuel gauge sensor failure',
    'Fuel pump relay click',
    'Fuel line disconnect',
    'Fuel pump motor failure',

// 'Exhaust System Issues',
    'Exhaust leak',
    'Exhaust smoke',
    'Exhaust rattle',
    'Catalytic converter failure',
    'Exhaust noise',
    'Exhaust manifold crack',
    'Exhaust muffler damage',
    'Exhaust backfire',
    'Exhaust pipe rust',
    'Exhaust system restriction',
    'Exhaust gas smell',
    'Exhaust pipe vibration',
    'Exhaust emission failure',
    'Exhaust valve leak',
    'Exhaust hanger breakage',
    'Exhaust manifold leak',
    'Exhaust smoke color',
    'Exhaust pipe loose',
    'Exhaust gas leak',
    'Exhaust noise at idle',
    'Exhaust tip discoloration',
    'Exhaust heat shield rattle',
    'Exhaust fumes in cabin',
    'Exhaust pipe bend damage',
    'Exhaust oxygen sensor failure',
    'Exhaust system blockage',
    'Exhaust manifold gasket leak',
    'Exhaust noise under load',
    'Exhaust pipe hole',
    'Exhaust pipe rusted through',
    'Exhaust pipe misalignment',
    'Exhaust system vibration',
    'Exhaust system resonance',
    'Exhaust manifold bolt failure',
    'Exhaust pipe hangers rusted',
    'Exhaust gasket blown',
    'Exhaust downpipe crack',
    'Exhaust muffler rust',
    'Exhaust smoke on startup',
    'Exhaust odor inside car',
    'Exhaust flange leak',
    'Exhaust pipe scraping',
    'Exhaust heat shield loose',
    'Exhaust rattle on acceleration',
    'Exhaust system rust',
    'Exhaust valve timing issue',
    'Exhaust pipe rubbing',
    'Exhaust tip damage',
    'Exhaust popping noise',
    'Exhaust downpipe leak',
    'Exhaust emission smell',
    'Exhaust gasket failure',
    'Exhaust vibration at idle',
    'Exhaust smoke on deceleration',
    'Exhaust pipe break',
    'Exhaust joint leak',
    'Exhaust pipe corrosion',

// 'Exhaust System Issues',
    'Exhaust manifold crack repair',
    'Exhaust muffler blockage',
    'Exhaust pipe joint rust',
    'Exhaust pressure loss',
    'Exhaust tip vibration',
    'Exhaust manifold bolt broken',
    'Exhaust valve sticking',
    'Exhaust heat shield corrosion',
    'Exhaust clamp loose',
    'Exhaust system hanger broken',
    'Exhaust pipe joint leak',
    'Exhaust downpipe rattle',
    'Exhaust system alignment issue',
    'Exhaust fumes outside car',
    'Exhaust manifold bolts loose',
    'Exhaust gasket wear',
    'Exhaust pipe misfire',
    'Exhaust mounting point damage',
    'Exhaust noise increase',
    'Exhaust smoke odor',
    'Exhaust manifold noise',
    'Exhaust valve noise',
    'Exhaust system buzzing',
    'Exhaust downpipe rust',
    'Exhaust backpressure problem',
    'Exhaust manifold heat damage',
    'Exhaust pipe clogging',
    'Exhaust smoke under load',
    'Exhaust valve failure',
    'Exhaust pipe rattles at idle',
    'Exhaust flange bolt failure',
    'Exhaust oxygen sensor leak',
    'Exhaust leak detection',

// 'Heating and Air Conditioning Problems',
    'A/C not blowing cold air',
    'Heater not working',
    'A/C compressor failure',
    'A/C refrigerant leak',
    'Heater core blockage',
    'A/C blowing warm air',
    'A/C clutch failure',
    'Heater fan not working',
    'A/C condenser leak',
    'Heater blowing cold air',
    'A/C fan noise',
    'A/C evaporator blockage',
    'A/C not turning on',
    'Heater control malfunction',
    'A/C fan speed issues',
    'Heater smells',
    'A/C refrigerant low',
    'Heater hose leak',
    'A/C condenser blockage',
    'A/C blower motor failure',
    'Heater control valve failure',
    'A/C smells musty',
    'Heater not blowing',
    'A/C compressor noise',
    'Heater core corrosion',
    'A/C pressure loss',
    'Heater temperature fluctuation',
    'A/C vents not working',
    'Heater air not hot',
    'A/C condenser fan failure',
    'Heater fan noise',
    'A/C refrigerant recharge',
    'Heater core bypass issue',
    'A/C control panel failure',
    'Heater vent not opening',
    'A/C system overpressure',
    'Heater fan speed issues',
    'A/C evaporator leak',
    'Heater stuck on hot',
    'A/C compressor clutch not engaging',
    'Heater blower motor failure',
    'A/C cycling on and off',
    'Heater valve stuck',
    'A/C cabin air filter clog',
    'Heater core coolant leak',
    'A/C line freezing',
    'Heater blower not adjusting',
    'A/C fan not engaging',
    'Heater core replacement',
    'A/C control module failure',
    'Heater duct blockage',
    'A/C noise on startup',
    'Heater leaking inside cabin',
    'A/C fuse blown',
    'Heater control cable snapped',
    'A/C relay failure',
    'Heater air flow weak',
    'A/C compressor seizure',
    'Heater temperature control failure',
    'A/C lines sweating',
    'Heater not defrosting',
    'A/C making hissing noise',
    'Heater stuck on cold',
    'A/C expansion valve failure',
    'Heater core flushing',
    'A/C not cooling evenly',
    'Heater vent stuck',
    'A/C low refrigerant pressure',
    'Heater switch malfunction',
    'A/C system clogging',
    'Heater core airlock',
    'A/C compressor relay stuck',
    'Heater knob broken',
    'A/C refrigerant overcharge',
    'Heater fan relay failure',
    'A/C system vacuum leak',
    'Heater air not circulating',
    'A/C cabin filter replacement',
    'Heater air smells burnt',
    'A/C idle pressure issues',
    'Heater blowing only hot air',
    'A/C hose rupture',
    'Heater not responsive',
    'A/C system freezing up',
    'Heater duct leak',
    'A/C system recharging',
    'Heater fan intermittent',
    'A/C drain line clog',
    'Heater mode door stuck',
    'A/C fuse replacement',
    'Heater control module short',
    'A/C line leak detection',
    'Heater cable adjustment',
    'A/C blowing hot intermittently',
    'Heater air temperature drop',
    'A/C temperature control issue',
    'Heater not turning off',
    'A/C hissing from vents',
    'Heater air distribution problem',

//TRANSMISSIOJ PROBLEM
    'Transmission not shifting',
    'Transmission gear stuck',
    'Transmission control module failure',
    'Transmission juddering',
    'Transmission won\'t engage',
    'Transmission shifting late',
    'Transmission whining noise',
    'Transmission error codes',
    'Transmission rough shifting',
    'Transmission oil leak',
    'Transmission fluid change',
    'Transmission downshifting problem',
    'Transmission delayed engagement',
    'Transmission knocking noise',
    'Transmission shifting rough into gear',
    'Transmission clutch wear',
    'Transmission overheat warning',
    'Transmission valve body failure',
    'Transmission slipping out of gear',
    'Transmission no reverse',
    'Transmission filter clogging',
    'Transmission fluid foaming',
    'Transmission popping out of gear',
    'Transmission gear grinding',
    'Transmission stuck in limp mode',
    'Transmission oil cooler leak',
    'Transmission fluid level sensor fault',
    'Transmission not holding gear',
    'Transmission oil contamination',
    'Transmission stuck in park',
    'Transmission jerks on acceleration',
    'Transmission fluid pressure loss',
    'Transmission fluid smells burnt',
    'Transmission slipping in high gear',
    'Transmission delayed shifting',

// 'Miscellaneous Mechanical Problems',
    'Ignition coil failure',
    'Spark plug fouling',
    'Timing belt noise',
    'Belt tensioner failure',
    'Serpentine belt squeal',
    'Thermostat stuck closed',
    'Valve cover gasket leak',
    'Engine ticking noise',
    'Engine misfire at idle',
    'Engine oil consumption',
    'Engine rough idle',
    'Engine stalling at stop',
    'Radiator clogging',
    'Camshaft sensor failure',
    'Crankshaft sensor fault',
    'Timing chain rattle',
    'Oil pressure low',
    'Oil pump failure',
    'Fuel injector noise',
    'Piston slap noise',
    'Crankshaft seal leak',
    'Timing cover leak',
    'Oil pan gasket leak',
    'Exhaust manifold gasket blow',
    'Engine knocking on acceleration',
    'Radiator cap leak',
    'Power steering fluid leak',
    'Power steering pump noise',
    'Shock absorber leak',
    'Strut mount noise',
    'Differential noise',
    'Driveshaft vibration',
    'CV joint noise',
    'Wheel bearing play',
    'Brake rotor warp',
    'Clutch slipping',
    'Clutch pedal noise',
    'Fuel filter clogging',
    'Oxygen sensor failure',
    'Mass air flow sensor fault',
    'Throttle body sticking',
    'EGR valve clogging',
    'Turbocharger noise',
    'Turbo lag',
    'Wastegate failure',
    'Exhaust drone',
    'Headlight flickering',
    'Blower motor failure',
    'Wiper motor noise',
    'Window regulator failure',
    'Door lock actuator noise',
    'Sunroof leak',
    'Trunk latch sticking',
    'Fuel door not opening',
    'Hood latch failure',
    'Tire pressure sensor fault',
    'ABS module failure',
    'Oil filter housing leak',
    'Coolant hose leak',
    'Idle air control valve failure',
    'PCV valve clogging',
    'Exhaust valve ticking',
    'Timing belt slip',
    'Cabin air filter clogging',
    'Transfer case noise',
    'Axle shaft clicking',
    'Wheel alignment drift',
    'Windshield washer pump failure',
    'Head gasket failure',
    'Valve train noise',
    'Piston ring wear',
    'Turbo wastegate rattle',
    'Radiator hose collapse',
    'Coolant reservoir crack',
    'Radiator fan shroud noise',
    'Fog light condensation',
    'Airbag warning light',
    'Tire sidewall bulge'
  };

  final normalizedQuery = query.toLowerCase();
  final allKeywords = mechanicalKeywords
      .map((word) => word.toLowerCase())
      .toSet()
    ..addAll(mechanicalIssuesRemedies.keys.map((issue) => issue.toLowerCase()));

  return allKeywords.any((keyword) => normalizedQuery.contains(keyword));
}
