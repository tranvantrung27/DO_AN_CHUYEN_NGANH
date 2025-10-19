import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibration/vibration.dart';
import '../../constants/index.dart';

/// Enum cho các loại button
enum AppButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

/// Enum cho kích thước button
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Custom button widget tái sử dụng với nhiều style và animation
class AppButton extends StatefulWidget {
  /// Text hiển thị trên button
  final String text;
  
  /// Callback khi button được nhấn
  final VoidCallback? onPressed;
  
  /// Loại button (primary, secondary, etc.)
  final AppButtonType type;
  
  /// Kích thước button
  final AppButtonSize size;
  
  /// Icon hiển thị bên trái text (optional)
  final IconData? leftIcon;
  
  /// Icon hiển thị bên phải text (optional)
  final IconData? rightIcon;
  
  /// Widget custom thay thế cho text (optional)
  final Widget? child;
  
  /// Có loading không
  final bool isLoading;
  
  /// Có haptic feedback không
  final bool enableHaptic;
  
  /// Border radius custom
  final double? borderRadius;
  
  /// Width custom (null = wrap content)
  final double? width;
  
  /// Height custom (null = theo size)
  final double? height;
  
  /// Gradient background (optional)
  final Gradient? gradient;
  
  /// Shadow elevation
  final double elevation;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.leftIcon,
    this.rightIcon,
    this.child,
    this.isLoading = false,
    this.enableHaptic = true,
    this.borderRadius,
    this.width,
    this.height,
    this.gradient,
    this.elevation = 2,
  });

  /// Factory constructor cho primary button
  factory AppButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isLoading,
    double? width,
  }) = _AppButtonPrimary;

  /// Factory constructor cho secondary button
  factory AppButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isLoading,
    double? width,
  }) = _AppButtonSecondary;

  /// Factory constructor cho outline button
  factory AppButton.outline({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isLoading,
    double? width,
  }) = _AppButtonOutline;

  /// Factory constructor cho text button
  factory AppButton.text({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isLoading,
  }) = _AppButtonText;

  /// Factory constructor cho danger button
  factory AppButton.danger({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isLoading,
    double? width,
  }) = _AppButtonDanger;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.buttonPressedScale,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Lấy style theo type
  ButtonStyle get _buttonStyle {
    switch (widget.type) {
      case AppButtonType.primary:
        return _primaryStyle;
      case AppButtonType.secondary:
        return _secondaryStyle;
      case AppButtonType.outline:
        return _outlineStyle;
      case AppButtonType.text:
        return _textStyle;
      case AppButtonType.danger:
        return _dangerStyle;
    }
  }

  ButtonStyle get _primaryStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryGreen,
    foregroundColor: Colors.white,
    disabledBackgroundColor: AppColors.primaryGreen.withOpacity(AppAnimations.disabledOpacity),
    elevation: widget.elevation,
    padding: _padding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
    ),
  );

  ButtonStyle get _secondaryStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.backgroundWhite,
    foregroundColor: AppColors.primaryGreen,
    elevation: widget.elevation,
    padding: _padding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      side: BorderSide(color: AppColors.primaryGreen, width: 1.w),
    ),
  );

  ButtonStyle get _outlineStyle => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryGreen,
    side: BorderSide(color: AppColors.primaryGreen, width: 1.w),
    padding: _padding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
    ),
  );

  ButtonStyle get _textStyle => TextButton.styleFrom(
    foregroundColor: AppColors.primaryGreen,
    padding: _padding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
    ),
  );

  ButtonStyle get _dangerStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: Colors.white,
    elevation: widget.elevation,
    padding: _padding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
    ),
  );

  EdgeInsets get _padding {
    switch (widget.size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h);
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h);
      case AppButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h);
    }
  }

  double get _borderRadius => widget.borderRadius ?? 8.r;

  double get _fontSize {
    switch (widget.size) {
      case AppButtonSize.small:
        return 14.sp;
      case AppButtonSize.medium:
        return 16.sp;
      case AppButtonSize.large:
        return 18.sp;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case AppButtonSize.small:
        return 16.r;
      case AppButtonSize.medium:
        return 20.r;
      case AppButtonSize.large:
        return 24.r;
    }
  }

  Widget get _buttonContent {
    if (widget.child != null) return widget.child!;

    final children = <Widget>[];

    // Left icon
    if (widget.leftIcon != null && !widget.isLoading) {
      children.add(Icon(widget.leftIcon, size: _iconSize));
      children.add(SizedBox(width: 8.w));
    }

    // Loading indicator hoặc text
    if (widget.isLoading) {
      children.add(
        SizedBox(
          width: _iconSize,
          height: _iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.type == AppButtonType.primary || widget.type == AppButtonType.danger
                  ? Colors.white
                  : AppColors.primaryGreen,
            ),
          ),
        ),
      );
      children.add(SizedBox(width: 8.w));
      children.add(Text(
        'Đang tải...',
        style: TextStyle(fontSize: _fontSize),
      ));
    } else {
      children.add(Text(
        widget.text,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
        ),
      ));
    }

    // Right icon
    if (widget.rightIcon != null && !widget.isLoading) {
      children.add(SizedBox(width: 8.w));
      children.add(Icon(widget.rightIcon, size: _iconSize));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Future<void> _onPressed() async {
    if (widget.onPressed == null || widget.isLoading) return;

    // Haptic feedback
    if (widget.enableHaptic) {
      try {
        await Vibration.vibrate(duration: 50, amplitude: 128);
      } catch (e) {
        // Ignore haptic errors on unsupported devices
      }
    }

    // Animation
    await _animationController.forward();
    await _animationController.reverse();

    // Execute callback
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    Widget button;

    switch (widget.type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
      case AppButtonType.danger:
        button = ElevatedButton(
          onPressed: _onPressed,
          style: _buttonStyle,
          child: _buttonContent,
        );
        break;
      case AppButtonType.outline:
        button = OutlinedButton(
          onPressed: _onPressed,
          style: _buttonStyle,
          child: _buttonContent,
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          onPressed: _onPressed,
          style: _buttonStyle,
          child: _buttonContent,
        );
        break;
    }

    // Wrap with AnimatedBuilder for scale animation
    button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: button,
    );

    // Apply custom width/height if specified
    if (widget.width != null || widget.height != null) {
      button = SizedBox(
        width: widget.width?.w,
        height: widget.height?.h,
        child: button,
      );
    }

    // Apply gradient if specified (only for elevated buttons)
    if (widget.gradient != null && 
        (widget.type == AppButtonType.primary || 
         widget.type == AppButtonType.secondary ||
         widget.type == AppButtonType.danger)) {
      button = Container(
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: ElevatedButton(
          onPressed: _onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: _padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
          child: _buttonContent,
        ),
      );
    }

    return button;
  }
}

