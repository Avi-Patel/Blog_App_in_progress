
import 'package:blogging_app/Blog/blog_data_model.dart';
import 'package:blogging_app/Blog/futuredata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

class ShowSavedBlogs extends StatefulWidget {
  String type;
  ShowSavedBlogs(this.type);
  @override
  _ShowSavedBlogsState createState() => _ShowSavedBlogsState();
}

class _ShowSavedBlogsState extends State<ShowSavedBlogs> {
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
      body: Streambuilder("", widget.type),
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

  // List ids=List();
  String uid;
  List list=List();
  var flushbar;
  void show(String s1) 
  {
      flushbar = Flushbar(
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.info_outline,color: Colors.blue,),
      messageText: Text(
        s1,
        style: TextStyle(color: Colors.white,fontWeight: FontWeight.w300),
      ),
      backgroundColor: Colors.black87,
    );
  }
  
  Future<void> _fetchsavedDocuments() async
  {
    List ids=List();
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get()
      .then((value){
        if(value.data().containsKey(type))
          ids=value.data()[type];
      })
      .catchError((e){
        print(e);
      });
    print(ids);
    for(var element in ids)
    {
      await FirebaseFirestore.instance
        .collection(type)
        .doc(element)
        .get()
        .then((value){
          list.add(value);
        });
    }
    print(list);
  }

  Future<void> _deleteSavedBlog(var index) async
  {
    print(list[index].id);
    print(type);
    print(uid);
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
        'Saved Blogs': FieldValue.increment(-1),
        type : FieldValue.arrayRemove([list[index].id]),
      })
      .then((_){
        print("Blog removed from your saved blogs");
        show("Blog removed from your saved blogs");
        flushbar.show(context);
      })
      .catchError((e)
      {
        print("error : " +e.toString());
        show("Opps!! Something went wrong");
        flushbar.show(context);
      });
    setState(() {
      list.removeAt(index);
    });
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    uid=FirebaseAuth.instance.currentUser.uid;  
    _fetchsavedDocuments().then((_) {
      setState(() {});
    });  
  }
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
      child: list.length==0?
      Center(
        child: Text(
          "There are not any blogs to show",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      )
      :
      ListView.builder(
        itemCount: list.length,
        itemBuilder: (context,index){
          DocumentSnapshot doc=list[index];
          FutureDataModel data=FutureDataModel.fromSnapshot(list[index]);
          if(qry==null || list[index].data()['title'].toLowerCase().contains(qry.toLowerCase()))
          return Dismissible(
            key: UniqueKey(),
            secondaryBackground: Container(
              child: Center(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              color: Colors.red,
            ),
            background: Container(),
            child: FutureData(data,type,"saved"),
            onDismissed: (direction) async{
              await _deleteSavedBlog(index);
            },
          );
        },
      ),
    );
  }
}