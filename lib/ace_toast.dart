import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum NotificationType { success, error, warning, info }

enum NotificationPosition { top, bottom }

// enum DismissDirection { up, down, horizontal }

class NotificationConfig {
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final bool showProgressIndicator;
  final Color? progressIndicatorColor;
  final double progressIndicatorHeight;
  final double borderRadius;
  final EdgeInsets padding;
  final NotificationPosition position;
  final Duration animationDuration;
  final DismissDirection dismissDirection;
  final double elevation;
  final IconData? icon;
  final double? maxWidth;
  final EdgeInsets? margin;

  const NotificationConfig({
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.showProgressIndicator = false,
    this.progressIndicatorColor,
    this.progressIndicatorHeight = 2,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.position = NotificationPosition.top,
    this.animationDuration = const Duration(milliseconds: 300),
    this.dismissDirection = DismissDirection.horizontal,
    this.elevation = 2,
    this.icon,
    this.maxWidth,
    this.margin,
  });

  NotificationConfig copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? textColor,
    Color? iconColor,
    bool? showProgressIndicator,
    Color? progressIndicatorColor,
    double? progressIndicatorHeight,
    double? borderRadius,
    EdgeInsets? padding,
    NotificationPosition? position,
    Duration? animationDuration,
    DismissDirection? dismissDirection,
    double? elevation,
    IconData? icon,
    double? maxWidth,
    EdgeInsets? margin,
  }) {
    return NotificationConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      textColor: textColor ?? this.textColor,
      iconColor: iconColor ?? this.iconColor,
      showProgressIndicator:
          showProgressIndicator ?? this.showProgressIndicator,
      progressIndicatorColor:
          progressIndicatorColor ?? this.progressIndicatorColor,
      progressIndicatorHeight:
          progressIndicatorHeight ?? this.progressIndicatorHeight,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      position: position ?? this.position,
      animationDuration: animationDuration ?? this.animationDuration,
      dismissDirection: dismissDirection ?? this.dismissDirection,
      elevation: elevation ?? this.elevation,
      icon: icon ?? this.icon,
      maxWidth: maxWidth ?? this.maxWidth,
      margin: margin ?? this.margin,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static OverlayState? _overlayState;
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;
  static Timer? _timer;
  static NotificationConfig _globalConfig = const NotificationConfig();
  static bool debugMode = false;
  static const Duration _defaultDuration = Duration(seconds: 3);
  static void initialize(BuildContext context) {
    _overlayState = Overlay.of(context);
    _log('NotificationService initialized');
  }

  static void setGlobalConfig(NotificationConfig config) {
    _globalConfig = config;
    _log('Global config updated');
  }

  static void showSuccess(
    String message, {
    Duration? duration,
    NotificationConfig? config,
  }) {
    _show(
      message: message,
      type: NotificationType.success,
      duration: duration,
      config: config,
    );
  }

  static void showError(
    String message, {
    Duration? duration,
    NotificationConfig? config,
  }) {
    _show(
      message: message,
      type: NotificationType.error,
      duration: duration,
      config: config,
    );
  }

  static void showWarning(
    String message, {
    Duration? duration,
    NotificationConfig? config,
  }) {
    _show(
      message: message,
      type: NotificationType.warning,
      duration: duration,
      config: config,
    );
  }

  static void showInfo(
    String message, {
    Duration? duration,
    NotificationConfig? config,
  }) {
    _show(
      message: message,
      type: NotificationType.info,
      duration: duration,
      config: config,
    );
  }

  static void show({
    required Widget Function(BuildContext, Animation<double>) builder,
    Duration? duration,
  }) {
    if (_overlayState == null) {
      throw Exception(
          'NotificationService not initialized. Call initialize() first.');
    }

    _timer?.cancel();
    _overlayEntry?.remove();
    _isVisible = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => builder(context, const AlwaysStoppedAnimation(1.0)),
    );

    _overlayState!.insert(_overlayEntry!);

    if (duration != null) {
      _timer = Timer(duration, () {
        _dismiss();
      });
    }
  }

  static void _show({
    required String message,
    required NotificationType type,
    Duration? duration,
    NotificationConfig? config,
  }) {
    duration ??= _defaultDuration;

    if (_overlayState == null) {
      throw Exception(
          'NotificationService not initialized. Call initialize() first.');
    }

    _log('Showing notification: $message (Type: $type)');

    _timer?.cancel();
    _overlayEntry?.remove();
    _isVisible = true;

    final effectiveConfig = config ?? _globalConfig;

    _overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWidget(
        message: message,
        type: type,
        config: effectiveConfig,
        onDismiss: _dismiss,
        duration: duration,
      ),
    );

    _overlayState!.insert(_overlayEntry!);

    _timer = Timer(duration, () {
      _dismiss();
    });
  }

  static void _dismiss() {
    _timer?.cancel();
    _timer = null;

    if (!_isVisible) return;
    _isVisible = false;

    _overlayEntry?.remove();
    _overlayEntry = null;

    _log('Notification dismissed');
  }

  static void _log(String message) {
    if (debugMode) {}
  }
}

