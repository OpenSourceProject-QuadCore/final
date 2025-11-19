import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

final WebViewController _controller=WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..enableZoom(false);

class RouteInfo {
  final String routeId;      // 노선 ID
  final String routeNo;      // 노선 번호 (예: 100번)
  final String routeTp;      // 노선 유형
  final String startStName;  // 기점 정류장 이름
  final String endStName;    // 종점 정류장 이름

  RouteInfo({
    required this.routeId,
    required this.routeNo,
    required this.routeTp,
    required this.startStName,
    required this.endStName,
  });

  // JSON 응답을 Dart 객체로 변환하는 팩토리 생성자
  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      routeId: json['routeid'] ?? 'N/A',
      routeNo: json['routeno']?.toString() ?? 'N/A',
      routeTp: json['routetp'] ?? 'N/A',
      startStName: json['startnodenm'] ?? 'N/A',
      endStName: json['endnodenm'] ?? 'N/A',
    );
  }
}

class StopInfo {
  final double gpslati;
  final double gpslong;
  final String nodeID;
  final String nodeName;  
  final String nodeNo;
  final int nodeOrd;
  final String routeID;

  StopInfo({
    required this.gpslati,
    required this.gpslong,
    required this.nodeID,
    required this.nodeName,
    required this.nodeNo,
    required this.nodeOrd,
    required this.routeID,
  });

  factory StopInfo.fromJson(Map<String, dynamic> json) {
    return StopInfo(
      gpslati: json['gpslati'] ?? -1.0,
      gpslong: json['gpslong'] ?? -1.0,
      nodeID: json['nodeid'] ?? 'N/A',
      nodeName: json['nodenm'] ?? 'N/A',
      nodeNo: json['nodeno']?.toString() ?? 'N/A',
      nodeOrd: json['nodeord'] ?? 'N/A',
      routeID: json['routeid'] ?? 'N/A',
    );
  }
}

class busposition {
  final String nodeID;
  final String nodeName;
  final int nodeOrd;
  final String routeTp;
  final String vehicleNo;

  busposition({
    required this.nodeID,
    required this.nodeName,
    required this.nodeOrd,
    required this.routeTp,
    required this.vehicleNo,
  });

  factory busposition.fromJson(Map<String, dynamic> json) {
    return busposition(
      nodeID: json['nodeid'] ?? 'N/A',
      nodeName: json['nodenm'] ?? 'N/A',
      nodeOrd: json['nodeord'] ?? -1,
      routeTp: json['routetp'] ?? 'N/A',
      vehicleNo: json['vehicleno'] ?? 'N/A',
    );
  }
}

class StoparriveInfo {
  final int arrprevstationcnt;      // 노선 ID
  final int arrtime;      // 노선 번호 (예: 100번)
  final String nodeID;      // 노선 유형
  final String nodeName;  // 기점 정류장 이름
  final String routeID;
  final String routeNo;
  final String routeTp;
  final String vehicleTp;

  StoparriveInfo({
    required this.arrprevstationcnt,
    required this.arrtime,
    required this.nodeID,
    required this.nodeName,
    required this.routeID,
    required this.routeNo,
    required this.routeTp,
    required this.vehicleTp,
  });

  factory StoparriveInfo.fromJson(Map<String, dynamic> json) {
    return StoparriveInfo(
      arrprevstationcnt: json['arrprevstationcnt'] ?? -1,
      arrtime: json['arrtime'] ?? -1,
      nodeID: json['nodeid'] ?? 'N/A',
      nodeName: json['nodenm'] ?? 'N/A',
      routeID: json['routeid'] ?? 'N/A',
      routeNo: json['routeno']?.toString() ?? 'N/A',
      routeTp: json['routetp'] ?? 'N/A',
      vehicleTp: json['vehicletp'] ?? 'N/A',
    );
  }
}
/*
class FirstStatefulPage extends StatefulWidget {
  const FirstStatefulPage({super.key});
  @override
  State<FirstStatefulPage> createState() => _FirstStatefulPageState();
}*/
class busRoutePage extends StatefulWidget {
  final String id,number;
  const busRoutePage({super.key, required this.id, required this.number});
  @override
  State<busRoutePage> createState() => _busRoutePage();
}

