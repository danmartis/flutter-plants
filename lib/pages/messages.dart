import 'package:chat/models/profiles.dart';
import 'package:chat/models/profiles_response.dart';
import 'package:chat/pages/avatar_image.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/principal_page.dart';
import 'package:chat/pages/profile_page.dart';
import 'package:chat/providers/messages_providers.dart';
import 'package:chat/theme/theme.dart';
import 'package:chat/widgets/avatar_user_chat.dart';
import 'package:chat/widgets/header_appbar_pages.dart';
import 'package:chat/widgets/text_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';

import 'package:chat/models/mensajes_response.dart';
import 'package:chat/widgets/chat_message.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class CustomAppBar extends StatefulWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final String title;
  final Profiles profile;

  CustomAppBar({
    this.title,
    this.profile,
    Key key,
  })  : preferredSize = Size.fromHeight(60.0),
        super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;
    return AppBar(
      leadingWidth: 65,
      backgroundColor: Colors.black,
      actions: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Icon(
            Icons.more_vert,
            color: currentTheme.accentColor,
            size: 30,
          ),
        ),
      ],
      title: Text('Mensajes'),
      leading: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(left: 10.0),
        child: GestureDetector(
          onTap: () {
            {
              Provider.of<MenuModel>(context, listen: false).currentPage = 2;
              Navigator.push(context, _createRoute());
            }
          },
          child: Container(
            child: Hero(
              tag: widget.profile.user.uid,
              child: Material(
                type: MaterialType.transparency,
                child: ImageUserChat(
                  width: 100,
                  height: 100,
                  profile: widget.profile,
                  fontsize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      automaticallyImplyLeading: true,
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        SliverAppBarProfilepPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(-0.5, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with TickerProviderStateMixin {
  final _textController = new TextEditingController();
  final _focusNode = new FocusNode();
  final messagesProvider = new MessagesProvider();

  ChatService chatService;
  SocketService socketService;
  AuthService authService;
  Profiles profile;
  List<ChatMessage> _messages = [];
  bool _isWriting = false;

  ScrollController _hideBottomNavController;

  var _isVisible;

  @override
  void initState() {
    super.initState();

    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);
    profile = authService.profile;
    this.socketService.socket.on('personal-message', _listenMessage);
    this.bottomControll();
    //_chargeRecord(this.chatService.userFor.user.uid);
  }

  bottomControll() {
    _isVisible = true;
    _hideBottomNavController = ScrollController();
    _hideBottomNavController.addListener(
      () {
        if (_hideBottomNavController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (_isVisible)
            setState(() {
              _isVisible = false;
            });
        }
        if (_hideBottomNavController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!_isVisible)
            setState(() {
              _isVisible = true;
            });
        }
      },
    );
  }

  void _chargeRecord(String userId) async {
    List<Message> chat = await this.chatService.getChat(userId);

    final history = chat.map((m) => new ChatMessage(
          text: m.message,
          uid: m.by,
          animationController: new AnimationController(
              vsync: this, duration: Duration(milliseconds: 0))
            ..forward(),
        ));

    setState(() {
      _messages.insertAll(0, history);
    });
  }

  void _listenMessage(dynamic payload) {
    ChatMessage message = new ChatMessage(
      text: payload['message'],
      uid: payload['by'],
      animationController: AnimationController(
          vsync: this, duration: Duration(milliseconds: 300)),
    );

    setState(() {
      _messages.insert(0, message);
    });

    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        body: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              makeHeaderCustom('Mensajes'),
              makeListChats(context)
            ]),
        bottomNavigationBar: BottomNavigation(isVisible: _isVisible),
      ),
    );
  }

  SliverPersistentHeader makeHeaderCustom(String title) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return SliverPersistentHeader(
        floating: true,
        delegate: SliverCustomHeaderDelegate(
            minHeight: 60,
            maxHeight: 60,
            child: Container(
                color: Colors.black,
                child: Container(
                    color: Colors.black,
                    child: CustomAppBarHeaderPages(
                      title: title,
                      action:
                          //  Container()

                          GestureDetector(
                        onTap: () => {},

                        //Scaffold.of(context).openEndDrawer(),
                        child: Container(
                            child: Icon(
                          Icons.menu,
                          size: 35,
                          color: currentTheme.accentColor,
                        )),
                      ),
                    )))));
  }

  SliverList makeListChats(context) {
    return SliverList(
        delegate: SliverChildListDelegate([
      buildSuggestions(context),
    ]));
  }

  Widget buildSuggestions(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return FutureBuilder(
      future: messagesProvider.getProfilesChatByUser(profile.user.uid),
      builder:
          (BuildContext context, AsyncSnapshot<ProfilesResponse> snapshot) {
        if (snapshot.hasData) {
          final profiles = snapshot.data.profiles;

          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: profiles.length,
            itemBuilder: (BuildContext ctxt, int index) {
              final message = profiles[index];
              if (message.subscribeApproved && message.subscribeActive) {
                final DateTime dateMessage = message.messageDate;
                final DateFormat formatter = DateFormat('kk:mm a');
                final String formatted = formatter.format(dateMessage);
                final nameSub =
                    (message.name == "") ? message.user.username : message.name;
                return Column(
                  children: [
                    Material(
                      child: ListTile(
                        tileColor: currentTheme.scaffoldBackgroundColor,
                        leading: ImageUserChat(
                            width: 100,
                            height: 100,
                            profile: message,
                            fontsize: 20),
                        title: Text(nameSub,
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            EmojiText(
                                text: message.message,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white54),
                                emojiFontMultiplier: 1.5),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '· $formatted',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 15),
                            ),
                          ],
                        ),
                        onTap: () {
                          final chatService =
                              Provider.of<ChatService>(context, listen: false);
                          chatService.userFor = message;

                          Navigator.push(context, createRouteChat());
                        },
                      ),
                    ),
                    Divider(height: 1),
                  ],
                );
              } else {
                return Container();
              }
            },
          );
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
        height: 400.0, child: Center(child: CircularProgressIndicator()));
  }

  Route createRouteChat() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ChatPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 400),
    );
  }

  Widget _inputChat() {
    return SafeArea(
        child: Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
              child: TextField(
            controller: _textController,
            onSubmitted: _handleSubmit,
            onChanged: (texto) {
              setState(() {
                if (texto.trim().length > 0) {
                  _isWriting = true;
                } else {
                  _isWriting = false;
                }
              });
            },
            decoration: InputDecoration.collapsed(hintText: 'Enviar mensaje'),
            focusNode: _focusNode,
          )),

          // Botón de enviar

          (_isWriting)
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconTheme(
                      data: IconThemeData(color: Color(0xffE8C213)),
                      child: IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        icon: Icon(Icons.send),
                        onPressed: _isWriting
                            ? () => _handleSubmit(_textController.text.trim())
                            : null,
                      ),
                    ),
                  ),
                )
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconTheme(
                      data: IconThemeData(color: Color(0xffE87213)),
                      child: IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        icon: Icon(Icons.camera_alt),
                        onPressed: _isWriting
                            ? () => _handleSubmit(_textController.text.trim())
                            : null,
                      ),
                    ),
                  ),
                )
        ],
      ),
    ));
  }

  _handleSubmit(String text) {
    if (text.length == 0) return;

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = new ChatMessage(
      uid: authService.profile.user.uid,
      text: text,
      animationController: AnimationController(
          vsync: this, duration: Duration(milliseconds: 200)),
    );
    _messages.insert(0, newMessage);
    newMessage.animationController.forward();

    setState(() {
      _isWriting = false;
    });

    this.socketService.emit('personal-message', {
      'by': this.authService.profile.user.uid,
      'for': this.chatService.userFor.user.uid,
      'message': text
    });

    /*    this.socketService.emit('personal-message', {
      'by': this.authService.profile.user.uid,
      'for': this.chatService.userFor.user.uid,
      'message': text
    }); */
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }

    this.socketService.socket.off('personal-message');
    super.dispose();
  }
}
