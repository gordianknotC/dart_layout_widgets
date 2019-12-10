import 'dart:math';

import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';


final _D = Logger(name:'HOME', levels: LEVEL0);


/// fetched from https://www.davidanaya.io/flutter/combine-multiple-gestures.html
///
class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
	final bool Function(Offset offset) onPanDown;
	final Function(Offset offset) onPanUpdate;
	final Function(Offset offset) onPanEnd;
	int _custom_pointer;
	int get custom_pointer => _custom_pointer;
	CustomPanGestureRecognizer(
			{@required this.onPanDown,
				@required this.onPanUpdate,
				@required this.onPanEnd});
	
	void stopAndResumeTracking(int pointer){
		try {
			stopTracking();
			startTrackingPointer(pointer);
			resolve(GestureDisposition.accepted);
		} on AssertionError catch(e){
		} catch (e, s) {
			_D.debug('[ERROR] CustomPanGestureRecognizer.stopAndResumeTracking failed: $e\n$s');
			rethrow;
		}
		
	}
	void stopTracking(){
		try {
			stopTrackingPointer(_custom_pointer);
			_D.debug('stopTracking');
		} on AssertionError catch(e) {
		} catch (e, s) {
			_D.debug('[ERROR] CustomPanGestureRecognizer.stopTracking failed: $e\n$s');
			rethrow;
		}
	}
	
	void startTracking(){
		try {
			startTrackingPointer(_custom_pointer);
			resolve(GestureDisposition.accepted);
		} on AssertionError catch(e){
		} catch (e, s) {
			_D.debug('[ERROR] CustomPanGestureRecognizer.startTracking failed: $e\n$s');
			rethrow;
		}
		
	}
	
	@override
	void addPointer(PointerEvent event) {
		
		_custom_pointer = event.pointer;
		if (onPanDown(event.position)) {
			startTrackingPointer(event.pointer);
			resolve(GestureDisposition.accepted);
		} else {
			stopTrackingPointer(event.pointer);
		}
	}
	
	@override
	void handleEvent(PointerEvent event) {
		_custom_pointer = event.pointer;
		if (event is PointerMoveEvent) {
			onPanUpdate(event.position);
		}
		if (event is PointerUpEvent) {
			onPanEnd(event.position);
			stopTrackingPointer(event.pointer);
		}
	}
	
	@override
	String get debugDescription => 'customPan';
	
	@override
	void didStopTrackingLastPointer(int pointer) {
		_D.debug('didStopTrackingLastPointer $pointer');
	}
}


enum DualControllerState{
	panelStartDrag, panelUpdate, panelOpened, panelClosed,
	contentStartDrag, contentUpdate, contentEnd, contentStart,
}


/// [Example]
///
/// 	@override void initState(){
//		super.initState();
//		controller = ScrollerNestedPanelGestureController(
//			pageController: PageController(),
//			panelController: widget.panelController,
//			panelHeight: widget.height
//		);
//	}
//
//	Widget baseBuilder(BuildContext context, Widget child){
//		return LayoutBuilder(
//			builder: (context, constraint) => PanelGestureDetector(
//			 	gestureController: controller,
//			  child: SingleChildScrollView(
//			  	controller: controller.pageController,
//			    child: Column(
//			    	children: <Widget>[
//			    		SizedBox(height: widget.marginTop),
//			    		Container(
//			    			decoration: BoxDecoration(
//			    					color: Colors.white,
//			    					borderRadius: BorderRadius.all(Radius.circular(24.0)),
//			    					boxShadow: [
//			    						BoxShadow(
//			    							blurRadius: 10.0,
//			    							color: Colors.grey,
//			    						),
//			    					]
//			    			),
//			    			child: child,
//			    		),
//			    	],
//			    ),
//			  ),
//			)		);
//	}
class PanelGestureDetector extends RawGestureDetector{
	PanelGestureDetector({@required Widget child, @required ScrollerNestedPanelGestureController gestureController}):
			super(gestures: <Type, GestureRecognizerFactory>{
				CustomPanGestureRecognizer:
				GestureRecognizerFactoryWithHandlers<CustomPanGestureRecognizer>(
					() => gestureController.detector,
					(CustomPanGestureRecognizer instance) {
					
					},
				),
			}, child: child);
}


class ScrollerNestedPanelGestureController{
	final PageController pageController;
	final PanelController panelController;
	double panelHeight;
	
	void Function() _onOpened;
	void Function() _onClosed;
	
	// ignore: avoid_setters_without_getters
	void Function() wrapOnOpened(void cb()){
		return (){
			_D.debug('on open panel');
			if (panelController.getPanelPosition() == 1 && pageController.offset == 0){
				cb();
				_D.debug('on open shift');
				shiftScrollContent();
			}
		};
	}
	// ignore: avoid_setters_without_getters
	void Function() wrapOnClosed(void cb()){
		return (){
			_D.debug('on close panel');
			if (panelController.getPanelPosition() == 0 && pageController.offset != 0){
				cb();
				_D.debug('on close shift');
				shiftScrollContent();
			}
		};
	}
	
	CustomPanGestureRecognizer detector;
	bool _repelListening = false;
	
