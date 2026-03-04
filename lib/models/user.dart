class User {
  final String? name, uid, image, email, youtube, facebook, twitter, instagram;

  User({
    this.name,
    this.uid,
    this.image,
    this.email,
    this.youtube,
    this.facebook,
    this.twitter,
    this.instagram,
  });

  // Create User from row data
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      name: data["name"] as String?,
      uid: data["uid"] as String?,
      image: data["image"] as String?,
      email: data["email"] as String?,
      youtube: data["youtube"] as String?,
      facebook: data["facebook"] as String?,
      twitter: data["twitter"] as String?,
      instagram: data["instagram"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "uid": uid,
        "image": image,
        "email": email,
        "youtube": youtube,
        "facebook": facebook,
        "twitter": twitter,
        "instagram": instagram,
      };
}