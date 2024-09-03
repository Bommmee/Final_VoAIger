import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'spot_page.dart';

class SeoulPage extends StatefulWidget {
  @override
  _SeoulPageState createState() => _SeoulPageState();
}

class _SeoulPageState extends State<SeoulPage> {
  List<String> _selectedCategories = [];
  final List<String> _categoryOptions = ['역사', '문화', '예술', '식당', '쇼핑', '체험'];
  final Color brandLightBlue = Color(0xFF219de7); // 브랜드 하늘색 컬러

  Future<void> _navigateToNearestLandmark() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => SpotPage(
          currentLatitude: position.latitude,
          currentLongitude: position.longitude,
          selectedCategories: _selectedCategories,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('서울'),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                // 버튼을 중앙에 배치
                child: CupertinoButton(
                  color: brandLightBlue, // 하늘색 브랜드컬러 적용
                  onPressed: _navigateToNearestLandmark,
                  child: Text('랜드마크 둘러보기'),
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.pexels.com/photos/26173418/pexels-photo-26173418.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '서울, 한국은 역사와 현대가 공존하는 활기찬 도시입니다. 경복궁 같은 웅장한 궁전을 탐방하고, 남대문과 같은 전통 시장을 거닐며, 강남과 같은 트렌디한 지역에서 쇼핑을 즐길 수 있습니다. 인사동에서 한국 문화를 체험하며, 미술관과 찻집을 방문해보세요. 자연을 사랑하는 이들은 북한산의 아름다운 등산로를 오르거나 한강의 풍경을 즐길 수 있습니다. 다채로운 K-팝 씬과 풍부한 미식 경험을 제공하는 서울은 전통과 현대적 매력을 모두 찾는 이들에게 필수 방문지로 추천할 만합니다',
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
              SizedBox(height: 16),
              Text(
                '카테고리 선택:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categoryOptions.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: CupertinoButton(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        minSize: 36.0,
                        color: _selectedCategories.contains(category)
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey4,
                        onPressed: () {
                          setState(() {
                            if (_selectedCategories.contains(category)) {
                              _selectedCategories.remove(category);
                            } else {
                              _selectedCategories.add(category);
                            }
                          });
                        },
                        child: Text(
                          category,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
