
//import 'package:flutter_riverpod/all.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storyreader/model/story.dart';

final storySelected = StateProvider((ref) => Story());
final isSearch = StateProvider((ref)=>false);
