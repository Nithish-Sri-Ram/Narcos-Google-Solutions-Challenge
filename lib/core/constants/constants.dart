import 'package:drug_discovery/features/feed/feed_screen.dart';
import 'package:drug_discovery/features/posts/screens/add_post_screen.dart';

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
    AddPostScreen(),
  ];
}
