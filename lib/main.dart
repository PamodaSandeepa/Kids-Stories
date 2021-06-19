import 'dart:convert';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storyreader/model/story.dart';
import 'package:storyreader/screens/story_screen.dart';
import 'package:storyreader/state/state_manager.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  FirebaseApp app;
  MyApp({this.app});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      routes: {'/stories': (context) => StoryScreen()},
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AnimatedSplashScreen(
        splashIconSize: 100000,
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.black,
        splash: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
          child: Image.asset(
            'assets/story.jpg',
            fit: BoxFit.cover,
          ),
        ),
        nextScreen: MyHomePage(
          title: 'Story Reader',
          app: app,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.app}) : super(key: key);

  final FirebaseApp app;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference _bannerRef, _storyRef;
  List<Story> listStoryFromFirebase = new List<Story>();

  void initState() {
    super.initState();
    final FirebaseDatabase _database = FirebaseDatabase(app: widget.app);
    _bannerRef = _database.reference().child('Banners');
    _storyRef = _database.reference().child('Comic');
  }

  Future<List<String>> getBanners(DatabaseReference bannerRef) {
    return bannerRef
        .once()
        .then((snapshot) => snapshot.value.cast<String>().toList());
  }

  Future<List<dynamic>> getStory(DatabaseReference storyRef) {
    return storyRef.once().then((snapshot) => snapshot.value);
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
  }

  int _current = 0;

  Future<List<Story>> searchStory(String searchString) async {
    return listStoryFromFirebase
        .where((comic) =>
            comic.name.toLowerCase().contains(searchString.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, _) {
        var searchEnable = watch(isSearch).state;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            title: searchEnable
                ? TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                        decoration: InputDecoration(
                            hintText: 'Story Name',
                            hintStyle: TextStyle(color: Colors.white60)),
                        autofocus: false,
                        style: DefaultTextStyle.of(context).style.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 18,
                            color: Colors.white)),
                    suggestionsCallback: (searchString) async {
                      return await searchStory(searchString);
                    },
                    itemBuilder: (context, story) {
                      return ListTile(
                        leading: Image.network(story.image),
                        title: Text('${story.name}'),
                      );
                    },
                    onSuggestionSelected: (story) {
                      context.read(storySelected).state = story;
                      Navigator.pushNamed(context, '/stories');
                    },
                  )
                : Center(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
            actions: [
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => context.read(isSearch).state =
                      !context.read(isSearch).state)
            ],
          ),
          body: FutureBuilder<List<String>>(
            future: getBanners(_bannerRef),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /*    SizedBox(
                      height: 200.0,
                      width: 400.0,
                      child: Carousel(
                        images: [],
                        dotSize: 4.0,
                        dotSpacing: 15.0,
                        dotColor: Colors.lightGreenAccent,
                        indicatorBgPadding: 5.0,
                        dotBgColor: Colors.purple.withOpacity(0.5),
                        borderRadius: true,
                      )),  */
                      CarouselSlider(
                          items: snapshot.data
                              .map((e) => Builder(
                                    builder: (context) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            image: DecorationImage(
                                              image: NetworkImage(e),
                                              fit: BoxFit.fill,
                                            )),
                                      );
                                    },
                                  ))
                              .toList(),
                          options: CarouselOptions(
                            autoPlay: true,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            aspectRatio: 16 / 9,
                            reverse: false,
                            viewportFraction: 1,
                            initialPage: 0,

                            // height: MediaQuery.of(context).size.height/3,
                          )),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              color: Colors.blueAccent,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  'New Stories',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.black,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(''),
                                ),
                              ))
                        ],
                      ),
                      FutureBuilder(
                        future: getStory(_storyRef),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.hasError)
                            return Center(
                              child: Text('${snapshot.error}'),
                            );
                          else if (snapshot.hasData) {
                            //    List<Comic> comics
                            listStoryFromFirebase = new List<Story>();
                            snapshot.data.forEach((item) {
                              var story = Story.fromJson(
                                  json.decode(json.encode(item)));
                              listStoryFromFirebase.add(story);
                            });

                            return Expanded(
                                child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              padding: const EdgeInsets.all(6.0),
                              mainAxisSpacing: 2.0,
                              crossAxisSpacing: 2.0,
                              children: listStoryFromFirebase.map((story) {
                                return GestureDetector(
                                  onTap: () {
                                    context.read(storySelected).state = story;
                                    Navigator.pushNamed(context, "/stories");
                                    /*   Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return ChapterScreen();
                                }));  */
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    elevation: 12,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(story.image,
                                            fit: BoxFit.contain),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              color: Color(0xAA434343),
                                              padding: EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${story.name}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ));
                          }
                          return CircularProgressIndicator();
                        },
                      )
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}
