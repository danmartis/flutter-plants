import 'package:animate_do/animate_do.dart';
import 'package:leafety/bloc/dispensary_bloc.dart';
import 'package:leafety/bloc/subscribe_bloc.dart';
import 'package:leafety/models/dispensaries_products_response%20copy.dart';
import 'package:leafety/models/profiles.dart';
import 'package:leafety/models/subscribe.dart';
import 'package:leafety/pages/chat_page.dart';
import 'package:leafety/pages/recipe_image_page.dart';
import 'package:leafety/pages/register_page.dart';
import 'package:leafety/providers/subscription_provider.dart';
import 'package:leafety/services/auth_service.dart';
import 'package:leafety/services/aws_service.dart';
import 'package:leafety/services/chat_service.dart';
import 'package:leafety/services/socket_service.dart';
import 'package:leafety/services/subscription_service.dart';
import 'package:leafety/theme/theme.dart';
import 'package:leafety/widgets/avatar_user_chat.dart';
import 'package:leafety/widgets/button_gold.dart';
import 'package:leafety/widgets/productProfile_card.dart';
import 'package:leafety/widgets/sliver_header.dart';
import 'package:leafety/widgets/text_emoji.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

import 'package:universal_platform/universal_platform.dart';

class ProfileCard extends StatefulWidget {
  ProfileCard(
      {@required this.profileColor,
      this.isUserAuth = false,
      this.isUserEdit = false,
      @required this.profile,
      @required this.image,
      this.loading = false,
      this.isEmpty = false,
      @required this.productsDispensaryBloc});

  final ProductDispensaryBloc productsDispensaryBloc;

  final Color profileColor;
  static const double avatarRadius = 48;
  static const double titleBottomMargin = (avatarRadius * 2) + 18;

  final bool isUserAuth;
  final bool isUserEdit;
  final Profiles profile;

  final bool isEmpty;
  final loading;
  final ui.Image image;

  final picker = ImagePicker();

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  Profiles profileMyUser;

  Profiles profileUser;

  Subscription subscription;

  Stream streamSubscription;

  bool loadSub = false;

  bool isSuscriptionApprove = false;
  bool isSuscriptionActive = false;
  bool isUploadRecipe = false;

  SocketService socketService;

  final subscriptionApiProvider = new SubscriptionApiProvider();

  final subscriptionBlocUser = new SubscribeBloc();

  @override
  void initState() {
    final authService = Provider.of<AuthService>(context, listen: false);
    profileMyUser = authService.profile;

    this.socketService = Provider.of<SocketService>(context, listen: false);

    super.initState();

    if (!widget.isUserAuth) {
      subscriptionBlocUser.getSubscription(
          profileMyUser.user.uid, widget.profile.user.uid);
    }

    setState(() {
      loadSub = true;
    });
  }

  @override
  void dispose() {
    this.socketService.socket.off('principal-notification');
    super.dispose();
  }

  File imageCover;
  final picker = ImagePicker();

  bool isData = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentTheme = Provider.of<ThemeChanger>(context);

    final awsService = Provider.of<AwsService>(context, listen: false);
    // final bloc = CustomProvider.subscribeBlocIn(context);

    final chatService = Provider.of<ChatService>(context, listen: false);
    profileUser = (widget.isUserAuth) ? widget.profile : chatService.userFor;

