import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'custom_gesture.dart';

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