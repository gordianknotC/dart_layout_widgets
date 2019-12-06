import 'package:behaviors/behaviors.dart';
import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';



class HiddableAwareWidget extends StatelessWidget {
	final double x;
	final double y;
	final Widget child;
	final ScrollAccAware awareness;
	final ScrollDirection hideDirection;
	const HiddableAwareWidget({this.x, this.y, this.child, this.awareness, this.hideDirection = ScrollDirection.reverse});
	
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










