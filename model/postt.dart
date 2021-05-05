class Poster{
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Poster(this.postId, this.ownerId, this.username, this.location, this.description, this.mediaUrl, this.likes);

  factory Poster.fromDocument(doc)=> Poster(doc['postId'],doc['ownerId'],doc['username'],doc['location'],doc['description'],doc['mediaUrl'],doc['likes']);

}