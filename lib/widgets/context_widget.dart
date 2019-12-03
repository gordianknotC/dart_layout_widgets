import 'package:flutter/cupertino.dart';
import 'stateful.dart';


class TContext{
	final BoxConstraints constraints;
	final Size size;
	const TContext(this.constraints, this.size);
}

/// container to recap constraints at second rebuild
/// and apply that constraints to the rest of rebuild
Map<Key, TContext> _contextContainer = {};


///
/// Keep constraints on second build, until any screen changed.
///
/// For circumstances you want to use [IntrinsicHeightWidget] to infer
/// widget's size but want to avoid IntrinsicHeightWidget to rebuild
/// on every changes from children.
///
/// The size of its children is only unknown at first
/// build time but can be knowable at second time.
///
class ContextKeeper extends StatefulWidget {
	/// a key for access/restore constraints,
	/// a constant one would be preferred
	final Key 		contextKey;
	final Widget 	child;
	final bool 		keepWidthOnly;
	final bool 		keepHeightOnly;
	final ValueNotifier<Size> screenSizeNotifier;
	const ContextKeeper(
			this.contextKey, {@required this.child, this.keepWidthOnly = false,
			this.keepHeightOnly = false, @required this.screenSizeNotifier,
	}): super(key: contextKey);

  @override
  _ContextKeeperState createState(){
  	_contextContainer.remove(contextKey);
		return _ContextKeeperState();
	}
}

class _ContextKeeperState extends State<ContextKeeper> with StatefulMixin{
	@override
  void initState() {
    super.initState();
  }
  
  void _contextInit(){
		print('contextKeeper phrase 3');
		final size = context.size;
		double w, h;
		if (widget.keepWidthOnly) {
			h = size.height;
		}
		if (widget.keepHeightOnly) {
			w = size.width;
		}
		if (widget.keepHeightOnly == false && widget.keepWidthOnly == false){
			w = size.width;
			h = size.height;
		}
		_contextContainer[widget.contextKey] = TContext(BoxConstraints.expand(width : w, height: h), widget.screenSizeNotifier.value);
	}
	
  void _scheduleInitialContext(){
		scheduleUpdateWhen(() => _contextContainer[widget.contextKey] == null, _contextInit);
	}
	
	void _scheduleContext(){
		scheduleUpdate(_contextInit);
	}
	
	bool get isTheSameScreenSize{
		final prevsize = _contextContainer[widget.contextKey].size;
		return prevsize.width == widget.screenSizeNotifier.value.width && prevsize.height == widget.screenSizeNotifier.value.height;
	}
	
	@override
  Widget build(BuildContext context) {
		if (_contextContainer[widget.contextKey] == null){
			_scheduleInitialContext();
			print('contextKeeper phrase 1: $_contextContainer}');
			return widget.child;
		}
		final constraints = _contextContainer[widget.contextKey].constraints;
		print('contextSize: ${constraints.maxWidth}/${constraints.maxHeight}');
		return ValueListenableBuilder<Size>(
			valueListenable: widget.screenSizeNotifier,
			builder: (context, size, w){
				print('contextKeeper phrase 2 changed:${!isTheSameScreenSize}/${widget.screenSizeNotifier.value}');
				if (!isTheSameScreenSize){
					_scheduleContext();
					return widget.child;
				}
				return Container(
						width: constraints.maxWidth,
						height: constraints.maxHeight,
						child: widget.child
				);
			},
		);
	}
	
	@override
  void dispose() {
    super.dispose();
		_contextContainer.remove(widget.contextKey);
		print('dispose ContextKeeper');
  }
}