class _busRoutePage extends State<busRoutePage> {
  //final String id,number;
  static const String baseUrl = "https://apis.data.go.kr/1613000/BusRouteInfoInqireService/getRouteAcctoThrghSttnList?serviceKey=0e8d45a31b5844ea457426701ab25d0732b16b9074643572222e9c3deaa1547f&pageNo=1&numOfRows=100&_type=json&cityCode=37050&routeId=";
  static const String baseUrl1 = "https://apis.data.go.kr/1613000/BusLcInfoInqireService/getRouteAcctoBusLcList?serviceKey=0e8d45a31b5844ea457426701ab25d0732b16b9074643572222e9c3deaa1547f&pageNo=1&numOfRows=10&_type=json&cityCode=37050&routeId=";
  //const busRoutePage({super.key, required this.id, required this.number});

  Future<List<StopInfo>> getStops() async {
    try {
      //final id = this.id;
      // 2. HTTP GET 요청 실행
      //final response = await http.get(Uri.parse($baseUrl));
      final url = Uri.parse("$baseUrl${widget.id}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 3. 성공적인 응답 처리
        // 공공데이터포털 API는 보통 응답 시 인코딩을 명시해줍니다.
        // 대부분의 한글 데이터는 EUC-KR 인코딩이므로 변환이 필요할 수 있습니다.
        // UTF-8이 기본이지만, 응답 헤더를 확인하거나 API 가이드를 따라야 합니다.

        // * UTF-8로 가정하고 디코딩
        final String body = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(body);

        // API 응답 구조: jsonResponse['response']['body']['items']['item']
        // 데이터를 item 리스트까지 접근
        final items = jsonResponse['response']['body']['items']['item'] as List;
        final count = jsonResponse['response']['body']['totalCount'];

        // items 리스트를 RouteInfo 객체 리스트로 변환
        _controller.runJavaScript('resetPath()');
        for(int i=0;i<count;i++) {
          final locaResponse = jsonEncode({
            "gpslati": items[i]['gpslati'],
            "gpslong": items[i]['gpslong'],
          });
          _controller.runJavaScript('drawBusroute($locaResponse)');
        }
        return items.map((json) => StopInfo.fromJson(json)).toList();

      } else {
        // 5. 서버 오류 (예: 400 Bad Request, 403 Forbidden 등)
        throw Exception('API 요청 실패 (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      // 6. 네트워크 오류 (인터넷 연결 끊김 등)
      print('버스 노선 네트워크 요청 중 오류 발생: $e');
      throw Exception('데이터 로드 실패: $e');
    }
  }
  Future<List<busposition>> getlocations() async {
    try {
      //final id = this.id;
      // 2. HTTP GET 요청 실행
      //final response = await http.get(Uri.parse($baseUrl));
      final url = Uri.parse("$baseUrl1${widget.id}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 3. 성공적인 응답 처리
        // 공공데이터포털 API는 보통 응답 시 인코딩을 명시해줍니다.
        // 대부분의 한글 데이터는 EUC-KR 인코딩이므로 변환이 필요할 수 있습니다.
        // UTF-8이 기본이지만, 응답 헤더를 확인하거나 API 가이드를 따라야 합니다.

        // * UTF-8로 가정하고 디코딩
        final String body = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(body);

        // API 응답 구조: jsonResponse['response']['body']['items']['item']
        // 데이터를 item 리스트까지 접근
        late final List<dynamic> items;
        //late final List<StoparriveInfo> result;
        final count=jsonResponse['response']['body']['totalCount'];
        if(count==1) {
          items=[jsonResponse['response']['body']['items']['item']];
        }
        else if(count==0) {
          return [];
        }
        else {
          items = jsonResponse['response']['body']['items']['item'] as List;
        }
        // items 리스트를 RouteInfo 객체 리스트로 변환
        final List<busposition> result = items.map((json) => busposition.fromJson(json)).toList();
        return result;

      } else {
        // 5. 서버 오류 (예: 400 Bad Request, 403 Forbidden 등)
        throw Exception('API 요청 실패 (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      // 6. 네트워크 오류 (인터넷 연결 끊김 등)
      print('버스 위치 네트워크 요청 중 오류 발생: $e');
      throw Exception('데이터 로드 실패: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.number}'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(//<List<StopInfo>>(
        future: Future.wait([getStops(),getlocations()]),//getStops(), // 데이터 로드 함수 호출
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 중일 때
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // 오류 발생 시
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '오류 발생: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            // 데이터 수신 성공 시
            final List<StopInfo> stops = snapshot.data![0] as List<StopInfo>;
            final List<busposition> poses = snapshot.data![1] as List<busposition>;
            int poscount = poses.length;
            int posindex = 0;

            if (stops.isEmpty) {
              return const Center(child: Text('해당 버스의 노선정류장이 없습니다.'));
            }
            _controller.runJavaScript('resetlocas()');

            for(int i=0;i<poses.length;i++) {
              final locaResponse = jsonEncode({
                "lati": stops[poses[i].nodeOrd-1].gpslati,
                "long": stops[poses[i].nodeOrd-1].gpslong,
              });
              _controller.runJavaScript('markloca($locaResponse)');
            }

            // 노선 리스트를 ListView로 출력
            return ListView.builder(
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                Icon stopicon = Icon(Icons.circle, color: Colors.grey, size: 15);
                if(posindex < poscount) {
                  if (stop.nodeOrd == poses[posindex].nodeOrd) {
                    stopicon = Icon(Icons.directions_bus, color: Colors.blue);
                    posindex++;
                  }
                }
                return ListTile(
                  leading: stopicon,//const Icon(Icons.circle, color: Colors.grey, size: 15),
                  title: Text('${stop.nodeName}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${stop.nodeNo}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: (){
                    final selectstop = jsonEncode({
                      "lati": stop.gpslati,
                      "long": stop.gpslong,
                    });
                    _controller.runJavaScript('moveforvisibility($selectstop)');
                  },
                );
              },
            );
          }

          // 기본 반환 (발생할 일은 거의 없음)
          return const Center(child: Text('데이터를 찾을 수 없습니다.'));
        },
      ),
    );
  }
}
/*
class FirstStatefulPage extends StatefulWidget {
  const FirstStatefulPage({super.key});
  @override
  State<FirstStatefulPage> createState() => _FirstStatefulPageState();
}*/

class DetailPage extends StatefulWidget {
  final String id,name;
  const DetailPage({super.key, required this.id, required this.name});
  @override
  State<DetailPage> createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  //final String id,name;
  var st;
  static const String baseUrl = "https://apis.data.go.kr/1613000/BusSttnInfoInqireService/getSttnThrghRouteList?serviceKey=0e8d45a31b5844ea457426701ab25d0732b16b9074643572222e9c3deaa1547f&pageNo=1&numOfRows=150&_type=json&cityCode=37050&nodeid=";
  static const String baseUrl1 = "https://apis.data.go.kr/1613000/ArvlInfoInqireService/getSttnAcctoArvlPrearngeInfoList?serviceKey=0e8d45a31b5844ea457426701ab25d0732b16b9074643572222e9c3deaa1547f&pageNo=1&numOfRows=20&_type=json&cityCode=37050&nodeId=";
  //const DetailPage({super.key, required this.id, required this.name});
  /*
  var uriResponse = http.get(Uri.parse("https://apis.data.go.kr/1613000/BusSttnInfoInqireService/getSttnThrghRouteList?serviceKey=0e8d45a31b5844ea457426701ab25d0732b16b9074643572222e9c3deaa1547f&pageNo=1&numOfRows=50&_type=json&cityCode=37050&nodeid=GMB132"));

  var json = jsonDecode(uriResponse.body);*/
  Future<List<RouteInfo>> getStopRoutes() async {
    try {
      //final id = this.id;
      // 2. HTTP GET 요청 실행
      //final response = await http.get(Uri.parse($baseUrl));
      final url = Uri.parse("$baseUrl${widget.id}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 3. 성공적인 응답 처리
        // 공공데이터포털 API는 보통 응답 시 인코딩을 명시해줍니다.
        // 대부분의 한글 데이터는 EUC-KR 인코딩이므로 변환이 필요할 수 있습니다.
        // UTF-8이 기본이지만, 응답 헤더를 확인하거나 API 가이드를 따라야 합니다.

        // * UTF-8로 가정하고 디코딩
        final String body = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(body);

        // API 응답 구조: jsonResponse['response']['body']['items']['item']
        // 데이터를 item 리스트까지 접근
        final items = jsonResponse['response']['body']['items']['item'] as List;
        // items 리스트를 RouteInfo 객체 리스트로 변환
        return items.map((json) => RouteInfo.fromJson(json)).toList();

      } else {
        // 5. 서버 오류 (예: 400 Bad Request, 403 Forbidden 등)
        throw Exception('API 요청 실패 (Status Code: ${response.statusCode})');
      }

    } catch (e) {
      // 6. 네트워크 오류 (인터넷 연결 끊김 등)
      print('네트워크 요청 중 오류 발생: $e');
      throw Exception('데이터 로드 실패: $e');
    }
  }
  Future<List<StoparriveInfo>> getarriveInfos() async {
    try {
      // 2. HTTP GET 요청 실행
      final url = Uri.parse("$baseUrl1${widget.id}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 3. 성공적인 응답 처리
        // 공공데이터포털 API는 보통 응답 시 인코딩을 명시해줍니다.
        // 대부분의 한글 데이터는 EUC-KR 인코딩이므로 변환이 필요할 수 있습니다.
        // UTF-8이 기본이지만, 응답 헤더를 확인하거나 API 가이드를 따라야 합니다.

        // * UTF-8로 가정하고 디코딩
        final String body = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(body);

        // API 응답 구조: jsonResponse['response']['body']['items']['item']
        // 데이터를 item 리스트까지 접근
        late final List<dynamic> items;
        //late final List<StoparriveInfo> result;
        if(jsonResponse['response']['body']['totalCount']==1) {
          items=[jsonResponse['response']['body']['items']['item']];
        }
        else if(jsonResponse['response']['body']['totalCount']==0) {
          return [];
        }
        else {
          items = jsonResponse['response']['body']['items']['item'] as List;
        }
        //final items = jsonResponse['response']['body']['items']['item'] as List;
        // items 리스트를 RouteInfo 객체 리스트로 변환
        final List<StoparriveInfo> result = items.map((json) => StoparriveInfo.fromJson(json)).toList();
        return result;//items.map((json) => StoparriveInfo.fromJson(json)).toList();

      } else {
        // 5. 서버 오류 (예: 400 Bad Request, 403 Forbidden 등)
        throw Exception('API 요청 실패 (Status Code: ${response.statusCode})');
      }

    } catch (e) {
      // 6. 네트워크 오류 (인터넷 연결 끊김 등)
      print('도착 네트워크 요청 중 오류 발생: $e');
      throw Exception('데이터 로드 실패: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    st = Provider.of<Stackwid>(context,listen:false);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name}'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(//<List<RouteInfo>>(
        future: Future.wait([getStopRoutes(),getarriveInfos()]),//getStopRoutes(), // 데이터 로드 함수 호출
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 중일 때
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // 오류 발생 시
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '오류 발생: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            // 데이터 수신 성공 시
            final List<RouteInfo> routes = snapshot.data![0] as List<RouteInfo>;
            final List<StoparriveInfo> arrives = snapshot.data![1] as List<StoparriveInfo>;
            int arricount = arrives.length;
            if (routes.isEmpty) {
              return const Center(child: Text('해당 정류장을 경유하는 노선이 없습니다.'));
            }

            // 노선 리스트를 ListView로 출력
            return ListView.builder(
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                String arrtime='도착 예정 없음';
                TextStyle style = TextStyle(fontSize : 10);
                for(int i=0;i<arricount;i++) {
                  if(route.routeId==arrives[i].routeID) {
                    arrtime='${(arrives[i].arrtime/60).toInt()}분';
                    style = TextStyle(fontSize : 15, fontWeight: FontWeight.bold);
                    break;
                  }
                }
                return ListTile(
                  leading: const Icon(Icons.directions_bus, color: Colors.indigo),
                  title: Text('${route.routeNo}번 노선 (${route.routeTp})',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${route.endStName}방면'), //Text('기점: ${route.startStName} | 종점: ${route.endStName}'),
                  trailing: Text(arrtime,style : style),//const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Widget addw=Align(
                      // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: double.infinity,
                        child: busRoutePage(id: route.routeId, number: route.routeNo),
                      ),
                    );
                    st.updateStack(addw);
                  }
                );
              },
            );
          }

          // 기본 반환 (발생할 일은 거의 없음)
          return const Center(child: Text('데이터를 찾을 수 없습니다.'));
        },
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // KakaoMap API javascript 키 입력
  const kakaoJavascriptKey = "e945222623a72228f5a7ec826f1fa318";
  runApp(const MyApp(kakaoJavascriptKey: kakaoJavascriptKey));
}

class Stackwid extends ChangeNotifier {
  List<Widget> stacklist=[WebViewWidget(controller: _controller)];

