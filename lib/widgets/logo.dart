import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Logo extends StatelessWidget {
  final EdgeInsets padding;
  final double height;
  final double width;
  const Logo({
    super.key,
    this.padding = const .all(0),
    this.height = 25.0,
    this.width = 25.0,
  });
  static final String logoName = 'assets/images/se2.svg';
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: SvgPicture.asset(
        logoName,
        semanticsLabel: 'SE2 Logo',
        width: width,
        height: height,
      ),
    );
  }
}
