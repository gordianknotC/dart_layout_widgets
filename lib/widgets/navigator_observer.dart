import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';


final _D = Logger(name:'NavOB', levels: LEVEL0);


class NavHistory{
	List<Route> data;
	
	Route get last => data.isNotEmpty ? data.last : null;
	
	void add(Route route){
		_D.debug('add route: ${route.settings.name}');
		return data.add(route);
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
 
}

/// An interface for observing the behavior of a [Navigator].
class AppNavObserver extends NavigatorObserver {
	static AppNavObserver I;
	static NavHistory history;
	AppNavObserver._();
	factory AppNavObserver.singleton(){
		if (I == null) {
		  return I = AppNavObserver._();
		}
		return I;
	}
	
	void initObserver(BuildContext context){
		if (!(Navigator.of(context).widget?.observers?.contains?.call(this) ?? true)){
			Navigator.of(context).widget.observers.add(this);
			_D.info('register AppNavObserver to Navigator');
		}else{
			_D.sys('try register AppNavObserver to Navigator, but not completed yet');
		}
	}
	
	/// The navigator that the observer is observing, if any.
	@override NavigatorState get navigator => super.navigator;
	
	/// The [Navigator] pushed `route`.
	///
	/// The route immediately below that one, and thus the previously active
	/// route, is `previousRoute`.
	@override void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
		assert(history.last == previousRoute);
		history.add(route);
	}
	
	/// The [Navigator] popped `route`.
	///
	/// The route immediately below that one, and thus the [newly] active
	/// route, is `previousRoute`.
	@override void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
		assert(history.last == route);
		history.removeLast();
		assert(history.last == previousRoute);
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
		final removedIdx = history.indexOf(route);
		final neighborIdx = history.indexOf(previousRoute);
		assert(removedIdx == neighborIdx +1);
		history.removeAt(removedIdx);
	}
	
	/// The [Navigator] replaced `oldRoute` with `newRoute`.
	@override void didReplace({ Route<dynamic> newRoute, Route<dynamic> oldRoute }) {
		final idx = history.indexOf(oldRoute);
		history[idx] = newRoute;
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
	void didStartUserGesture(Route<dynamic> route, Route<dynamic> previousRoute) {
	
	}
	
	/// User gesture is no longer controlling the [Navigator].
	///
	/// Paired with an earlier call to [didStartUserGesture].
	void didStopUserGesture() {
	
	}
}