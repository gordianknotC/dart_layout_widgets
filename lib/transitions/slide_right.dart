import 'package:flutter/cupertino.dart';

class SlideRightRoute extends PageRouteBuilder<Widget> {
	final Widget widget;
	SlideRightRoute({required this.widget, required RouteSettings settings})
			: super(
		pageBuilder: (
				BuildContext context,
				Animation<double> animation,
				Animation<double> secondaryAnimation) {
			return widget;
		},
		transitionsBuilder: (
				BuildContext context,
				Animation<double> animation,
				Animation<double> secondaryAnimation,
				Widget child) {
			return SlideTransition(
				position: Tween<Offset>(
					begin: const Offset(1.0, 0.0),
					end: Offset.zero,
				).animate(animation),
				child: child,
			);
		},
		transitionDuration: const Duration(milliseconds: 300),
		settings: settings,
	
	);
}