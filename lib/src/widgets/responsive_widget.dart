import 'package:dart_common/dart_common.dart';
import 'package:flutter/material.dart';

import '../screen/screen_utils.dart';
import 'stateful.dart';

final _D = Logger.filterableLogger(moduleName:'RWD');

var _RBOUND = 1200;
var _LBOUND = 768;

class ResponsiveScreen extends StatelessWidget {
  static void setRbound(int size){
    _RBOUND = size;
  }
  static void setLbound(int size){
    _LBOUND = size;
  }
  final Widget largeScreen;
  final Widget mediumScreen;
  final Widget smallScreen;
  final BoxConstraints? constraints;
  EPlatform get platform => PLATFORM;
  bool      get isMobile => IS_MOBILE;

  const ResponsiveScreen({Key? key,
    required this.largeScreen,
    required this.mediumScreen,
    required this.smallScreen,
    this.constraints,
  }) : super(key: key);

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < _LBOUND;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= _LBOUND;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= _LBOUND &&
        MediaQuery.of(context).size.width < _RBOUND;
  }

  bool _isLargeOrMedium(BoxConstraints constraints){
    return constraints.maxWidth >= _LBOUND;
  }

  bool _isMedium(BoxConstraints constraints){
    return constraints.maxWidth >= _LBOUND &&
        constraints.maxWidth < _RBOUND;
  }

  bool _isSmall(BoxConstraints constraints){
    return constraints.maxWidth < _LBOUND;
  }

  Widget buildBySize(BuildContext context, BoxConstraints _constraints){
    if (_isLargeOrMedium(_constraints)) {
      if (_isMedium(_constraints)){
        // medium
        _D.d(()=>'rebuild responsive medium: ${_constraints.maxWidth}');
        return mediumScreen ?? largeScreen;
      }
      // large
      _D.d(()=>'rebuild responsive large: ${_constraints.maxWidth}');
      return largeScreen;
    } else {
      // small
      _D.d(()=>'rebuild responsive small: ${_constraints.maxWidth}/ ${key}');
      return smallScreen ?? largeScreen;
    }
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _constraints) {
        if (_constraints.maxWidth > 10000 && constraints != null){
          return buildBySize(context, constraints!);
        }
        return buildBySize(context, _constraints);
      },
    );
  }
}



class ResponsiveSize{
  final int lbound;
  final int rbound;
  const ResponsiveSize({required this.rbound, required this.lbound });

  bool isSmall(num size) {
    return size <= lbound;
  }
  bool isLargeOrMedium(num size) {
    return size > lbound;
  }
  bool isMedium(num size) {
    return size >= lbound && size < rbound;
  }
  @override String toString() {
    return "TResponsiveSize($rbound/$lbound)";
  }
}

const SIZE_SKILLAUDIO = ResponsiveSize(rbound: 768, lbound: 580);
const SIZE_GALLERY    = ResponsiveSize(rbound: 768, lbound: 580);
const SIZE_CELLPHONE = ResponsiveSize(rbound: 768, lbound: 365);
const SIZE_DESKTOP   = ResponsiveSize(rbound: 1280, lbound: 768);
final SIZE_DESIGNCANVAS = ResponsiveSize(
    rbound: ScreenUtil.mediumDesign.sketchWidth.toInt(),  // 1024
    lbound: ScreenUtil.smallDesign.sketchWidth.toInt()   // 545
);


class TRWMedia{
  final double mediaWidth;
  final double mediaHeight;
  double get maxWidth => mediaWidth;
  double get maxHeight => mediaHeight;

  TRWMedia({
    this.mediaWidth = double.infinity,
    this.mediaHeight = double.infinity
  });

  TRWMedia.fromConstaints(BoxConstraints constraints)
    : mediaWidth = constraints.maxWidth, mediaHeight = constraints.maxHeight,
        assert(constraints.maxWidth < 10000, "input constraints with infinite width");
}

class ResponsiveElt extends StatelessWidget {
  final Widget? large;
  final Widget? medium;
  final Widget? small;
  final TRWMedia media;
  final ResponsiveSize responsiveSize;

  const ResponsiveElt({Key? key,
    required this.responsiveSize,
    required this.media,
    this.large,
    this.medium,
    this.small,
  }): assert(large != null || medium != null || small != null),
      super(key: key);

  bool isSmall(TRWMedia constraints) {
    final w = constraints.maxWidth;
    return responsiveSize.isSmall(w);
  }

  bool isLargeOrMedium(TRWMedia constraints) {
    final w = constraints.maxWidth;
    return responsiveSize.isLargeOrMedium(w);
  }

  bool isMedium(TRWMedia constraints) {
    final w = constraints.maxWidth;
    return responsiveSize.isMedium(w);
  }

  @override
  Widget build(BuildContext context) {
    if (isLargeOrMedium(media)) {
      if (isMedium(media)) {
        _D.d(()=>'ResponsiveElt medium: ${media.maxWidth}/$responsiveSize');
        return medium ?? large!;
      }
      _D.d(()=>'ResponsiveElt larege: ${media.maxWidth}/$responsiveSize');
      return large!;
    } else {
      _D.d(()=>'ResponsiveElt small: ${media.maxWidth}/$responsiveSize');
      return small ?? large!;
    }
  }
}