class _NotificationWidget extends StatefulWidget {
  final String message;
  final NotificationType type;
  final NotificationConfig config;
  final VoidCallback onDismiss;
  final Duration? duration;

  const _NotificationWidget({
    required this.message,
    required this.type,
    required this.config,
    required this.onDismiss,
    this.duration,
  });

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _opacityAnimation;
  Timer? _progressTimer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );

    final begin = widget.config.position == NotificationPosition.top
        ? const Offset(0, -1)
        : const Offset(0, 1);

    _offsetAnimation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _controller.forward();

    if (widget.duration != null && widget.config.showProgressIndicator) {
      _startProgress();
    }
  }

  void _startProgress() {
    const updateInterval = Duration(milliseconds: 50);
    final totalSteps =
        widget.duration!.inMilliseconds ~/ updateInterval.inMilliseconds;
    double stepValue = 1 / totalSteps;

    _progressTimer = Timer.periodic(updateInterval, (timer) {
      setState(() {
        _progress += stepValue;
        if (_progress >= 1.0) {
          _progressTimer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _dismissNotification() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  IconData _getIcon() {
    return widget.config.icon ??
        switch (widget.type) {
          NotificationType.success => FontAwesomeIcons.circleCheck,
          NotificationType.error => FontAwesomeIcons.circleExclamation,
          NotificationType.warning => FontAwesomeIcons.triangleExclamation,
          NotificationType.info => FontAwesomeIcons.circleInfo,
        };
  }

// [Previous code remains the same up until the _getTheme method]

  ThemeData _getTheme(NotificationType type) {
    return switch (type) {
      NotificationType.success => ThemeData(
          primaryColor: Colors.green,
        ),
      NotificationType.error => ThemeData(
          primaryColor: Colors.red,
          cardColor: Colors.red.shade50,
        ),
      NotificationType.warning => ThemeData(
          primaryColor: Colors.orange,
          cardColor: Colors.orange.shade50,
        ),
      NotificationType.info => ThemeData(
          primaryColor: Colors.blue,
          cardColor: Colors.blue.shade50,
        ),
    };
  }

  Color _getBackgroundColor(NotificationType type, ThemeData theme) {
    return widget.config.backgroundColor ?? theme.cardColor;
  }

  Color _getBorderColor(NotificationType type, ThemeData theme) {
    return widget.config.borderColor ?? theme.primaryColor.withOpacity(0.3);
  }

  Color _getTextColor(NotificationType type, ThemeData theme) {
    return widget.config.textColor ?? theme.primaryColor;
  }

  Color _getIconColor(NotificationType type, ThemeData theme) {
    return widget.config.iconColor ?? theme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme(widget.type);
    final backgroundColor = _getBackgroundColor(widget.type, theme);
    final borderColor = _getBorderColor(widget.type, theme);
    final textColor = _getTextColor(widget.type, theme);
    final iconColor = _getIconColor(widget.type, theme);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Align(
              alignment: widget.config.position == NotificationPosition.top
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              child: Padding(
                padding: widget.config.margin ?? const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.config.maxWidth ?? 600,
                  ),
                  child: GestureDetector(
                    onTap: _dismissNotification,
                    child: Dismissible(
                      key: Key(
                          'notification_${DateTime.now().millisecondsSinceEpoch}'),
                      direction: widget.config.dismissDirection,
                      onDismissed: (_) => widget.onDismiss(),
                      child: Material(
                        elevation: widget.config.elevation,
                        borderRadius:
                            BorderRadius.circular(widget.config.borderRadius),
                        child: Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(
                                widget.config.borderRadius),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: widget.config.padding,
                                child: Row(
                                  children: [
                                    FaIcon(
                                      _getIcon(),
                                      color: iconColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.message,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.config.showProgressIndicator &&
                                  widget.duration != null)
                                LinearProgressIndicator(
                                  value: _progress,
                                  backgroundColor: borderColor.withOpacity(0.2),
                                  color: widget.config.progressIndicatorColor ??
                                      theme.primaryColor,
                                  minHeight:
                                      widget.config.progressIndicatorHeight,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
