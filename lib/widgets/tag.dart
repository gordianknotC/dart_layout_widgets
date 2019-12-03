import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/tag.dart';

class CloudStyle{
	static const double PDL = 15;
	static const double PDR = 6;
	
}

class CloudTag extends StatelessWidget{
	final Ttag tag;
	final double height;
	final double iconSize;
	final Color bgColor;
	final Color iconColor;
	final EdgeInsets padding;
	final TextStyle style;
	const CloudTag(this.tag, {this.height = 26, this.iconSize = 16,
		this.bgColor, this.iconColor, this.padding,
		this.style
	});
	
	@override
	Widget build(BuildContext context) {
		return Container(
				height: height,
				decoration: BoxDecoration(
					color: bgColor,
					borderRadius: BorderRadius.all(Radius.circular(height/2)),
				),
				child: Padding(
					padding: padding ?? EdgeInsets.only(left: CloudStyle.PDL, right: CloudStyle.PDR),
					child: Row(
							mainAxisSize: MainAxisSize.min,
							crossAxisAlignment: CrossAxisAlignment.center,
							mainAxisAlignment: MainAxisAlignment.start,
							children:[
								tag.icon == null
									? Container()
									: Icon(tag.icon, size: iconSize, color: iconColor),
								Text(tag.name, style: style),
							]),
				)
		);
	}
	
}
