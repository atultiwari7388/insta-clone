import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_clone/Widgets/like_animations.widget.dart';
import 'package:instagram_clone/models/user.model.dart';
import 'package:instagram_clone/providers/user.provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/comment_screen.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  const PostCard({Key? key, required this.snapData}) : super(key: key);
  final snapData;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLength = 0;

  @override
  void initState() {
    super.initState();
    getComments();
  }

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("posts")
          .doc(widget.snapData["postId"])
          .collection("comments")
          .get();
      commentLength = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return GestureDetector(
      onDoubleTap: () async {
        await FireStoreMethod().likePost(
          widget.snapData["postId"],
          user.uid,
          widget.snapData["likes"],
        );

        setState(() {
          isLikeAnimating = true;
        });
      },
      child: Stack(
        children: [
          // post section
          Container(
            alignment: Alignment.center,
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.snapData["postUrl"]),
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: isLikeAnimating ? 1 : 0,
              child: LikeAnimation(
                child: Icon(
                  IconlyBold.heart,
                  color: Colors.red,
                  size: 70,
                ),
                isAnimating: isLikeAnimating,
                duration: Duration(milliseconds: 400),
                onEnd: () {
                  setState(() {
                    isLikeAnimating = false;
                  });
                },
              ),
            ),
          ),
          //blur full screen
          Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(15.0),
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.black12.withOpacity(0.3),
                  Colors.black12.withOpacity(0.3),
                  Colors.black12.withOpacity(0.3),
                  // Colors.white12.withOpacity(0.1),
                  // Colors.black26.withOpacity(0.3),
                ],
                // stops: [
                //   0.08,
                //   0.0470,
                //   0.0890,
                // ],
                tileMode: TileMode.repeated,
              ),
            ),
          ),
          //like , comment , share section
          Positioned(
            top: 400,
            right: 20,
            bottom: 0,
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Column(
                children: [
                  //like button
                  IconButton(
                      onPressed: () async {
                        await FireStoreMethod().likePost(
                          widget.snapData["postId"],
                          user.uid,
                          widget.snapData["likes"],
                        );
                      },
                      icon: widget.snapData['likes'].contains(user.uid)
                          ? Icon(
                              IconlyBold.heart,
                              color: Colors.red,
                            )
                          : Icon(IconlyLight.heart, color: Colors.white)),
                  SizedBox(height: 5),
                  Text(
                    "${widget.snapData['likes'].length}",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  //comment button
                  GestureDetector(
                    onTap: () {
                      buildShowModalBottomSheet(context);
                    },
                    child: FaIcon(
                      FontAwesomeIcons.comment,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "$commentLength",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 25),
                  // share button
                  Icon(Icons.share, color: Colors.white),
                  Text(
                    "Share",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          //profile photo and
          Positioned(
            // top: 0,
            bottom: 50,
            child: Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.only(left: 10),
              width: 300,
              child: Row(
                children: [
                  //profile image
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        NetworkImage(widget.snapData["profileImage"]),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      //name section
                      Text(
                        widget.snapData["name"],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      //userName Section
                      Text(
                        "@${widget.snapData["userName"]}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 5),
                      //description section
                      SizedBox(
                        width: 200,
                        child: Text(
                          widget.snapData["description"],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //top Section
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  "$commentLength Comments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ]),
              //show comments
              Flexible(child: CommentScreen(snap: widget.snapData)),
            ],
          ),
        );
      },
    );
  }
}