  void resetStack() {
    stacklist=[WebViewWidget(controller: _controller)];
  }

  void updateStack(Widget add) {
    stacklist.add(add);
    stacklist.add(Positioned(
      left:6,
      bottom:355,
      child:
      Container(
        height: 30,
        width: 30,
        child: IconButton(//FloatingActionButton(
          onPressed:(){backStack();_controller.runJavaScript('resetPath()');_controller.runJavaScript('resetlocas()');},
          icon: Icon(Icons.arrow_back,color:Colors.grey),
          //backgroundColor: Colors.grey,
        ),
      ),
    ),);
    notifyListeners();
  }

  void backStack() {
    List<Widget> temp=[];
    for(int i=0;i<stacklist.length-2;i++) {
      temp.add(stacklist[i]);
    }
    stacklist = temp;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final String kakaoJavascriptKey;
  const MyApp({super.key, required this.kakaoJavascriptKey});

  @override
  Widget build(BuildContext context) {
/*
    return MaterialApp(
      title: 'Kakao Map (WebView)',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: KakaoMapPage(kakaoJavascriptKey: kakaoJavascriptKey),
    );*/

    return ChangeNotifierProvider<Stackwid>(
      create: (_) => Stackwid(),
      child: MaterialApp(
        title: 'NavigatorDemo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: KakaoMapPage(kakaoJavascriptKey: kakaoJavascriptKey),
        /*
        initialRoute: '/first',
        routes: {
          '/first': (context) => KakaoMapPage(kakaoJavascriptKey: kakaoJavascriptKey),
          '/second': (context) => DetailPage(id: id, name: name),
        },*/
      ),
    );
  }
}

class KakaoMapPage extends StatefulWidget {
  final String kakaoJavascriptKey;
  const KakaoMapPage({super.key, required this.kakaoJavascriptKey});

