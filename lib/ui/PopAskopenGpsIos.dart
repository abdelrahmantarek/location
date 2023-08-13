

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PopAskOpenGpsIos extends StatelessWidget {
  final Function? onCancel;
  final Function? onGoSettings;
  final String gpsTitle;
  final String gpsSubtitle;
  final String cancelText;
  final String settingsText;
  const PopAskOpenGpsIos({Key? key,
    this.onCancel,
    this.onGoSettings,
    required this.gpsTitle,
    required this.gpsSubtitle,
    required this.cancelText,
    required this.settingsText
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title:  Text(gpsTitle),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(gpsSubtitle),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child:  Text(settingsText),
          onPressed: () {
            onGoSettings!();
          },
        ),
        TextButton(
          child:  Text(cancelText),
          onPressed: () {
            onCancel!();
          },
        ),
      ],
    );
  }
}