	/// content scroller positions...
	double _delta = 0;
	double _prev_offset = 0;
	double _current_offset = 0;
	
	/// panel scroller positions...
	double _drag_start_y = 0;
	double _drag_start_ratio = 0;
	double _drag_displacement = 0;
	double _draggin_y = 0;
	double _drop_y = 0;
	
	/// while true, hand over gesture tracking to custom gesture(panel)
	bool _insertTracking = false;
	
	/// is content scroller position at the end
	bool get _isApproachingEnd{
		return _delta > 0 && pageController.position.extentAfter < 5;
	}
	
	/// is content scroller position at the beginning
	bool get _isApproachingStart{
		return _delta < 0 && _current_offset <= 5;
	}
	
	/// is user intent to collapse panel
	bool get _isIntentToCollapse{
		return _delta == 0 && _current_offset <= 5;
	}
	
	ScrollerNestedPanelGestureController({
		@required this.pageController, @required this.panelController, this.panelHeight
	}){
		detector = CustomPanGestureRecognizer(
			onPanDown: _onPanDown,
			onPanUpdate: _onPanUpdate,
			onPanEnd: _onPanEnd
		)	;
		pageController.addListener(_onPageScroll);
		shiftScrollContent();
	}
	
	int _retries = 0;
	void shiftScrollContent(){
		SchedulerBinding.instance.addPostFrameCallback((_){
			if (pageController.hasClients){
				_repelListening = true;
				_retries = 0;
				_D.debug('shift pageController');
				/// make displacement for scroller content, so that gesture
				/// could be detected whether it's at the beginning of scroll position
				/// or not.
				pageController.jumpTo(pageController.offset == 0 ? 0.04 : pageController.offset);
			}else{
				_retries ++;
				if (_retries < 5){
					shiftScrollContent();
				}else{
					_retries = 0;
				}
			}
		});
	}
	
	void _onPageScroll(){
		if (_repelListening){
			_D.debug('_repelListening');
			_repelListening = false;
//			return;
		}
		
		_current_offset = pageController.offset;
		_delta = _current_offset - _prev_offset;
		
		if (_current_offset != 0)
			_prev_offset = _current_offset;
		///
		/// 1) content scroller position is at the beginning and about to scroll down
		/// 2) since no more scroll content are available, hand over gesture
		///    pointer to panel controller
		if (_isApproachingStart){
			_insertTracking = true;
			_drag_start_ratio = panelController.getPanelPosition();
			detector.startTracking();
			_D.debug('approaching start, startTracking');
			return;
		}
		///
		/// 1) content scroller position is at the end
		if (_isApproachingEnd){
			final ratio = _drag_start_ratio = panelController.getPanelPosition();
			_D.debug('approaching end ${ratio}');
			/// 2) if user are scrolling up and content scroller position is at the end
			/// 	a) if panel scroll position is at the beginning - no hand over
			/// 	b) if panel scroll position is not at the beginning.
			///    		hand over gesture pointer to panel controller
			if (ratio != 1){
				_insertTracking = true;
				_drag_start_ratio = ratio;
				detector.startTracking();
				_D.debug('approach end at non start position, startTracking');
			}
			return;
		}
//		_D.debug('$_current_offset/ $_delta - after:${pageController.position.extentAfter}/before:${pageController.position.extentBefore}');
	}
	
	bool _onPanDown(Offset offset) {
		_delta = 0;
		_drag_displacement = 0;
		_drag_start_y = offset.dy;
		_drag_start_ratio = panelController.getPanelPosition();
		_D.debug('onPanDown: $offset/${pageController.offset}');
		return false;
	}
	
	void _onPanUpdate(Offset offset) {
		if (_insertTracking){
			_drag_start_y = offset.dy;
			_insertTracking = false;
			_D.debug('reset insert tracking');
		}
		
		_draggin_y = offset.dy;
		_drag_displacement = _drag_start_y - _draggin_y;
		if (!_isApproachingEnd && _drag_displacement > 0){
			detector.stopTracking();
			_D.debug('stop tracking, exploring more content');
			return;
		}
		
		if (_isApproachingStart && _drag_displacement < 0 || _isApproachingEnd){
			final value = _drag_start_ratio + (_drag_displacement / panelHeight);
			panelController.setPanelPosition(min(1, value));
			//_D.debug('onPanUpdate: $_drag_displacement');
			return;
		}
		
		if (_delta == 0 && _current_offset == 0){
			final value = _drag_start_ratio + (_drag_displacement / panelHeight);
			//_D.debug('onPanUpdate: ${_drag_start_ratio} / ${_drag_displacement / panelHeight}');
			panelController.setPanelPosition(min(1, value));
			return;
		}
		
		_D.debug('uncaught ...');
	}
	
	void _onPanEnd(Offset offset) {
		_D.debug('_onPanEnd: $offset');
		if (panelController.getPanelPosition() < 0.85){
//			shiftPageController();
			panelController.close();
			_D.debug('close panel');
		}else{
//			shiftPageController();
			panelController.open();
			_D.debug('open panel');
		}
		_drop_y = offset.dy;
	}
	
	void dispose(){
		pageController.dispose();
		detector.dispose();
	}
}



