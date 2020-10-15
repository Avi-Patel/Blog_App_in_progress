import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'futuredata.dart';
import 'blog_data_model.dart';
 
// ignore: must_be_immutable
class ShowBlogs extends StatefulWidget {
  String type;
  var _index;
  ShowBlogs(this.type,this._index);
  @override
  _ShowBlogsState createState() => _ShowBlogsState(_index);
 }
 
class _ShowBlogsState extends State<ShowBlogs> {
  var _index;
  _ShowBlogsState(this._index);  

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
  String type;
  var _index;
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
                // DocumentSnapshot doc=snapshot.data.docs[index];
                FutureDataModel data=FutureDataModel.fromSnapshot(snapshot.data.docs[index]);
                if(qry==null || snapshot.data.docs[index].data()['title'].toLowerCase().contains(qry.toLowerCase()))
                return FutureData(data,type,"general",_index);
                else return SizedBox();
              },
            ),
          );
        },
      ),
    );
  }
}