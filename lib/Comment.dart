

class Comment {
  var content = "";
  var time = "";
  var by = "";

  Comment({
    var content,
    var time,
    var by,
  }){
    if(content != null){ this.content = content; }
    if(time != null){ this.time = time; }
    if(by != null){ this.by = by; }
  }

}