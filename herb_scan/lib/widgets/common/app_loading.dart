import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/index.dart';

/// Enum cho các loại loading animation
enum AppLoadingType {
  circular,
  dots,
  wave,
  pulse,
  bounce,
  ring,
  dual,
}

/// Custom loading widget với nhiều animation styles
class AppLoading extends StatelessWidget {
  /// Loại loading animation
  final AppLoadingType type;
  
  /// Kích thước loading
  final double size;
  
  /// Màu sắc
  final Color color;
  
  /// Text hiển thị dưới loading (optional)
  final String? text;
  
  /// Text style cho text
  final TextStyle? textStyle;

  const AppLoading({
    super.key,
    this.type = AppLoadingType.circular,
    this.size = 40,
    this.color = AppColors.primaryGreen,
    this.text,
    this.textStyle,
  });

  /// Factory cho loading đơn giản
  factory AppLoading.simple({
    double? size,
    Color? color,
  }) = _AppLoadingSimple;

  /// Factory cho loading với text
  factory AppLoading.withText({
    String? text,
    AppLoadingType? type,
    double? size,
    Color? color,
    TextStyle? textStyle,
  }) = _AppLoadingWithText;

  /// Factory cho page loading
  factory AppLoading.page({
    String? text,
    AppLoadingType? type,
  }) = _AppLoadingPage;

  @override
  Widget build(BuildContext context) {
    final loading = _buildLoadingWidget();
    
    if (text != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loading,
          SizedBox(height: 16.h),
          Text(
            text!,
            style: textStyle ?? AppTheme.bodyMedium.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    return loading;
  }

  Widget _buildLoadingWidget() {
    switch (type) {
      case AppLoadingType.circular:
        return SizedBox(
          width: size.r,
          height: size.r,
          child: CircularProgressIndicator(
            color: color,
            strokeWidth: 3.w,
          ),
        );
        
      case AppLoadingType.dots:
        return SpinKitThreeBounce(
          color: color,
          size: size.r,
        );
        
      case AppLoadingType.wave:
        return SpinKitWave(
          color: color,
          size: size.r,
        );
        
      case AppLoadingType.pulse:
        return SpinKitPulse(
          color: color,
          size: size.r,
        );
        
      case AppLoadingType.bounce:
        return SpinKitFadingCircle(
          color: color,
          size: size.r,
        );
        
      case AppLoadingType.ring:
        return SpinKitRing(
          color: color,
          size: size.r,
          lineWidth: 3.w,
        );
        
      case AppLoadingType.dual:
        return SpinKitDualRing(
          color: color,
          size: size.r,
          lineWidth: 3.w,
        );
    }
  }
}

/// Loading overlay để hiển thị trên toàn màn hình
class AppLoadingOverlay extends StatelessWidget {
  /// Có hiển thị overlay không
  final bool isLoading;
  
  /// Widget con
  final Widget child;
  
  /// Loading widget custom
  final Widget? loadingWidget;
  
  /// Màu nền overlay
  final Color overlayColor;
  
  /// Text hiển thị
  final String? text;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
    this.overlayColor = Colors.black54,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor,
            child: Center(
              child: loadingWidget ?? AppLoading.withText(
                text: text ?? 'Đang tải...',
                type: AppLoadingType.wave,
                color: Colors.white,
                textStyle: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Shimmer loading cho skeleton UI
class AppShimmer extends StatelessWidget {
  /// Widget con để apply shimmer effect
  final Widget child;
  
  /// Màu base
  final Color baseColor;
  
  /// Màu highlight
  final Color highlightColor;
  
  /// Có enabled không
  final bool enabled;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.enabled = true,
  });

  /// Factory cho shimmer text
  factory AppShimmer.text({
    Key? key,
    double? width,
    double? height,
    double? borderRadius,
  }) = _AppShimmerText;

  /// Factory cho shimmer rectangle
  factory AppShimmer.rectangle({
    Key? key,
    required double width,
    required double height,
    double? borderRadius,
  }) = _AppShimmerRectangle;

  /// Factory cho shimmer circle
  factory AppShimmer.circle({
    Key? key,
    required double size,
  }) = _AppShimmerCircle;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

/// Shimmer loading cho list items
class AppShimmerList extends StatelessWidget {
  /// Số lượng items
  final int itemCount;
  
  /// Builder cho mỗi item
  final Widget Function(BuildContext context, int index) itemBuilder;
  
  /// Padding cho list
  final EdgeInsets? padding;
  
  /// Separator giữa các items
  final Widget? separator;

  const AppShimmerList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.separator,
  });

  /// Factory cho shimmer list đơn giản
  factory AppShimmerList.simple({
    Key? key,
    int? itemCount,
    EdgeInsets? padding,
  }) = _AppShimmerListSimple;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (context, index) => separator ?? SizedBox(height: 8.h),
      itemBuilder: (context, index) => AppShimmer(
        child: itemBuilder(context, index),
      ),
    );
  }
}

// Factory implementations
class _AppLoadingSimple extends AppLoading {
  const _AppLoadingSimple({
    double? size,
    Color? color,
  }) : super(
    type: AppLoadingType.circular,
    size: size ?? 24,
    color: color ?? AppColors.primaryGreen,
  );
}

class _AppLoadingWithText extends AppLoading {
  const _AppLoadingWithText({
    String? text,
    AppLoadingType? type,
    double? size,
    Color? color,
    TextStyle? textStyle,
  }) : super(
    text: text ?? 'Đang tải...',
    type: type ?? AppLoadingType.dots,
    size: size ?? 40,
    color: color ?? AppColors.primaryGreen,
    textStyle: textStyle,
  );
}

class _AppLoadingPage extends AppLoading {
  const _AppLoadingPage({
    String? text,
    AppLoadingType? type,
  }) : super(
    text: text ?? 'Đang tải...',
    type: type ?? AppLoadingType.wave,
    size: 60,
    color: AppColors.primaryGreen,
  );
}

class _AppShimmerText extends AppShimmer {
  _AppShimmerText({
    super.key,
    double? width,
    double? height,
    double? borderRadius,
  }) : super(
    child: Container(
      width: (width ?? 100).w,
      height: (height ?? 16).h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((borderRadius ?? 4).r),
      ),
    ),
  );
}

class _AppShimmerRectangle extends AppShimmer {
  _AppShimmerRectangle({
    super.key,
    required double width,
    required double height,
    double? borderRadius,
  }) : super(
    child: Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((borderRadius ?? 8).r),
      ),
    ),
  );
}

class _AppShimmerCircle extends AppShimmer {
  _AppShimmerCircle({
    super.key,
    required double size,
  }) : super(
    child: Container(
      width: size.r,
      height: size.r,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    ),
  );
}

class _AppShimmerListSimple extends AppShimmerList {
  _AppShimmerListSimple({
    super.key,
    int? itemCount,
    super.padding,
  }) : super(
    itemCount: itemCount ?? 5,
    itemBuilder: (context, index) => Container(
      height: 80.h,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 16.h,
                  width: double.infinity,
                  color: Colors.grey,
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 14.h,
                  width: 200.w,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
