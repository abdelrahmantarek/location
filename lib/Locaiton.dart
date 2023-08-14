

class Location{

  final double latitude;
  final double longitude;

  Location({this.latitude = 0.0, this.longitude = 0.0});

  factory Location.fromJson(Map<String,dynamic> json){
    return Location(
      latitude: json["lat"],
      longitude: json["lng"],
    );
  }

  factory Location.fromList(List<dynamic> json){
    return Location(
      latitude: json[0],
      longitude: json[1],
    );
  }

  Map<String,dynamic> toJson(){
    Map<String,dynamic> data = {};
    data["lat"] = latitude;
    data["lng"] = longitude;
    return data;
  }

  bool get isNull{
    return latitude == 0.0 && longitude == 0.0;
  }

}