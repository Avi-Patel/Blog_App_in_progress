import 'package:blogging_app/Profile/show_saved_blogs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;
import 'package:blogging_app/image_urls.dart';

class SavedBlogs extends StatefulWidget {
  @override
  _SavedBlogsState createState() => _SavedBlogsState();
}

class _SavedBlogsState extends State<SavedBlogs> {

  Urls _urls=Urls();
  var blogArr = [
    'Tech',
    'Non-Tech',
    'Interview',
    'Internship',
    'Food',
    'Travel',
    'Political',
    'Business'
  ];
  var blogExtention = [
    'Blogs',
    'Blogs',
    'Exps',
    'Exps',
    'Blogs',
    'Blogs',
    'Blogs',
    'Blogs'
  ];

  Future<void> _tryagain() async
  {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Saved Blogs",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () async{
          _tryagain();
        },
        child: Container(
          // height: MediaQuery.of(context).size.height,
          // width: MediaQuery.of(context).size.width,
          // color: Colors.black,
          child: GridView.count(
            crossAxisCount: 2,
            children: List.generate(8, (index) {
              return InkWell(
                splashColor: Colors.white,
                highlightColor: Colors.white,
                child: Card(
                  elevation: 10.0,
                  color: Colors.black,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.white),
                      image: DecorationImage(
                        // image: AssetImage("assets/${blogArr[index].toLowerCase()}"+"_"+"${blogExtention[index].toLowerCase()}.jpg"),
                        image: CachedNetworkImageProvider(
                          _urls.urls[index],
                        ),
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.7), BlendMode.darken),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        //  SizedBox(height: MediaQuery.of(context).size.height/15,),
                        Column(
                          children: [
                            Text(
                              blogArr[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w400
                              ),
                            ),
                            Text(
                              blogExtention[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w400
                              ),
                            ),
                          ],
                        ),
                        
                        Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: Colors.white,
                          size: 30.0,
                        )

                      ],
                    ),
                  ),
                ),
                onTap: (){
                  Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => ShowSavedBlogs("${blogArr[index]}"+" "+"${blogExtention[index]}",index)));
                }
              );
            }),
          ),
        ),
      ),
    );
  }
}