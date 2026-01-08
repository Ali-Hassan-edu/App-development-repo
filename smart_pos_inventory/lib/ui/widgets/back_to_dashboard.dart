import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';

class BackToDashboardWrapper extends StatelessWidget {
  final Widget child;
  const BackToDashboardWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
        return false;
      },
      child: child,
    );
  }
}

Widget backToDashboardButton(BuildContext context, {Color? color}) {
  return IconButton(
    icon: Icon(Icons.arrow_back, color: color),
    onPressed: () {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    },
  );
}
