import 'package:flutter/material.dart';
import 'stateful.dart';



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
//    print('   isSmallScreen: ${MediaQuery.of(context).size.width < 768}/${MediaQuery.of(context).size.width}');
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
  
  bool _isSmall(BoxConstraints constraints){
    return constraints.maxWidth < 768;
  }
  
  Widget buildBySize(BuildContext context, BoxConstraints _constraints){
    if (_isLargeOrMedium(_constraints)) {
      if (_isMedium(_constraints)){
        // medium
        print('rebuild responsive medium: ${_constraints.maxWidth}');
        return mediumScreen ?? largeScreen;
      }
      // large
      print('rebuild responsive large: ${_constraints.maxWidth}');
      return largeScreen;
    } else {
      // small
      print('rebuild responsive small: ${_constraints.maxWidth}/ ${key}');
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
  final int medium;
  final int large;
  const TResponsiveSize({@required this.large, this.medium });
  
  @override String toString() {
    return "TResponsiveSize($large/$medium)";
  }
}

const SIZE_SKILLAUDIO = TResponsiveSize(large: 768, medium: 580);
const SIZE_CELLPHONE = TResponsiveSize(large: 768, medium: 360);
const SIZE_DESKTOP   = TResponsiveSize(large: 1280, medium: 768);

class ResponsiveElt extends StatelessWidget {
  final Widget large;
  final Widget medium;
  final Widget small;
  final BoxConstraints constraints;
  final TResponsiveSize size;

  const ResponsiveElt({Key key,
    @required this.large,
    @required this.size,
    @required this.constraints,
    this.medium,
    this.small,
  }): super(key: key);
  
  bool isSmall(BoxConstraints constraints) {
    return constraints.maxWidth <= size.medium;
  }
  
  bool isLargeOrMedium(BoxConstraints constraints) {
    return constraints.maxWidth > size.medium;
  }
  
  bool isMedium(BoxConstraints constraints) {
    return constraints.maxWidth >= size.medium && constraints.maxWidth < size.large;
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLargeOrMedium(constraints)) {
      if (isMedium(constraints)) {
        print('ResponsiveElt medium: ${constraints.maxWidth}/$size');
        return medium ?? large;
      }
      print('ResponsiveElt larege: ${constraints.maxWidth}/$size');
      return large;
    } else {
      print('ResponsiveElt small: ${constraints.maxWidth}/$size');
      return small ?? large;
    }
  
  }
}