import 'package:flutter/material.dart';
import 'package:flutter_live_commerce/store/channel_store.dart';
import 'package:flutter_live_commerce/util/util.dart';
import 'package:flutter_live_commerce/vo/chat_item.dart';
import 'package:provider/provider.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class ChatBaseItem extends StatelessWidget {
  final ChatItem data;
  final Widget content;

  const ChatBaseItem(
    this.data,
    this.content, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var channel = context.read<ChannelStore>().channel;
    bool isWhisper = data.messageType == MessageType.whisper;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () {
            if (!data.isMe) {
              Util.sendWhisperDialog(context, channel, data);
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffeaeaea),
                  border: Border.all(
                    width: 2,
                    color: const Color(0xffeaeaea),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(13),
                  ),
                  child: Image.asset(
                    "assets/profile/profile_img_${data.userInfo?['profile'].toString() ?? '1'}.png",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        maxWidth: 150,
                      ),
                      child: Opacity(
                        opacity: 0.8,
                        child: Text(
                          data.nickName ?? '홍길동',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(204, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                    if (isWhisper)
                      Text(
                        data.isMe ? '님에게' : '님이',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0x80ffffff),
                        ),
                      ),
                    const SizedBox(height: 5),
                    content,
                    const SizedBox(height: 5),
                    Text(
                      Util.getCurrentDate(data.messageDt).toString(),
                      style: const TextStyle(
                        color: Color.fromARGB(127, 255, 255, 255),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
