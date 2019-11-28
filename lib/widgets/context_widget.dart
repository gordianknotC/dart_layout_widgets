import 'package:flutter/cupertino.dart';
import 'package:layout/widgets/stateful.dart';


/// container to recap constraints at second rebuild
/// and apply that constraints to the rest of rebuild
Map<Key, BoxConstraints> _contextContainer = {};


///
/// Keep constraints on second build, implemented on scheduleUpdate, and
/// apply that constraints to our container.
///
/// For circumstances you want to use [IntrinsicHeightWidget] to infer
/// widget's size but want to avoid
/// IntrinsicHeightWidget to rebuild on every changes from child. In Some
/// circumstances, the size of its children is only unknown at first
/// build time but can be knowable on second time.
///
class ContextKeeper extends StatefulWidget {
	/// a key for access/restore constraints,
	/// a constant one would be preferred
	final Key 		contextKey;
	final Widget 	child;
	final bool 		keepWidthOnly;
	final bool 		keepHeightOnly;
	const ContextKeeper(
			this.contextKey, {@required this.child, this.keepWidthOnly = false,
			this.keepHeightOnly = false
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
		scheduleUpdateWhen(() => _contextContainer[widget.contextKey] == null, (){
			print('contextKeeper phrase 2');
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
			_contextContainer[widget.contextKey] = BoxConstraints.expand(width : w, height: h);
		});
	}
 
	@override
  Widget build(BuildContext context) {
		if (_contextContainer[widget.contextKey] == null){
			_contextInit();
			print('contextKeeper phrase 1: $_contextContainer}');
			return widget.child;
		}
		final constraints = _contextContainer[widget.contextKey];
		print('contextSize: ${constraints.maxWidth}/${constraints.maxHeight}');
		return Container(
			width: constraints.maxWidth,
			height: constraints.maxHeight,
			child: widget.child
		);
	}
	
	@override
  void dispose() {
    super.dispose();
		_contextContainer.remove(widget.contextKey);
		print('dispose ContextKeeper');
  }
}










