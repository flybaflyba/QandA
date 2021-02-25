import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:qanda/pages/MenuPage.dart';


class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void onIntroEnd(context) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MenuPage()),
    );
  }

  Widget buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/images/$assetName.png', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.lightBlue,
      imagePadding: EdgeInsets.only(top: 70),
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "\n\nAcademic Posts",
          body:
          "Find an answer when you questions about a class.",
          image: buildImage('intro_academic'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "\n\nCampus Life Posts",
          body:
          "See what is going on on campus.",
          image: buildImage('intro_campus_life'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "\n\nPost Something",
          body:
          "Share your life, or ask a question.",
          image: buildImage('intro_post'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "\n\nLarge Image View",
          body: "View an image in large scale, support zoom in and out!",
          image: buildImage('intro_large'),
          // footer: RaisedButton(
          //   onPressed: () {
          //     introKey.currentState?.animateScroll(0);
          //   },
          //   child: const Text(
          //     'FooButton',
          //     style: TextStyle(color: Colors.white),
          //   ),
          //   color: Colors.lightBlue,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(8.0),
          //   ),
          // ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "\n\nYour Home Page",
          body: "Update your profile, and view the posts you made",
          image: buildImage('intro_home'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeColor: Colors.black,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
