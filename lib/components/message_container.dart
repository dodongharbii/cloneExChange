import 'package:flutter/material.dart';

class MessageContainer extends StatelessWidget {
  const MessageContainer(
      {Key? key, required this.message, required this.isCurrentUser})
      : super(key: key);

  final String message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.all(10),
          constraints: BoxConstraints(
            maxWidth: 235,
          ),
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.yellow[300] : Colors.grey[200],
            borderRadius: isCurrentUser
                ? BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20))
                : BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
