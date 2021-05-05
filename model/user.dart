
class Userr{
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  Userr(this.id, this.username, this.email, this.photoUrl, this.displayName, this.bio);

  // factory = static
  factory Userr.fromDocument(doc)=> Userr(doc['id'], doc['username'], doc['email'], doc['photoUrl'], doc['displayName'], doc['bio']);

}