import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:blogging_app/Profile/Show_personal_blogs.dart';
import 'package:blogging_app/image_urls.dart';

class PersonalBlogs extends StatefulWidget {
  @override
  _PersonalBlogsState createState() => _PersonalBlogsState();
}

class _PersonalBlogsState extends State<PersonalBlogs> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Blogs",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        padding: EdgeInsets.all(10.0),
        children: List.generate(8, (index) {
          return InkWell(
            splashColor: Colors.white,
            customBorder:RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Card(
              margin: EdgeInsets.all(2.0),
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white,width: 0.5),
                  image: DecorationImage(
                    // image: AssetImage("assets/${blogArr[index].toLowerCase()}"+"_"+"${blogExtention[index].toLowerCase()}.jpg"),
                    image: CachedNetworkImageProvider(
                      _urls.urls[index],
                    ),
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), BlendMode.darken),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
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
                .push(MaterialPageRoute(builder: (context) => ShowPersonalBlogs("${blogArr[index]}"+" "+"${blogExtention[index]}",index)));
            }
          );
        }),
      ),
    );
  }
}