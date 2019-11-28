import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class DividerF extends StatelessWidget {
	final Color color;
	final double height;
	final double lflag;
	final double rflag;
	final double length;
	const DividerF({this.color, this.length, this.height = 1, this.lflag = 0.15, this.rflag = 0.15});
	
	@override
  Widget build(BuildContext context) {
		final fader = RadialGradient(
				tileMode: TileMode.clamp,
				colors: [color, color.withOpacity(0)],
				center: AlignmentDirectional.center,
				radius: length / height);
		
		return SizedBox(
			height: height,
			child: Center(
				child: Container(
					height: height,
					margin: EdgeInsetsDirectional.only(start: length* lflag, end: length* rflag),
					decoration: BoxDecoration(
						gradient: fader,
					),
				),
			),
		);
	}
}


