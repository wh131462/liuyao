import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MyLicensePage extends StatelessWidget {
  const MyLicensePage({Key? key}) : super(key: key);

  Future<String> getVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    return info.version;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 400,
      child: FutureBuilder<String>(
        future: getVersion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // 显示加载动画
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            return LicensePage(
              applicationIcon: SizedBox(
                width: 128,
                height: 128,
                child: Image.asset(
                  "assets/icon/logo.png",
                  fit: BoxFit.cover,
                ),
              ),
              applicationVersion: 'v${snapshot.data}',
              applicationName: '六爻通神',
              applicationLegalese: 'Copyright© 2024${DateTime.now().year == 2024 ? "" : "-${DateTime.now().year}"} EternalHeart',
            );
          } else {
            return const Text("No Version Data");
          }
        },
      ),
    );
  }
}
