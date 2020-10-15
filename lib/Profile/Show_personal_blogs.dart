import 'package:blogging_app/Blog/blog_data_model.dart';
import 'package:blogging_app/Blog/futuredata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

// ignore: must_be_immutable
class ShowPersonalBlogs extends StatefulWidget {
  String type;
  var _index;
  ShowPersonalBlogs(this.type,this._index);
  @override
  _ShowPersonalBlogsState createState() => _ShowPersonalBlogsState(_index);
}

class _ShowPersonalBlogsState extends State<ShowPersonalBlogs> {
  var _index;
  _ShowPersonalBlogsState(this._index);
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
              delegate: Datasearch(widget.type,_index),              
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Streambuilder("",widget.type,_index),
    );
  }
}

class Datasearch extends SearchDelegate<String>{
  var _index;
  String type;
  Datasearch(this.type,this._index);

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
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    
    return Streambuilder(query,type,_index);
  }

}

// ignore: must_be_immutable
class Streambuilder extends StatefulWidget {
  String qry,type;
  var _index;
  Streambuilder(this.qry,this.type,this._index);
  @override
  _StreambuilderState createState() => _StreambuilderState(qry,type,_index);
}

class _StreambuilderState extends State<Streambuilder> {
  String qry,type;
  var _index;
  _StreambuilderState(this.qry,this.type,this._index);

  String uid=FirebaseAuth.instance.currentUser.uid;

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
          if (!snapshot.hasData) {
            return Text(
              "Loading...",
              style: TextStyle(
                color: Colors.white
              ),
            );
          }
          List list= List();
          snapshot.data.docs.forEach((element) {
            if(element.data()['userId']==uid)
            {
              list.add(element);
            }
          });
          if(list.length==0)
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
              itemCount: list.length,
              itemBuilder: (context,index){
                // DocumentSnapshot doc=list[index];
                FutureDataModel data=FutureDataModel.fromSnapshot(list[index]);
                if(qry==null || list[index].data()['title'].toLowerCase().contains(qry.toLowerCase()))
                return FutureData(data,type,"personal",_index);
                return SizedBox();
              },
            ),
          );
        },
      ),
    );
  }
}