import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IosPhotos extends StatelessWidget {
  const IosPhotos({super.key});

  final List<String> _images = const [
    'assets/img/ios/iphone.webp',
    'assets/img/windows/windows-Light.jpg',
    'assets/img/windows/icons/computer.png',
    'assets/img/windows/icons/network.png',
    'assets/img/windows/icons/explorer.png',
    'assets/img/windows/icons/folder.png',
    'assets/img/windows/icons/github.png',
    'assets/img/windows/icons/linkedin.png',
    'assets/img/windows/icons/adobe.png',
    'assets/img/windows/icons/macos.png',
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text("Photos")),
      child: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 1.0,
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Open full screen view? For now just simple box
              },
              child: Container(
                color: Colors.grey[300],
                child: Image.asset(
                  _images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      const Center(child: Icon(Icons.error)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
