import 'package:flutter/material.dart';

class VideoProvider extends StatefulWidget {
  const VideoProvider({super.key, required this.child, required this.video});

  static VideoProvider of(BuildContext context) {
    final _InheritedProvider? p =
        context.dependOnInheritedWidgetOfExactType<_InheritedProvider>();
    assert(p != null, 'No VideoProvider found in context');
    return p!.data;
  }

  final Widget child;
  final ValueNotifier video;

  @override
  State<StatefulWidget> createState() => _VideoProviderState();
}

class _VideoProviderState extends State<VideoProvider> {
  @override
  void initState() {
    super.initState();
    widget.video.addListener(didValueChange);
  }

  didValueChange() {
    print(widget.video.value);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedProvider(
      video: widget.video,
      data: widget,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    widget.video.dispose();
    super.dispose();
  }
}

class _InheritedProvider extends InheritedWidget {
  _InheritedProvider({
    required this.child,
    required this.video,
    required this.data,
  }) : _videoValue = video.value,
       super(child: child);

  final Widget child;
  final ValueNotifier video;
  final VideoProvider data;
  final String _videoValue;

  @override
  bool updateShouldNotify(_InheritedProvider oldWidget) {
    return _videoValue != oldWidget._videoValue;
  }
}
