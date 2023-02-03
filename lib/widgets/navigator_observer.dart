import 'dart:async';

import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';


final _D = Logger(name:'NavOB', levels: LEVEL0);


class NavHistory{
	final List<Route> data = [];
	NavHistory();
	
	Route get last => data.isNotEmpty ? data.last : null;
	int get length => data.length;
	bool get isEmpty => data.isEmpty;
	bool get isNotEmpty => data.isNotEmpty;
	bool get isRoot => data.length == 1;
	
	void add(Route route){
		_D.debug('add route: "${route.settings.name}" - $this');
		if (data.isNotEmpty){
//			assert(route.settings.name != null, "may be you forget to assign route settings in your route builder?");
		}
		return data.add(route);
	}
	bool overlaps(List<Route> others){
		return data.any((d) => others.contains(d));
	}
	bool contains(Route other){
		return data.contains(other);
	}
	bool containsSettingName(String other){
		return data.any((d) => d.settings.name == other);
	}
	bool overlapsSettingName(Iterable<String> others){
		return data.any((d) => others.contains(d.settings.name));
	}
	
	Route removeLast(){
		_D.debug('pop route: ${last?.settings?.name}');
		return data.removeLast();
	}
	int indexOf(Route route){
		return data.indexOf(route);
	}
	Route removeAt(int idx){
		return data.removeAt(idx);
	}
	Route operator [](int other) {
		return data[other];
  }
  void operator []=(int idx, Route assignment){
		final old = data[idx];
		data[idx] = assignment;
		_D.debug('replace route ${old.settings.name} with ${assignment.settings.name}');
	}
 
	@override String toString(){
		return data.map((d) => d.settings.name).join(', ');
	}
}

enum ERouteEventType{
	pop, push, remove, replace
}

class TRouteEvent{
	final ERouteEventType type;
	final Route current;
	final Route prev;
	const TRouteEvent(this.current, this.prev, this.type);
}

/// An interface for observing the behavior of a [Navigator].
class AppNavObserver extends NavigatorObserver {
	static AppNavObserver I;
	final StreamController<TRouteEvent> _onRouteCtrl = StreamController<TRouteEvent>.broadcast();
	
	NavHistory history;
	AppNavObserver._();
	
	
	/// The navigator that the observer is observing, if any.
	@override NavigatorState get navigator => super.navigator;
	
	
	factory AppNavObserver.singleton(){
		if (I == null) {
		  return I = AppNavObserver._()..history = NavHistory();
		}
		return I;
	}
	
	StreamSubscription<TRouteEvent> addEventListener(void cb(TRouteEvent e)){
		return _onRouteCtrl.stream.listen(cb);
	}
	
	
	/// The [Navigator] pushed `route`.
	///
	/// The route immediately below that one, and thus the previously active
	/// route, is `previousRoute`.
	@override void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
		_D.debug('didPush ${route.settings.name} - ${previousRoute?.settings?.name}');
		assert(history.last == previousRoute);
		history.add(route);
		_onRouteCtrl.add(TRouteEvent(route, previousRoute, ERouteEventType.push));
	}
	
	/// The [Navigator] popped `route`.
	///
	/// The route immediately below that one, and thus the [newly] active
	/// route, is `previousRoute`.
	@override void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
		_D.debug('didpop ${route.settings.name} - ${previousRoute?.settings?.name}');
		assert(history.last == route);
		history.removeLast();
		assert(history.last == previousRoute);
		_onRouteCtrl.add(TRouteEvent(route, previousRoute, ERouteEventType.pop));
	}
	
	/// The [Navigator] removed `route`.
	///
	/// If only one route is being removed, then the route immediately below
	/// that one, if any, is `previousRoute`.
	///
	/// If multiple routes are being removed, then the route below the
	/// bottommost route being removed, if any, is `previousRoute`, and this
	/// method will be called once for each removed route, from the topmost route
	/// to the bottommost route.
	@override void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
		_D.debug('didRemove ${route.settings.name} - ${previousRoute?.settings?.name}');
		final removedIdx = history.indexOf(route);
		final neighborIdx = history.indexOf(previousRoute);
		assert(removedIdx == neighborIdx +1);
		history.removeAt(removedIdx);
		_onRouteCtrl.add(TRouteEvent(route, previousRoute, ERouteEventType.remove));
	}
	
	/// The [Navigator] replaced `oldRoute` with `newRoute`.
	@override void didReplace({ Route<dynamic> newRoute, Route<dynamic> oldRoute }) {
		_D.debug('didReplace ${newRoute.settings.name} - ${oldRoute.settings.name}');
		final idx = history.indexOf(oldRoute);
		history[idx] = newRoute;
		_onRouteCtrl.add(TRouteEvent(newRoute, oldRoute, ERouteEventType.replace));
	}
	
	/// The [Navigator]'s route `route` is being moved by a user gesture.
	///
	/// For example, this is called when an iOS back gesture starts.
	///
	/// Paired with a call to [didStopUserGesture] when the route is no longer
	/// being manipulated via user gesture.
	///
	/// If present, the route immediately below `route` is `previousRoute`.
	/// Though the gesture may not necessarily conclude at `previousRoute` if
	/// the gesture is canceled. In that case, [didStopUserGesture] is still
	/// called but a follow-up [didPop] is not.
	@override void didStartUserGesture(Route<dynamic> route, Route<dynamic> previousRoute) {
		_D.debug('didStartUserGesture');
	}
	
	/// User gesture is no longer controlling the [Navigator].
	///
	/// Paired with an earlier call to [didStartUserGesture].
	@override void didStopUserGesture() {
		_D.debug('didStopUserGesture');
	}
	
}