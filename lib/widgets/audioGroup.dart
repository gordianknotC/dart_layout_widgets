import 'package:behaviors/behaviors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


// ignore: must_be_immutable
class SimpleAudioGroup<T> extends StatelessWidget {
// ignore: overridden_fields
	@override Key key;
	final bool multiSelection;
	final List<T> resources;
	final List<T> initialSelecteds;
	final Widget Function(BuildContext ctx, List<T>) builder;
	final SingleGroupAware<T> awareness;
	
	SimpleAudioGroup({
		@required this.key, 		@required this.resources,
		@required this.builder, this.multiSelection = false,
		this.initialSelecteds
	}): awareness = SingleGroupAware.singleton(
			children: resources,
			initialSelection: initialSelecteds,
			multipleAwareness: multiSelection,
			key: key == null ? null : shortHash(key)
	), super(key: key);
	
	@override Widget build(BuildContext context) {
		try {
			return builder(context, resources);
		} catch (e, s) {
			print('[ERROR] SimpleGroup.build failed: $e\n$s');
			rethrow;
		}
	}
	
}
