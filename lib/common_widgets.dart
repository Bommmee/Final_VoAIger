import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../landmarks_page.dart'; // 폴더 구조에 따라 경로를 수정했습니다.

Widget buildLandmarkList(BuildContext context,
    List<Map<String, dynamic>> landmarksData, Position currentPosition) {
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: landmarksData.length,
    itemBuilder: (context, index) {
      final landmark = landmarksData[index];
      final distance =
          '${(Geolocator.distanceBetween(currentPosition.latitude, currentPosition.longitude, landmark['latitude'], landmark['longitude']) / 10).round() * 10}m';
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => LandmarksPage(
                landmarkName: landmark['name'],
                description: landmark['description'],
                landmarksData: landmarksData, // 추가된 부분
                currentPosition: currentPosition, // 추가된 부분
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(landmark['name']),
              Text(
                distance,
                style: TextStyle(color: CupertinoColors.systemGrey),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget buildGifWithText(String landmarkName) {
  return Stack(
    alignment: Alignment.bottomCenter,
    children: [
      Image.asset(
        'assets/gifs/icon.gif',
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      ),
      Positioned(
        bottom: -5,
        child: Text(
          landmarkName,
          style: TextStyle(
            color: Color(0xFF7E59CC),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}
