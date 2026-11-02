import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_state.dart';
import 'package:ecommerce/util/dimensions.dart';

class MessageBubbleShimmer extends StatelessWidget {
  final bool isMe;
  const MessageBubbleShimmer({super.key, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isMe
          ? const EdgeInsets.fromLTRB(50, 5, 10, 5)
          : const EdgeInsets.fromLTRB(10, 5, 50, 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (p, c) =>
                  (p.messageModel == null) != (c.messageModel == null),
              builder: (context, state) {
                return Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: state.messageModel == null,
                  child: Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(
                          Dimensions.radiusDefault,
                        ),
                        bottomLeft: isMe
                            ? const Radius.circular(Dimensions.radiusDefault)
                            : const Radius.circular(0),
                        bottomRight: isMe
                            ? const Radius.circular(0)
                            : const Radius.circular(Dimensions.radiusDefault),
                        topRight: const Radius.circular(
                          Dimensions.radiusDefault,
                        ),
                      ),
                      color: isMe
                          ? Theme.of(context).hintColor
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
