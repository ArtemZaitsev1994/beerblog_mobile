import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentsList extends StatelessWidget {
  final List comments;
  
  const CommentsList({Key key, this.comments}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ExpansionTile(
        leading: Icon(Icons.comment),
        trailing: Text(comments.length.toString()),
        title: Text("Комментарии:", style: Theme.of(context).textTheme.headline2),
        children: List<Widget>.generate(
          comments.length,
          (int index) => SingleComment(
            key: ValueKey(index),
            comment: comments[index],
            needDivider: index != 0,
          ),
        ),
      ),
    );
  }
}

class SingleComment extends StatelessWidget {
  final Map comment;
  final bool needDivider;

  const SingleComment({Key key, @required this.comment, this.needDivider}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          needDivider ? Divider(
            color: Colors.black45,
          ) : SizedBox.shrink(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                comment['author'],
                style: Theme.of(context).textTheme.headline2
              ),
              Text(comment['date'], style: TextStyle(fontSize: 10),)
            ]
          ),
          SizedBox(height: 5,),
          Text(
            comment['text'],
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyText1
          ),
        ],
      ),
    );
  }
}