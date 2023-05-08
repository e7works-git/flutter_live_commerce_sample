import 'package:flutter/material.dart';
import 'package:flutter_live_commerce/vo/chat_item.dart';

class ChatNoticeItem extends StatelessWidget {
  final ChatItem data;
  const ChatNoticeItem(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: data.message,
        style: const TextStyle(
          color: Color(0xffffe26c),
          fontSize: 12.0,
          height: 1.5,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }
}
