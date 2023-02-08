import 'package:ui_common_behaviors/ui_common_behaviors.dart';
import 'package:dart_common/dart_common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';



class HidableAwareWidget extends StatelessWidget {
	final double x;
	final double y;
	final Widget child;
	final ScrollAccAware awareness;
	final ScrollDirection hideDirection;
	const HidableAwareWidget({
		required this.x, required this.y, required this.child, required this.awareness, this.hideDirection = ScrollDirection.reverse});

	@override Widget build(BuildContext context) {
		return Observer(builder: observerGuard(() { //OB:
			final d  = hideDirection == ScrollDirection.forward ? - 1 : 1;
			final p1 = awareness.offset;
			final p2 = awareness.delta;
			return Transform(
				transform: Matrix4.translationValues(x, y + d * p1, 0.0),
				child: Container(
					width: double.infinity,
					height: awareness.containerHeight,
					child: child
				)
			);
		}, "HiddableAwareWidget.build"));

	}
}

@Deprecated("use HidableAwareWidget instead")
class HiddableAwareWidget extends HidableAwareWidget{
  HiddableAwareWidget({required double x, required double y, required Widget child, required ScrollAccAware awareness}) : super(x: x, y: y, child: child, awareness: awareness);
}









