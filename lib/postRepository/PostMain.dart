import 'dart:convert';

PostMain moviesMainFromJson(String str) => PostMain.fromJson(json.decode(str));

String moviesMainToJson(PostMain data) => json.encode(data.toJson());

class PostMain {
  PostMain({
    this.movies,
  });

  List<Post>? movies;

  factory PostMain.fromJson(Map<String, dynamic> json) => PostMain(
    movies: json["movies"] == null ? null : List<Post>.from(json["movies"].map((x) => Post.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "movies": movies == null ? null : List<dynamic>.from(movies!.map((x) => x.toJson())),
  };
}

class Post {
  Post({
    this.id,
    this.userImage,
    this.location,
    this.userName,
    this.genres,
    this.ratings,
    this.videoUrl,
    this.content,
    this.likes,
    this.timestamp,
    this.caption,
    // this.originalTitle,
    this.storyline,
    this.comments,
    this.imdbRating,
    this.posterurl,
  });

  String? id;
  String? userImage;
  String? location;
  String? userName;
  List<String>? genres;
  List<int>? ratings;
  String? videoUrl='';
  String? content;
  List<String>? likes=[];
  String? timestamp;
  String? caption;
  // OriginalTitle? originalTitle;
  String? storyline;
  List<String>? comments;
  dynamic imdbRating;
  String? posterurl;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json["id"] == null ? null : json["id"],
  /*  title: json["title"] == null ? null : json["title"],
    year: json["year"] == null ? null : json["year"],
    genres: json["genres"] == null ? null : List<String>.from(json["genres"].map((x) => x)),
    ratings: json["ratings"] == null ? null : List<int>.from(json["ratings"].map((x) => x)),
    poster: json["poster"] == null ? null : json["poster"],
    content: json["contentRating"] == null ? null : json["contentRating"],
    duration: json["duration"] == null ? null : json["duration"],
    releaseDate: json["releaseDate"] == null ? null : json["releaseDate"],
    averageRating: json["averageRating"] == null ? null : json["averageRating"],
    // originalTitle: json["originalTitle"] == null ? null : originalTitleValues.map[json["originalTitle"]],
    storyline: json["storyline"] == null ? null : json["storyline"],
    actors: json["actors"] == null ? null : List<String>.from(json["actors"].map((x) => x)),
    imdbRating: json["imdbRating"],
    posterurl: json["posterurl"] == null ? null : json["posterurl"],*/
  );

  Map<String, dynamic> toJson() => {
   /* "id": id == null ? null : id,
    "title": title == null ? null : title,
    "year": year == null ? null : year,
    "genres": genres == null ? null : List<dynamic>.from(genres!.map((x) => x)),
    "ratings": ratings == null ? null : List<dynamic>.from(ratings!.map((x) => x)),
    "poster": poster == null ? null : poster,
    "contentRating": contentRating == null ? null : contentRating,
    "duration": duration == null ? null : duration,
    "releaseDate": releaseDate == null ? null : releaseDate,
    "averageRating": averageRating == null ? null : averageRating,
    // "originalTitle": originalTitle == null ? null : originalTitleValues.reverse[originalTitle],
    "storyline": storyline == null ? null : storyline,
    "actors": actors == null ? null : List<dynamic>.from(actors!.map((x) => x)),
    "imdbRating": imdbRating,
    "posterurl": posterurl == null ? null : posterurl,*/
  };
}

// enum OriginalTitle { EMPTY, ANNIHILATION, A_WRINKLE_IN_TIME, THE_LEISURE_SEEKER, CE_QUI_NOUS_LIE }

/*final originalTitleValues = EnumValues({
  "Annihilation": OriginalTitle.ANNIHILATION,
  "A Wrinkle in Time": OriginalTitle.A_WRINKLE_IN_TIME,
  "Ce qui nous lie": OriginalTitle.CE_QUI_NOUS_LIE,
  "": OriginalTitle.EMPTY,
  "The Leisure Seeker": OriginalTitle.THE_LEISURE_SEEKER
});*/

class EnumValues<T> {
  late Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}