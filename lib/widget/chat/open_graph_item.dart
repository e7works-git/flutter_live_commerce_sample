import 'package:flutter/material.dart';
import 'package:flutter_live_commerce/util/util.dart';
import 'package:flutter_live_commerce/widget/common/anchor.dart';
import 'package:vchatcloud_flutter_sdk/vchatcloud_flutter_sdk.dart';

class OpenGraphItem extends StatefulWidget {
  final String url;
  const OpenGraphItem(this.url, {super.key});

  @override
  State<OpenGraphItem> createState() => _OpenGraphItemState();
}

class _OpenGraphItemState extends State<OpenGraphItem> {
  late final Future<OpenGraphModel> model;

  @override
  void initState() {
    super.initState();
    model = VChatCloudApi.openGraph(requestUrl: widget.url);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: model,
      builder: (context, snapshot) =>
          snapshot.hasData && snapshot.data?.url.isNotEmpty == true
              ? Anchor(
                  onTap: () => Util.openLink(widget.url),
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(top: 5),
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: double.infinity,
                            height: 76,
                            child: Image.network(
                              snapshot.data!.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data!.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff333333),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                snapshot.data!.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff666666),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
    );
  }
}
