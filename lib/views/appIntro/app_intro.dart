import 'package:event_ease/views/authentication_view/owner_login.dart';
import 'package:flutter/material.dart';
import 'package:event_ease/views/appIntro/first_page.dart';
import 'package:event_ease/views/appIntro/fifth_page.dart';
import 'package:event_ease/views/appIntro/fourth_page.dart';
import 'package:event_ease/views/appIntro/second_page.dart';
import 'package:event_ease/views/appIntro/sixth_page.dart';
import 'package:event_ease/views/appIntro/third_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AppIntro extends StatefulWidget {
  const AppIntro({super.key});

  @override
  State<AppIntro> createState() => _AppIntroState();
}

class _AppIntroState extends State<AppIntro> {
  final PageController _controller = PageController();

  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(
                () {
                  isLastPage = (index == 5);
                },
              );
            },
            children: const [
              FirstPage(),
              SecondPage(),
              ThirdPage(),
              FourthPage(),
              FifthPage(),
              SixthPage(),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.90),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(5);
                  },
                  child: const Text('skip'),
                ),
                SmoothPageIndicator(controller: _controller, count: 6),
                isLastPage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return OwnerLoginScreen();
                              },
                            ),
                          );
                        },
                        child: const Text('done'),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        },
                        child: const Text('next'),
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}
