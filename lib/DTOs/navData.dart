enum Navdata {rolePage,gamingPage,wonPage,lobby;
String toJson()=>name;
factory Navdata.fromJson(String json){
  return Navdata.values.firstWhere((e)=>e.name==json,orElse: () => Navdata.rolePage,);
}

}