import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:storyreader/state/state_manager.dart';

class StoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      var comic = watch(storySelected).state;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Center(
            child: Text(
              '${comic.name}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: Center(
          child: (comic.pages == null || comic.pages.length == 0)
              ? Text("This story is translating...")
              : CarouselSlider(
                  items: comic.pages
                      .map((e) => Builder(
                            builder: (context) {
                              return Image.network(
                                e,
                                fit: BoxFit.fitWidth,
                              );
                            },
                          ))
                      .toList(),
                  options: CarouselOptions(
                    aspectRatio: 16 / 9,
                    autoPlay: false,
                    height: MediaQuery.of(context).size.height / 1.8,
                    enlargeCenterPage: false,
                    viewportFraction: 1,
                    initialPage: 0,
                  ),
                ),
        ),
        /* body:comic.chapters != null && comic.chapters.length>0? Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: comic.chapters.length,
              itemBuilder: (context,index) {
                return GestureDetector(onTap: () {},
                  child: Column(
                    children: [
                      ListTile(title: Text('${comic.chapters[index].name}'),),
                      Divider(thickness: 1,)
                    ],
                  ),
                );
              }
             )
        ): Center(child: Text('We are translating this comic'),)  */
      );
    });
  }
}
