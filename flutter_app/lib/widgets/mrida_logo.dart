import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MridaLogo extends StatelessWidget {
  const MridaLogo({super.key, this.width = 220});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/branding/mrida_logo.svg',
      width: width,
    );
  }
}
