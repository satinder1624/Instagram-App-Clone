import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget cachedNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    // context, url we have to pass and we did not need them as well
    placeholder: (context,url) => Padding(child: CircularProgressIndicator(), padding: EdgeInsets.all(20.0)),
    // If image has error
    errorWidget: (context,url,error)=> Icon(Icons.error),
  );
}
