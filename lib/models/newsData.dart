class NewsData {
  int? id;
  String? picture;
  String? date;
  String? time;
  NewsData(this.picture,this.date,this.time);
  NewsData.withId(this.id, this.picture,this.date,this.time);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'picture': picture,
      'date': date,
      'time': time
    };
    return map;
  }

  NewsData.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    picture = map['picture'];
    date = map['date'];
    time = map['time'];
  }

  @override
  String toString() {
    return 'NewsData{id: $id, picture: $picture, date: $date, time: $time}';
  }
}