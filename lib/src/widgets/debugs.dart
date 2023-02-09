import 'package:flutter/material.dart';
import 'package:layout_widgets/layout_widgets.dart';
import 'package:random_color/random_color.dart';

RandomColor _rc = RandomColor();
Color get _random => _rc.randomColor();

///
/// 於 Container 繪制一亂數色彩的 border, 用於 debug 視覺化 Container 大小
/// [DebugBox.setBoxDebugOn] - turning debug on
/// [DebugBox.setBoxDebugOff] - turning debug off
///
class DebugBox extends StatelessWidget {
	static bool _debug = true;
	static void setBoxDebugOn(){
		_debug = true;
	}
	static void setBoxDebugOff(){
		_debug = false;
	}
	final Widget child;
	final Color borderColor;
	DebugBox({required this.child}): borderColor = _random;

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

@Deprecated("use DContainer instead")
class BoundingBox extends DebugBox {
  BoundingBox({required Widget child}) : super(child: child);
}
