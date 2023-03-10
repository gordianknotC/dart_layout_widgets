import 'dart:math';

import 'package:dart_common/dart_common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

final _D = Logger.filterableLogger(moduleName: 'HOME');



///
/// 為了自定義 [GestureRecognizer] 需要實作 [RawGestureDetector], [PanelGestureRecognizer] 透過實作
/// [RawGestureDetector] 來解決當一個 Scrollable 物件其 Gesture 在接受 Scroll 事件後，便無法接收 panel
/// 平移的事件，如 SlidingPanel 可以透過 onPan 平移 panel 但是，當其內部置入了一個 Scrollable 以後，原來
/// 的 onPan 事件則被 Scroll 事件吃掉了，為了取得其 event arena 的所有權，需要自行實作客制的 [GestureRecognizer]
/// [CustomPanGestureRecognizer] 便是為了解決平移事件被內容物事件吃掉的問題
///
/// __event arena__
/// ```txt
/// [scrollEvent]   priority-1
///      |
///      |
///  [panEvent]     priority-2
/// ```
///
/// 當只有 SlidingPanel 時可平移 Panel 但是，當其內部置入了一個 Scrollable 以後，原來
/// 的 onPan 事件則因優先權低於子層而被 Scroll 事件擋掉了，為了取得其 event arena 的所有權，需要自行實作客制的
/// [GestureRecognizer], 而 [CustomPanGestureRecognizer] 便是為了解決平移事件被內容物事件擋掉的問題，而需實
/// 作一個可以外部偵聽 控制的 [GestureRecognizer]
///
///
class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  /// on pan down, 其 return 值決定是否取得 pan 事件，還是讓渡
  /// return false to yield the event arena
  /// return true to win the event arena
  final bool Function(Offset offset) onPanDown;
  /// 當 pan 成功 update 時
  final Function(Offset offset) onPanUpdate;
  /// 當 pan 結束
  final Function(Offset offset) onPanEnd;
  int? _custom_pointer;

  int? get custom_pointer => _custom_pointer;

  CustomPanGestureRecognizer({
    required this.onPanDown,
    required this.onPanUpdate,
    required this.onPanEnd
  });

  Map<Type, GestureRecognizerFactory>
  createGestures([void onInit(CustomPanGestureRecognizer inst)?]){
    return <Type, GestureRecognizerFactory>{
      CustomPanGestureRecognizer: GestureRecognizerFactoryWithHandlers<CustomPanGestureRecognizer>(
        () => this,
        onInit ?? (instance){},
      ),
    };
  }

  void stopAndResumeTracking(int pointer) {
    try {
      stopTracking();
      startTrackingPointer(pointer);
      resolve(GestureDisposition.accepted);
    } on AssertionError catch (e) {
    } catch (e, s) {
      _D.d(() =>
          '[ERROR] CustomPanGestureRecognizer.stopAndResumeTracking failed: $e\n$s');
      rethrow;
    }
  }

  void stopTracking() {
    try {
      stopTrackingPointer(_custom_pointer!);
      _D.d(() => 'stopTracking');
    } on AssertionError catch (e) {
    } catch (e, s) {
      _D.d(() =>
          '[ERROR] CustomPanGestureRecognizer.stopTracking failed: $e\n$s');
      rethrow;
    }
  }

  void startTracking() {
    try {
      startTrackingPointer(_custom_pointer!);
      resolve(GestureDisposition.accepted);
    } on AssertionError catch (e) {
    } catch (e, s) {
      _D.d(() =>
          '[ERROR] CustomPanGestureRecognizer.startTracking failed: $e\n$s');
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
    _D.d(() => 'didStopTrackingLastPointer $pointer');
  }
}

///
/// 當 Panel 內置一個 Scrollable content 時，Gesture 事件因優先權在子層而無法控制
/// Panel，所以需要透過實作 [RawGestureDetector] 以對 [GestureRecognizer] 作進一步控
/// 制，[PanelGestureRecognizer] 的 Controller - [ScrollerNestablePanelGestureController]
///
/// ### [Example]
/// ```dart
/// 	@override void initState(){
///		super.initState();
///		controller = ScrollerNestedPanelGestureController(
///			pageController: PageController(),
///			panelController: widget.panelController,
///			panelHeight: widget.height
///		);
///	}
///
///	Widget baseBuilder(BuildContext context, Widget child){
///		return LayoutBuilder(
///			builder: (context, constraint) => PanelGestureRecognizer(
///			 	gestureController: controller,
///			  child: SingleChildScrollView(
///			  	controller: controller.pageController,
///			    child: Column(
///			    	children: <Widget>[
///			    		SizedBox(height: widget.marginTop),
///			    		Container(
///			    			decoration: BoxDecoration(
///			    					color: Colors.white,
///			    					borderRadius: BorderRadius.all(Radius.circular(24.0)),
///			    					boxShadow: [
///			    						BoxShadow(
///			    							blurRadius: 10.0,
///			    							color: Colors.grey,
///			    						),
///			    					]
///			    			),
///			    			child: child,
///			    		),
///			    	],
///			    ),
///			  ),
///			)		);
///	}
/// ```
class PanelGestureRecognizer extends RawGestureDetector {
  PanelGestureRecognizer({
    required Widget child,
    required ScrollerNestablePanelGestureController gestureController
  }) : super(
      gestures: gestureController.detector.createGestures(),
      child: child
  );
}

@Deprecated("use PanelGestureRecogizer instead")
class PanelGestureDetector extends PanelGestureRecognizer{
  PanelGestureDetector({required Widget child, required ScrollerNestablePanelGestureController gestureController}) : super(child: child, gestureController: gestureController);
}





