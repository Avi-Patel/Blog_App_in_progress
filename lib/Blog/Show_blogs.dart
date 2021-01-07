import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'futuredata.dart';
import 'blog_data_model.dart';
 
// ignore: must_be_immutable
class ShowBlogs extends StatefulWidget {
  String _type;
  var _index;
  ShowBlogs(this._type,this._index);
  @override
  _ShowBlogsState createState() => _ShowBlogsState(_type,_index);
 }
 
class _ShowBlogsState extends State<ShowBlogs> {
  var _index,_type;
  _ShowBlogsState(this._type,this._index);  
  bool _isbutton=true;
  String _sort="star";

  Widget _floatingRow(BuildContext context)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MaterialButton(
          elevation: 10.0,
          splashColor: Colors.white,
          shape:RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            
          ),
          color: Colors.blue,
          child: Text(
            "Date",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
          ),
          onPressed: (){
            setState(() {
              _sort="date";    
              _isbutton=true;          
            });
          },
        ),
        MaterialButton(
          elevation: 10.0,
          splashColor: Colors.white,
          shape:RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.blue,
          child: Text(
            "Likes",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
          ),
          onPressed: (){
            setState(() {
              _sort="likes";
              _isbutton=true;  
            });
          },
        ),
        MaterialButton(
          elevation: 10.0,
          splashColor: Colors.white,
          shape:RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.blue,
          child: Text(
            "Star",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
          ),
          onPressed: (){
            setState(() {
              _sort="star";
              _isbutton=true;              
            });
          },
        )
      ],
    );
  }
  Future<void> _tryagain() async
  {
    setState(() {});  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _type,
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
              delegate: Datasearch(_type,_index),              
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
      floatingActionButton: _isbutton?
      FloatingActionButton(
        elevation: 2.0,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        splashColor: Colors.white,
        highlightElevation: 10.0,
        child: Icon(
          Icons.sort,
          color: Colors.white,
          size: 30.0,
        ),
        onPressed: () 
        {
          setState(() {
            _isbutton=false;              
          });
        },
      )
      :_floatingRow(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: RefreshIndicator(
        onRefresh: () async{
          _tryagain();
        },
        child: StreamBuilder<QuerySnapshot>  (
          stream: FirebaseFirestore.instance.collection(_type)
                  .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (snapshot.hasError) {
              return Center(
                child:Text(
                  'Something went wrong',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  )
                )
              );
            }          
            if (!snapshot.hasData) {
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
                itemBuilder: (BuildContext context,index){
                  print(_sort);
                  snapshot.data.docs.toList().sort((a,b){
                    if( a.data()[_sort] > b.data()[_sort]) return 1;
                    else if(a.data()[_sort] < b.data()[_sort]) return -1;
                    else return 0;
                  });
                  FutureDataModel data=FutureDataModel.fromSnapshot(snapshot.data.docs[index]);
                  return AnimatedSwitcher(
                    duration: Duration(seconds:1),
                    child: FutureData(data,_type,"general",_index)
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class Datasearch extends SearchDelegate<String>{
  String _type;
  var _index;
  Datasearch(this._type,this._index);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white),
      primaryColor: Colors.white,
    );
  }
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      new IconButton
      (
        icon: Icon
        (
          Icons.clear
        ), 
        onPressed: (){ 
          query="";
        }
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
    return Streambuilder(query,_type,_index);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var qry=query;
    return Streambuilder(qry,_type,_index);
  }

}


// ignore: must_be_immutable
class Streambuilder extends StatefulWidget {
  String qry,_type;
  var _index;
  Streambuilder(this.qry,this._type,this._index);
  @override
  _StreambuilderState createState() => _StreambuilderState(qry,_type,_index);
}

class _StreambuilderState extends State<Streambuilder> {
  String qry,_type;
  var _index;
  _StreambuilderState(this.qry,this._type,this._index);
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
        stream: FirebaseFirestore.instance.collection(_type).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
          if (snapshot.hasError) {
            return Center(
              child:Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                )
              )
            );
          }          
          if (!snapshot.hasData) {
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
              itemBuilder: (BuildContext context,index){
                // snapshot.data.docs.toList().sort((a,b){
                //   return a.data()[_sort].toString().compareTo(b.data()[_sort].toString());
                // });
                FutureDataModel data=FutureDataModel.fromSnapshot(snapshot.data.docs[index]);
                if(qry==null || snapshot.data.docs[index].data()['title'].toLowerCase().contains(qry.toLowerCase()))
                  return AnimatedSwitcher(
                    duration: Duration(seconds:1),
                    child: FutureData(data,_type,"general",_index)
                  );
                else return SizedBox();
              },
            ),
          );
        },
      ),
    );
  }
}