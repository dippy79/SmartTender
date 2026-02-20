import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  late final GenerativeModel _model;
  final List<Map<String, String>> _messages = [];
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;
    final userMsg = _controller.text;
    setState(() {
      _messages.add({'role': 'user', 'text': userMsg});
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final content = [Content.text(userMsg)];
      final response = await _model.generateContent(content);
      setState(() {
        _messages.add({'role': 'ai', 'text': response.text ?? 'No response from AI'});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'text': 'Error: Check your connection or API key.'});
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Tender Assistant")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final isUser = _messages[i]['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.cyan.withOpacity(0.8) : Colors.grey.shade900,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                      ),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(_messages[i]['text']!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(color: Colors.cyanAccent, backgroundColor: Colors.transparent),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, border: const Border(top: BorderSide(color: Colors.white10))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "Ask about tenders, rates, or risks...", border: InputBorder.none),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send_rounded, color: Colors.cyanAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
