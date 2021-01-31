

class Comment {
  var content = "";
  var time = "";
  var by = "";
  var replies = List<Map>();

  Comment({
    var content,
    var time,
    var by,
  }){
    if(content != null){ this.content = content; }
    if(time != null){ this.time = time; }
    if(by != null){ this.by = by; }
  }

  printOut() {
    print("content: " + content);
    print("time: " + time);
    print("by: " + by);
    print("replies: " + replies.toString());
  }

}