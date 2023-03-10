import 'package:ui_common_behaviors/ui_common_behaviors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '_hiddable_widget.dart';


typedef _TCustomAppBarBuilder = Widget Function(Widget leading, BuildContext context);

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
	static Widget defaultLeading(BuildContext context, {IconData icon = Icons.menu}){
		final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
		final bool canPop = parentRoute?.canPop ?? false;
		final bool useCloseButton = parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;

		bool hasDrawer = Scaffold.of(context).hasDrawer;
		Widget? _leading;
		if (hasDrawer) {
			_leading = IconButton(
				icon: Icon(icon),
				onPressed: Scaffold.of(context).openDrawer,
				tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
			);
		} else {
			if (canPop) {
				_leading = useCloseButton ? const CloseButton() : const BackButton();
			}
		}
		if (_leading != null) {
			_leading = ConstrainedBox(
				constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
				child: _leading,
			);
		}else{
			_leading = Container();
		}
		return _leading;
	}

	final double height;
	final Widget? child;
	final Widget? leading;
	final _TCustomAppBarBuilder? builder;
	const _CustomAppBar({Key? key,
		required this.height, this.child, this.builder, required this.leading,
	}) : super(key: key);



	Widget getLeading(BuildContext context){
		if (leading != null) {
		  return leading!;
		}
		return defaultLeading(context);
	}

	@override
	Widget build(BuildContext context) {
		final _leading = getLeading(context);
		return builder?.call(_leading, context)
			?? Row(
				mainAxisAlignment: MainAxisAlignment.start,
				children:[
					_leading,
			]);
	}

	@override
	Size get preferredSize => Size.fromHeight(height);
}


///
/// note: following is a NG widget, keep it for reference
/// if your wanna apply scroll effect to appbar, use SliverAppbar instread.
///
/// [Example]:
///
/// HiddableAppBar(
///			hideDirection: ScrollDirection.reverse,
///			awareness: AppGeneralLayout.scrollAwareness,
///			height: 60, builder:(leading, ctx){
///			return Container(
///				constraints: constraints,
///				color: Colors.transparent,
///				padding: EdgeInsets.only(top:20, bottom:10),
///				child: Row(
///						mainAxisSize: MainAxisSize.min,
///						mainAxisAlignment: MainAxisAlignment.start,
///						crossAxisAlignment: CrossAxisAlignment.center,
///						children:[
///							leading,
///							BoundingBox(child: ResponsiveScreen(
///								constraints: constraints,
///								largeScreen : BoundingBox(child: Paddings.homePadding(child: _buildLogoLarge())),
///								mediumScreen: BoundingBox(child: Paddings.homePadding(child: _buildLogoMedium())),
///								smallScreen : BoundingBox(child: _buildLogo()),
///							)),
///							if (!ResponsiveScreen.isSmallScreen(context))
///								Expanded(
///									child: Row(
///											mainAxisSize: MainAxisSize.min,
///											mainAxisAlignment: MainAxisAlignment.end,
///											children:_buildDrawerActionsWithoutSpacing(context, showIcon: false)),
///								),
///							SizedBox(width: ScreenUtil.instance.setWidth(HomePage.designPaddingLR + 50))
///						]),
///			);
///		});
///
class _HidableAppBar extends _CustomAppBar  {
	final ScrollAccAware awareness;
	final ScrollDirection hideDirection;
	const _HidableAppBar({
		Key? key,
		required this.awareness,
		this.hideDirection = ScrollDirection.reverse,
		required double height,
		Widget? child,
		_TCustomAppBarBuilder? builder,
		Widget? leading,
	}) :  super(key: key, height: height, child: child, builder: builder, leading: leading);

 	@override Widget build(BuildContext context){
 		return HidableAwareWidget(
			x: 0,y: 0, awareness: awareness, hideDirection: hideDirection,
			child: builder?.call(getLeading(context), context) ?? child ?? Container()
		);
	}
}

@Deprecated("use HidableAppBar instead")
class _HiddableAppBar extends _HidableAppBar{
  _HiddableAppBar({required ScrollAccAware awareness, required double height}) : super(awareness: awareness, height: height);
}







