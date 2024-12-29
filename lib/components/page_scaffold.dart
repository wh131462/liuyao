import 'package:flutter/material.dart';

class PageScaffold extends StatelessWidget {
  final bool canBack;
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.canBack = false,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: canBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
                onPressed: () => Navigator.of(context).canPop()?Navigator.of(context).pop():Navigator.of(context).pushNamed('/'),
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: actions,
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: body,
    );
  }
}
