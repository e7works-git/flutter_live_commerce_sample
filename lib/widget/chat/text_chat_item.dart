import 'package:flutter/material.dart';
import 'package:flutter_live_commerce/vo/chat_item.dart';
import 'package:flutter_live_commerce/widget/chat/chat_base_item.dart';
import 'package:flutter_live_commerce/widget/chat/text_box.dart';

class TextChatItem extends StatelessWidget {
  final ChatItem data;
  const TextChatItem(
    this.data, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChatBaseItem(
      data,
      TextBox(data),
    );
  }
}
