import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

RandomColor _rc = RandomColor();
Color get _random => _rc.randomColor();

class BoundingBox extends StatelessWidget {
	static bool _debug = true;
	static void setDebugOn(){
		_debug = true;
	}
	static void setDebugOff(){
		_debug = false;
	}
	final Widget child;
	final Color borderColor;
	BoundingBox({this.child}): borderColor = _random;
	
  @override
  Widget build(BuildContext context) {
    return _debug
			? Container(
				decoration: BoxDecoration(
					border: Border.all(width:0.4, color: borderColor),
				),
				child: child)
			: child;
  }
}
