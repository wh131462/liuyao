import 'package:flutter/material.dart';
class MyLicensePage extends StatelessWidget {
  const MyLicensePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 400,
      child: const LicensePage(
        applicationIcon: FlutterLogo(),
        applicationVersion: 'v0.0.1',
        applicationName: '六爻通神',
        applicationLegalese: 'Copyright© 2024 EternalHeart',
      ),
    );
  }
}
