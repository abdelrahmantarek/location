

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PopAskOpenGpsIos extends StatelessWidget {
  final Function? onCancel;
  final Function? onGoSettings;
  const PopAskOpenGpsIos({Key? key, this.onCancel, this.onGoSettings}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('خدمات الموقع'),
      content: SingleChildScrollView(
        child: Column(
          children: const <Widget>[
            Text('للاستمرار يجب عليك تفعيل خدمات الموقع من الاعدادات / الخصوصية / خدمات الموقع'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('الاعدادات'),
          onPressed: () {
            onGoSettings!();
          },
        ),
        TextButton(
          child: const Text('الغاء'),
          onPressed: () {
            onCancel!();
          },
        ),
      ],
    );
  }
}