  @override
  State<KakaoMapPage> createState() => _KakaoMapPageState();
}

class _KakaoMapPageState extends State<KakaoMapPage> {
  //late final WebViewController _controller;
  Timer? _mockTimer;
  var st;

  // 시작 위치(금오공대 근처)

  double lat = 36.1430;
  double lng = 128.3941;
  List<List<dynamic>> stop_data = [];

  void loadCsvData() async {
    final csvString = await rootBundle.loadString('assets/csv/gumi_bus_stops.csv');
    stop_data = const CsvToListConverter().convert(csvString);
  }

  @override
  void initState() {
    super.initState();
    loadCsvData();
    final html = _buildHtml(widget.kakaoJavascriptKey, lat, lng);
/*
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..addJavaScriptChannel('toFlutter', onMessageReceived: (message) {
          _handleJsMessage(message.message); // 수신한 메시지 처리 함수 호출
        },
      )*/

      /*..addJavaScriptChannel('onMapReady', onMessageReceived: (message) {
        // 지도 초기화 완료 시 타이머 시작

        _mockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
          lng += 0.0005;

          final mockApiString = jsonEncode({
            "lat": lat,
            "lng": lng,
            "speed": 12.3,
            "heading": 95.0,
            "updatedAt": DateTime.now().toIso8601String(),
          });

          _controller.runJavaScript('updateBus($mockApiString)');
        });
      })*/
      //..loadHtmlString(html);
      _controller.addJavaScriptChannel('toFlutter',onMessageReceived: (message) {
          _handleJsMessage(message.message);
        },
      );
      _controller.loadHtmlString(html);
      //st=Provider.of<Stackwid>(context,listen:true);
      //st.resetStack();
  }
  //for ver2

