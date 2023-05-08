import 'package:flutter/material.dart';
import 'package:flutter_live_commerce/store/channel_store.dart';
import 'package:flutter_live_commerce/util/util.dart';
import 'package:flutter_live_commerce/vo/chat_item.dart';
import 'package:flutter_live_commerce/widget/chat/text_box.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class WhisperChatItem extends StatelessWidget {
  final ChatItem data;
  const WhisperChatItem(
    this.data, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var channel = Provider.of<ChannelStore>(context, listen: false);
    return GestureDetector(
      onLongPress: data.isMe
          ? null
          : () => Util.sendWhisperDialog(context, channel.channel, data),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/chat/ico_whisper.svg"),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: data.nickName,
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                            TextSpan(
                              text: data.isMe ? "님에게 귓속말" : "님의 귓속말",
                              style: TextStyle(
                                color: Colors.yellow.withOpacity(0.8),
                                fontSize: 14.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextBox(data),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            Util.getCurrentDate(data.messageDt).toString(),
            style: const TextStyle(
              color: Color(0x4cffffff),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
