import 'package:bland_tv/providers/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:bland_tv/utils/globals.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class TvDrawer extends StatefulWidget {
  const TvDrawer({super.key});

  @override
  TvDrawerState createState() => TvDrawerState();
}

class TvDrawerState extends State<TvDrawer> {
  late FocusNode drawerFocus;
  late List<FocusNode> _focusNodes;
  late double itemHeight;
  late double parentHeight;
  late ScrollController _scrollController;

  bool firstTimeLoad = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    itemHeight = 40.0;

    _focusNodes = List.generate(
      Globals.channels.length,
      (index) => FocusNode(),
    );
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => buildCallback(context),
    );
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    print("se llamó al dispose!");

    super.dispose();
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  void focusButton(int index) {
    print("Se a ejecutado focusButton");
    print(index);
    if (index < _focusNodes.length) {
      _focusNodes[index].requestFocus();
      _scrollController.animateTo(
        index * itemHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void buildCallback(BuildContext context) {
    if (!firstTimeLoad) {
      return;
    }
    firstTimeLoad = false;
    _ensureVisible();
    Future.delayed(Duration(milliseconds: 200), () {
      FocusScope.of(context).requestFocus(_focusNodes[Globals.currentChannel]);
      setState(() {});
    });
    //setState((){});
  }

  Future<Null> _ensureVisible() async {
    double offset = (itemHeight * Globals.currentChannel) + itemHeight / 2;
    double halfWay = parentHeight / 2;

    if (offset > halfWay || offset == 0) {
      _scrollController.animateTo(
        (offset - halfWay) + itemHeight / 2,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var videoProvider = VideoProvider.of(context);
    var screenSize = MediaQuery.of(context).size;
    parentHeight = screenSize.height;

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: hexToColor("#060c24")),
      child: Drawer(
        child: Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
          },
          child: Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: ListView.builder(
              key: Key('channels_list'),
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              itemCount: Globals.channels.length,
              itemBuilder: (BuildContext context, int index) {
                return AnimatedContainer(
                  height: itemHeight,
                  padding: EdgeInsets.only(left: 20.0),
                  duration: Duration(milliseconds: 200),
                  child: TextButton(
                    focusNode: _focusNodes[index],
                    child: Text(
                      Globals.channels[index].title,
                      style: TextStyle(),
                    ),
                    onPressed: () {
                      Globals.currentChannel = index;
                      videoProvider.video.value = Globals.channels[index].link;
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
