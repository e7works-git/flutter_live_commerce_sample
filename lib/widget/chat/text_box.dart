import 'package:flutter/material.dart';
import 'package:flutter_live_commerce/util/util.dart';
import 'package:flutter_live_commerce/vo/chat_item.dart';
import 'package:flutter_live_commerce/widget/chat/open_graph_item.dart';
import 'package:flutter_live_commerce/widget/common/anchor.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class TextBox extends StatelessWidget {
  final ChatItem data;
  const TextBox(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    const regex = Util.urlRegex;
    final List<InlineSpan> texts = [];
    bool isWhisper = MessageType.whisper == data.messageType;

    data.message.toString().splitMapJoin(RegExp(regex), onMatch: (m) {
      texts.add(
        WidgetSpan(
          child: Anchor(
            onTap: () => Util.openLink(m[0]!),
            child: Text(
              '${m[0]}',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
      return '';
    }, onNonMatch: (n) {
      texts.add(
        TextSpan(
          text: n,
          style: const TextStyle(
            color: Color(0xffffffff),
            fontSize: 14,
          ),
        ),
      );
      return '';
    });
    var firstUrl = RegExp(regex).firstMatch(data.message);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width -
                    (60 + 30 + 26 + 8 + 5 + (isWhisper ? 10 : 0)),
              ),
              child: Text.rich(TextSpan(children: texts)),
            ),
            if (firstUrl != null && !isWhisper)
              OpenGraphItem(firstUrl.group(0)!)
          ],
        ),
      ],
    );
  }
}
