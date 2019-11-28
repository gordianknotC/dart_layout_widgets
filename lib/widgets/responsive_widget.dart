import 'package:flutter/material.dart';
import 'package:layout/widgets/stateful.dart';



class ResponsiveScreen extends StatelessWidget {
  final Widget largeScreen;
  final Widget mediumScreen;
  final Widget smallScreen;
  
  EPlatform get platform => PLATFORM;
  bool      get isMobile => IS_MOBILE;
  
  const ResponsiveScreen({Key key,
        @required this.largeScreen,
        this.mediumScreen,
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        print('rebuild responsive: ${constraints.maxWidth}');
        if (constraints.maxWidth > 768) {
          // large
          return largeScreen;
        } else if (constraints.maxWidth < 1200 && constraints.maxWidth > 425) {
          // medium
          return mediumScreen ?? largeScreen;
        } else {
          // small
          return smallScreen ?? largeScreen;
        }
      },
    );
  }
}



class TResponsiveSize{
  final int medium;
  final int large;
  const TResponsiveSize({@required this.large, this.medium });
}

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
        return medium ?? large;
      }
      return large;
    } else {
      return small ?? large;
    }
  
  }
}