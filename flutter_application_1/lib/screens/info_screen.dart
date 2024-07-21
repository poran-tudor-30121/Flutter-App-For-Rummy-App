import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class InfoScreen extends StatelessWidget {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildPage(
                  ['assets/ps_screen_1.jpg'],
                  'After pushing the "Start Game" button you will enter the Player Selection Screen.',
                  context,
                ),
                _buildPage(
                  ['assets/ps_screen_2.jpg', 'assets/ps_screen_3.jpg'],
                  'Here please choose the number of players, complete your names and your position at the table. The left, right, top orientations are based on the person who is taking the pictures (the person taking them should assign itself at the bottom).',
                  context,
                ),
                _buildPage(
                  ['assets/pi_screen.jpg', 'assets/pi_screen2.jpg'],
                  'Pick or take a picture of the whole table.',
                  context,
                ),
                _buildPage(
                  ['assets/pu_screen_2.jpg'],
                  'Make sure every piece is visible. Have at least one formation with only 3 tiles. If you attached tiles for bonus points make sure to put them in the picture as a formation. Keep a small space between each formation and make sure each players formations are far enough from each other.',
                  context,
                ),
                _buildPage(
                  ['assets/pi_screen_4.jpg'],
                  'Before uploading the picture make sure to choose the Winning Round Bonus according to the rules you are following. Once you set the wanted value press "Upload Image".',
                  context,
                ),
                _buildPage(
                  ['assets/pu_screen_3.jpg'],
                  'After getting the initial results, you will be able to check your detected tiles and check your bonuses. (ATU, Won Round, X2, X4). The score will update instantly.',
                  context,
                ),
                _buildPage(
                  ['assets/pu_screen_4.jpg', 'assets/pu_screen_6.jpg'],
                  'After setting up your bonuses make sure to verify the tiles and edit if some of them were not correctly identified. If you want to change a tile into a Jolly just write "Jolly".',
                  context,
                ),
                _buildPage(
                  ['assets/pu_screen_3.jpg'],
                  'If, for any reason, you want to discard the results of this round, click the "Retry" button and upload an image again.',
                  context,
                ),
                _buildPage(
                  ['assets/pu_screen_1.jpg'],
                  'If the app was not even close to process your tiles and score, press the pen icon and you will be able to manually introduce your score for this round.',
                  context,
                ),
                _buildPage(
                  ['assets/pu_screen_7.jpg'],
                  'Repeat the process by uploading the next picture of your new round. The score will update accordingly.',
                  context,
                ),
                _buildPage(
                  ['assets/endscreen1.jpg', 'assets/endscreen2.jpg'],
                  'When you have had enough Rumy for today, press the "End Game" button.',
                  context,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 11,
              effect: WormEffect(
                dotHeight: 12,
                dotWidth: 12,
                activeDotColor: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(List<String> imagePaths, String text, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imagePaths
                .map(
                  (path) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullscreenImageGallery(imagePaths: imagePaths),
                          ),
                        );
                      },
                      child: Image.asset(path),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class FullscreenImageGallery extends StatelessWidget {
  final List<String> imagePaths;

  FullscreenImageGallery({required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info'),
      ),
      body: PhotoViewGallery.builder(
        itemCount: imagePaths.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: AssetImage(imagePaths[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(),
      ),
    );
  }
}
