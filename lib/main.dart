import 'package:flutter/cupertino.dart';
import 'seoul_page.dart';

void main() {
  runApp(CityExplorerApp());
}

class CityExplorerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
      ),
      home: CitySelectionPage(),
    );
  }
}

class CitySelectionPage extends StatelessWidget {
  final Color koreaColor = Color(0xFF219de7); // 대한민국 도시용 하늘색
  final Color europeColor = Color(0xFFf7b410); // 유럽 도시용 노란색

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('원하는 도시를 선택하기'),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'With AI Guide Anytime',
                    style:
                        CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                  ),
                  CupertinoButton(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    color: Color(0xFF014b88), // 브랜드 네이비 컬러
                    borderRadius: BorderRadius.circular(8.0),
                    child: Text(
                      '한/Eng',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12.0, // 폰트 크기 줄임
                      ),
                    ),
                    onPressed: () {
                      // 언어 전환 로직을 추가하려면 여기에 작성
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            _buildSectionTitle(context, '대한민국'),
            _buildCityGrid(context, ['서울', '부산', '인천', '제주도'], isKorea: true),
            SizedBox(height: 32),
            _buildSectionTitle(context, '유럽'),
            _buildCityGrid(context, ['파리', '런던', '바르셀로나', '로마'],
                isKorea: false),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
      ),
    );
  }

  Widget _buildCityGrid(BuildContext context, List<String> cities,
      {required bool isKorea}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: cities.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 2.5,
        ),
        itemBuilder: (context, index) {
          return CupertinoButton(
            color: isKorea ? koreaColor : europeColor,
            padding: EdgeInsets.all(16.0),
            borderRadius: BorderRadius.circular(12.0),
            onPressed: () {
              if (cities[index] == '서울') {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => SeoulPage(),
                  ),
                );
              } else {}
            },
            child: Text(
              cities[index],
              style: TextStyle(color: CupertinoColors.white),
            ),
          );
        },
      ),
    );
  }
}
