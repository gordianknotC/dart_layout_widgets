/*
 * Created by 李卓原 on 2018/9/29.
 * email: zhuoyuan93@gmail.com
 */


import 'package:common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final _D = Logger(name:'SCN_UTIL', levels: LEVEL0);


enum DesignCanvas{
  small, medium, large
}

class ScreenUtil {
  static BoxConstraints get screenConstraintMin => BoxConstraints(minWidth: ScreenUtil.screenWidthDp, minHeight: ScreenUtil.screenHeightDp);
  static BoxConstraints get screenConstraintMax => BoxConstraints(maxWidth: ScreenUtil.screenWidthDp, maxHeight: ScreenUtil.screenHeightDp);
  
  static ScreenUtil largeDesign  ;
  static ScreenUtil mediumDesign  ;
  static ScreenUtil smallDesign  ;
  
  static bool get isSmalDesign{
    final w = (smallDesign).sketchWidth;
    return screenWidthDp <= w;
  }
  
  static bool get isMediumDesign{
    return !isSmalDesign && !isLargeDesign;
  }
  
  static bool get isLargeDesign{
    final w = (largeDesign ?? mediumDesign ?? smallDesign).sketchWidth;
    if (screenWidthDp >= w) {
      return true;
    } else if (screenWidthDp > (mediumDesign ?? smallDesign).sketchWidth) {
      return true;
    }
    return false;
  }
  
  /// UI设计中手机尺寸 , px
  /// Size of the phone in UI Design , px
  final double sketchWidth;
  final double sketchHeight;
  
  /// 控制字体是否要根据系统的“字体大小”辅助选项来进行缩放。默认值为false。
  /// allowFontScaling Specifies whether fonts should scale to respect Text Size accessibility settings. The default is false.
  final bool allowFontScaling;
  
  final DesignCanvas _designType;
  
  static final ValueNotifier<Size> screenSizeNotifier = ValueNotifier<Size>(Size(screenWidthDp, screenHeightDp));
  static MediaQueryData _mediaQueryData;
  static double _screenWidth;
  static double _screenHeight;
  static double _pixelRatio;
  static double _statusBarHeight;
  
  static double _bottomBarHeight;
  static double _textScaleFactor;
  static bool isPortrait;
  
  
  const ScreenUtil.large({
    this.sketchWidth = 1600,
    this.sketchHeight = 1024,
    this.allowFontScaling = false,
  }): _designType = DesignCanvas.large;
  
  const ScreenUtil.medium({
    this.sketchWidth = 1024,
    this.sketchHeight = 1024,
    this.allowFontScaling = false,
  }): _designType = DesignCanvas.medium;
  
  const ScreenUtil.small({
    this.sketchWidth = 545,
    this.sketchHeight = 1024,
    this.allowFontScaling = false,
  }): _designType = DesignCanvas.small;
  
  
  static ScreenUtil getInstance() {
    return largeDesign;
  }
  
  static void init(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    _mediaQueryData = mediaQuery;
    _pixelRatio = mediaQuery.devicePixelRatio;
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _statusBarHeight = mediaQuery.padding.top;
    _bottomBarHeight = _mediaQueryData.padding.bottom;
    _textScaleFactor = mediaQuery.textScaleFactor;
    _infoStartup();
    isPortrait = screenWidth < screenHeight;
    
    _D.debug('onScreen changed ${Size(_screenWidth, _screenHeight)}');
    screenSizeNotifier.value = Size(_screenWidth, _screenHeight);
  }
  
  static double get screenLongestSide  => isPortrait ? screenHeightDp : screenWidthDp;
  static double get screenShortestSide => isPortrait ? screenWidthDp : screenHeightDp;
  
  static MediaQueryData get mediaQueryData => _mediaQueryData;
  
  /// 每个逻辑像素的字体像素数，字体的缩放比例
  /// The number of font pixels for each logical pixel.
  static double get textScaleFactory => _textScaleFactor;
  
  /// 设备的像素密度
  /// The size of the media in logical pixels (e.g, the size of the screen).
  static double get pixelRatio => _pixelRatio;
  
