import 'package:drug_discovery/features/feed/feed_screen.dart';
import 'package:drug_discovery/features/gpt/screens/gpt_screen.dart';
import 'package:drug_discovery/features/posts/screens/add_post_screen.dart';
import 'package:flutter/material.dart';

class Constants {
  static const logoPath = 'assets/images/logo.png';
  static const loginEmotePath = 'assets/images/loginEmote.png';
  static const googlePath = 'assets/images/google.png';

  static const bannerDefault =
      'https://thumbs.dreamstime.com/b/abstract-stained-pattern-rectangle-background-blue-sky-over-fiery-red-orange-color-modern-painting-art-watercolor-effe-texture-123047399.jpg';

  static const avatarDefault =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Font_Awesome_5_solid_user-astronaut.svg/768px-Font_Awesome_5_solid_user-astronaut.svg.png?20180810222530';

  static const tabWidgetss = [
    FeedScreen(),
    GptScreen(),
    AddPostScreen(),
  ];

  static const IconData up =
      IconData(0xe800, fontFamily: 'MyFlutterApp', fontPackage: null);
  static const IconData down =
      IconData(0xe801, fontFamily: 'MyFlutterApp', fontPackage: null);

  static const awardsPath = 'assets/images/awards';

  static const awards = {
    'awesomeAns': '${Constants.awardsPath}/awesomeanswer.png',
    'gold': '${Constants.awardsPath}/gold.png',
    'platinum': '${Constants.awardsPath}/platinum.png',
    'helpful': '${Constants.awardsPath}/helpful.png',
    'plusone': '${Constants.awardsPath}/plusone.png',
    'rocket': '${Constants.awardsPath}/rocket.png',
    'thankyou': '${Constants.awardsPath}/thankyou.png',
    'til': '${Constants.awardsPath}/til.png',
  };
}
