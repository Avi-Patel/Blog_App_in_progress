import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'futuredata.dart';
import 'blog_data_model.dart';
 
class ShowBlogs extends StatefulWidget {
  String type;
  ShowBlogs(this.type);
  @override
  _ShowBlogsState createState() => _ShowBlogsState();
 }
 
class _ShowBlogsState extends State<ShowBlogs> {
  @override
  void initState() 
  {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() 
  {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal:10.0),
              child: Icon(
                Icons.search,
              ),
            ),
            onTap: ()=>showSearch(
              context: context, 
              delegate: Datasearch(widget.type),              
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Streambuilder("",widget.type),
    );
  }
}

class Datasearch extends SearchDelegate<String>{
  String type;
  Datasearch(this.type);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      new IconButton
      (
        icon: Icon
        (
          Icons.clear
        ), 
        onPressed: (){ query="";}
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return 
      new IconButton(
        icon: new AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, 
          progress: transitionAnimation,
        ), 
        onPressed: (){
          close(context, null);
        }
      );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    
    return Streambuilder(query,type);
  }

}


class Streambuilder extends StatefulWidget {
  String qry,type;
  Streambuilder(this.qry,this.type);
  @override
  _StreambuilderState createState() => _StreambuilderState(qry,type);
}

class _StreambuilderState extends State<Streambuilder> {
  String qry,type;
  _StreambuilderState(this.qry,this.type);

  SpinKitFadingCircle spinkit = SpinKitFadingCircle(
    color: Colors.blue,
    size: 50.0,
    duration: Duration(milliseconds: 2000),
  );

  Future<void> _tryagain() async
  {
    setState(() {});  
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async{
        _tryagain();
      },
      child: StreamBuilder<QuerySnapshot>  (
        stream: FirebaseFirestore.instance.collection(type).snapshots(),

        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
          if (snapshot.hasError) {
          return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text(
                "Loading...",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                )
              ),
            );
          }
          if(snapshot.data.docs.length==0)
          {
            return Center(
              child: Text(
                "There are not any blogs to show",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return Container(
            color: Colors.black,
            child: ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context,index){
                DocumentSnapshot doc=snapshot.data.docs[index];
                FutureDataModel data=FutureDataModel.fromSnapshot(snapshot.data.docs[index]);
                if(qry==null || snapshot.data.docs[index].data()['title'].toLowerCase().contains(qry.toLowerCase()))
                return FutureData(data,type,"general");
              },
            ),
          );
        },
      ),
    );
  }
}