@Deprecated("use NestedScrollerPanelGestureController instead")
class ScrollerNestedPanelGestureController
    extends ScrollerNestablePanelGestureController {
  ScrollerNestedPanelGestureController(
      {required PageController pageController,
      required PanelController panelController})
      : super(pageController: pageController, panelController: panelController);
}

class ScrollerNestablePanelGestureController {
  final PageController pageController;
  final PanelController panelController;
  double panelHeight;

  void Function()? _onOpened;
  void Function()? _onClosed;

  // ignore: avoid_setters_without_getters
  void Function() wrapOnOpened(void cb()) {
    return () {
      _D.d(() => 'on open panel');
      if (panelController.panelPosition == 1.0 && pageController.offset == 0) {
        cb();
        _D.d(() => 'on open shift');
        shiftScrollContent();
      }
    };
  }

  // ignore: avoid_setters_without_getters
  void Function() wrapOnClosed(void cb()) {
    return () {
      _D.d(() => 'on close panel');
      if (panelController.panelPosition == 0.0 && pageController.offset != 0) {
        cb();
        _D.d(() => 'on close shift');
        shiftScrollContent();
      }
    };
  }

  late CustomPanGestureRecognizer detector;
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
  bool get _isApproachingEnd {
    return _delta > 0 && pageController.position.extentAfter < 5;
  }

  /// is content scroller position at the beginning
  bool get _isApproachingStart {
    return _delta < 0 && _current_offset <= 5;
  }

  /// is user intent to collapse panel
  bool get _isIntentToCollapse {
    return _delta == 0 && _current_offset <= 5;
  }

  ScrollerNestablePanelGestureController({
    required this.pageController,
    required this.panelController,
    this.panelHeight = 32.0
  }) {
    detector = CustomPanGestureRecognizer(
        onPanDown: _onPanDown,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd
    );
    pageController.addListener(_onPageScroll);
    shiftScrollContent();
  }

  int _retries = 0;

  void shiftScrollContent() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        _repelListening = true;
        _retries = 0;
        _D.d(() => 'shift pageController');

        /// make displacement for scroller content, so that gesture
        /// could be detected whether it's at the beginning of scroll position
        /// or not.
        pageController
            .jumpTo(pageController.offset == 0 ? 0.04 : pageController.offset);
      } else {
        _retries++;
        if (_retries < 5) {
          shiftScrollContent();
        } else {
          _retries = 0;
        }
      }
    });
  }

  void _onPageScroll() {
    if (_repelListening) {
      _D.d(() => '_repelListening');
      _repelListening = false;
//			return;
    }

    _current_offset = pageController.offset;
    _delta = _current_offset - _prev_offset;

    if (_current_offset != 0) _prev_offset = _current_offset;

    ///
    /// 1) content scroller position is at the beginning and about to scroll down
    /// 2) since no more scroll content are available, hand over gesture
    ///    pointer to panel controller
    if (_isApproachingStart) {
      _insertTracking = true;
      _drag_start_ratio = panelController.panelPosition;
      detector.startTracking();
      _D.d(() => 'approaching start, startTracking');
      return;
    }

    ///
    /// 1) content scroller position is at the end
    if (_isApproachingEnd) {
      final ratio = _drag_start_ratio = panelController.panelPosition;
      _D.d(() => 'approaching end ${ratio}');

      /// 2) if user are scrolling up and content scroller position is at the end
      /// 	a) if panel scroll position is at the beginning - no hand over
      /// 	b) if panel scroll position is not at the beginning.
      ///    		hand over gesture pointer to panel controller
      if (ratio != 1) {
        _insertTracking = true;
        _drag_start_ratio = ratio;
        detector.startTracking();
        _D.d(() => 'approach end at non start position, startTracking');
      }
      return;
    }
//		_D.d(()=>'$_current_offset/ $_delta - after:${pageController.position.extentAfter}/before:${pageController.position.extentBefore}');
  }

  bool _onPanDown(Offset offset) {
    _delta = 0;
    _drag_displacement = 0;
    _drag_start_y = offset.dy;
    _drag_start_ratio = panelController.panelPosition;
    _D.d(() => 'onPanDown: $offset/${pageController.offset}');
    return false;
  }

  void _onPanUpdate(Offset offset) {
    if (_insertTracking) {
      _drag_start_y = offset.dy;
      _insertTracking = false;
      _D.d(() => 'reset insert tracking');
    }

    _draggin_y = offset.dy;
    _drag_displacement = _drag_start_y - _draggin_y;
    if (!_isApproachingEnd && _drag_displacement > 0) {
      detector.stopTracking();
      _D.d(() => 'stop tracking, exploring more content');
      return;
    }

    if (_isApproachingStart && _drag_displacement < 0 || _isApproachingEnd) {
      final value = _drag_start_ratio + (_drag_displacement / panelHeight);
      panelController.panelPosition = (min(1, value));
      //_D.d(()=>'onPanUpdate: $_drag_displacement');
      return;
    }

    if (_delta == 0 && _current_offset == 0) {
      final value = _drag_start_ratio + (_drag_displacement / panelHeight);
      //_D.d(()=>'onPanUpdate: ${_drag_start_ratio} / ${_drag_displacement / panelHeight}');
      panelController.panelPosition = (min(1, value));
      return;
    }

    _D.d(() => 'uncaught ...');
  }

  void _onPanEnd(Offset offset) {
    _D.d(() => '_onPanEnd: $offset');
    if (panelController.panelPosition < 0.85) {
//			shiftPageController();
      panelController.close();
      _D.d(() => 'close panel');
    } else {
//			shiftPageController();
      panelController.open();
      _D.d(() => 'open panel');
    }
    _drop_y = offset.dy;
  }

  void dispose() {
    pageController.dispose();
    detector.dispose();
  }
}
