import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'custom_gesture.dart';


///
/// 由 [PageController]/[PanelController] 二個 controller 組成，交替控制切換其所有權,
/// 其行為定義如下
///
/// 1) 當 Scrollable content 於起點時，且使用者往下 pan，這時因為已經沒有額外的可視內容，
///    判定使用者真正想要做的是想將 Panel 下拉，而將所有權交給 Panel
/// 2) 當 Scrollable content 於結尾時，且使用者往上 pan，將所有權交給 Panel
/// 3) 其餘狀態所有權為 Scrollable content
///
/// __example__
/// ```dart
/// class Sample  {
///   late ScrollerNestedPanelGestureController gestureController;
///   ScrollerNestableSlidingUpPanel? panel;
///
///   @override
///   void initState() {
///     // TODO: implement initState
///     super.initState();
///     gestureController = ScrollerNestedPanelGestureController(
///       pageController: PageController(),
///       panelController: PanelController(),
///     );
///   }
///
///   Widget slidingUp(Widget body) {
///     BorderRadiusGeometry radius = BorderRadius.only(
///       topLeft: Radius.circular(24.0),
///       topRight: Radius.circular(24.0),
///     );
///     final double cheight = 35;
///     final double marginTop = 20;
///     final double panelHeight = ScreenUtil.screenHeightDp - 20;
///     final double collapseW = max(ScreenUtil.screenWidthDp / 3, 210);
///     panel = ScrollerNestableSlidingUpPanel(
///       renderPanelSheet: false,
///       minHeight: cheight + marginTop,
///       maxHeight: panelHeight,
///       backdropEnabled: true,
///       backdropTapClosesPanel: true,
///       gestureController: gestureController,
///       panel: PortfolioPanel(
///           width: ScreenUtil.screenWidthDp,
///           height: panelHeight,
///           marginTop: marginTop + cheight,
///           gestureController: gestureController
///       ),
///       collapsed: PortfolioCollapseArea(
///           width: collapseW, height: cheight, marginTop: marginTop),
///       body: body,
///       borderRadius: radius,
///       parallaxEnabled: true,
///     );
///     assert(panel?.controller != null);
///     return ConstrainedBox(
///       constraints: BoxConstraints(
///         minHeight: ScreenUtil.screenConstraintMax.minHeight,
///         minWidth: ScreenUtil.screenConstraintMax.minWidth,
///       ),
///       child: panel,
///     );
///   }
/// }
/// ```
class ScrollerNestableSlidingUpPanel extends SlidingUpPanel {
  ScrollerNestableSlidingUpPanel({
    Key? key,
    required Widget panel,
    required ScrollerNestablePanelGestureController gestureController,
    bool backdropEnabled = false,
    bool backdropTapClosesPanel = true,
    bool isDraggable = true,
    bool panelSnapping = true,
    bool parallaxEnabled = false,
    bool renderPanelSheet = true,
    Border? border,
    BorderRadiusGeometry? borderRadius,
    Color backdropColor = Colors.black,
    Color color = Colors.white,
    double backdropOpacity = 0.5,
    double maxHeight = 500.0,
    double minHeight = 100.0,
    double parallaxOffset = 0.1,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    PanelState defaultPanelState = PanelState.CLOSED,
    SlideDirection slideDirection = SlideDirection.UP,
    void Function(double position)? onPanelSlide,
    VoidCallback? onPanelClosed,
    VoidCallback? onPanelOpened,
    Widget? body,
    Widget? collapsed,
    List<BoxShadow> boxShadow = const <BoxShadow>[
      BoxShadow(
        blurRadius: 8.0,
        color: Color.fromRGBO(0, 0, 0, 0.25),
      )
    ],
  }) : super(
            key: key,
            panel: panel,
            body: body,
            collapsed: collapsed,
            minHeight: minHeight,
            maxHeight: maxHeight,
            border: border,
            borderRadius: borderRadius,
            boxShadow: boxShadow,
            color: color,
            padding: padding,
            margin: margin,
            renderPanelSheet: renderPanelSheet,
            panelSnapping: panelSnapping,
            backdropEnabled: backdropEnabled,
            backdropOpacity: backdropOpacity,
            backdropTapClosesPanel: backdropTapClosesPanel,
            onPanelSlide: onPanelSlide,
            parallaxEnabled: parallaxEnabled,
            parallaxOffset: parallaxOffset,
            isDraggable: isDraggable,
            slideDirection: slideDirection,
            defaultPanelState: defaultPanelState,
            // ----------------------------
            onPanelClosed:
                gestureController.wrapOnClosed(onPanelClosed ?? () {}),
            onPanelOpened:
                gestureController.wrapOnOpened(onPanelOpened ?? () {}),
            controller: gestureController.panelController) {
    gestureController.panelHeight = maxHeight;
  }
}

// class ScrollerNestableSlidingUpPanel extends ScrollerNestableSlidingUpPanel{}
