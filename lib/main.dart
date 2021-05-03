import 'package:flutter/cupertino.dart'; 
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';

void main() {
  runApp(
    FriendlyChatApp(),
  );
}

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.deepOrange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);


//認証によって送信者の名前取得できるといいね
String _date = '5/3';

class FriendlyChatApp extends StatelessWidget {
  const FriendlyChatApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'あしあと',
      theme: defaultTargetPlatform == TargetPlatform.iOS 
        ? kIOSTheme                                      
        : kDefaultTheme,   
      home: Chatscreen(),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({required this.text, required this.animationController});
  final String text;
  final AnimationController animationController;
  @override
  Widget build(BuildContext context) {
    return SizeTransition(             
      sizeFactor:                      
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),  
      axisAlignment: 0.0,              
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal.shade200,
          // 枠線
          //border: Border.all(color: Colors.lime, width: 5),
          borderRadius: BorderRadius.circular(12), // 角丸
        ),
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 15.0,left: 18.0, top: 10.0, bottom: 10.0),
              child: CircleAvatar(backgroundColor: Colors.white, child: Text(_date),foregroundColor: Colors.teal.shade400,),
            ),
            Expanded(
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10.0, right: 18.0, bottom: 10.0),
                    child: Text(text),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

class Chatscreen extends StatefulWidget {
  @override
  _ChatscreenState createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false; 

  void _handleSubmitted(String text) {
    _textController.clear();
    setState((){
      _isComposing = false;
    });

    ChatMessage message = ChatMessage(
      text: text,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 700),
        vsync: this,
      ),
    );
    setState((){
      _messages.insert(0, message);
    });
    _focusNode.requestFocus();
    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('あしあと'),
        elevation:
          Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ), 
      body: Container(
        child: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
          ),
        ],
      ),
      decoration: Theme.of(context).platform == TargetPlatform.iOS 
            ? BoxDecoration(                                 
                border: Border(                              
                  top: BorderSide(color: Colors.grey[200]!), 
                ),                                           
              )                                              
            : null),
    );
  }

  Widget _buildTextComposer() {
    return  IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child:  Row(                         
          children: [                           
            Flexible(                          
              child:  TextField(
                controller: _textController,
                onChanged: (String text) {            
                  setState(() {                      
                    _isComposing = text.isNotEmpty;   
                  });                                
                }, 
                onSubmitted: _isComposing ? _handleSubmitted : null,
                decoration:  InputDecoration.collapsed(
                    hintText: 'Send a message'),
                focusNode: _focusNode,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child:  Theme.of(context).platform == TargetPlatform.iOS ?
              CupertinoButton(                                          
                child: Text('Send'),                                    
                onPressed: _isComposing                                 
                    ? () =>  _handleSubmitted(_textController.text)     
                    : null,) :
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isComposing
                  ? () => _handleSubmitted(_textController.text)
                  : null,
                )
            )                                    
          ],                                    
        ),                                     
      ),
    );
  }

  @override
  void dispose() {
    for (var message in _messages){
      message.animationController.dispose();
    }
    super.dispose();
  }


}