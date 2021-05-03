import 'package:flutter/cupertino.dart'; 
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    FriendlyChatApp(),
  );
}

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.brown,
  primaryColor: Color(0xfffcd1d1), //Colors.red[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[200],
);


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
  ChatMessage({required this.text, required this.date, required this.time, required this.animationController});
  final String text;
  final String date;
  final String time;
  final AnimationController animationController;
  @override
  Widget build(BuildContext context) {
    return SizeTransition(             
      sizeFactor:                      
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),  
      axisAlignment: 0.0,              
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffece2e1), //Colors.teal.shade100,
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
              child: CircleAvatar(backgroundColor: Colors.white, child: Text(date),foregroundColor: Color(0xff766161),),//Colors.teal.shade400,),
            ),
            Expanded(
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10.0),//, right: 18.0, bottom: 10.0),
                    child: Text(time)//, style: TextStyle(decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dashed),),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 2.0, right: 18.0, bottom: 10.0),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                        //color: Theme.of(context).primaryColor,
                        ),
                    ),
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
  bool _edit = false;
  Color _editbuttoncollor = Colors.white;

  String getTodayDate() {
    initializeDateFormatting('ja');
    return DateFormat.Md('ja').format(DateTime.now()).toString(); //yMMMd
  }
  String getTime() {
    initializeDateFormatting('ja');
    return DateFormat.Hm('ja').format(DateTime.now()).toString(); //yMMMd
  }


  void _handleSubmitted(String text) {
    _textController.clear();
    setState((){
      _isComposing = false;
    });

    ChatMessage message = ChatMessage(
      text: text,
      date: getTodayDate(),
      time: getTime(),
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
    if (_edit == false){
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
                reverse: false,
                itemBuilder: (_, int index) => _messages[index],
                itemCount: _messages.length,
              ),
            ),
            //Divider(height: 1.0),
            //Container(
            //  decoration: BoxDecoration(
            //    color: Colors.white),//Theme.of(context).cardColor),
            //    child: _writeButton(),//_buildTextComposer(),
            //),
          ],
        ),
        decoration: Theme.of(context).platform == TargetPlatform.iOS 
              ? BoxDecoration(                                 
                  border: Border(                              
                    top: BorderSide(color: Colors.grey[200]!), 
                  ),                                           
                )                                              
              : null),
      floatingActionButton: _writeButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('あしあと'),
          elevation:
            Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        floatingActionButton: _writeButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, 
      );
    }
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
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: IconButton(
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
  Widget _writeButton(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: CircleAvatar(
        backgroundColor: _editbuttoncollor,//Colors.white,//Color(0xffffb6b9),//
        maxRadius: 30.0,
        child: IconButton(
          iconSize: 40.0,
          icon: const Icon(Icons.create_sharp),
          onPressed: _editStart,// () {},
        )
      )
    ); 
  }

  void _editStart(){
    if (_edit == true){
      setState((){
        _edit = false;
        _editbuttoncollor = Colors.white;
      });
    }else{
      setState((){
        _edit = true;
        _editbuttoncollor = Colors.brown ;
      });  
    }
    //setState((){
    //  _edit = true;
    //});
  }

  @override
  void dispose() {
    for (var message in _messages){
      message.animationController.dispose();
    }
    super.dispose();
  }


}