    final dispensary = new DispensariesProduct();
    return Stack(
      children: [
        Hero(
          tag: profileUser.imageHeader,
          child: cachedNetworkImage(profileUser.getHeaderImg()),
        ),
        Positioned(
            child: Container(
                margin: EdgeInsets.only(
                  left: (widget.isUserEdit) ? 0 : 22,
                ),
                child: Align(
                    alignment: (widget.isUserEdit)
                        ? Alignment.bottomCenter
                        : Alignment.bottomLeft,
                    child: Hero(
                      tag: profileUser.user.uid,
                      child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.transparent,
                          child: CircleAvatar(
                              radius: ProfileCard.avatarRadius + 120,
                              backgroundColor: Colors.transparent,
                              child: Container(
                                  width: 100,
                                  height: 100,
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: ImageUserChat(
                                      width: size.width,
                                      height: size.height,
                                      profile: widget.profile,
                                      fontsize: 20,
                                    ),
                                  )))),
                    )))),
        (!widget.isUserAuth && profileMyUser.isClub && !profileUser.isClub)
            ? StreamBuilder(
                stream: subscriptionBlocUser.subscription.stream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  isData = snapshot.hasData;

                  if (isData) {
                    subscription = snapshot.data;

                    if (subscription.subscribeActive &&
                        subscription.subscribeApproved) {
                      return FadeIn(
                        duration: Duration(milliseconds: 500),
                        child: Container(
                            //top: size.height / 3.5,
                            margin: EdgeInsets.only(
                                left: (UniversalPlatform.isWeb)
                                    ? size.width / 2.2
                                    : size.width / 1.8,
                                bottom: 10,
                                right: 10),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: ButtonSubEditProfile(
                                  isSub: true,
                                  color: currentTheme.currentTheme.accentColor,
                                  textColor:
                                      currentTheme.currentTheme.accentColor,
                                  text: 'DISPENSAR',
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        createRouteDispensar(
                                            profileUser,
                                            dispensary,
                                            widget.productsDispensaryBloc));
                                  }),
                            )),
                      );
                    } else if (subscription.subscribeActive &&
                        !subscription.subscribeApproved) {
                      return FadeIn(
                        duration: Duration(milliseconds: 500),
                        child: Container(
                          margin: EdgeInsets.only(
                              left: (UniversalPlatform.isWeb)
                                  ? size.width / 2.2
                                  : size.width / 1.8,
                              bottom: 10,
                              right: 10),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: ButtonSubEditProfile(
                                color: (currentTheme.customTheme)
                                    ? currentTheme
                                        .currentTheme.scaffoldBackgroundColor
                                    : Colors.black54,
                                textColor: Colors.white,
                                text: 'Pendiente',
                                onPressed: () {
                                  solicitudPendiente(
                                    context,
                                    currentTheme.currentTheme.accentColor,
                                    awsService.isUploadRecipe,
                                  );
                                }),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                })
            : Container(),
        (widget.isUserAuth)
            ? FadeIn(
                duration: Duration(milliseconds: 500),
                child: Container(
                    //top: size.height / 3.5,
                    margin: EdgeInsets.only(
                        left: (UniversalPlatform.isWeb)
                            ? size.width / 2.2
                            : size.width / 1.8,
                        bottom: 10,
                        right: 10),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ButtonSubEditProfile(
                          color: (currentTheme.customTheme)
                              ? currentTheme
                                  .currentTheme.scaffoldBackgroundColor
                              : Colors.black54,
                          textColor: Colors.white,
                          text: 'Editar perfil',
                          onPressed: () {
                            Navigator.of(context)
                                .push(createRouteEditProfile());
                          }),
                    )),
              )
            : Container(),
        StreamBuilder(
            stream: subscriptionBlocUser.subscription.stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              isData = snapshot.hasData;

              if (isData) {
                subscription = snapshot.data;

                final imageRecipe =
                    (snapshot.data.imageRecipe == "") ? false : true;

                if (loadSub &&
                    profileUser.isClub &&
                    !widget.isUserAuth &&
                    !subscription.subscribeActive &&
                    !subscription.subscribeApproved) {
                  return FadeIn(
                    duration: Duration(milliseconds: 500),
                    child: Container(
                      //top: size.height / 3.5,

                      margin: EdgeInsets.only(
                          left: (UniversalPlatform.isWeb)
                              ? size.width / 2.2
                              : size.width / 1.8,
                          bottom: 10,
                          right: 10),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: ButtonSubEditProfile(
                            isSub: true,
                            color: currentTheme.currentTheme.accentColor,
                            textColor: currentTheme.currentTheme.accentColor,
                            text: 'SUSCRIBIRME',
                            onPressed: () {
                              (widget.isUserAuth)
                                  ? Navigator.of(context)
                                      .push(createRouteEditProfile())
                                  : updateFieldToSubscribe(
                                      context,
                                      currentTheme.currentTheme.accentColor,
                                      subscription,
                                      size);
                            }),
                      ),
                    ),
                  );
                } else if (loadSub &&
                    !widget.isUserAuth &&
                    imageRecipe &&
                    profileUser.isClub &&
                    subscription.subscribeActive &&
                    !subscription.subscribeApproved) {
                  return FadeIn(
                    duration: Duration(milliseconds: 500),
                    child: Container(
                      //top: size.height / 3.5,

                      margin: EdgeInsets.only(
                          left: (UniversalPlatform.isWeb)
                              ? size.width / 2.2
                              : size.width / 1.8,
                          bottom: 10,
                          right: 10),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: ButtonSubEditProfile(
                            color: (currentTheme.customTheme)
                                ? currentTheme
                                    .currentTheme.scaffoldBackgroundColor
                                : Colors.black54,
                            textColor: Colors.white,
                            text: 'Pendiente',
                            onPressed: () {
                              (widget.isUserAuth)
                                  ? Navigator.of(context)
                                      .push(createRouteEditProfile())
                                  : unSubscribe(
                                      context,
                                      currentTheme.currentTheme.accentColor,
                                      awsService.isUploadRecipe,
                                    );
                            }),
                      ),
                    ),
                  );
                } else if (loadSub &&
                        !widget.isUserAuth &&
                        imageRecipe &&
                        profileUser.isClub ||
                    !subscription.subscribeActive &&
                        !subscription.subscribeApproved) {
                  return FadeIn(
                    duration: Duration(milliseconds: 500),
                    child: Container(
                      //top: size.height / 3.5,
                      margin: EdgeInsets.only(
                          left: (UniversalPlatform.isWeb)
                              ? size.width / 2.2
                              : size.width / 1.8,
                          bottom: 10,
                          right: 10),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: ButtonSubEditProfile(
                            isSub: true,
                            color: currentTheme.currentTheme.accentColor,
                            textColor: currentTheme.currentTheme.accentColor,
                            text: 'SUSCRIBIRME',
                            onPressed: () {
                              (widget.isUserAuth)
                                  ? Navigator.of(context)
                                      .push(createRouteEditProfile())
                                  : updateFieldToSubscribe(
                                      context,
                                      currentTheme.currentTheme.accentColor,
                                      subscription,
                                      size,
                                    );
                            }),
                      ),
                    ),
                  );
                } else if (loadSub &&
                    !widget.isUserAuth &&
                    imageRecipe &&
                    profileUser.isClub &&
                    subscription.subscribeActive &&
                    subscription.subscribeApproved) {
                  return FadeIn(
                    duration: Duration(milliseconds: 500),
                    child: Container(
                      //top: size.height / 3.5,
                      margin: EdgeInsets.only(
                          left: (UniversalPlatform.isWeb)
                              ? size.width / 2.2
                              : size.width / 1.8,
                          bottom: 10,
                          right: 10),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: ButtonSubEditProfile(
                            isSub: true,
                            color: currentTheme.currentTheme.accentColor,
                            textColor: currentTheme.currentTheme.accentColor,
                            text: 'SUSCRITO',
                            onPressed: () {
                              (widget.isUserAuth)
                                  ? Navigator.of(context)
                                      .push(createRouteEditProfile())
                                  : unSubscribe(
                                      context,
                                      currentTheme.currentTheme.accentColor,
                                      awsService.isUploadRecipe,
                                    );
                            }),
                      ),
                    ),
                  );
                }
              }

              return Container();
            }),
      ],
    );
  }

  Route createRouteRecipeViewImage(Profiles item) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          RecipeImagePage(profile: item),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
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

  updateFieldToSubscribe(
    context,
    color,
    Subscription subscription,
    Size size,
  ) {
    const List<Color> orangeGradients = [
      Color(0xff1C3041),
      Color(0xff1C3041),
      Color(0xff1C3041),
    ];

    bool isIos = UniversalPlatform.isIOS;
    bool isAndroid = UniversalPlatform.isAndroid;
    bool isWeb = UniversalPlatform.isWeb;

    if (isAndroid) {
      // Android
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                contentPadding: EdgeInsets.only(top: 10, bottom: 10),
                title: Text(
                  'Suscribirme',
                  style: TextStyle(color: Colors.white54, fontSize: 20),
                ),
                content: StreamBuilder(
                    stream: subscriptionBlocUser.subscription.stream,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      final isHasData = snapshot.hasData;

                      if (isHasData) {
                        final imageRecipe =
                            (snapshot.data.imageRecipe == "") ? false : true;

                        if (!imageRecipe &&
                            !snapshot.data.isUpload &&
                            !snapshot.data.subscribeApproved &&
                            !snapshot.data.subscribeActive) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Subir mi receta',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 15),
                              ),
                              GestureDetector(
                                  child: roundedRectButtonIcon(
                                      "Desde mis fotos",
                                      orangeGradients,
                                      FontAwesomeIcons.fileUpload),
                                  onTap: !isHasData
                                      ? null
                                      : () => {_selectImage(false)}),
                              GestureDetector(
                                  child: roundedRectButtonIcon(
                                      "Desde mi camara",
                                      orangeGradients,
                                      FontAwesomeIcons.camera),
                                  onTap: !isHasData
                                      ? null
                                      : () => {_selectImage(true)}),
                            ],
                          );
                        } else if (isHasData &&
                                imageRecipe &&
                                !snapshot.data.subscribeApproved ||
                            !snapshot.data.subscribeActive) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => {
                                  Navigator.push(context,
                                      createRouteRecipeViewImage(profileMyUser))
                                  //_selectImage(false)
                                },
                                child: Container(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      child: Container(
                                          child: Container(
                                        padding: EdgeInsets.only(
                                            left: size.width / 20, top: 10),
                                        child: Container(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              FaIcon(
                                                FontAwesomeIcons.notesMedical,
                                                size: 20,
                                                color: color,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Mi receta',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: color),
                                              )
                                            ],
                                          ),
                                        ),
                                      ) /* FadeInImage(

                                      image:
                                          NetworkImage(snapshot.data.imageRecipe),
                                      placeholder:
                                          AssetImage('assets/loading2.gif'),
                                      fit: BoxFit.cover,
                                      height: 120,
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                    ), */
                                          )),
                                ),
                              ),
                            ],
                          );
                        }
                      } else {
                        return Container();
                      }

                      return Container();
                    }),
                actions: <Widget>[
                  StreamBuilder(
                      stream: subscriptionBlocUser.subscription.stream,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        isData = snapshot.hasData;

                        if (isData) {
                          final imageRecipe =
                              (snapshot.data.imageRecipe == "") ? false : true;
                          return Row(
                            children: [
                              Expanded(
                                child: CupertinoDialogAction(
                                    isDefaultAction: true,
                                    child: Text(
                                      'ENVIAR',
                                      style: TextStyle(
                                          color: (imageRecipe)
                                              ? color
                                              : Colors.white54),
                                    ),
                                    onPressed: () => (imageRecipe)
                                        ? addSubscription(context)
                                        : null),
                              ),
                              Expanded(
                                child: CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    child: Text(
                                      'Cancelar',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                    onPressed: () => Navigator.pop(context)),
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      }),
                ],
              ));
    } else if (isIos || isWeb) {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text(
                  'Suscribirme',
                  style: TextStyle(color: Colors.white54, fontSize: 20),
                ),
                content: StreamBuilder(
                    stream: subscriptionBlocUser.subscription.stream,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      final isHasData = snapshot.hasData;

                      if (isHasData) {
                        final imageRecipe =
                            (snapshot.data.imageRecipe == "") ? false : true;

                        if (!imageRecipe &&
                            !snapshot.data.isUpload &&
                            !snapshot.data.subscribeApproved &&
                            !snapshot.data.subscribeActive) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Subir mi receta',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 15),
                              ),
                              GestureDetector(
                                  child: roundedRectButtonIcon(
                                      "Desde mis fotos",
                                      orangeGradients,
                                      FontAwesomeIcons.fileUpload),
                                  onTap: !isHasData
                                      ? null
                                      : () => {_selectImage(false)}),
                              GestureDetector(
                                  child: roundedRectButtonIcon(
                                      "Desde mi camara",
                                      orangeGradients,
                                      FontAwesomeIcons.camera),
                                  onTap: !isHasData
                                      ? null
                                      : () => {_selectImage(true)}),
                            ],
                          );
                        } else if (isHasData ||
                            imageRecipe &&
                                !snapshot.data.subscribeApproved &&
                                !snapshot.data.subscribeActive) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => {
                                  Navigator.push(context,
                                      createRouteRecipeViewImage(profileMyUser))
                                  //_selectImage(false)
                                },
                                child: Container(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      child: Container(
                                          child: Container(
                                        padding: EdgeInsets.only(
                                            left: size.width / 20, top: 10),
                                        child: Container(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              FaIcon(
                                                FontAwesomeIcons.notesMedical,
                                                size: 20,
                                                color: color,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Mi receta',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: color),
                                              )
                                            ],
                                          ),
                                        ),
                                      ) /* FadeInImage(

                                      image:
                                          NetworkImage(snapshot.data.imageRecipe),
                                      placeholder:
                                          AssetImage('assets/loading2.gif'),
                                      fit: BoxFit.cover,
                                      height: 120,
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                    ), */
                                          )),
                                ),
                              ),
                            ],
                          );
                        }
                      } else {
                        return Container();
                      }

                      return Container();
                    }),
                actions: <Widget>[
                  StreamBuilder(
                      stream: subscriptionBlocUser.subscription.stream,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        isData = snapshot.hasData;

                        if (isData) {
                          final imageRecipe =
                              (snapshot.data.imageRecipe == "") ? false : true;
                          return Row(
                            children: [
                              Expanded(
                                child: CupertinoDialogAction(
                                    isDefaultAction: true,
                                    child: Text(
                                      'ENVIAR',
                                      style: TextStyle(
                                          color: (imageRecipe)
                                              ? color
                                              : Colors.white54),
                                    ),
                                    onPressed: () => (imageRecipe)
                                        ? addSubscription(context)
                                        : null),
                              ),
                              Expanded(
                                child: CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    child: Text(
                                      'Cancelar',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                    onPressed: () => Navigator.pop(context)),
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      }),
                ],
              ));
    }
  }

  unSubscribe(context, color, bool isUploadRecipe) {
    /*   const List<Color> orangeGradients = [
      Color(0xff34EC9C),
      Color(0xff1C3041),
      Color(0xff34EC9C),
    ]; */

    final nameClub = widget.profile.name;

    bool isIos = UniversalPlatform.isIOS;
    bool isAndroid = UniversalPlatform.isAndroid;
    bool isWeb = UniversalPlatform.isWeb;
//
    if (isAndroid) {
      // Android
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                  title: Container(
                    child: Text(
                      '¿Deseas anular tu suscripción a $nameClub ?',
                      style: TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                  ),
                  actions: <Widget>[
                    Column(
                      children: [
                        CupertinoDialogAction(
                            isDefaultAction: true,
                            child: Text(
                              'ANULAR SUSCRIPCIÓN',
                              style: TextStyle(color: color, fontSize: 15),
                            ),
                            onPressed: () => (loadSub)
                                ? unSubscription(context, subscriptionBlocUser)
                                : null),
                        CupertinoDialogAction(
                            isDestructiveAction: true,
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 15),
                            ),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    )
                  ]));
    } else if (isIos || isWeb) {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                  title: Container(
                    child: Text(
                      '¿Deseas anular tu suscripción a $nameClub ?',
                      style: TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                  ),
                  actions: <Widget>[
                    Column(
                      children: [
                        CupertinoDialogAction(
                            isDefaultAction: true,
                            child: Text(
                              'ANULAR SUSCRIPCIÓN',
                              style: TextStyle(color: color, fontSize: 15),
                            ),
                            onPressed: () => (loadSub)
                                ? unSubscription(context, subscriptionBlocUser)
                                : null),
                        CupertinoDialogAction(
                            isDestructiveAction: true,
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 15),
                            ),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    )
                  ]));
    }
  }

  solicitudPendiente(context, color, bool isUploadRecipe) {
    /*   const List<Color> orangeGradients = [
      Color(0xff34EC9C),
      Color(0xff1C3041),
      Color(0xff34EC9C),
    ]; */

    void approveSubscription() async {
      final res = await this
          .subscriptionApiProvider
          .approveSubscription(widget.profile.subId);
      if (res) {
        subscriptionBloc.getSubscriptionsPending(profileMyUser.user.uid);

        subscriptionBlocUser.getSubscription(
            profileMyUser.user.uid, widget.profile.user.uid);

        this.socketService.emit('principal-notification',
            {'by': profileMyUser.user.uid, 'for': widget.profile.user.uid});

        Navigator.pop(context);
        _showSnackBar(
            context, 'Suscripción Aprobada, Agregado en "Miembros" 👍');
      }
    }

    _deleteSubscription() async {
      final res = await this
          .subscriptionApiProvider
          .disapproveSubscription(widget.profile.subId);
      if (res) {
        setState(() {
          subscriptionBloc.getSubscriptionsPending(profileMyUser.user.uid);
          subscriptionBlocUser.getSubscription(
              profileMyUser.user.uid, widget.profile.user.uid);

          Navigator.pop(context);
          Navigator.pop(context);

          _showSnackBar(context, 'Se Rechazo la solicitud');
        });
      }
    }

    bool isIos = UniversalPlatform.isIOS;
    bool isAndroid = UniversalPlatform.isAndroid;
    bool isWeb = UniversalPlatform.isWeb;
//
    if (isAndroid) {
      // Android
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                  title: Container(
                    child: Text(
                      'Solicitud Pendiente',
                      style: TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                  ),
                  content: Text(
                      '¿Que deseas hacer con esta solicitud de suscripción?',
                      style: TextStyle(color: Colors.grey)),
                  actions: <Widget>[
                    Column(
                      children: [
                        MaterialButton(
                            child: Text('Aceptar'),
                            elevation: 5,
                            textColor: color,
                            onPressed: () => {approveSubscription()}),
                        MaterialButton(
                            child: Text('Rechazar'),
                            elevation: 5,
                            textColor: Colors.red,
                            onPressed: () => _deleteSubscription()),
                        MaterialButton(
                            child: Text('Cancelar'),
                            elevation: 5,
                            textColor: Colors.grey,
                            onPressed: () => Navigator.pop(context))
                      ],
                    )
                  ]));
    } else if (isIos || isWeb) {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                  title: Container(
                    child: Text(
                      'Solicitud Pendiente',
                      style: TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                  ),
                  content: Text(
                      '¿Que deseas hacer con esta solicitud de suscripción?',
                      style: TextStyle(color: Colors.grey)),
                  actions: <Widget>[
                    Column(
                      children: [
                        CupertinoDialogAction(
                            isDefaultAction: true,
                            child: Text(
                              'APROBAR',
                              style: TextStyle(color: color, fontSize: 15),
                            ),
                            onPressed: () => {approveSubscription()}),
                        CupertinoDialogAction(
                            isDestructiveAction: true,
                            child: Text(
                              'RECHAZAR',
                              style: TextStyle(color: Colors.red, fontSize: 15),
                            ),
                            onPressed: () => _deleteSubscription()),
                        CupertinoDialogAction(
                            isDestructiveAction: true,
                            child: Text(
                              'Cancelar',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    )
                  ]));
    }
  }

  _selectImage(
    bool isCamera,
  ) async {
    final awsService = Provider.of<AwsService>(context, listen: false);
    final subscription = subscriptionBlocUser.subscription.value;

    final pickedFile = await picker.getImage(
        source: (isCamera) ? ImageSource.camera : ImageSource.gallery);

    if (pickedFile != null) {
      imageCover = File(pickedFile.path);

      final fileType = pickedFile.path.split('.');

      final resp = await awsService.uploadImageCoverPlant(
          fileType[0], fileType[1], imageCover);

      final newSubscription = new Subscription(
        id: subscription.id,
        subscriptor: profileMyUser.user.uid,
        club: widget.profile.user.uid,
        imageRecipe: resp,
      );
      setState(() {
        subscriptionBlocUser.subscription.sink.add(newSubscription);
      });
    } else {
      print('No image selected.');
    }
  }

  void addSubscription(
    context,
  ) async {
    Subscription subscription = subscriptionBlocUser.subscription.value;

    final subscriptionService =
        Provider.of<SubscriptionService>(context, listen: false);

    final resp = await subscriptionService.createSubscription(subscription);

    if (resp.ok) {
      subscriptionBlocUser.getSubscription(
          resp.subscription.subscriptor, resp.subscription.club);

      this.socketService.emit('principal-notification', {
        'by': profileMyUser.user.uid,
        'for': profileUser.user.uid,
      });
    }

    _showSnackBar(context, 'Suscripción Enviada al Club 👍');

    Navigator.pop(context);
  }
}

void _showSnackBar(BuildContext context, String text) {
  final currentTheme = Provider.of<ThemeChanger>(context, listen: false);

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: (currentTheme.customTheme) ? Colors.white : Colors.black,
    content: EmojiText(
        text: text,
        style: TextStyle(
            color: (currentTheme.customTheme) ? Colors.black : Colors.white,
            fontSize: 15),
        emojiFontMultiplier: 1.5),
  ));
}

void unSubscription(context, SubscribeBloc subscriptionBlocUser) async {
  final subscription = subscriptionBlocUser.subscription.value;

  final subscriptionService =
      Provider.of<SubscriptionService>(context, listen: false);

  final resp = await subscriptionService.unSubscription(subscription);

  if (resp.ok) {
    subscriptionBlocUser.getSubscription(
        resp.subscription.subscriptor, resp.subscription.club);
  }

  _showSnackBar(context, 'Suscripción Anulada');

  Navigator.pop(context);
}

Route createRouteChat() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ChatPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 400),
  );
}
