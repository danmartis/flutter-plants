import 'package:flutter/material.dart';

class ButtonGold extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color color;
  final Color textColor;

  const ButtonGold(
      {Key key,
      @required this.text,
      @required this.onPressed,
      @required this.color,
      this.textColor = Colors.black})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      elevation: 2,
      highlightElevation: 5,
      color: this.color,
      shape: StadiumBorder(),
      onPressed: this.onPressed,
      child: Container(
        width: double.infinity,
        height: 55,
        child: Center(
          child:
              Text(this.text, style: TextStyle(color: textColor, fontSize: 17)),
        ),
      ),
    );
  }
}

class ButtonSubEditProfile extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color color;
  final Color textColor;

  const ButtonSubEditProfile(
      {Key key,
      @required this.text,
      @required this.onPressed,
      @required this.color,
      this.textColor = Colors.black})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: this.textColor, width: 1.5)),
      elevation: 2,
      highlightElevation: 5,
      color: this.color,

      // shape: StadiumBorder(),
      onPressed: this.onPressed,
      child: Container(
        width: double.infinity,
        height: 40,
        child: Center(
          child: Text(this.text,
              style: TextStyle(
                  color: textColor, fontSize: 17, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
