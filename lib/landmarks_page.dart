import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'common_widgets.dart';
import 'package:geolocator/geolocator.dart';

const apiKey = 'api';

class LandmarksPage extends StatefulWidget {
  final String landmarkName;
  final String description;
  final List<Map<String, dynamic>> landmarksData;
  final Position currentPosition;

  const LandmarksPage({
    Key? key,
    required this.landmarkName,
    required this.description,
    required this.landmarksData,
    required this.currentPosition,
  }) : super(key: key);

  @override
  _LandmarksPageState createState() => _LandmarksPageState();
}

class _LandmarksPageState extends State<LandmarksPage> {
  TextEditingController _textController = TextEditingController();
  bool _isSending = false;
  List<String> _messages = [];
  late GenerativeModel model;
  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initializeModel();
  }

  void initializeModel() {
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing image')),
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
                child: buildGifWithText(widget.landmarkName),
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
                  color: Colors.black87,
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
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Scrollbar(
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              buildLandmarkList(
                  context, widget.landmarksData, widget.currentPosition),
            ],
          ),
        ),
      ),
    );
  }
}
