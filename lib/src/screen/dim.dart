import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'screen_utils.dart';

class TDim {
  final double width;
  final double height;
  final double left;
  final double top;
  final EdgeInsets? padding;

  /// adaptive to screen size
  final bool? adaptive;

  const TDim({
    this.width = double.infinity,
    this.height = double.infinity,
    this.left = 0,
    this.top = 0,
    this.padding,
    this.adaptive
  });

  TDim copyWith({
    double? width,
    double? height,
    double? left,
    double? top,
    EdgeInsets? padding,
    bool? adaptive,
  }) {
    return TDim(
        width: width ?? this.width,
        height: height ?? this.height,
        left: left ?? this.left,
        top: top ?? this.top,
        padding: padding ?? this.padding,
        adaptive: adaptive ?? this.adaptive);
  }
}

class TDims {
  final TDim? small;
  final TDim? medium;
  final TDim? large;
  final TDim? defaults;

  const TDims({this.small, this.medium, this.large, this.defaults})
      : assert(small != null ||
            medium != null ||
            large != null ||
            defaults != null);

  double _setX(double Function(double) setter, double result, bool adapt) {
    if (adapt) {
      return setter(result);
    }
    return result;
  }

  double _setSmall(double Function(double) setter, double result) {
    return _setX(setter, result, smallAdapt);
  }

  double _setMedium(double Function(double) setter, double result) {
    return _setX(setter, result, mediumAdapt);
  }

  double _setLarge(double Function(double) setter, double result) {
    return _setX(setter, result, largeAdapt);
  }

  double get width {
    if (ScreenUtil.isLargeDesign) {
      final result = large?.width ?? defaults?.width;
      return _setLarge(ScreenUtil.largeDesign.setWidth, result ?? 0.0);
    } else if (ScreenUtil.isSmalDesign) {
      final result = small?.width ?? defaults?.width;
      return _setSmall(ScreenUtil.smallDesign.setWidth, result ?? 0.0);
    } else {
      final result = medium?.width ?? defaults?.width;
      return _setMedium(ScreenUtil.mediumDesign.setWidth, result ?? 0.0);
    }
  }

  double get height {
    if (ScreenUtil.isLargeDesign) {
      final result = large?.height ?? defaults?.height ?? 0.0;
      return _setLarge(ScreenUtil.largeDesign.setHeight, result);
    } else if (ScreenUtil.isSmalDesign) {
      final result = small?.height ?? defaults?.height ?? 0.0;
      return _setSmall(ScreenUtil.smallDesign.setHeight, result);
    } else {
      final result = medium?.height ?? defaults?.height ?? 0.0;
      return _setMedium(ScreenUtil.mediumDesign.setHeight, result);
    }
  }

  double get left {
    if (ScreenUtil.isLargeDesign) {
      final result = large?.left ?? defaults?.left ?? 0;
      return _setLarge(ScreenUtil.largeDesign.setWidth, result);
    } else if (ScreenUtil.isSmalDesign) {
      final result = small?.left ?? defaults?.left ?? 0;
      return _setSmall(ScreenUtil.smallDesign.setWidth, result);
    } else {
      final result = medium?.left ?? defaults?.left ?? 0;
      return _setMedium(ScreenUtil.mediumDesign.setWidth, result);
    }
  }

  double get top {
    if (ScreenUtil.isLargeDesign) {
      final result = large?.height ?? defaults?.height ?? 0;
      return _setLarge(ScreenUtil.largeDesign.setHeight, result);
    } else if (ScreenUtil.isSmalDesign) {
      final result = small?.height ?? defaults?.height ?? 0;
      return _setSmall(ScreenUtil.smallDesign.setHeight, result);
    } else {
      final result = medium?.height ?? defaults?.height ?? 0;
      return _setMedium(ScreenUtil.mediumDesign.setHeight, result);
    }
  }

  EdgeInsets get padding {
    EdgeInsets? result;
    double Function(double) setterL;
    double Function(double) setterR;
    bool adapt;
    if (ScreenUtil.isLargeDesign) {
      result = large?.padding ?? defaults?.padding;
      setterL = ScreenUtil.largeDesign.setWidth;
      setterR = ScreenUtil.largeDesign.setHeight;
      adapt = largeAdapt;
    } else if (ScreenUtil.isSmalDesign) {
      result = small?.padding ?? defaults?.padding;
      setterL = ScreenUtil.smallDesign.setWidth;
      setterR = ScreenUtil.smallDesign.setHeight;
      adapt = smallAdapt;
    } else {
      result = medium?.padding ?? defaults?.padding;
      setterL = ScreenUtil.mediumDesign.setWidth;
      setterR = ScreenUtil.mediumDesign.setHeight;
      adapt = mediumAdapt;
    }
    result ??= const EdgeInsets.all(0);
    return result.copyWith(
        left: _setX(setterL, result.left, adapt),
        top: _setX(setterR, result.top, adapt),
        right: _setX(setterL, result.right, adapt),
        bottom: _setX(setterR, result.bottom, adapt));
  }

  bool get largeAdapt {
    return (large?.adaptive ?? defaults?.adaptive) ?? false;
  }

  bool get mediumAdapt {
    return (medium?.adaptive ?? defaults?.adaptive) ?? false;
  }

  bool get smallAdapt {
    return (small?.adaptive ?? defaults?.adaptive) ?? false;
  }
}
