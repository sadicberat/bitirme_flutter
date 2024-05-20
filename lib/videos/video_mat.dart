import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_app_bar.dart';

class VideoMatPage extends StatefulWidget {
  const VideoMatPage({Key? key}) : super(key: key);

  @override
  _VideoMatPageState createState() => _VideoMatPageState();
}

class _VideoMatPageState extends State<VideoMatPage> {
  final List<Map<String, dynamic>> videos = [
    {
      'thumbnail': 'assets/images/video1.jpg',
      'url': 'https://youtu.be/MXL4jMnxbtk?list=PL5kIOunpmSBM0o91I0NrwdE8T0oXWDSng',
    },
    {
      'thumbnail': 'assets/images/video2.jpg',
      'url': 'https://youtu.be/NAI5TZGTwkU?list=PL5kIOunpmSBM0o91I0NrwdE8T0oXWDSng',
    },
    // Diğer videolar...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CustomAppBar(title: 'matematik Videoları'),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(videos[index]['thumbnail']),
            title: Text('Video ${index + 1}'),
            trailing: ElevatedButton(
              child: Text('İzle'),
              onPressed: () {
                launch(videos[index]['url']);
              },
            ),
          );
        },
      ),
    );
  }
}