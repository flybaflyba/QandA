
import 'package:flutter/material.dart';
import 'package:nice_button/nice_button.dart';
import 'package:qanda/universals/UniversalValues.dart';

class SearchCourseWidget extends StatefulWidget{

  @override
  _SearchCourseWidgetState createState() => _SearchCourseWidgetState();
}

class _SearchCourseWidgetState extends State<SearchCourseWidget>{

  var course = "";
  TextEditingController courseTextEditingController = new TextEditingController();
  var boxConstraints = BoxConstraints(minWidth: 100, maxWidth: 250);
  var boxColor = Colors.white;

  Widget listMatchedCourses(String enteredString)
  {

    print(enteredString);
    List<dynamic> filteredCourses = new List<dynamic>();
    setState(() {
      for(var i = UniversalValues.courses.length - 1; i > -1; i--){
        if (UniversalValues.courses[i].contains(enteredString.toUpperCase())) {
          if(course != UniversalValues.courses[i]) {
            filteredCourses.add(UniversalValues.courses[i]);
          }
        }
      }
      if(filteredCourses.length == 0 && !UniversalValues.courses.contains(enteredString.toUpperCase())) {
        filteredCourses.add("No Course Found");
      }
    });

    // print(filteredCourses.length);
    List<Widget> list = new List<Widget>();
    if (enteredString != "") {
      for(var i = filteredCourses.length - 1; i > -1; i--){
        //list.add(new Text(strings[i]));
        String temp = filteredCourses[i];
        list.add(
          Container(
            margin: EdgeInsets.all(5),
            child: Center(
              child: FlatButton(
                textColor: Colors.blueAccent,
                onPressed: () {
                  if (temp != "No Course Found") {
                    setState(() {
                      course = temp;
                      courseTextEditingController.text = temp;
                    });
                  }
                },
                child: Text(
                  temp,
                ),
              ),
            ),
          ),
        );
      }
    }
    return new ListView(
      shrinkWrap: true,
      children: list,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 150, maxWidth: 350),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minWidth: 150, maxWidth: 350),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              // color: Colors.redAccent,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  ListTile(
                    title: Text(
                      "Search by course",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // IconButton(icon: Icon(Icons.person), onPressed: null),
                        Container(
                          color: boxColor,
                          constraints: boxConstraints,
                          margin: EdgeInsets.only(left: 10),
                          child: TextField(
                            controller: courseTextEditingController,
                            onChanged: (value){
                              setState(() {
                                course = value;
                              });
                              // print(course);
                            },
                            decoration: InputDecoration(
                              hintText: "",
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    color: Colors.grey[300],
                    constraints: BoxConstraints(minHeight: 0, maxHeight: 200),
                    child: listMatchedCourses(course),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        // color: boxColor,
                        // constraints: boxConstraints,
                        height: 60,
                        child: NiceButton(
                          width: 250,
                          radius: 40,
                          padding: const EdgeInsets.all(15),
                          // icon: Icons.account_box,
                          gradientColors: [Color(0xff5b86e5), Color(0xff36d1dc)],
                          text: "Search",
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),);
  }
}