
import 'package:flutter/material.dart';

class AppScreen extends StatelessWidget {
	final Key? scaffoldKey;
	final Widget body;
	final Widget? title;
	final Widget? drawer;
	final Widget? floatingActionButton;
	final Widget? appBarButtons;
	const AppScreen({super.key, this.scaffoldKey, this.title, required this.body, this.drawer, this.floatingActionButton, this.appBarButtons});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			key: scaffoldKey,
			appBar: AppBar(
				leading: appBarButtons,
				title: title,
			),
			body: Center(child: body),
			drawer: drawer,
			floatingActionButton: floatingActionButton,
		);
	}
}