  /// 当前设备宽度 dp
  /// The horizontal extent of this size.
  static double get screenWidthDp => _screenWidth;
  
  ///当前设备高度 dp
  ///The vertical extent of this size. dp
  static double get screenHeightDp => _screenHeight;
  
  /// 当前设备宽度 px
  /// The vertical extent of this size. px
  static double get screenWidth => _screenWidth * _pixelRatio;
  
  /// 当前设备高度 px
  /// The vertical extent of this size. px
  static double get screenHeight => _screenHeight * _pixelRatio;
  
  /// 状态栏高度 dp 刘海屏会更高
  /// The offset from the top
  static double get statusBarHeight => _statusBarHeight;
  
  /// 底部安全区距离 dp
  /// The offset from the bottom.
  static double get bottomBarHeight => _bottomBarHeight;
  
  /// 实际的dp与UI设计px的比例
  /// The ratio of the actual dp to the design draft px
  double get scaleWidth => _screenWidth / sketchWidth;
  
  double get scaleHeight => _screenHeight / sketchHeight;
  
  /// 根据UI设计的设备宽度适配
  /// 高度也可以根据这个来做适配可以保证不变形,比如你先要一个正方形的时候.
  /// Adapted to the device width of the UI Design.
  /// Height can also be adapted according to this to ensure no deformation ,
  /// if you want a square
  double setWidth(double width) => width * scaleWidth;
  
  /// 根据UI设计的设备高度适配
  /// 当发现UI设计中的一屏显示的与当前样式效果不符合时,
  /// 或者形状有差异时,建议使用此方法实现高度适配.
  /// 高度适配主要针对想根据UI设计的一屏展示一样的效果
  /// Highly adaptable to the device according to UI Design
  /// It is recommended to use this method to achieve a high degree of adaptation
  /// when it is found that one screen in the UI design
  /// does not match the current style effect, or if there is a difference in shape.
  double setHeight(double height) => height * scaleHeight;
  
  ///字体大小适配方法
  ///@param [fontSize] UI设计上字体的大小,单位px.
  ///Font size adaptation method
  ///@param [fontSize] The size of the font on the UI design, in px.
  ///@param [allowFontScaling]
  double setSp(double fontSize) => allowFontScaling
      ? setWidth(fontSize)
      : setWidth(fontSize) / _textScaleFactor;
  
  
  static void _infoStartup(){
    _D.debug('----------------------------------');
    _D.debug('      initial configuration       ');
    _D.debug('');
    if (isLargeDesign){
      _D.debug('deisgnWidth (L): ${largeDesign?.sketchWidth}');
      _D.debug('designHeight(L): ${largeDesign?.sketchHeight}');
      _D.debug('scaleWidth (L): ${largeDesign?.scaleWidth}');
      _D.debug('scaleHeight(L): ${largeDesign?.scaleHeight}');
    }else if (isMediumDesign){
      _D.debug('deisgnWidth (M): ${mediumDesign?.sketchWidth}');
      _D.debug('designHeight(M): ${mediumDesign?.sketchHeight}');
      _D.debug('scaleWidth (M): ${mediumDesign?.scaleWidth}');
      _D.debug('scaleHeight(M): ${mediumDesign?.scaleHeight}');
    }else{
      _D.debug('deisgnWidth (S): ${smallDesign?.sketchWidth}');
      _D.debug('designHeight(S): ${smallDesign?.sketchHeight}');
      _D.debug('scaleWidth (S): ${smallDesign?.scaleWidth}');
      _D.debug('scaleHeight(S): ${smallDesign?.scaleHeight}');
    }
    _D.debug('ratio          : $_pixelRatio/$pixelRatio');
    _D.debug('screen width   : $_screenWidth/$screenWidth');
    _D.debug('screen height  : $_screenHeight/$screenHeight');
    _D.debug('statusBarHeight: $_statusBarHeight/$statusBarHeight');
    _D.debug('bottomBarHeight: $_bottomBarHeight/$bottomBarHeight');
    _D.debug('textScaleFactor: $_textScaleFactor/$textScaleFactory');
  }
}