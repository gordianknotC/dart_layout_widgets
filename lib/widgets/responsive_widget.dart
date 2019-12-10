import 'package:common/common.dart';
import 'package:flutter/material.dart';

import '../screen/screen_utils.dart';
import 'stateful.dart';

final _D = Logger(name:'RWD', levels: LEVEL0);


class ResponsiveScreen extends StatelessWidget {
  final Widget largeScreen;
  final Widget mediumScreen;
  final Widget smallScreen;
  final BoxConstraints constraints;
  EPlatform get platform => PLATFORM;
  bool      get isMobile => IS_MOBILE;
  
  const ResponsiveScreen({Key key,
        @required this.largeScreen,
        this.mediumScreen, this.constraints,
        this.smallScreen})
      : super(key: key);

  static bool isSmallScreen(BuildContext context) {
//    _D.debug('   isSmallScreen: ${MediaQuery.of(context).size.width < 768}/${MediaQuery.of(context).size.width}');
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1200;
  }
  
  bool _isLargeOrMedium(BoxConstraints constraints){
    return constraints.maxWidth >= 768;
  }

  bool _isMedium(BoxConstraints constraints){
    return constraints.maxWidth >= 768 &&
        constraints.maxWidth < 1200;
  }
  
  // ignore: unused_element
  bool _isSmall(BoxConstraints constraints){
    return constraints.maxWidth < 768;
  }
  
  Widget buildBySize(BuildContext context, BoxConstraints _constraints){
    if (_isLargeOrMedium(_constraints)) {
      if (_isMedium(_constraints)){
        // medium
        _D.debug('rebuild responsive medium: ${_constraints.maxWidth}');
        return mediumScreen ?? largeScreen;
      }
      // large
      _D.debug('rebuild responsive large: ${_constraints.maxWidth}');
      return largeScreen;
    } else {
      // small
      _D.debug('rebuild responsive small: ${_constraints.maxWidth}/ ${key}');
      return smallScreen ?? largeScreen;
    }
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _constraints) {
        if (_constraints.maxWidth > 10000 && constraints != null){
          return buildBySize(context, constraints);
        }
        return buildBySize(context, _constraints);
      },
    );
  }
}



class TResponsiveSize{
  final int small;
  final int large;
  const TResponsiveSize({@required this.large, this.small });
  
  @override String toString() {
    return "TResponsiveSize($large/$small)";
  }
}

const SIZE_SKILLAUDIO = TResponsiveSize(large: 768, small: 580);
const SIZE_GALLERY    = TResponsiveSize(large: 768, small: 580);
const SIZE_CELLPHONE = TResponsiveSize(large: 768, small: 365);
const SIZE_DESKTOP   = TResponsiveSize(large: 1280, small: 768);
final SIZE_DESIGNCANVAS = TResponsiveSize(
    large: ScreenUtil.mediumDesign.sketchWidth.toInt(),  // 1024
    small: ScreenUtil.smallDesign.sketchWidth.toInt()   // 545
);


class TRWMedia{
  final double mediaWidth;
  final double mediaHeight;
  double get maxWidth => mediaWidth;
  double get maxHeight => mediaHeight;
  
  TRWMedia({this.mediaWidth, this.mediaHeight});
  
  TRWMedia.fromConstaints(BoxConstraints constraints)
    : mediaWidth = constraints.maxWidth, mediaHeight = constraints.maxHeight,
        assert(constraints.maxWidth < 10000, "input constraints with infinite width");
}

class ResponsiveElt extends StatelessWidget {
  final Widget large;
  final Widget medium;
  final Widget small;
  final TRWMedia media;
  final TResponsiveSize responsiveSize;

  const ResponsiveElt({Key key,
    @required this.large,
    @required this.responsiveSize,
    @required this.media,
    this.medium,
    this.small,
  }): super(key: key);
  
  bool isSmall(TRWMedia constraints) {
    return constraints.maxWidth <= responsiveSize.small;
  }
  
  bool isLargeOrMedium(TRWMedia constraints) {
    return constraints.maxWidth > responsiveSize.small;
  }
  
  bool isMedium(TRWMedia constraints) {
    return constraints.maxWidth >= responsiveSize.small && constraints.maxWidth < responsiveSize.large;
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLargeOrMedium(media)) {
      if (isMedium(media)) {
        _D.debug('ResponsiveElt medium: ${media.maxWidth}/$responsiveSize');
        return medium ?? large;
      }
      _D.debug('ResponsiveElt larege: ${media.maxWidth}/$responsiveSize');
      return large;
    } else {
      _D.debug('ResponsiveElt small: ${media.maxWidth}/$responsiveSize');
      return small ?? large;
    }
  
  }
}