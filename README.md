於 [flutter 2019 web portfolio][portfolio] 中抽出的 package

## 可用組件
- [CustomPanGestureRecognizer](#CustomPanGestureRecognizer--source)
- [PanelGestureRecognizer](#PanelGestureRecognizer--source)
- [ScrollerNestablePanelGestureController](#ScrollerNestablePanelGestureController--source)
- [DebugBox](#DebugBox--source)
- [ResponsiveScreen/ResponsiveELt](#ResponsiveScreen/ResponsiveELt--source)
- [ContextKeeper](#ContextKeeper--source)
- [Dim](#Dim--source)

### CustomPanGestureRecognizer | [source][custom_gesture]

為了自定義 [GestureRecognizer] 需要實作 [RawGestureDetector], [PanelGestureRecognizer] 透過實作
[RawGestureDetector] 來解決當一個 Scrollable 物件其 Gesture 在接受 Scroll 事件後，便無法接收 [Panel][Panel]
平移的事件，如當 [Panel][Panel] 巢狀一個 Scrollable 子物件時，其 event arena 如下

__event arena__

```txt
[scrollEvent]   priority-1
     |
     |
 [panEvent]     priority-2
```

當只有 SlidingPanel 時可平移 Panel 但是，當其內部置入了一個 Scrollable 以後，原來
的 onPan 事件則因優先權低於子層而被 Scroll 事件擋掉了，為了取得其 event arena 的所有權，需要自行實作客制的
[GestureRecognizer], 而 [CustomPanGestureRecognizer] 便是為了解決平移事件被內容物事件擋掉的問題，而需實
作一個可以外部偵聽 控制的 [GestureRecognizer]

__interface__

```dart
/// on pan down, 其 return 值決定是否取得 pan 事件，還是讓渡
/// return false to yield the event arena
/// return true to win the event arena
final bool Function(Offset offset) onPanDown;
/// 當 pan 成功 update 時
final Function(Offset offset) onPanUpdate;
/// 當 pan 結束
final Function(Offset offset) onPanEnd;
CustomPanGestureRecognizer({
  required this.onPanDown,
  required this.onPanUpdate,
  required this.onPanEnd
});
```

### PanelGestureRecognizer | [source][custom_gesture]

當 Panel 內置一個 Scrollable content 時，Gesture 事件因優先權在子層而無法控制 Panel，所以需要透過實作
[RawGestureDetector] 以對 [GestureRecognizer] 作進一步控制，[PanelGestureRecognizer] 的 Controller
- [ScrollerNestablePanelGestureController]

__interface__

```dart
class PanelGestureRecognizer extends RawGestureDetector {
  PanelGestureRecognizer({
    required Widget child,
    required ScrollerNestablePanelGestureController gestureController
  }) : super(
      gestures: gestureController.detector.createGestures(),
      child: child
  );
}
```

__Example__

```dart
class Sample {
  Widget baseBuilder(BuildContext context, Widget child) {
    return LayoutBuilder(
        builder: (context, constraint) =>
            PanelGestureDetector(
              gestureController: widget.gestureController,
              child: SingleChildScrollView(
                controller: widget.gestureController.pageController,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: widget.marginTop),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(24.0)),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10.0,
                              color: Colors.grey,
                            ),
                          ]
                      ),
                      child: child,
                    ),
                  ],
                ),
              ))
        );
  }
}
```

### ScrollerNestablePanelGestureController | [source][portfolio_slideup_panel]

由 [PageController]/[PanelController] 二個 controller 組成，交替控制切換其所有權, 其行為定義如下

1) 當 Scrollable content 於起點時，且使用者往下 pan，這時因為已經沒有額外的可視內容，判定使用者真正想要做的是想將 Panel 下拉，而將所有權交給 Panel
2) 當 Scrollable content 於結尾時，且使用者往上 pan，將所有權交給 Panel
3) 其餘狀態所有權為 Scrollable content

__interface__

```dart
class ScrollerNestablePanelGestureController {
  final PageController pageController;
  final PanelController panelController;
}
```

__example__

```dart
class Sample  {
  late ScrollerNestedPanelGestureController gestureController;
  ScrollerNestableSlidingUpPanel? panel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gestureController = ScrollerNestedPanelGestureController(
      pageController: PageController(),
      panelController: PanelController(),
    );
  }

  Widget slidingUp(Widget body) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    final double cheight = 35;
    final double marginTop = 20;
    final double panelHeight = ScreenUtil.screenHeightDp - 20;
    final double collapseW = max(ScreenUtil.screenWidthDp / 3, 210);
    panel = ScrollerNestableSlidingUpPanel(
      renderPanelSheet: false,
      minHeight: cheight + marginTop,
      maxHeight: panelHeight,
      backdropEnabled: true,
      backdropTapClosesPanel: true,
      gestureController: gestureController,
      panel: PortfolioPanel(
          width: ScreenUtil.screenWidthDp,
          height: panelHeight,
          marginTop: marginTop + cheight,
          gestureController: gestureController
      ),
      collapsed: PortfolioCollapseArea(
          width: collapseW, height: cheight, marginTop: marginTop),
      body: body,
      borderRadius: radius,
      parallaxEnabled: true,
    );
    assert(panel?.controller != null);
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: ScreenUtil.screenConstraintMax.minHeight,
        minWidth: ScreenUtil.screenConstraintMax.minWidth,
      ),
      child: panel,
    );
  }
}
```

### DebugBox | [source][bounding]
於 Container 繪制一亂數色彩的 border, 用於 debug 視覺化 Container 大小

__interface__
```dart
class DebugBox extends StatelessWidget {
	final Widget child;
	final Color borderColor;
	DebugBox({required this.child}): borderColor = _random;
}
```

__turning debug off__
```dart
DebugBox.setBoxDebugOff();
```

__turning debug on__
```dart
DebugBox.setBoxDebugOn();
```

### ResponsiveScreen/ResponsiveELt | [source][responsive_widget]

二者功能皆同，只是情境不同，均需使用在可取得 Constraint (如  LayoutBuilder) 下，
透過已知 Constraint 的情況下，依據輸入的大／中／小 情境下，提供相對應版本的 Widget

__ResponsiveScreen - example__ [demo][portfolio]

```dart
class Example{
    Widget _buildLargeScreen(BuildContext context, BoxConstraints constraints) {
        final lcolConstraints = BoxConstraints(
          maxWidth: HomeLCol.screenWidthLD,
          maxHeight: constraints.maxHeight,
        );
    
        final rcolConstraints = BoxConstraints(
          maxWidth: HomeRCol.screenWidthLD,
          maxHeight: constraints.maxHeight,
        );
    
        _D.d(()=>'rebuild _buildLargeScreen homeL(${HomeLCol.screenWidthLD}), homeR(${HomeRCol.screenWidthLD})');
        return IntrinsicHeight(
          child: BoundingBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                /// if we use expanded here would cause an unbounded height definition
                /// on Column, which entails some render problem, hence we need to
                /// use IntrinsincHeight to wrap on top of Column
                Expanded(
                  child: Paddings.homePadding(
                    child: Paddings.homeBodyTop(
                      size: HomePage.homeBody.large,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          /// _buildLeftCol(context),
                          /// ----------------------------------------------------------
                          /// note: [Expanded] flex: 1.. here is neccsssary
                          /// The reason why [Expanded] here is neccessary is that,
                          /// the following Colum[HomeRCol] has a restrict width, so that
                          /// [Expanded] could get it's available space to fill the rest.
                          Expanded(child:HomeLCol(lcolConstraints)),
                          BoundingBox(child: Paddings.gallery(
                            child: HomeRCol(rcolConstraints),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                HomeFooter.large()
              ],
            ),
          ),
        );
      }

  Widget _buildMediumScreen(BuildContext context, BoxConstraints constraints) {
    _D.d(()=>'rebuild _buildMediumScreen home');
    final rcolConstraints = BoxConstraints(
      maxWidth: constraints.maxWidth - ScreenUtil.largeDesign.setWidth(HomePage.designPaddingLR)*2,
      maxHeight: constraints.maxHeight,
    );
    return IntrinsicHeight(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Paddings.homePadding(
              child: Paddings.homeBodyTop(
                size: HomePage.homeBody.medium,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: HomeLCol(constraints)),
                  ],
                ),
              ),
            ),
          ),
          Paddings.homePadding(
              child: HomeRCol(rcolConstraints)),
          HomeFooter.large()
        ],
      ),
    );
  }

  Widget _buildSmallScreen(BuildContext context, BoxConstraints constraints) {
    _D.d(()=>'rebuild _buildSmallScreen home');
    return Stack(
      children: <Widget>[
        IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Paddings.homePadding(
                  child: Paddings.homeBodyTop(
                  size: HomePage.homeBody.small,
                  /// using [Row] here is necessary, since [Expanded] must be placed
                  /// directly inside [Flex] widgets (Column/Row/...)
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: HomeLCol(constraints)),
                    ],
                  )),
                )
              ),
              Paddings.gallerySmallMedium(child: HomeRCol(constraints)/*480*/),
              HomeFooter.small()
            ],
          ),
        ),

      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (!visible)
      return Container();

    return LayoutBuilder(
        key: ValueKey("HomePage"),
        builder: (context, constraints) {
          _D.d(()=>'rebuild home layout builder, ${constraints.maxWidth}');
          return SingleChildScrollView(
            child: ResponsiveScreen(
              key: const ValueKey("HomeLayoutResponsive"),
              largeScreen : ((_buildLargeScreen(context, constraints))),
              mediumScreen: (_buildMediumScreen(context, constraints)),
              smallScreen : (_buildSmallScreen(context, constraints)),
            ),
          );
        });
  }
}
```

__ResponsiveElt - example__
```dart
class SmallGallery{
@override
  @override
    Widget build(BuildContext context) {
      final size = IS_MOBILE ? SIZE_GALLERY : SIZE_DESKTOP;
      final gallery = _GalleryBaseLayout();
      
      // 當前 gallery 的 constraints
      final w = constraints.maxWidth - ScreenUtil.largeDesign.setWidth(HomeRCol.imageDesignPaddingR);
      final h = w / gallery.whRatio;
      final media = TRWMedia.fromConstaints(constraints);
      
      // 依據 constraints, 及設計上的 responsive size 來選擇 render large|medium|small
      final responsive = ResponsiveElt(
          responsiveSize: size,
          media: media,
          large: _GalleryLarge(constraints),
          medium: _GalleryMedium(constraints),
          small: _GallerySmall(constraints));
      _D.d(() => 'isLarge :	${responsive.isLargeOrMedium(media)}');
      _D.d(() => 'isMedium: ${responsive.isMedium(media)}');
      _D.d(() => 'isSmall : ${responsive.isSmall(media)}');
      return responsive;
    }
}

```


### ContextKeeper | [source][context]
```txt
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
```


### Dim (Dimension model) | [source][dim]




-----

[bounding]:lib/src/widgets/debugs.dart
[context_widget]:lib/src/widgets/context_widget.dart
[context]:lib/src/widgets/context_widget.dart
[custom_appbar]:lib/src/widgets/custom_appbar.dart
[custom_gesture]:lib/src/widgets/custom_gesture.dart
[hiddable_widget]:lib/src/widgets/_hiddable_widget.dart
[portfolio_slideup_panel]:lib/src/widgets/portfolio_slideup_panel.dart
[responsive_widget]:lib/src/widgets/responsive_widget.dart
[dim]:lib/src/screen/dim.dart
[portfolio]: https://gordianknotC.github.io/portfolio2019Fl
[Panel]: https://pub.dev/packages/sliding_up_panel
