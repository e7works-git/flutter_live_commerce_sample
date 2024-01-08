import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_live_commerce/main.dart';
import 'package:flutter_live_commerce/store/channel_store.dart';
import 'package:flutter_live_commerce/store/emoji_store.dart';
import 'package:flutter_live_commerce/util/logger.dart';
import 'package:flutter_live_commerce/util/util.dart';
import 'package:flutter_live_commerce/vo/chat_item.dart';
import 'package:flutter_live_commerce/widget/chat/chat_notice_item.dart';
import 'package:flutter_live_commerce/widget/chat/emoji_chat_item.dart';
import 'package:flutter_live_commerce/widget/chat/emoji_images.dart';
import 'package:flutter_live_commerce/widget/chat/emoji_list.dart';
import 'package:flutter_live_commerce/widget/chat/text_chat_item.dart';
import 'package:flutter_live_commerce/widget/chat/user_join_item.dart';
import 'package:flutter_live_commerce/widget/chat/user_leave_item.dart';
import 'package:flutter_live_commerce/widget/chat/whisper_chat_item.dart';
import 'package:flutter_live_commerce/widget/common/anchor.dart';
import 'package:flutter_live_commerce/widget/common/heart_icon.dart';
import 'package:flutter_live_commerce/widget/drawer/right_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';
import 'package:video_player/video_player.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late final Channel channel;

  var inputController = TextEditingController();
  final _scrollController = ScrollController();
  late final VideoPlayerController _videoPlayerController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _focus = FocusNode();
  var currentScrollPosition = false;
  var emojiActive = false;
  ChatRoomModel? roomInfo;
  TargetDrawer target = TargetDrawer.Help;
  var rowHeight = 50.0;
  // 모바일에서는 키보드 노출 여부로 체크(포커스 되어있어도 키보드가 올라와있지 않으면 작동하지 않는것으로 체크)
  bool get noKeyboard => Util.isMobile
      ? MediaQuery.of(context).viewInsets.bottom != 0
      : _focus.hasFocus;
  double get emojiHeight => emojiActive ? 327 : 0;

  @override
  void initState() {
    channel = Provider.of<ChannelStore>(context, listen: false).channel!;
    VChatCloudApi.getRoomInfo(roomId: roomId).then((value) {
      setState(() {
        roomInfo = value;
      });
    });
    _videoPlayerController = Util.isWindows
        ? VideoPlayerController.file(File("assets/common/sample_video.mp4"))
        : VideoPlayerController.asset("assets/common/sample_video.mp4")
      ..initialize().then((value) {
        _videoPlayerController.setLooping(true);
        _videoPlayerController.play();
        setState(() {});
      });
    inputController.addListener(() {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          rowHeight = rowKey.currentContext?.size?.height ?? 50.0;
        });
      });
    });
    _focus.onKey = (node, event) {
      if (event is RawKeyDownEvent && !Util.isMobile) {
        if (event.isShiftPressed && event.logicalKey.keyLabel == 'Enter') {
          return KeyEventResult.ignored;
        } else if (event.logicalKey.keyLabel == 'Enter') {
          sendMessage();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };
    _scrollController.addListener(() {
      scrollController();
    });
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _scrollController.dispose();
    _focus.dispose();
    VChatCloud.disconnect(VChatCloudResult.success);
    super.dispose();
  }

  void scrollController() {
    if (_scrollController.offset <= 300) {
      setState(() {
        currentScrollPosition = false;
      });
    } else if (currentScrollPosition == false) {
      setState(() {
        currentScrollPosition = true;
      });
    }
  }

  void clientListHandler() {
    logger.d('client list clicked');
    setState(() {
      target = TargetDrawer.ClientList;
      _scaffoldKey.currentState!.openEndDrawer();
    });
    unfocus();
  }

  void helpHandler() {
    logger.d('help clicked');
    setState(() {
      target = TargetDrawer.Help;
      _scaffoldKey.currentState!.openEndDrawer();
    });
    unfocus();
  }

  void backHandler() {
    Navigator.pop(context);
  }

  void emojiHandler() {
    _focus.unfocus();
    setState(() {
      emojiActive = !emojiActive;
    });
  }

  void moveScrollBottom() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.jumpTo(0);
      setState(() {});
    });
  }

  void unfocus() {
    _focus.unfocus();
    setState(() {
      emojiActive = false;
    });
  }

  void sendMessage() {
    if (!Util.isMobile) {
      _focus.requestFocus();
    }
    if (messageIsEmpty) return;

    channel.sendMessage(inputController.text);
    inputController.clear();

    moveScrollBottom();
  }

  bool get messageIsEmpty => inputController.text.trim().isEmpty;

  @override
  Widget build(BuildContext context) {
    var chatLog = Provider.of<ChannelStore>(context).chatLog;
    var clientList = Provider.of<ChannelStore>(context).clientList;

    return GestureDetector(
      onTap: () {
        unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: RightDrawer(
          target: target,
        ),
        endDrawerEnableOpenDragGesture: false,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  ),
                ),
                // AppBar
                Scaffold(
                  backgroundColor: Colors.transparent,
                  resizeToAvoidBottomInset: true,
                  body: Stack(
                    children: [
                      // title
                      Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: IconButton(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.zero,
                                    iconSize: 24,
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
                                    splashRadius: 24,
                                    onPressed: backHandler,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  roomInfo?.roomNm ?? "로딩중입니다...",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xffffffff),
                                    fontSize: 20.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 11),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/common/ico_live.svg",
                                  width: 36,
                                  height: 20,
                                ),
                                const SizedBox(width: 8),
                                Anchor(
                                  onTap: clientListHandler,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        clientList.length
                                            .toString()
                                            .padLeft(3, '0'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                                Anchor(
                                  onTap: helpHandler,
                                  child: const Icon(
                                    Icons.help_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            // 50은 TextField 높이
                            margin: EdgeInsets.only(bottom: emojiHeight),
                            height:
                                MediaQuery.of(context).size.height * 0.5 + 50,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5 -
                                        50,
                                child: GestureDetector(
                                  onTap: unfocus,
                                  child: Stack(
                                    alignment: Alignment.bottomLeft,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(child: chatBuilder(chatLog)),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 5),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                if (currentScrollPosition)
                                                  FloatingActionButton.small(
                                                    onPressed: () {
                                                      _scrollController
                                                          .jumpTo(0);
                                                      setState(() {
                                                        currentScrollPosition =
                                                            false;
                                                      });
                                                    },
                                                    tooltip: "Scroll to Bottom",
                                                    child: const Icon(
                                                        Icons.arrow_downward),
                                                  ),
                                                const HeartIcon(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              bottomBarBuilder(),
                              if (emojiActive) emojiBuilder(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget emojiBuilder() {
    var emoji = Provider.of<EmojiStore>(context);
    emoji.initEmojiList();
    emoji.initChildEmojiList();

    return const Column(
      children: [
        EmojiImages(),
        EmojiList(),
      ],
    );
  }

  Widget bottomBarBuilder() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: noKeyboard || emojiActive
          ? const Color(0xffeeeeee)
          : Colors.transparent,
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 15,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                TextField(
                  key: rowKey,
                  focusNode: _focus,
                  controller: inputController,
                  minLines: 1,
                  maxLines: 1,
                  textInputAction: TextInputAction.send,
                  scrollPadding: const EdgeInsets.only(bottom: 200),
                  cursorColor: const Color(0xff2a61be),
                  onTap: () {
                    setState(() {
                      emojiActive = false;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    contentPadding: const EdgeInsets.only(
                      left: 12,
                      right: 30,
                    ),
                    alignLabelWithHint: true,
                    hintText: "실시간 채팅에 참여하세요.",
                    hintStyle: TextStyle(
                      color: noKeyboard || emojiActive
                          ? const Color(0xff999999)
                          : const Color(0x80ffffff),
                      fontSize: 14,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(
                        color: Color(0xffe3e3e3),
                        width: 1,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(
                        color: Color(0xffe3e3e3),
                        width: 1,
                      ),
                    ),
                    fillColor: noKeyboard || emojiActive
                        ? Colors.white
                        : Colors.transparent,
                  ),
                  style: TextStyle(
                    color:
                        noKeyboard || emojiActive ? Colors.black : Colors.white,
                  ),
                  onEditingComplete: sendMessage,
                ),
                Positioned(
                  right: 16 / 2,
                  child: SizedBox(
                    width: 20,
                    child: IconButton(
                      onPressed: emojiHandler,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      color:
                          (emojiActive) ? Colors.blue[700] : Colors.grey[500],
                      icon: const Icon(
                        Icons.emoji_emotions,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Anchor(
            onTap: sendMessage,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 30,
              height: 30,
              child: messageIsEmpty
                  ? SvgPicture.asset("assets/chat/send_disable.svg")
                  : SvgPicture.asset("assets/chat/send.svg"),
            ),
          )
        ],
      ),
    );
  }

  Widget chatBuilder(List<ChatItem> chatLog) {
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.transparent,
          ],
          stops: [0.0, 0.2],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(15),
        reverse: true,
        child: Column(
          children: [
            ...chatLog.asMap().entries.expand(
              (entry) {
                var log = entry.value;

                return [
                  const SizedBox(height: 15),
                  if (log.messageType == MessageType.join)
                    UserJoinItem(log)
                  else if (log.messageType == MessageType.leave)
                    UserLeaveItem(log)
                  else if (log.messageType == MessageType.notice)
                    ChatNoticeItem(log)
                  else if (log.messageType == MessageType.whisper)
                    WhisperChatItem(
                      log,
                    )
                  else if (log.messageType == MessageType.custom)
                    const Text("커스텀")
                  else if (log.mimeType == MimeType.emojiImg)
                    EmojiChatItem(
                      log,
                    )
                  else
                    TextChatItem(
                      log,
                    ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
