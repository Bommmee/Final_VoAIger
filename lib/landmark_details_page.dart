import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class LandmarkDetailsPage extends StatefulWidget {
  final String landmarkName;
  final String description;
  final List<Map<String, dynamic>> landmarksData;
  final Position currentPosition;

  const LandmarkDetailsPage({
    Key? key,
    required this.landmarkName,
    required this.description,
    required this.landmarksData,
    required this.currentPosition,
  }) : super(key: key);

  @override
  _LandmarkDetailsPageState createState() => _LandmarkDetailsPageState();
}

class _LandmarkDetailsPageState extends State<LandmarkDetailsPage> {
  GlobalKey _globalKey = GlobalKey();
  late GenerativeModel model;

  List<String> _messages = [];
  TextEditingController _textController = TextEditingController();
  bool _isSending = false;

  List<Map<String, dynamic>> closestLandmarks = [];

  @override
  void initState() {
    super.initState();
    initializeModel();
    _sortLandmarksByDistance();
  }

  void initializeModel() {
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: 'api',
    );
  }

  void _sortLandmarksByDistance() {
    List<Map<String, dynamic>> sortedLandmarks =
        List.from(widget.landmarksData);
    sortedLandmarks.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(
          widget.currentPosition.latitude,
          widget.currentPosition.longitude,
          a['latitude'],
          a['longitude']);
      double distanceB = Geolocator.distanceBetween(
          widget.currentPosition.latitude,
          widget.currentPosition.longitude,
          b['latitude'],
          b['longitude']);
      return distanceA.compareTo(distanceB);
    });

    // 현재 보고 있는 랜드마크를 제외한 가장 가까운 3개의 랜드마크 선택
    closestLandmarks = sortedLandmarks
        .where((landmark) => landmark['name'] != widget.landmarkName)
        .take(3)
        .toList();
  }

  Future<void> _shareMergedImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final directory = (await getTemporaryDirectory()).path;
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final filePath = '$directory/${widget.landmarkName}_shared.png';
      File imgFile = File(filePath);
      await imgFile.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(imgFile.path)],
        text: 'Check out this landmark: ${widget.landmarkName}',
        subject: widget.landmarkName,
      );
    } catch (e) {
      print('Error sharing image: $e');
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Error'),
            content: Text('Error sharing image'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.landmarkName),
        previousPageTitle: 'Back',
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.share),
          onPressed: _shareMergedImage,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepaintBoundary(
                key: _globalKey,
                child: GifWithText(landmarkName: widget.landmarkName),
              ),
              SizedBox(height: 16),
              Text(
                widget.landmarkName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                widget.description,
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.black,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '자주 묻는 질문',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('• ${widget.landmarkName} 입장료는 얼마인가요?'),
              Text('• ${widget.landmarkName} 운영시간은 언제인가요?'),
              SizedBox(height: 16),
              Text(
                '채팅 기록',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoScrollbar(
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(_messages[index]),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              CupertinoTextField(
                controller: _textController,
                placeholder: 'Ask something...',
                onSubmitted: _isSending ? null : (value) => _sendMessage(value),
              ),
              SizedBox(height: 8),
              CupertinoButton.filled(
                onPressed: _isSending
                    ? null
                    : () => _sendMessage(_textController.text),
                child: Text('Send'),
              ),
              SizedBox(height: 20),
              Text(
                '가까운 랜드마크',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                children: closestLandmarks.map((landmark) {
                  final distance = _calculateDistance(
                      landmark['latitude'], landmark['longitude']);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => LandmarkDetailsPage(
                            landmarkName: landmark['name'],
                            description: landmark['description'],
                            landmarksData: widget.landmarksData,
                            currentPosition: widget.currentPosition,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              landmark['name'],
                              style: TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.black,
                              ),
                            ),
                          ),
                          Text(
                            distance,
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    String modifiedMessage = '${widget.landmarkName}에 대한 질문입니다: $message';

    setState(() {
      _isSending = true;
      _messages.add('User: $message');
    });

    try {
      final content = [Content.text(modifiedMessage)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.add('Gemini: ${response.text ?? 'No response from Gemini'}');
        _isSending = false;
      });
    } catch (e) {
      setState(() {
        _messages.add('Error: Unable to get a response.');
        _isSending = false;
      });
    }

    _textController.clear();
  }

  String _calculateDistance(double lat, double lon) {
    double distance = Geolocator.distanceBetween(
        widget.currentPosition.latitude,
        widget.currentPosition.longitude,
        lat,
        lon);
    return '${(distance / 10).round() * 10}m'; // 10미터 단위로 반올림
  }
}

class GifWithText extends StatelessWidget {
  final String landmarkName;

  const GifWithText({required this.landmarkName});

  @override
  Widget build(BuildContext context) {
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
}
