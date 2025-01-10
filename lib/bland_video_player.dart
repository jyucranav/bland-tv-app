import 'package:bland_tv/components/drawer.dart';
import 'package:bland_tv/models/channel.dart';
import 'package:bland_tv/providers/video_provider.dart';
import 'package:bland_tv/utils/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:http/http.dart' as http;

class Video extends ValueNotifier {
  Video(super.value);
}

class BlandVideoPlayerApp extends StatelessWidget {
  const BlandVideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    var video = Video(Globals.channels[Globals.currentChannel].link);
    return VideoProvider(video: video, child: BlandVideoPlayer());
  }
}

class BlandVideoPlayer extends StatefulWidget {
  const BlandVideoPlayer({super.key});

  @override
  BlandVideoPlayerState createState() => BlandVideoPlayerState();
}

class BlandVideoPlayerState extends State<BlandVideoPlayer> {
  late VideoPlayerController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late FocusNode tvNode;
  bool _isPlaying = false;
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    tvNode = FocusNode();
    validateAndPlay(Globals.channels[Globals.currentChannel].link);
    WakelockPlus.enable();
  }

  void _handleDrawerState(bool isOpen) {
    // Check if the drawer is open and request focus
    print("se cambio el estado del drawer");
    print(isOpen);
    if (isOpen) {
      TvDrawerState().focusButton(Globals.currentChannel);
      print("si se abrio la cosa");
    }
  }

  Future<void> validateAndPlay(String url) async {
    try {
      if (_isControllerInitialized) {
        _controller.dispose();
        _isControllerInitialized = false;
      }
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(url));
        _controller.addListener(playerListener);
        _controller
            .initialize()
            .then((_) {
              setState(() {
                _controller.play();
                _isControllerInitialized = true;
              });
            })
            .catchError((error) {
              print('Error initializing video player: $error');
            });
      } else {
        print('Error: HTTP ${response.statusCode}');
        setState(() {
          _isControllerInitialized = false; // Reset state
        });
      }
    } catch (e) {
      print('Network error: $e');
      setState(() {
        _isControllerInitialized = false; // Reset state
      });
    }
  }

  void _previousChannel() {
    Globals.currentChannel =
        Globals.currentChannel > 0
            ? Globals.currentChannel - 1
            : Globals.channels.length - 1;
    setState(() {});
  }

  void _nextChannel() {
    Globals.currentChannel =
        Globals.currentChannel < Globals.channels.length - 1
            ? Globals.currentChannel + 1
            : 0;
    setState(() {});
  }

  void playerListener() {
    final bool isPlaying = _controller.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    }

    if (_controller.value.hasError && kDebugMode) {
      print('Video player error: ${_controller.value.errorDescription}');
    }
  }

  void videoInfoOverlay(BuildContext context) async {
    Channel channel = Globals.channels[Globals.currentChannel];
    var content = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(right: 1.0),
          child: Text(
            channel.number.toString(),
            style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 15.0),
          ),
        ),
        SizedBox(width: 10.0),
        Text(
          channel.title,
          style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 15.0),
        ),
      ],
    );
    var appBarFin = Padding(
      padding: const EdgeInsets.all(16.0),
      child: AppBar(title: content, backgroundColor: Colors.transparent),
    );

    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: MediaQuery.of(context).size.height / 30.0,
            width: MediaQuery.of(context).size.width / 3.0,
            right: 0.0,
            child: appBarFin,
          ),
    );
    overlayState.insert(overlayEntry);
    await Future.delayed(Duration(seconds: 4));
    overlayEntry.remove();
  }

  void _handleKeyEvent(KeyEvent event, VideoProvider provider) {
    if (event is KeyDownEvent) {
      print('Se presionó la tecla $event.logicalKey');
      switch (event.logicalKey) {
        case LogicalKeyboardKey.channelUp:
          print('channel Up Pressed');
          _nextChannel();
          provider.video.value = Globals.channels[Globals.currentChannel].link;
          videoInfoOverlay(context);
          break;
        case LogicalKeyboardKey.channelDown:
          print('channel Down Pressed');
          _previousChannel();
          provider.video.value = Globals.channels[Globals.currentChannel].link;
          videoInfoOverlay(context);
          break;
        case LogicalKeyboardKey.arrowRight:
          print('Arrow Right Pressed');
          if (_scaffoldKey.currentState?.isDrawerOpen == false) {
            _scaffoldKey.currentState?.openDrawer();
          }
          break;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.accept:
        case LogicalKeyboardKey.select:
          videoInfoOverlay(context);
          break;
      }
    }
  }

  @override
  void dispose() {
    if (_isControllerInitialized) {
      _controller.dispose();
    }
    tvNode.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void deactivate() {
    _controller.removeListener(playerListener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(tvNode);
    final videoProvider = VideoProvider.of(context);

    if (_isControllerInitialized &&
        _controller.dataSource != videoProvider.video.value) {
      _controller.dispose();
      _isControllerInitialized = false;
      validateAndPlay(videoProvider.video.value);
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: TvDrawer(),
      onDrawerChanged: _handleDrawerState,
      body: KeyboardListener(
        focusNode: tvNode,
        onKeyEvent: (event) => _handleKeyEvent(event, videoProvider),
        child: Center(
          child: Container(
            color: Colors.black,
            child:
                _isControllerInitialized
                    ? AspectRatio(
                      aspectRatio: 16 / 9,
                      child: VideoPlayer(_controller),
                    )
                    : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
