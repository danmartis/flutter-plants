import 'package:chat/controllers/slide_controler.dart';
import 'package:chat/helpers/ui_overlay_style.dart';
import 'package:chat/pages/principal_page.dart';
import 'package:chat/theme/theme.dart';
import 'package:chat/widgets/headercurves_logo_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat/services/auth_service.dart';
import 'package:chat/services/socket_service.dart';

import 'package:chat/helpers/mostrar_alerta.dart';

import 'package:chat/widgets/custom_input.dart';
import 'package:chat/widgets/labels.dart';
import 'package:chat/widgets/button_gold.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    changeStatusDark();
    return Scaffold(
        backgroundColor: Color(0xff0F0F0F),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.95,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                HeaderMultiCurvesText(
                    title: 'Sign Up!',
                    subtitle: 'Hello,',
                    color: Color(0xffD9B310)),
                _Form(),
                Labels(
                  rute: 'login',
                  title: '¿Ya tienes una cuenta?',
                  subTitulo: 'Ingresa ahora!',
                  colortText1: Colors.white70,
                  colortText2: Color(0xffD9B310),
                ),
                StyledLogoCustom()
              ],
            ),
          ),
        ));
  }
}

class _Form extends StatefulWidget {
  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: <Widget>[
          Theme(
            data: Theme.of(context).copyWith(primaryColor: Color(0xffD9B310)),
            child: CustomInput(
              icon: Icons.perm_identity,
              placeholder: 'Username',
              keyboardType: TextInputType.text,
              textController: nameCtrl,
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(primaryColor: Color(0xffD9B310)),
            child: CustomInput(
              icon: Icons.mail_outline,
              placeholder: 'Email',
              keyboardType: TextInputType.emailAddress,
              textController: emailCtrl,
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(primaryColor: Color(0xffD9B310)),
            child: CustomInput(
              icon: Icons.lock_outline,
              placeholder: 'Password',
              textController: passCtrl,
              isPassword: true,
            ),
          ),
          ButtonGold(
            color: currentTheme.accentColor,
            text: 'Crear cuenta',
            onPressed: authService.authenticated
                ? null
                : () async {
                    FocusScope.of(context).unfocus();

                    print(nameCtrl.text);
                    print(emailCtrl.text);
                    print(passCtrl.text);
                    final registroOk = await authService.register(
                        nameCtrl.text.trim(),
                        emailCtrl.text.trim(),
                        passCtrl.text.trim());
                    if (registroOk != null) {
                      if (registroOk == true) {
                        socketService.connect();
                        Navigator.push(context, _createRute());
                      } else {
                        mostrarAlerta(
                            context, 'Registro incorrecto', registroOk);
                      }
                    } else {
                      mostrarAlerta(context, 'Error del servidor',
                          'lo sentimos, Intentelo mas tarde');
                    }
                  },
          )
        ],
      ),
    );
  }
}

Route _createRute() {
  return PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          UsersPage(),
      transitionDuration: Duration(seconds: 1),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation =
            CurvedAnimation(parent: animation, curve: Curves.easeInOut);

        return FadeTransition(
            child: child,
            opacity:
                Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation));
      });
}