  int lookforlong(double long, int start, int end) {
    int mid=((start+end)/2).toInt();

    if((stop_data[mid][4]-long).abs() < 0.00011 || end-start<2) {
      return mid;
    }
    else if(stop_data[mid][4]>long) {
      return lookforlong(long,start,mid);
    }
    else {
      return lookforlong(long,mid,end);
    }
  }
  void lookformarkers(double startlati, double endlati, int start, int end) {
    for(int i=start;i<=end;i++) {
      if(stop_data[i][3]>startlati && stop_data[i][3]<endlati) {
        final stopjson = jsonEncode({
          "lati": stop_data[i][3],
          "long": stop_data[i][4],
          "nodeid": stop_data[i][0],
          "nodenm": stop_data[i][1],
          "nodeno": stop_data[i][2],
        });
        _controller.runJavaScript('markStop_ff($stopjson)');
      }
    }
  }
  void _handleJsMessage(String message) {
    try {
      final data = jsonDecode(message);
      final action = data['action'];
      // 마커 클릭 통신 받고 정류장 정보 페이지 열기
      if (action == 'navigateToDetail') {
        final nodeid = data['nodeid'];
        final name = data['name'];
/*
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailPage(id: nodeid,name: name), // 이동할 Widget 지정
          ),
        );*/
        //showDetailPageDialog(context, nodeid, name);
        //_addWidgetToStack(nodeid, name);
        st.resetStack();
        Widget addw=Align(
          // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            child: DetailPage(id: nodeid, name: name),
          ),
        );
        st.updateStack(addw);

      }
      //ver2
      else if (action == 'viewmove') {
        final double startlng = data['startlng'];
        final double endlng = data['endlng'];
        final double startlat = data['startlat'];
        final double endlat = data['endlat'];
        stopsinview(startlng,endlng,startlat,endlat);
      }
    } catch (e) {
      print('Error decoding JS message: $e');
    }
  }
  void showDetailPageDialog(BuildContext context, String nodeid, String name) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent, // 배경을 어둡게 만듭니다.
      barrierDismissible: true, // 배경 탭 시 닫힘
      barrierLabel: 'Transparent Dialog',
      useRootNavigator: true,
      transitionDuration: const Duration(milliseconds: 300), // 애니메이션 시간
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Align(
          // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
          alignment: Alignment.bottomCenter,
          child: Material( // Material 위젯으로 감싸서 다이얼로그의 형태를 만듭니다.
            type: MaterialType.transparency,
            child: Container(
              // 화면 높이의 절반
              height: MediaQuery.of(context).size.height * 0.5,
              // 가로 길이는 화면 전체
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: const [ // 다이얼로그의 경계를 확실히 보여주기 위해 그림자 추가
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 100.0,
                    spreadRadius: 20.0,
                  ),
                ],
              ),
              // 🌟 DetailPage 위젯을 여기에 넣습니다.
              child: DetailPage(id: nodeid, name: name),
            ),
          ),
        );
      },
    );
  }
  void stopsinview(double startlng,double endlng, double startlat,double endlat) {
    final int longstart = lookforlong(startlng,0,1566);
    final int longend = lookforlong(endlng,longstart,1566);
    lookformarkers(startlat, endlat, longstart, longend);
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    super.dispose();
  }
  //List<Widget> stacklist=[WebViewWidget(controller: _controller)];
  /*
  void _addWidgetToStack(String nodeid, String name) {
    /*
    Widget addw=Align(
      // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: double.infinity,
        child: DetailPage(id: nodeid, name: name),
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => addw, // 이동할 Widget 지정
      ),
    );*/

    setState(() {
      // 예시: Positioned된 빨간색 사각형 위젯을 추가
      Widget stack0=stacklist[0];
      stacklist=[stack0];
      stacklist.add(
        Align(
          // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
            alignment: Alignment.bottomCenter,
            child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            child: DetailPage(id: nodeid, name: name),
          ),
        ),
      );
      stacklist.add(
          Positioned(
            left:6,
            bottom:355,
            child:
            Container(
              height: 30,
              width: 30,
              child: FloatingActionButton(
                onPressed:(){
                  setState(() {
                    Widget stack0=stacklist[0];
                    stacklist=[stack0];
                  });
                },
                child: Icon(Icons.arrow_back,color:Colors.white),
                backgroundColor: Colors.grey,
              ),
            ),
          ),

      );
    });
  }*/

  @override
  Widget build(BuildContext context) {
    st = Provider.of<Stackwid>(context,listen:true);
    //st.resetStack();
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Kakao Map + Mock API String'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _controller.runJavaScript('focusToBus()');
            },
          ),
        ],
      ),*/
      body: Stack(
          children :st.stacklist,
      ),
      /*
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 임의로 다른 목업 문자열 주입(사용자가 API 응답 받았다고 가정)
          final fakeResponse = jsonEncode({
            "gpslati": 36.1500,
            "gpslong": 128.3990,
            "speed": 5.0,
            "heading": 10.0,
            "updatedAt": DateTime.now().toIso8601String(),
          });
          await _controller.runJavaScript('resetPath()');
        },
        label: const Text('Mock API Inject'),
        icon: const Icon(Icons.send),
      ),*/
    );
  }

  String _buildHtml(String appKey, double initLat, double initLng) {
    // Flutter에서 로컬 HTML을 만들어 WebView로 로드.
    // 카카오 JS SDK 로드 후, 글로벌 함수 updateBus(json)로 마커/지도 갱신.
    return '''
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">
<title>Kakao Map</title>
<style>
  html, body, #map { width:100%; height:100%; margin:0; padding:0; }
  .badge {
    position: absolute; z-index: 10; top: 12px; left: 12px;
    background: rgba(0,0,0,0.6); color: #fff; padding: 6px 10px; border-radius: 8px; font-size: 12px;
  }
</style>
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=$appKey&autoload=false"></script>
<script>
  let map, busCircle, busPath;
  var busMarker;
  let selectcircle;
  var stops = [];
  var locas = [];

  function initMap() {
    kakao.maps.load(function() {
      const container = document.getElementById('map');
      const center = new kakao.maps.LatLng($initLat, $initLng);
      map = new kakao.maps.Map(container, {
        center: center,
        level: 4
      });
      selectcircle = new kakao.maps.Circle({
        center: center,
        radius: 15,
        strokeWeight: 1,
        strokeColor: '#3388ff',
        strokeOpacity: 0.8,
        strokeStyle: 'solid',
        fillColor: '#3388ff',
        fillOpacity: 0.8
      });

      busMarker = new kakao.maps.Marker({
        position: center,
        clickable: true
      });
      
      //markStop('금오공대종점','GMB132',36.14313118,128.39444061)
      //markStop('금오공대입구(옥계중학교방면)','GMB131',36.13949422,128.39671151)

      // 일종의 정확도/범위 느낌(옵션)
      /*
      busCircle = new kakao.maps.Circle({
        center: center,
        radius: 25,
        strokeWeight: 1,
        strokeColor: '#3388ff',
        strokeOpacity: 0.8,
        strokeStyle: 'solid',
        fillColor: '#3388ff',
        fillOpacity: 0.2
      });
      busCircle.setMap(map);*/

      busPath = new kakao.maps.Polyline({
        path: [],
        strokeWeight: 8,
        strokeColor: '#00A0FF',
        strokeOpacity: 0.8,
        strokeStyle: 'solid'
      });
      busPath.setMap(map);
      
      kakao.maps.event.addListener(map, 'dragend', function() {    
        var bounds=map.getBounds();
        var swLatLng=bounds.getSouthWest();
        var neLatLng=bounds.getNorthEast();
        var level=map.getLevel();

        resetstops();

        if(level<5) {
          const dataToSend = JSON.stringify({
            action: 'viewmove', // Flutter에서 처리할 액션 이름
            startlng: swLatLng.getLng(),
            endlng: neLatLng.getLng(),
            startlat: swLatLng.getLat(), // 이동할 페이지에 전달할 데이터 (예: 상세 정보 ID)
            endlat: neLatLng.getLat()
          });
          toFlutter.postMessage(dataToSend);
        }
      });
      kakao.maps.event.addListener(map, 'zoom_changed', function() {        
        var bounds=map.getBounds();
        var swLatLng=bounds.getSouthWest();
        var neLatLng=bounds.getNorthEast();
        var level=map.getLevel();

        resetstops();

        if(level<5) {
          const dataToSend = JSON.stringify({
            action: 'viewmove', // Flutter에서 처리할 액션 이름
            startlng: swLatLng.getLng(),
            endlng: neLatLng.getLng(),
            startlat: swLatLng.getLat(), // 이동할 페이지에 전달할 데이터 (예: 상세 정보 ID)
            endlat: neLatLng.getLat()
          });
          toFlutter.postMessage(dataToSend);
        }
      });
      updateviewstops();

      // Flutter로 초기화 완료 신호 전송
      //onMapReady.postMessage('true');
    });
  }
  
  function updateviewstops() {
    var bounds=map.getBounds();
    var swLatLng=bounds.getSouthWest();
    var neLatLng=bounds.getNorthEast();
    var level=map.getLevel();

    resetstops();

    if(level<5) {
      const dataToSend = JSON.stringify({
        action: 'viewmove',
        startlng: swLatLng.getLng(),
        endlng: neLatLng.getLng(),
        startlat: swLatLng.getLat(),
        endlat: neLatLng.getLat()
      });
      toFlutter.postMessage(dataToSend);
      console.log("1009");
    }
  }
  
  function resetstops() {
    for (var i = 0; i < stops.length; i++) {
      stops[i].setMap(null);
    }            
  }
  
  // Flutter에서 이 함수를 호출해 버스 위치 갱신
  function updateBus(json) {
    try {
      const data = (typeof json === 'string') ? JSON.parse(json) : json;
      if (!map || !busMarker) return;

      const pos = new kakao.maps.LatLng(data.lat, data.lng);
      busMarker.setPosition(pos);
      busCircle.setPosition(pos);

      // 이동 경로(폴리라인) 이어 붙이기
      const oldPath = busPath.getPath();
      oldPath.push(pos);
      busPath.setPath(oldPath);

      // 화면 상단 배지 업데이트
      const badge = document.getElementById('badge');
      if (badge) {
        badge.innerText = \`lat: \${data.lat.toFixed(6)}, lng: \${data.lng.toFixed(6)} | speed: \${data.speed ?? '-'} | heading: \${data.heading ?? '-'}\`;
      }
    } catch (e) {
      console.error('updateBus error:', e);
    }
  }

  // 마커 위치로 지도를 부드럽게 센터링
  function focusToBus() {
    if (!map || !busMarker) return;
    const pos = busMarker.getPosition();
    map.panTo(pos);
  }
  
  function drawBusroute(addbusStop) {
    try {
      const data = (typeof addbusStop === 'string') ? JSON.parse(addbusStop) : addbusStop;
      if (!map || !busMarker) return;

      const pos=new kakao.maps.LatLng(data.gpslati,data.gpslong);
      
      const oldPath=busPath.getPath();
      oldPath.push(pos);
      busPath.setPath(oldPath);
    } catch (e) {
      console.error('drawRoute Error:',e);
    }
  }
  
  function markStop(nodenm,nodeid,lati,long) {
    const pos = new kakao.maps.LatLng(lati, long);
    busMarker = new kakao.maps.Marker({
        map: map,
        position: pos,
        clickable: true
    });
    kakao.maps.event.addListener(busMarker, 'click', function() {
      const dataToSend = JSON.stringify({
        action: 'navigateToDetail', // Flutter에서 처리할 액션 이름
        nodeid: nodeid, // 이동할 페이지에 전달할 데이터 (예: 상세 정보 ID)
        name: nodenm
      });
      toFlutter.postMessage(dataToSend);
    });
  }
  
  function markStop_ff(addmark) {
    const data = (typeof addmark === 'string') ? JSON.parse(addmark) : addmark;
    const pos = new kakao.maps.LatLng(data.lati, data.long);
    var busMarker = new kakao.maps.Marker({
        map: map,
        position: pos,
        clickable: true
    });
    kakao.maps.event.addListener(busMarker, 'click', function() {
      selectcircle.setMap(null);
      selectcircle.setPosition(pos);
      selectcircle.setMap(map);
      
      if(map.getLevel()!=3) {
        map.setLevel(3);
      }
      
      const movepos = new kakao.maps.LatLng(data.lati-0.0015, data.long);
      map.panTo(movepos);
      
      const dataToSend = JSON.stringify({
        action: 'navigateToDetail', // Flutter에서 처리할 액션 이름
        nodeid: data.nodeid, // 이동할 페이지에 전달할 데이터 (예: 상세 정보 ID)
        name: data.nodenm,
        number: data.nodeno
      });
      toFlutter.postMessage(dataToSend);
      
      updateviewstops();
    });
    stops.push(busMarker);
  }
  
  function moveforvisibility(selectstop) {
    const data = (typeof selectstop === 'string') ? JSON.parse(selectstop) : selectstop;
    
    if(map.getLevel()!=3) {
      map.setLevel(3);
    }
    const movepos = new kakao.maps.LatLng(data.lati-0.0015, data.long);
    map.panTo(movepos);
    
    updateviewstops();
  }
  
  function markloca(location) {
    const data = (typeof location === 'string') ? JSON.parse(location) : location;
    const pos = new kakao.maps.LatLng(data.lati, data.long);
    //console.log(data.lati, data.long);
    let locaCircle = new kakao.maps.Circle({
      center: pos,
      radius: 11,
      strokeWeight: 2,
      strokeColor: '#000000',
      strokeOpacity: 0.8,
      strokeStyle: 'solid',
      fillColor: '#ff0000',
      fillOpacity: 0.8
    });
    locaCircle.setMap(map);
    locas.push(locaCircle);
  }

  function resetlocas() {
    for (var i = 0; i < locas.length; i++) {
      locas[i].setMap(null);
    }            
  }
  
  function resetPath() {
    busPath.setPath([]);
  }

  // 초기화
  window.addEventListener('load', initMap);
</script>
</head>
<body>
  <!--<div id="badge" class="badge">loading…</div>-->
  <div id="map"></div>
</body>
</html>
''';
  }
}
