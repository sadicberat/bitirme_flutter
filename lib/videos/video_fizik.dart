import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_app_bar.dart';

class VideoFizikPage extends StatefulWidget {
  @override
  _VideoFizikPageState createState() => _VideoFizikPageState();
}

class _VideoFizikPageState extends State<VideoFizikPage> {
  final List<Map<String, dynamic>> videos = [
    {
      'thumbnail': 'assets/images/video1.jpg',
      'url': 'https://youtu.be/dwyenQSkWn4?list=PL5kIOunpmSBON_uyufuL2PLVOcVOyzYCl',
    },
    {
      'thumbnail': 'assets/images/video2.jpg',
      'url': 'https://youtu.be/kyatx8VArUg?list=PL5kIOunpmSBON_uyufuL2PLVOcVOyzYCl',
    },
    // Diğer videolar...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Fizik Videoları'),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(videos[index]['thumbnail']),
            title: Text('Video ${index + 1}'),
            trailing: ElevatedButton(
              child: Text('İzle'),
              onPressed: () {
                //launchUrl(videos[index]['url']);
                launchUrl(Uri.parse(videos[index]['url']));
              },
            ),
          );
        },
      ),
    );
  }
}