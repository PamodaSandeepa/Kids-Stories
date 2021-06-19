//import 'package:storyreader/model/chapters.dart';

class Story {
  String name, image;
  List<String> pages;

  Story({this.pages, this.image, this.name});

  Story.fromJson(Map<String, dynamic> json) {
    //  category = json['Category'];
    if (json['Pages'] != null) {
      pages = json['Pages'].cast<String>();
    }
    image = json['Image'];
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Pages'] = this.pages;
    /* if(this.pages!=null){
      data['Pages'] = this.pages.map((v)=>v.toJson()).toList();
    }  */
    data['Image'] = this.image;
    data['Name'] = this.name;
    return data;
  }
}
