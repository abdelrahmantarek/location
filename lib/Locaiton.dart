

class Location{
   double? lat;
   double? lng;

  Location(this.lat, this.lng);

  Location.fromJson(Map<String,dynamic> json){
    lat = json["lat"];
    lng = json["lng"];
  }
  Location.fromList(List<dynamic> json){
    lat = json[0];
    lng = json[1];
  }
  Map<String,dynamic> toJson(){
    Map<String,dynamic> data = {};
    data["lat"] = lat;
    data["lng"] = lng;
    return data;
  }
}