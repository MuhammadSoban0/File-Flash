import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:photo_view/photo_view.dart';
class ImageView extends StatefulWidget {
  final String tag;
  final String path;
  const ImageView({super.key,required this.tag,required this.path});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return  Hero(
      tag: widget.tag,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(onPressed: (){
                    Navigator.of(context).pop();
                  }, icon: Icon(Icons.close,
                    color: Colors.white,))),
              Expanded(
                child: PhotoView(
                  imageProvider: FileImage(File(widget.path)),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