// Factory implementations
class _AppButtonPrimary extends AppButton {
  const _AppButtonPrimary({
    super.key,
    required super.text,
    super.onPressed,
    AppButtonSize? size,
    super.leftIcon,
    super.rightIcon,
    bool? isLoading,
    super.width,
  }) : super(
    type: AppButtonType.primary,
    size: size ?? AppButtonSize.medium,
    isLoading: isLoading ?? false,
  );
}

class _AppButtonSecondary extends AppButton {
  const _AppButtonSecondary({
    super.key,
    required super.text,
    super.onPressed,
    AppButtonSize? size,
    super.leftIcon,
    super.rightIcon,
    bool? isLoading,
    super.width,
  }) : super(
    type: AppButtonType.secondary,
    size: size ?? AppButtonSize.medium,
    isLoading: isLoading ?? false,
  );
}

class _AppButtonOutline extends AppButton {
  const _AppButtonOutline({
    super.key,
    required super.text,
    super.onPressed,
    AppButtonSize? size,
    super.leftIcon,
    super.rightIcon,
    bool? isLoading,
    super.width,
  }) : super(
    type: AppButtonType.outline,
    size: size ?? AppButtonSize.medium,
    isLoading: isLoading ?? false,
  );
}

class _AppButtonText extends AppButton {
  const _AppButtonText({
    super.key,
    required super.text,
    super.onPressed,
    AppButtonSize? size,
    super.leftIcon,
    super.rightIcon,
    bool? isLoading,
  }) : super(
    type: AppButtonType.text,
    size: size ?? AppButtonSize.medium,
    isLoading: isLoading ?? false,
  );
}

class _AppButtonDanger extends AppButton {
  const _AppButtonDanger({
    super.key,
    required super.text,
    super.onPressed,
    AppButtonSize? size,
    super.leftIcon,
    super.rightIcon,
    bool? isLoading,
    super.width,
  }) : super(
    type: AppButtonType.danger,
    size: size ?? AppButtonSize.medium,
    isLoading: isLoading ?? false,
  );
}
