import 'package:chat/bloc/login_bloc.dart';
import 'package:chat/bloc/profile_bloc.dart';
import 'package:chat/bloc/register_bloc.dart';
import 'package:flutter/material.dart';

class CustomProvider extends InheritedWidget {
  final loginBloc = new LoginBloc();

  final registerBloc = new RegisterBloc();

  final profileBloc = new ProfileBloc();

  static CustomProvider _instancia;

  factory CustomProvider({Key key, Widget child}) {
    if (_instancia == null) {
      _instancia = new CustomProvider._internal(key: key, child: child);
    }

    return _instancia;
  }

  CustomProvider._internal({Key key, Widget child})
      : super(key: key, child: child);

  // Provider({ Key key, Widget child })
  //   : super(key: key, child: child );

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static LoginBloc of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<CustomProvider>())
        .loginBloc;
  }

  static RegisterBloc registerBlocIn(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<CustomProvider>())
        .registerBloc;
  }

  static ProfileBloc profileBlocIn(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<CustomProvider>())
        .profileBloc;
  }
}