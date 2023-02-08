import 'package:flutter/cupertino.dart';

abstract class RouteAwarePlus implements RouteAware{
	bool _visible = true;
	bool get visible => _visible;
	
	/// note:
	/// Called when a new route has been pushed, and the current route is no
	/// longer visible. Hide widget benefits rendering performance while multiple
	/// overlays stacked together....
	@override
	void didPushNext(){
		_visible = false;
	}
	
	@override
	void didPopNext(){
		_visible = true;
	}
}
