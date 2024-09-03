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
        middle: Text('Seoul'),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoButton(
                color: CupertinoColors.systemGrey4,
                onPressed: _navigateToNearestLandmark,
                child: Text('Explore the Landmarks'),
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
                'Seoul, Korea, is a vibrant city where history and modernity coexist. Explore grand palaces like Gyeongbokgung, stroll through traditional markets like Namdaemun, and shop in trendy districts like Gangnam. Immerse yourself in Korean culture in Insadong, home to art galleries and tea houses. Nature lovers can hike Bukhansan\'s scenic trails or enjoy the Han River’s beauty. With a dynamic K-pop scene and rich culinary offerings, Seoul offers a diverse travel experience that caters to all interests, making it a must-visit destination for those seeking both tradition and contemporary allure.',
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
              SizedBox(height: 16),
              Text(
                'Select Categories:',
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
