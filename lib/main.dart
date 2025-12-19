import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final WebViewController _controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..enableZoom(false);

List<List<dynamic>> stop_data_formap = [];
List<List<dynamic>> stop_data = [];
List<List<dynamic>> stop_buses_data = [];
List<List<dynamic>> bus_data = [];
List<List<dynamic>> bus_route_data = [];
List<List<dynamic>> bus_route_inroad_data = [];
List<List<String>> search_data = [];
List<List<dynamic>> stop_data_EN = [];
List<List<dynamic>> bus_data_EN = [];
List<List<String>> search_data_EN = [];
List<List<String>> search_data_KR = [];

class RouteInfo {
  final String routeId; // 노선 ID
  final String routeNo; // 노선 번호 (예: 100번)
  final String routeTp; // 노선 유형
  final String startStName; // 기점 정류장 이름
  final String endStName; // 종점 정류장 이름
  final int busindex;

  RouteInfo({
    required this.routeId,
    required this.routeNo,
    required this.routeTp,
    required this.startStName,
    required this.endStName,
    required this.busindex,
  });
}

class StopInfo {
  final double gpslati;
  final double gpslong;
  final String nodeID;
  final String nodeName;
  final String nodeNo;
  final int nodeOrd;
  final int stopindex;

  StopInfo({
    required this.gpslati,
    required this.gpslong,
    required this.nodeID,
    required this.nodeName,
    required this.nodeNo,
    required this.nodeOrd,
    required this.stopindex,
  });
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
  final int arrprevstationcnt; // 노선 ID
  final int arrtime; // 노선 번호 (예: 100번)
  final String nodeID; // 노선 유형
  final String nodeName; // 기점 정류장 이름
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

class StoparriveInfo_onAI2 {
  final int arrprevstationcnt; // 노선 IDv
  final int arrtime; // 노선 번호 (예: 100번)v
  final String nodeID; // 노선 유형v
  final String nodeName; // 기점 정류장 이름v
  final String routeID; //v
  final String routeNo; //v
  final String routeTp; //v
  final String vehicleTp; //v
  final String mode;

  StoparriveInfo_onAI2({
    required this.arrprevstationcnt,
    required this.arrtime,
    required this.nodeID,
    required this.nodeName,
    required this.routeID,
    required this.routeNo,
    required this.routeTp,
    required this.vehicleTp,
    required this.mode,
  });

  factory StoparriveInfo_onAI2.fromJson(Map<String, dynamic> json) {
    return StoparriveInfo_onAI2(
      arrprevstationcnt: json['arrprevstationcnt'] ?? -1,
      arrtime: json['arrtime'] ?? -1,
      nodeID: json['nodeid'] ?? 'N/A',
      nodeName: json['nodenm'] ?? 'N/A',
      routeID: json['routeid'] ?? 'N/A',
      routeNo: json['routeno']?.toString() ?? 'N/A',
      routeTp: json['routetp'] ?? 'N/A',
      vehicleTp: json['vehicletp'] ?? 'N/A',
      mode: json['mode'] ?? 'N/A',
    );
  }
}

class StoparriveInfo_onAI {
  final int arrprevstationcnt; // 노선 IDv
  final int arrtime; // 노선 번호 (예: 100번)v
  final String routeID; //v

  StoparriveInfo_onAI({
    required this.arrprevstationcnt,
    required this.arrtime,
    required this.routeID,
  });

  factory StoparriveInfo_onAI.fromJson(Map<String, dynamic> json) {
    return StoparriveInfo_onAI(
      arrprevstationcnt: json['remaining_stops'] ?? -1,
      arrtime: json['eta_seconds'] ?? -1,
      routeID: json['routeid'] ?? 'N/A',
    );
  }
}

class busposition_onAI {
  final String nodeID;
  final String nodeName;
  final int nodeOrd;
  final String vehicleNo;
  final String status;

  busposition_onAI({
    required this.nodeID,
    required this.nodeName,
    required this.nodeOrd,
    required this.vehicleNo,
    required this.status,
  });

  factory busposition_onAI.fromJson(Map<String, dynamic> json) {
    return busposition_onAI(
      nodeID: json['current_nodeid'] ?? 'N/A',
      nodeName: json['current_nodenm'] ?? 'N/A',
      nodeOrd: json['current_nodeord'] ?? -1,
      vehicleNo: json['vehicleno'] ?? 'N/A',
      status: json['status'] ?? 'N/A',
    );
  }
}

class busRoutePage extends StatefulWidget {
  final String id, number;
  final int index, apiid;

  const busRoutePage({
    super.key,
    required this.id,
    required this.number,
    required this.index,
    required this.apiid,
  });

  @override
  State<busRoutePage> createState() => _busRoutePage();
}

class _busRoutePage extends State<busRoutePage> {
  //final String id,number;
  var st;
  late List<dynamic> data;
  late List<StopInfo> route;
  static const String code="YOUR_CODE";
  static const String baseUrl1 =
      "https://apis.data.go.kr/1613000/BusLcInfoInqireService/getRouteAcctoBusLcList?serviceKey=${code}&pageNo=1&numOfRows=10&_type=json&cityCode=37050&routeId=";


  @override
  void initState() {
    super.initState();
  }

  void getdata() {
    List<dynamic> routeindexs = bus_route_data[widget.index];
    _controller.runJavaScript('resetPath()');
    for (int i = 0; i < bus_route_inroad_data[widget.index].length; i += 2) {
      final locaResponse = jsonEncode({
        "gpslati": bus_route_inroad_data[widget.index][i],
        "gpslong": bus_route_inroad_data[widget.index][i + 1],
      });
      _controller.runJavaScript('drawBusroute($locaResponse)');
    }
    route = [];
    if (st._language == Language.Korean) {
      data = bus_data[widget.index];
      for (int i = 0; i < routeindexs.length; i++) {
        route.add(
          StopInfo(
            gpslati: stop_data[routeindexs[i]][3],
            gpslong: stop_data[routeindexs[i]][4],
            nodeID: stop_data[routeindexs[i]][0].toString(),
            nodeName: stop_data[routeindexs[i]][1].toString(),
            nodeNo: stop_data[routeindexs[i]][2].toString(),
            nodeOrd: i + 1,
            stopindex: routeindexs[i],
          ),
        );
      }
    } else {
      data = bus_data_EN[widget.index];
      for (int i = 0; i < routeindexs.length; i++) {
        route.add(
          StopInfo(
            gpslati: stop_data_EN[routeindexs[i]][3],
            gpslong: stop_data_EN[routeindexs[i]][4],
            nodeID: stop_data_EN[routeindexs[i]][0].toString(),
            nodeName: stop_data_EN[routeindexs[i]][1].toString(),
            nodeNo: stop_data_EN[routeindexs[i]][2].toString(),
            nodeOrd: i + 1,
            stopindex: routeindexs[i],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.runJavaScript('resetPath()');
    _controller.runJavaScript('resetlocas()');
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
        final count = jsonResponse['response']['body']['totalCount'];
        if (count == 1) {
          items = [jsonResponse['response']['body']['items']['item']];
        } else if (count == 0) {
          return [];
        } else {
          items = jsonResponse['response']['body']['items']['item'] as List;
        }
        // items 리스트를 RouteInfo 객체 리스트로 변환
        final List<busposition> result = items
            .map((json) => busposition.fromJson(json))
            .toList();
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
    st = Provider.of<Stackwid>(context, listen: true);
    if (st.apistackid.last != widget.apiid) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Some widget is on top of this page.\nIf you see this, please restart the app.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    getdata();
    Icon star = Icon(
      Icons.star_border, // 일반 별 모양 아이콘
      color: Colors.black, // 아이콘 색상
    );
    Map<String, int> check = {'type': 0, 'index': widget.index};
    bool favorite = false;
    int favorite_index = -1;
    for (int i = 0; i < st.favorite_list.length; i++) {
      if (check['type'] == st.favorite_list[i]['type'] &&
          check['index'] == st.favorite_list[i]['index']) {
        star = Icon(
          Icons.star, // 일반 별 모양 아이콘
          color: Colors.yellow, // 아이콘 색상
        );
        favorite = true;
        favorite_index = i;
        break;
      }
    }
    Text title = Text(
      '${widget.number} (${data[0]} 방면)',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: st._fontsize == Fontsize.Normal ? 22 : 30,
      ),
    );
    if (st._language == Language.English) {
      title = Text(
        '${widget.number} (To ${data[0]})',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: st._fontsize == Fontsize.Normal ? 22 : 30,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: title,
        backgroundColor: Colors.white,
        actions: <Widget>[
          // 아이콘으로 만들어진 버튼
          IconButton(
            icon: star,
            // 버튼을 눌렀을 때 실행될 동작
            onPressed: () {
              //삭제
              if (favorite) {
                st.deleteFavorite(favorite_index);
              }
              //추가
              else {
                st.addFavorite(check);
              }
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder(
        //<List<StopInfo>>(
        future: getlocations(),// 데이터 로드 함수 호출
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
            final List<busposition> poses = snapshot.data as List<busposition>;

            if (route.isEmpty) {
              return const Center(child: Text('해당 버스의 노선정류장이 없습니다.'));
            }
            _controller.runJavaScript('resetlocas()');

            for (int i = 0; i < poses.length; i++) {
              for (int j = 0; j < route.length; j++) {
                if (poses[i].nodeID == route[j].nodeID) {
                  final locaResponse = jsonEncode({
                    /*"lati": route[poses[i].nodeOrd-1].gpslati,
                    "long": route[poses[i].nodeOrd-1].gpslong,*/
                    "lati": route[j].gpslati,
                    "long": route[j].gpslong,
                  });
                  _controller.runJavaScript('markloca($locaResponse)');
                  break;
                }
              }
            }

            // 노선 리스트를 ListView로 출력
            return ListView.builder(
              itemCount: route.length,
              itemBuilder: (context, index) {
                final stop = route[index];
                Icon stopicon = Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 30,
                );
                for (int i = 0; i < poses.length; i++) {
                  if (stop.nodeID == poses[i].nodeID) {
                    stopicon = Icon(
                      Icons.directions_bus,
                      color: Colors.green,
                      size: 30,
                    );
                    break;
                  }
                }

                return ListTile(
                  leading: stopicon,
                  title: Text(
                    '${stop.nodeName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: st._fontsize == Fontsize.Normal ? 15 : 30,
                    ),
                  ),
                  subtitle: Text(
                    '${stop.nodeNo}',
                    style: TextStyle(
                      fontSize: st._fontsize == Fontsize.Normal ? 15 : 20,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        child: const Icon(Icons.refresh),
        mini: true,
      ),
    );
  }
}

class busRoutePage_onAI extends StatefulWidget {
  final String id, number;
  final int index, apiid;

  const busRoutePage_onAI({
    super.key,
    required this.id,
    required this.number,
    required this.index,
    required this.apiid,
  });

  @override
  State<busRoutePage_onAI> createState() => _busRoutePage_onAI();
}

class _busRoutePage_onAI extends State<busRoutePage_onAI> {
  var st;
  late List<dynamic> data;
  late List<StopInfo> route;
  static const String baseUrl1 = "http://43.200.177.50:8000/api/buses/route/";

  void getdata() {
    List<dynamic> routeindexs = bus_route_data[widget.index];
    _controller.runJavaScript('resetPath()');
    for (int i = 0; i < bus_route_inroad_data[widget.index].length; i += 2) {
      final locaResponse = jsonEncode({
        "gpslati": bus_route_inroad_data[widget.index][i],
        "gpslong": bus_route_inroad_data[widget.index][i + 1],
      });
      _controller.runJavaScript('drawBusroute($locaResponse)');
    }
    route = [];
    if (st._language == Language.Korean) {
      data = bus_data[widget.index];
      for (int i = 0; i < routeindexs.length; i++) {
        route.add(
          StopInfo(
            gpslati: stop_data[routeindexs[i]][3],
            gpslong: stop_data[routeindexs[i]][4],
            nodeID: stop_data[routeindexs[i]][0].toString(),
            nodeName: stop_data[routeindexs[i]][1].toString(),
            nodeNo: stop_data[routeindexs[i]][2].toString(),
            nodeOrd: i + 1,
            stopindex: routeindexs[i],
          ),
        );
      }
    } else {
      data = bus_data_EN[widget.index];
      for (int i = 0; i < routeindexs.length; i++) {
        route.add(
          StopInfo(
            gpslati: stop_data_EN[routeindexs[i]][3],
            gpslong: stop_data_EN[routeindexs[i]][4],
            nodeID: stop_data_EN[routeindexs[i]][0].toString(),
            nodeName: stop_data_EN[routeindexs[i]][1].toString(),
            nodeNo: stop_data_EN[routeindexs[i]][2].toString(),
            nodeOrd: i + 1,
            stopindex: routeindexs[i],
          ),
        );
      }
    }
  }

  Future<List<busposition_onAI>> getlocations() async {
    try {
      // 2. HTTP GET 요청 실행
      final url = Uri.parse("$baseUrl1${widget.id}");
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final String body = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(body);

        late final List<dynamic> items;
        if (jsonResponse.length == 0) {
          return [];
        }
        items = jsonResponse;

        // items 리스트를 RouteInfo 객체 리스트로 변환
        final List<busposition_onAI> result = items
            .map((json) => busposition_onAI.fromJson(json))
            .toList();
        return result;
      } else {
        // 5. 서버 오류 (예: 400 Bad Request, 403 Forbidden 등)
        throw Exception('API 요청 실패 (Status Code: ${response.statusCode})');
      }
    } on TimeoutException {
      // ✨ 2. 타임아웃 오류: 서버가 요청을 받았지만 5초 안에 응답을 주지 않은 경우
      print('AI 서버 응답 시간 초과: TimeoutException.');
      return [];
    } catch (e) {
      // 6. 네트워크 오류 (인터넷 연결 끊김 등)
      print('AI 버스 위치 네트워크 요청 중 오류 발생: $e');
      throw Exception('데이터 로드 실패: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.runJavaScript('resetPath()');
    _controller.runJavaScript('resetlocas()');
  }

  @override
  Widget build(BuildContext context) {
    st = Provider.of<Stackwid>(context, listen: true);
    if (st.apistackid.last != widget.apiid) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Some widget is on top of this page.\nIf you see this, please restart the app.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    getdata();
    Icon star = Icon(
      Icons.star_border, // 일반 별 모양 아이콘
      color: Colors.black, // 아이콘 색상
    );
    Map<String, int> check = {'type': 0, 'index': widget.index};
    bool favorite = false;
    int favorite_index = -1;
    for (int i = 0; i < st.favorite_list.length; i++) {
      if (check['type'] == st.favorite_list[i]['type'] &&
          check['index'] == st.favorite_list[i]['index']) {
        star = Icon(
          Icons.star, // 일반 별 모양 아이콘
          color: Colors.yellow, // 아이콘 색상
        );
        favorite = true;
        favorite_index = i;
        break;
      }
    }
    Text title = Text(
      '${widget.number} (${data[0]} 방면)',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: st._fontsize == Fontsize.Normal ? 22 : 30,
        color: Colors.blue,
      ),
    );
    if (st._language == Language.English) {
      title = Text(
        '${widget.number} (To ${data[0]})',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: st._fontsize == Fontsize.Normal ? 22 : 30,
          color: Colors.blue,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: title,
        backgroundColor: Colors.white,
        actions: <Widget>[
          // 아이콘으로 만들어진 버튼
          IconButton(
            icon: star,
            // 버튼을 눌렀을 때 실행될 동작
            onPressed: () {
              //삭제
              if (favorite) {
                st.deleteFavorite(favorite_index);
              }
              //추가
              else {
                st.addFavorite(check);
              }
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getlocations(),
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
            //final List<StopInfo> stops = snapshot.data![0] as List<StopInfo>;
            final List<busposition_onAI> poses =
                snapshot.data as List<busposition_onAI>;

            if (route.isEmpty) {
              return const Center(child: Text('해당 버스의 노선정류장이 없습니다.'));
            }
            _controller.runJavaScript('resetlocas()');

            for (int i = 0; i < poses.length; i++) {
              for (int j = 0; j < route.length; j++) {
                if (poses[i].nodeID == route[j].nodeID) {
                  final locaResponse = jsonEncode({
                    "lati": route[j].gpslati,
                    "long": route[j].gpslong,
                  });
                  _controller.runJavaScript('markloca($locaResponse)');
                  break;
                }
              }
            }

            // 노선 리스트를 ListView로 출력
            return Stack(
              children: [
                ListView.builder(
                  itemCount: route.length,
                  itemBuilder: (context, index) {
                    final stop = route[index];
                    Icon stopicon = Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 30,
                    );
                    for (int i = 0; i < poses.length; i++) {
                      if (stop.nodeID == poses[i].nodeID) {
                        stopicon = Icon(
                          Icons.directions_bus,
                          color: poses[i].status == "active"
                              ? Colors.green
                              : Colors.blue,
                          size: 30,
                        );
                        break;
                      }
                    }

                    return ListTile(
                      leading: stopicon,
                      title: Text(
                        '${stop.nodeName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: st._fontsize == Fontsize.Normal ? 15 : 30,
                        ),
                      ),
                      subtitle: Text(
                        '${stop.nodeNo}',
                        style: TextStyle(
                          fontSize: st._fontsize == Fontsize.Normal ? 15 : 20,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        final selectstop = jsonEncode({
                          "lati": stop.gpslati,
                          "long": stop.gpslong,
                        });
                        _controller.runJavaScript(
                          'moveforvisibility($selectstop)',
                        );
                      },
                    );
                  },
                ),
                IgnorePointer(
                  ignoring: true,
                  child: Center(
                    child: Text(
                      st._language == Language.Korean
                          ? 'AI 예측 정보이므로\n실제와 차이가 있을 수 있습니다.'
                          : 'These are AI predictions.\nIt may differ from actual times.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.withOpacity(0.6),
                        // 투명도가 있는 연한 회색으로 설정
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }

          // 기본 반환 (발생할 일은 거의 없음)
          return const Center(child: Text('데이터를 찾을 수 없습니다.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        child: const Icon(Icons.refresh),
        mini: true,
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final String id, name;
  final int index, apiid;

  const DetailPage({
    super.key,
    required this.id,
    required this.name,
    required this.index,
    required this.apiid,
  });

  @override
  State<DetailPage> createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  var st;
  late List<dynamic> data;
  late List<RouteInfo> buses;
  static const String code="YOUR_CODE";
  static const String baseUrl1 =
      "https://apis.data.go.kr/1613000/ArvlInfoInqireService/getSttnAcctoArvlPrearngeInfoList?serviceKey=${code}&pageNo=1&numOfRows=30&_type=json&cityCode=37050&nodeId=";
  static const String baseUrl2 = "http://43.200.177.50:8000/api/arrival/";

  @override
  void initState() {
    super.initState();
  }

  void getdata() {
    if (st._language == Language.Korean) {
      data = stop_data[widget.index];
      List<dynamic> busindexs = stop_buses_data[widget.index];
      buses = [];
      for (int i = 0; i < busindexs.length; i++) {
        buses.add(
          RouteInfo(
            routeId: bus_data[busindexs[i]][1].toString(),
            routeNo: bus_data[busindexs[i]][2].toString(),
            routeTp: bus_data[busindexs[i]][3].toString(),
            startStName: bus_data[busindexs[i]][4].toString(),
            endStName: bus_data[busindexs[i]][0].toString(),
            busindex: busindexs[i],
          ),
        );
      }
    } else {
      data = stop_data_EN[widget.index];
      List<dynamic> busindexs = stop_buses_data[widget.index];
      buses = [];
      for (int i = 0; i < busindexs.length; i++) {
        buses.add(
          RouteInfo(
            routeId: bus_data_EN[busindexs[i]][1].toString(),
            routeNo: bus_data_EN[busindexs[i]][2].toString(),
            routeTp: bus_data_EN[busindexs[i]][3].toString(),
            startStName: bus_data_EN[busindexs[i]][4].toString(),
            endStName: bus_data_EN[busindexs[i]][0].toString(),
            busindex: busindexs[i],
          ),
        );
      }
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
        if (jsonResponse['response']['body']['totalCount'] == 1) {
          items = [jsonResponse['response']['body']['items']['item']];
        } else if (jsonResponse['response']['body']['totalCount'] == 0) {
          return [];
        } else {
          items = jsonResponse['response']['body']['items']['item'] as List;
        }
        // items 리스트를 RouteInfo 객체 리스트로 변환
        final List<StoparriveInfo> result = items
            .map((json) => StoparriveInfo.fromJson(json))
            .toList();
        return result; //items.map((json) => StoparriveInfo.fromJson(json)).toList();
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

  Future<List<StoparriveInfo_onAI>> getarriveInfos_AI() async {
    if (st._aimode == false) {
      return [];
    }
    try {
      // 2. HTTP GET 요청 실행
      final url = Uri.parse("$baseUrl2${widget.id}");
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final String body = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(body);

        late final List<dynamic> items;
        if (jsonResponse.length == 0) {
          return [];
        }
        items = jsonResponse;
        final List<StoparriveInfo_onAI> result = items
            .map((json) => StoparriveInfo_onAI.fromJson(json))
            .toList();
        return result; //items.map((json) => StoparriveInfo.fromJson(json)).toList();
      } else {
        // 5. 서버 오류 (예: 400 Bad Request, 403 Forbidden 등)
        return [];
      }
    } on TimeoutException {
      // ✨ 2. 타임아웃 오류: 서버가 요청을 받았지만 5초 안에 응답을 주지 않은 경우
      print('AI 서버 응답 시간 초과: TimeoutException.');
      return [];
      //throw Exception('AI 서버가 응답하지 않습니다.');
    } catch (e) {
      // 6. 네트워크 오류 (인터넷 연결 끊김 등)
      print('AI 도착 네트워크 요청 중 오류 발생: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    st = Provider.of<Stackwid>(context, listen: true);
    if (st.apistackid.last != widget.apiid) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Some widget is on top of this page.\nIf you see this, please restart the app.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    getdata();
    Icon star = Icon(
      Icons.star_border, // 일반 별 모양 아이콘
      color: Colors.black, // 아이콘 색상
    );
    Map<String, int> check = {'type': 1, 'index': widget.index};
    bool favorite = false;
    int favorite_index = -1;
    for (int i = 0; i < st.favorite_list.length; i++) {
      if (check['type'] == st.favorite_list[i]['type'] &&
          check['index'] == st.favorite_list[i]['index']) {
        star = Icon(
          Icons.star, // 일반 별 모양 아이콘
          color: Colors.yellow, // 아이콘 색상
        );
        favorite = true;
        favorite_index = i;
        break;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          //'${widget.name}',
          '${data[1]}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: st._fontsize == Fontsize.Normal ? 22 : 30,
          ),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          // 아이콘으로 만들어진 버튼
          IconButton(
            icon: star,
            // 버튼을 눌렀을 때 실행될 동작
            onPressed: () {
              //삭제
              if (favorite) {
                st.deleteFavorite(favorite_index);
              }
              //추가
              else {
                st.addFavorite(check);
              }
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future:
        Future.wait([
          getarriveInfos(),
          getarriveInfos_AI(),
        ]), // 데이터 로드 함수 호출
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 중일 때
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // 오류 발생 시
            String errortext =
                '앗! 문제가 발생했어요. 새로고침 해주세요.\n(오류 : ${snapshot.error})';
            if (st._language == Language.English) {
              errortext =
                  'Oops! Something went wrong. Please refresh.\n(Error: ${snapshot.error})';
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errortext, //'\nError: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            // 데이터 수신 성공 시
            final List<StoparriveInfo> arrives =
                snapshot.data![0]
                    as List<
                      StoparriveInfo
                    >;
            final List<StoparriveInfo_onAI> arrives_onAI =
                snapshot.data![1] as List<StoparriveInfo_onAI>;

            int arricount = arrives.length;
            int arriAIcount = arrives_onAI.length;
            if (buses.isEmpty) {
              return const Center(child: Text('해당 정류장을 경유하는 노선이 없습니다.'));
            }
            for (int i = 0; i < arrives.length; i++) {
              for (int j = 0; j < buses.length; j++) {
                if (arrives[i].routeID == buses[j].routeId) {
                  RouteInfo temp = buses.removeAt(j);
                  buses.insert(0, temp);
                  break;
                }
              }
            }
            for (int i = 0; i < arrives_onAI.length; i++) {
              for (int j = 0; j < buses.length; j++) {
                if (arrives_onAI[i].routeID == buses[j].routeId) {
                  RouteInfo temp = buses.removeAt(j);
                  buses.insert(0, temp);
                  break;
                }
              }
            }
            // 노선 리스트를 ListView로 출력
            bool _inAI = false;

            List<Widget> result_widgets = [
              ListView.builder(
                itemCount: buses.length,
                itemBuilder: (context, index) {
                  final route = buses[index];
                  String arrtime = '도착 예정 없음';
                  if (st._language == Language.English) {
                    arrtime = 'N/A';
                  }
                  TextStyle style = TextStyle(fontSize: 10);
                  Icon busicon = Icon(
                    Icons.directions_bus,
                    color: Colors.green,
                  );
                  if (route.routeTp == '좌석버스') {
                    busicon = Icon(Icons.directions_bus, color: Colors.purple);
                  }
                  for (int i = 0; i < arricount; i++) {
                    if (route.routeId == arrives[i].routeID) {
                      if (st._language == Language.Korean) {
                        arrtime = '${(arrives[i].arrtime / 60).toInt()}분';
                      } else {
                        arrtime = '${(arrives[i].arrtime / 60).toInt()}min';
                      }
                      style = TextStyle(
                        fontSize: st._fontsize == Fontsize.Normal ? 15 : 30,
                        fontWeight: FontWeight.bold,
                      );
                      if ((arrives[i].arrtime / 60) <= 2 ||
                          arrives[i].arrprevstationcnt <= 1) {
                        if (st._language == Language.Korean) {
                          arrtime = '곧도착($arrtime)';
                        } else {
                          arrtime = 'Soon($arrtime)';
                        }
                        style = TextStyle(
                          fontSize: st._fontsize == Fontsize.Normal ? 15 : 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        );
                      }
                      break;
                    }
                  }
                  bool _AI = false;
                  for (int i = 0; i < arriAIcount; i++) {
                    if (route.routeId == arrives_onAI[i].routeID) {
                      _AI = true;
                      if (_inAI == false) _inAI = true;
                      int arrtime_minus = arrives_onAI[i].arrtime - 60;
                      if (arrtime_minus > 60) {
                        if (st._language == Language.Korean) {
                          arrtime = '${(arrtime_minus / 60).toInt()}분';
                        } else {
                          arrtime = '${(arrtime_minus / 60).toInt()}min';
                        }
                        style = TextStyle(
                          fontSize: st._fontsize == Fontsize.Normal ? 15 : 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        );
                      } else {
                        if (st._language == Language.Korean) {
                          arrtime = '곧도착';
                        } else {
                          arrtime = 'Soon';
                        }
                        style = TextStyle(
                          fontSize: st._fontsize == Fontsize.Normal ? 15 : 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        );
                      }
                    }
                  }
                  Text subTitle = Text(
                    '${route.endStName}방면',
                    style: TextStyle(
                      fontSize: st._fontsize == Fontsize.Normal ? 14 : 20,
                    ),
                  );
                  if (st._language == Language.English) {
                    subTitle = Text(
                      'To ${route.endStName}',
                      style: TextStyle(
                        fontSize: st._fontsize == Fontsize.Normal ? 14 : 20,
                      ),
                    );
                  }
                  return ListTile(
                    leading: busicon,
                    title: Text(
                      '${route.routeNo}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: st._fontsize == Fontsize.Normal ? 16 : 30,
                        color: _AI ? Colors.blue : Colors.black,
                      ),
                    ),
                    subtitle: subTitle,
                    trailing: Text(arrtime, style: style),
                    onTap: () {
                      if (st._aimode &&
                          (route.busindex == 263 ||
                              route.busindex == 96 ||
                              route.busindex == 325 ||
                              route.busindex == 6)) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('AI모드 버스'),
                              // content에 원하는 내용을 추가할 수 있습니다.
                              content: st._language == Language.Korean
                                  ? Text('이 버스는 AI모드를 지원해요. AI모드로 보실래요?')
                                  : Text(
                                      'This bus supports AI mode. Do you want to see it?',
                                    ),
                              actions: <Widget>[
                                TextButton(
                                  child: st._language == Language.Korean
                                      ? Text('예')
                                      : Text('Yes'),
                                  onPressed: () {
                                    Widget addw = Align(
                                      // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height:
                                            MediaQuery.of(
                                              this.context,
                                            ).size.height *
                                            0.5,
                                        width: double.infinity,
                                        child: busRoutePage_onAI(
                                          id: route.routeId,
                                          number: route.routeNo,
                                          index: route.busindex,
                                          apiid: st.allocateapiid(),
                                        ),
                                      ),
                                    );
                                    st.updateStack(this.context, addw, 2);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: st._language == Language.Korean
                                      ? Text('아니오')
                                      : Text('No'),
                                  onPressed: () {
                                    Widget addw = Align(
                                      // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height:
                                            MediaQuery.of(
                                              this.context,
                                            ).size.height *
                                            0.5,
                                        width: double.infinity,
                                        child: busRoutePage(
                                          id: route.routeId,
                                          number: route.routeNo,
                                          index: route.busindex,
                                          apiid: st.allocateapiid(),
                                        ),
                                      ),
                                    );
                                    st.updateStack(this.context, addw, 2);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        Widget addw = Align(
                          // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: double.infinity,
                            child: busRoutePage(
                              id: route.routeId,
                              number: route.routeNo,
                              index: route.busindex,
                              apiid: st.allocateapiid(),
                            ),
                          ),
                        );
                        st.updateStack(context, addw, 2);
                      }
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            // title에 버스 번호를 표시합니다.
                            title: Text('${route.routeNo}'),
                            // content에 원하는 내용을 추가할 수 있습니다.
                            content: st._language == Language.Korean
                                ? Text('이 버스의 도착시간을 메인화면에 추가하시겠습니까?')
                                : Text(
                                    'Would you like to add this bus arrival time to the main screen?',
                                  ),
                            actions: <Widget>[
                              TextButton(
                                child: st._language == Language.Korean
                                    ? Text('예')
                                    : Text('Yes'),
                                onPressed: () {
                                  st.setminiarri(
                                    widget.id,
                                    widget.index,
                                    route.routeId,
                                  );
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: st._language == Language.Korean
                                    ? Text('아니오')
                                    : Text('No'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ];
            if (_inAI) {
              result_widgets.add(
                IgnorePointer(
                  ignoring: true,
                  child: Center(
                    child: Text(
                      st._language == Language.Korean
                          ? 'AI 예측 정보이므로\n실제와 차이가 있을 수 있습니다.'
                          : 'These are AI predictions.\nIt may differ from actual times.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.withOpacity(
                          0.6,
                        ), // 투명도가 있는 연한 회색으로 설정
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }
            return Stack(children: result_widgets);
          }

          // 기본 반환 (발생할 일은 거의 없음)
          return const Center(child: Text('데이터를 찾을 수 없습니다.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        child: const Icon(Icons.refresh),
        mini: true,
      ),
    );
  }
}

class miniarrivepage extends StatefulWidget {
  final String nodeid, routeid;
  final int nodeindex;

  const miniarrivepage({
    super.key,
    required this.nodeid,
    required this.nodeindex,
    required this.routeid,
  });

  @override
  State<miniarrivepage> createState() => _miniarrivepage();
}

class _miniarrivepage extends State<miniarrivepage> {
  late String baseUrl;
  String code = "YOUR_CODE";
  var st;

  @override
  void initState() {
    super.initState();
    baseUrl =
        "https://apis.data.go.kr/1613000/ArvlInfoInqireService/getSttnAcctoSpcifyRouteBusArvlPrearngeInfoList?serviceKey=${code}&pageNo=1&numOfRows=10&_type=json&cityCode=37050&nodeId=${widget.nodeid}&routeId=${widget.routeid}";
  }

  Future<List<StoparriveInfo>> getarriveInfos() async {
    try {
      // 2. HTTP GET 요청 실행
      final url = Uri.parse("$baseUrl");
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
        if (jsonResponse['response']['body']['totalCount'] == 1) {
          items = [jsonResponse['response']['body']['items']['item']];
        } else if (jsonResponse['response']['body']['totalCount'] == 0) {
          return [];
        } else {
          items = jsonResponse['response']['body']['items']['item'] as List;
        }
        // items 리스트를 RouteInfo 객체 리스트로 변환
        final List<StoparriveInfo> result = items
            .map((json) => StoparriveInfo.fromJson(json))
            .toList();
        return result; //items.map((json) => StoparriveInfo.fromJson(json)).toList();
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

  Widget _buildInfoCard(String mainText, String subText) {
    return Card(
      elevation: 4.0, // 약간의 그림자 효과

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // 둥근 모서리
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양쪽 끝으로 정렬
          children: [
            // 왼쪽: 버스 번호와 도착 정보
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
                children: [
                  Flexible(
                    child: Text(
                      mainText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      //overflow: TextOverflow.ellipsis, // 글자가 길면 ... 처리
                    ),
                  ),
                  Text(
                    subText,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 오른쪽: 닫기(X) 버튼
            Column(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    st.deleteminiarri();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    st = Provider.of<Stackwid>(context, listen: true);
    return FutureBuilder<List<StoparriveInfo>>(
      future: getarriveInfos(), // 비동기 API 호출 함수
      builder: (context, snapshot) {
        // 로딩 중일 때 로딩 인디케이터 표시
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // 에러가 발생했을 때
        if (snapshot.hasError) {
          if (st._language == Language.Korean) {
            return _buildInfoCard('오류', '정보를 불러올 수 없습니다.');
          } else {
            return _buildInfoCard('Error', 'Failed to load data.');
          }
        }
        // 데이터가 없거나, 버스가 운행 종료되었을 때
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          if (st._language == Language.Korean) {
            return _buildInfoCard('정보 없음', '');
          } else {
            return _buildInfoCard('No Bus', '');
          }
        }

        // 성공적으로 데이터를 가져왔을 때
        final arriveInfo = snapshot.data!.first; // 보통 하나의 정보만 오므로 first 사용

        // 표시할 텍스트들을 준비
        final busNo = arriveInfo.routeNo;
        final nodeNm = arriveInfo.nodeName;
        final remainingTime = (arriveInfo.arrtime / 60).toInt();
        final remainingStops = arriveInfo.arrprevstationcnt;

        final mainText = st._language == Language.Korean
            ? '${busNo}, ${nodeNm}까지'
            : '${busNo} to ${stop_data_EN[widget.nodeindex][1]}';
        final subText = st._language == Language.Korean
            ? '남은 시간: ${remainingTime}분, ${remainingStops}개 정류장 전'
            : 'Remaining: ${remainingTime}min, ${remainingStops} stops';

        // 만들어진 텍스트로 카드 UI를 구성하여 반환
        return _buildInfoCard(mainText, subText);
      },
    );
  }
}

class DetailPage_onAI extends StatefulWidget {
  final String id, name;
  final int index, apiid;

  const DetailPage_onAI({
    super.key,
    required this.id,
    required this.name,
    required this.index,
    required this.apiid,
  });

  @override
  State<DetailPage_onAI> createState() => _DetailPage_onAI();
}

class _DetailPage_onAI extends State<DetailPage_onAI> {
  var st;
  late List<dynamic> data;
  late List<RouteInfo> buses;
  static const String baseUrl = "http://13.125.234.0:8000/api/buses/station/";//todo limit 물어보기

  void getdata() {
    if (st._language == Language.Korean) {
      data = stop_data[widget.index];
      List<dynamic> busindexs = stop_buses_data[widget.index];
      buses = [];
      for (int i = 0; i < busindexs.length; i++) {
        buses.add(
          RouteInfo(
            routeId: bus_data[busindexs[i]][1].toString(),
            routeNo: bus_data[busindexs[i]][2].toString(),
            routeTp: bus_data[busindexs[i]][3].toString(),
            startStName: bus_data[busindexs[i]][4].toString(),
            endStName: bus_data[busindexs[i]][0].toString(),
            busindex: busindexs[i],
          ),
        );
      }
    } else {
      data = stop_data_EN[widget.index];
      List<dynamic> busindexs = stop_buses_data[widget.index];
      buses = [];
      for (int i = 0; i < busindexs.length; i++) {
        buses.add(
          RouteInfo(
            routeId: bus_data_EN[busindexs[i]][1].toString(),
            routeNo: bus_data_EN[busindexs[i]][2].toString(),
            routeTp: bus_data_EN[busindexs[i]][3].toString(),
            startStName: bus_data_EN[busindexs[i]][4].toString(),
            endStName: bus_data_EN[busindexs[i]][0].toString(),
            busindex: busindexs[i],
          ),
        );
      }
    }
  }

  Future<List<StoparriveInfo_onAI2>> getarriveInfos() async {
    try {
      final url = Uri.parse("$baseUrl${widget.id}");
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final String body = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(body);

        late final List<dynamic> items;

        if (jsonResponse.isEmpty) {
          // 데이터가 null 이면 빈 리스트 반환
          return [];
        }
        items = jsonResponse;
        final List<StoparriveInfo_onAI2> result = items
            .map((json) => StoparriveInfo_onAI2.fromJson(json))
            .toList();
        return result;
      } else {
        // 5. 서버 오류 (예: 400 Bad Request, 403 Forbidden 등)
        throw Exception('API 요청 실패 (Status Code: ${response.statusCode})');
      }
    } on TimeoutException {
      // ✨ 2. 타임아웃 오류: 서버가 요청을 받았지만 5초 안에 응답을 주지 않은 경우
      print('AI 서버 응답 시간 초과: TimeoutException.');
      return [];
      //throw Exception('AI 서버가 응답하지 않습니다.');
    } catch (e) {
      // 6. 네트워크 오류 (인터넷 연결 끊김 등)
      print('AI 도착 네트워크 요청 중 오류 발생: $e');
      throw Exception('데이터 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    st = Provider.of<Stackwid>(context, listen: true);
    if (st.apistackid.last != widget.apiid) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Some widget is on top of this page.\nIf you see this, please restart the app.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    getdata();
    Icon star = Icon(
      Icons.star_border, // 일반 별 모양 아이콘
      color: Colors.black, // 아이콘 색상
    );
    Map<String, int> check = {'type': 1, 'index': widget.index};
    bool favorite = false;
    int favorite_index = -1;
    for (int i = 0; i < st.favorite_list.length; i++) {
      if (check['type'] == st.favorite_list[i]['type'] &&
          check['index'] == st.favorite_list[i]['index']) {
        star = Icon(
          Icons.star, // 일반 별 모양 아이콘
          color: Colors.yellow, // 아이콘 색상
        );
        favorite = true;
        favorite_index = i;
        break;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${data[1]}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: st._fontsize == Fontsize.Normal ? 22 : 30,
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          // 아이콘으로 만들어진 버튼
          IconButton(
            icon: star,
            // 버튼을 눌렀을 때 실행될 동작
            onPressed: () {
              //삭제
              if (favorite) {
                st.deleteFavorite(favorite_index);
              }
              //추가
              else {
                st.addFavorite(check);
              }
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getarriveInfos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 중일 때
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // 오류 발생 시
            String errortext =
                '앗! 문제가 발생했어요. 새로고침 해주세요.\n(오류 : ${snapshot.error})';
            if (st._language == Language.English) {
              errortext =
                  'Oops! Something went wrong. Please refresh.\n(Error: ${snapshot.error})';
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errortext, //'\nError: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            // 데이터 수신 성공 시
            final List<StoparriveInfo_onAI2> arrives =
                snapshot.data as List<StoparriveInfo_onAI2>;
            int arricount = arrives.length;
            if (buses.isEmpty) {
              return const Center(child: Text('해당 정류장을 경유하는 노선이 없습니다.'));
            }
            for (int i = 0; i < arrives.length; i++) {
              for (int j = 0; j < buses.length; j++) {
                if (arrives[i].routeID == buses[j].routeId) {
                  RouteInfo temp = buses.removeAt(j);
                  buses.insert(0, temp);
                  break;
                }
              }
            }
            // 노선 리스트를 ListView로 출력
            return Stack(
              children: [
                ListView.builder(
                  itemCount: buses.length,
                  itemBuilder: (context, index) {
                    final route = buses[index];
                    String arrtime = '도착 예정 없음';
                    if (st._language == Language.English) {
                      arrtime = 'N/A';
                    }
                    TextStyle style = TextStyle(fontSize: 10);
                    Icon busicon = Icon(
                      Icons.directions_bus,
                      color: Colors.green,
                    );
                    if (route.routeTp == '좌석버스') {
                      busicon = Icon(
                        Icons.directions_bus,
                        color: Colors.purple,
                      );
                    }
                    for (int i = 0; i < arricount; i++) {
                      if (route.routeId == arrives[i].routeID) {
                        if (st._language == Language.Korean) {
                          arrtime = '${(arrives[i].arrtime / 60).toInt()}분';
                        } else {
                          arrtime = '${(arrives[i].arrtime / 60).toInt()}min';
                        }
                        style = TextStyle(
                          fontSize: st._fontsize == Fontsize.Normal ? 15 : 30,
                          fontWeight: FontWeight.bold,
                        );
                        if (arrives[i].mode == "predicted") {
                          style = TextStyle(
                            fontSize: st._fontsize == Fontsize.Normal ? 15 : 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          );
                        }
                        if ((arrives[i].arrtime / 60) <= 2 ||
                            arrives[i].arrprevstationcnt <= 1) {
                          if (st._language == Language.Korean) {
                            arrtime = '곧도착($arrtime)';
                          } else {
                            arrtime = 'Soon($arrtime)';
                          }
                          style = TextStyle(
                            fontSize: st._fontsize == Fontsize.Normal ? 15 : 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          );
                        }
                        break;
                      }
                    }
                    Text subTitle = Text(
                      '${route.endStName}방면',
                      style: TextStyle(
                        fontSize: st._fontsize == Fontsize.Normal ? 14 : 20,
                      ),
                    );
                    if (st._language == Language.English) {
                      subTitle = Text(
                        'To ${route.endStName}',
                        style: TextStyle(
                          fontSize: st._fontsize == Fontsize.Normal ? 14 : 20,
                        ),
                      );
                    }
                    return ListTile(
                      leading: busicon,
                      title: Text(
                        '${route.routeNo}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: st._fontsize == Fontsize.Normal ? 16 : 30,
                        ),
                      ),
                      subtitle: subTitle,
                      trailing: Text(arrtime, style: style),
                      onTap: () {
                        if (st._aimode &&
                            (route.busindex == 263 ||
                                route.busindex == 96 ||
                                route.busindex == 325 ||
                                route.busindex == 6)) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('AI모드 버스'),
                                // content에 원하는 내용을 추가할 수 있습니다.
                                content: st._language == Language.Korean
                                    ? Text('이 버스는 AI모드를 지원해요. AI모드로 보실래요?')
                                    : Text(
                                        'This bus supports AI mode. Do you want to see it?',
                                      ),
                                actions: <Widget>[
                                  TextButton(
                                    child: st._language == Language.Korean
                                        ? Text('예')
                                        : Text('Yes'),
                                    onPressed: () {
                                      Widget addw = Align(
                                        // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height:
                                              MediaQuery.of(
                                                this.context,
                                              ).size.height *
                                              0.5,
                                          width: double.infinity,
                                          child: busRoutePage_onAI(
                                            id: route.routeId,
                                            number: route.routeNo,
                                            index: route.busindex,
                                            apiid: st.allocateapiid(),
                                          ),
                                        ),
                                      );
                                      st.updateStack(this.context, addw, 2);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: st._language == Language.Korean
                                        ? Text('아니오')
                                        : Text('No'),
                                    onPressed: () {
                                      Widget addw = Align(
                                        // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height:
                                              MediaQuery.of(
                                                this.context,
                                              ).size.height *
                                              0.5,
                                          width: double.infinity,
                                          child: busRoutePage(
                                            id: route.routeId,
                                            number: route.routeNo,
                                            index: route.busindex,
                                            apiid: st.allocateapiid(),
                                          ),
                                        ),
                                      );
                                      st.updateStack(this.context, addw, 2);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          Widget addw = Align(
                            // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              width: double.infinity,
                              child: busRoutePage(
                                id: route.routeId,
                                number: route.routeNo,
                                index: route.busindex,
                                apiid: st.allocateapiid(),
                              ),
                            ),
                          );
                          st.updateStack(context, addw, 2);
                        }
                      },
                    );
                  },
                ),
                IgnorePointer(
                  ignoring: true,
                  child: Center(
                    child: Text(
                      st._language == Language.Korean
                          ? 'AI 예측 정보이므로\n실제와 차이가 있을 수 있습니다.'
                          : 'These are AI predictions.\nIt may differ from actual times.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.withOpacity(0.6),
                        // 투명도가 있는 연한 회색으로 설정
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }

          // 기본 반환 (발생할 일은 거의 없음)
          return const Center(child: Text('데이터를 찾을 수 없습니다.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        child: const Icon(Icons.refresh),
        mini: true,
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // KakaoMap API javascript 키 입력
  const kakaoJavascriptKey = "YOUR_CODE";
  runApp(const MyApp(kakaoJavascriptKey: kakaoJavascriptKey));
}

class Searchpage extends StatefulWidget {
  final BuildContext maincontext;

  const Searchpage({super.key, required this.maincontext});

  @override
  State<Searchpage> createState() => _Searchpage();
}

class _Searchpage extends State<Searchpage> {
  final TextEditingController _searchController = TextEditingController();
  var st;

  // 필터링된 결과를 담을 리스트 (초기에는 전체 데이터를 포함)
  List<Map<String, dynamic>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    // 2. 초기화: 처음에는 전체 데이터를 표시합니다.
    _filteredList = [];

    // 3. 리스너 추가: _searchController의 텍스트가 변경될 때마다 _filterList 함수를 호출합니다.
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    // 위젯이 파괴될 때 리스너를 제거하여 메모리 누수를 방지합니다.
    _searchController.removeListener(_filterList);
    _searchController.dispose();
    super.dispose();
  }

  // 4. 검색 필터링 로직
  void _filterList() {
    // 입력된 텍스트를 소문자로 변환하여 검색어(query)로 사용합니다.
    final String query = _searchController.text.toLowerCase();

    // 상태를 업데이트(_filteredList 변경)하여 화면을 갱신합니다.
    setState(() {
      _filteredList.clear();
      if (query.isEmpty) {
        // 검색어가 비어 있으면 전체 데이터를 표시합니다.
        //_filteredList = List.from(_allData);
        _filteredList = [];
      } else {
        // 검색어에 해당하는 항목들만 필터링합니다.
        for (int i = 0; i < search_data[0].length; i++) {
          final String item = search_data[0][i];
          if (item.toLowerCase().contains(query)) {
            _filteredList.add({'text': item, 'index': i});
          }
        }
      }
    });
  }

  //bool isVisible=true;
  @override
  Widget build(BuildContext context) {
    st = Provider.of<Stackwid>(context, listen: true);
    String label = '검색';
    String hint = '항목을 검색하세요';
    String noResult = '검색 결과가 없습니다.';
    if (st._language == Language.English) {
      label = 'Search';
      hint = 'Enter what you are looking for';
      noResult = 'No Result';
    }
    return Visibility(
      visible: st.search_visibility,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // 5. 검색창 (TextField) 구현
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                prefixIcon: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    st.backStack1(widget.maincontext);
                  },
                ),
                //const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                // 검색어 지우기 버튼 추가
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          // 버튼을 누르면 텍스트를 지우고 필터링을 다시 실행합니다.
                          _searchController.clear();
                          // clear()를 호출하면 addListener에 의해 _filterList가 자동으로 호출됩니다.
                        },
                      )
                    : null,
              ),
              // onChanged를 사용하지 않고 addListener를 사용했으므로 여기서 추가 작업은 필요 없습니다.
              // onChanged: (value) => _filterList(), // 이 방식도 사용 가능
            ),

            // 6. 필터링된 결과를 표시하는 리스트
            Expanded(
              child: _filteredList.isEmpty
                  ? Center(child: Text('$noResult'))
                  : ListView.builder(
                      itemCount: _filteredList.length,
                      itemBuilder: (context, index) {
                        Text title = Text(
                          _filteredList[index]['text'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: st._fontsize == Fontsize.Normal ? 16 : 30,
                          ),
                        );
                        int type = int.parse(
                          search_data[1][_filteredList[index]['index']],
                        );
                        int dataindex = int.parse(
                          search_data[2][_filteredList[index]['index']],
                        );
                        if (type == 0) {
                          title = Text(
                            '${_filteredList[index]['text']} (${bus_data[dataindex][0]} 방면)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: st._fontsize == Fontsize.Normal
                                  ? 16
                                  : 30,
                            ),
                          );
                          if (st._language == Language.English) {
                            title = Text(
                              '${_filteredList[index]['text']} (To ${bus_data_EN[dataindex][0]})',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: st._fontsize == Fontsize.Normal
                                    ? 16
                                    : 30,
                              ),
                            );
                          }
                        }
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title:
                                title,
                            onTap: () {
                              if (type == 0) {
                                if (st._aimode &&
                                    (dataindex == 263 ||
                                        dataindex == 96 ||
                                        dataindex == 325 ||
                                        dataindex == 6)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('AI모드 버스'),
                                        // content에 원하는 내용을 추가할 수 있습니다.
                                        content: st._language == Language.Korean
                                            ? Text(
                                                '이 버스는 AI모드를 지원해요. AI모드로 보실래요?',
                                              )
                                            : Text(
                                                'This bus supports AI mode. Do you want to see it?',
                                              ),
                                        actions: <Widget>[
                                          TextButton(
                                            child:
                                                st._language == Language.Korean
                                                ? Text('예')
                                                : Text('Yes'),
                                            onPressed: () {
                                              Widget addw = Align(
                                                // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  height:
                                                      MediaQuery.of(
                                                        widget.maincontext,
                                                      ).size.height *
                                                      0.5,
                                                  width: double.infinity,
                                                  child: busRoutePage_onAI(
                                                    id: bus_data[dataindex][1],
                                                    number:
                                                        bus_data[dataindex][2]
                                                            .toString(),
                                                    index: dataindex,
                                                    apiid: st.allocateapiid(),
                                                  ),
                                                ),
                                              );
                                              st.updateStack(
                                                widget.maincontext,
                                                addw,
                                                2,
                                              );
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child:
                                                st._language == Language.Korean
                                                ? Text('아니오')
                                                : Text('No'),
                                            onPressed: () {
                                              Widget addw = Align(
                                                // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  height:
                                                      MediaQuery.of(
                                                        widget.maincontext,
                                                      ).size.height *
                                                      0.5,
                                                  width: double.infinity,
                                                  child: busRoutePage(
                                                    id: bus_data[dataindex][1],
                                                    number:
                                                        bus_data[dataindex][2]
                                                            .toString(),
                                                    index: dataindex,
                                                    apiid: st.allocateapiid(),
                                                  ),
                                                ),
                                              );
                                              st.updateStack(
                                                widget.maincontext,
                                                addw,
                                                2,
                                              );
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  Widget addw = Align(
                                    // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      height:
                                          MediaQuery.of(
                                            widget.maincontext,
                                          ).size.height *
                                          0.5,
                                      width: double.infinity,
                                      child: busRoutePage(
                                        id: bus_data[dataindex][1],
                                        number: bus_data[dataindex][2]
                                            .toString(),
                                        index: dataindex,
                                        apiid: st.allocateapiid(),
                                      ),
                                    ),
                                  );
                                  st.updateStack(widget.maincontext, addw, 2);
                                }
                              } else {
                                if (st._aimode &&
                                    (dataindex == 122 ||
                                        dataindex == 123 ||
                                        dataindex == 124)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: st._language == Language.Korean
                                            ? Text('AI모드 정류장')
                                            : Text('AI Mode Stop'),
                                        // content에 원하는 내용을 추가할 수 있습니다.
                                        content: st._language == Language.Korean
                                            ? Text(
                                                '이 정류장은 AI모드를 지원해요. AI모드로 보실래요?',
                                              )
                                            : Text(
                                                'This stop supports AI mode. Do you want to see it?',
                                              ),
                                        actions: <Widget>[
                                          TextButton(
                                            child:
                                                st._language == Language.Korean
                                                ? Text('예')
                                                : Text('Yes'),
                                            onPressed: () {
                                              final selectstop = jsonEncode({
                                                "lati": stop_data[dataindex][3],
                                                "long": stop_data[dataindex][4],
                                              });
                                              _controller.runJavaScript(
                                                'selectstop_insearch($selectstop)',
                                              );

                                              Widget addw = Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  height:
                                                      MediaQuery.of(
                                                        widget.maincontext,
                                                      ).size.height *
                                                      0.5,
                                                  width: double.infinity,
                                                  child: DetailPage_onAI(
                                                    id: stop_data[dataindex][0],
                                                    name:
                                                        stop_data[dataindex][1],
                                                    index: dataindex,
                                                    apiid: st.allocateapiid(),
                                                  ),
                                                ),
                                              );
                                              st.updateStack(
                                                widget.maincontext,
                                                addw,
                                                1,
                                              );
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child:
                                                st._language == Language.Korean
                                                ? Text('아니오')
                                                : Text('No'),
                                            onPressed: () {
                                              final selectstop = jsonEncode({
                                                "lati": stop_data[dataindex][3],
                                                "long": stop_data[dataindex][4],
                                              });
                                              _controller.runJavaScript(
                                                'selectstop_insearch($selectstop)',
                                              );

                                              Widget addw = Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  height:
                                                      MediaQuery.of(
                                                        widget.maincontext,
                                                      ).size.height *
                                                      0.5,
                                                  width: double.infinity,
                                                  child: DetailPage(
                                                    id: stop_data[dataindex][0],
                                                    name:
                                                        stop_data[dataindex][1],
                                                    index: dataindex,
                                                    apiid: st.allocateapiid(),
                                                  ),
                                                ),
                                              );
                                              st.updateStack(
                                                widget.maincontext,
                                                addw,
                                                1,
                                              );
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  final selectstop = jsonEncode({
                                    "lati": stop_data[dataindex][3],
                                    "long": stop_data[dataindex][4],
                                  });
                                  _controller.runJavaScript(
                                    'selectstop_insearch($selectstop)',
                                  );

                                  Widget addw = Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      height:
                                          MediaQuery.of(
                                            widget.maincontext,
                                          ).size.height *
                                          0.5,
                                      width: double.infinity,
                                      child: DetailPage(
                                        id: stop_data[dataindex][0],
                                        name: stop_data[dataindex][1],
                                        index: dataindex,
                                        apiid: st.allocateapiid(),
                                      ),
                                    ),
                                  );
                                  st.updateStack(widget.maincontext, addw, 1);
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
    //);
  }
}

class Favoritepage extends StatefulWidget {
  final BuildContext maincontext;

  const Favoritepage({super.key, required this.maincontext});

  @override
  State<Favoritepage> createState() => _Favoritepage();
}

class _Favoritepage extends State<Favoritepage> {
  var st;

  @override
  Widget build(BuildContext context) {
    st = Provider.of<Stackwid>(context, listen: true);
    String title = '즐겨찾기';
    String noFavo = '즐겨찾기 목록이 비어있습니다.';
    if (st._language == Language.English) {
      title = 'Favorites';
      noFavo = 'No List';
    }
    return Visibility(
      visible: st.favoritepage_visibility,
      replacement: const SizedBox.shrink(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // Stackwid의 backStack1 메서드를 호출하여 이전 화면으로 돌아갑니다.
              st.backStack1(widget.maincontext);
            },
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: st._fontsize == Fontsize.Normal ? 22 : 30,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1, // AppBar에 약간의 그림자 효과를 줍니다.
        ),
        body: st.favorite_list.isEmpty
            // 비어있다면 안내 메시지를 중앙에 표시합니다.
            ? Center(
                child: Text(
                  noFavo, //'즐겨찾기 목록이 비어있습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            // 비어있지 않다면 ListView.builder를 사용하여 목록을 만듭니다.
            : ListView.builder(
                itemCount: st.favorite_list.length,
                itemBuilder: (context, index) {
                  // 현재 인덱스의 즐겨찾기 데이터를 가져옵니다.
                  final favoriteItem = st.favorite_list[index];
                  final itemType = favoriteItem['type'];
                  final itemIndex = favoriteItem['index']!;

                  Icon leadingIcon;
                  String title;
                  String subtitle;

                  // 타입에 따라 아이콘, 제목, 부제목을 설정합니다.
                  if (itemType == 0) {
                    // 버스인 경우
                    leadingIcon = const Icon(
                      Icons.directions_bus,
                      color: Colors.indigo,
                    );
                    title = '${bus_data[itemIndex][2]}';
                    subtitle = '${bus_data[itemIndex][0]} 방면';
                    if (st._language == Language.English) {
                      subtitle = 'To ${bus_data_EN[itemIndex][0]}';
                    }
                  } else {
                    // 정류장인 경우
                    leadingIcon = const Icon(
                      Icons.location_on,
                      color: Colors.green,
                    );
                    title = stop_data[itemIndex][1]; // 정류장 이름
                    subtitle = '${stop_data[itemIndex][2]}';
                    if (st._language == Language.English) {
                      title = '${stop_data_EN[itemIndex][1]}';
                      subtitle = '${stop_data_EN[itemIndex][2]}';
                    }
                  }

                  // 각 항목을 Card와 ListTile로 예쁘게 표시합니다.
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: leadingIcon,
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: st._fontsize == Fontsize.Normal ? 16 : 25,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: st._fontsize == Fontsize.Normal ? 14 : 20,
                        ),
                      ),
                      // X 버튼을 오른쪽에 추가하여 삭제 기능을 구현합니다.
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          // 삭제 버튼을 누르면 해당 항목을 즐겨찾기에서 제거합니다.
                          st.deleteFavorite(index);
                          setState(() {});
                        },
                      ),
                      onTap: () {
                        // 리스트 항목을 탭했을 때의 동작
                        if (itemType == 0) {
                          // 버스
                          if (st._aimode &&
                              (itemIndex == 263 ||
                                  itemIndex == 96 ||
                                  itemIndex == 325 ||
                                  itemIndex == 6)) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('AI모드 버스'),
                                  // content에 원하는 내용을 추가할 수 있습니다.
                                  content: st._language == Language.Korean
                                      ? Text('이 버스는 AI모드를 지원해요. AI모드로 보실래요?')
                                      : Text(
                                          'This bus supports AI mode. Do you want to see it?',
                                        ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: st._language == Language.Korean
                                          ? Text('예')
                                          : Text('Yes'),
                                      onPressed: () {
                                        Widget addw = Align(
                                          // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height:
                                                MediaQuery.of(
                                                  widget.maincontext,
                                                ).size.height *
                                                0.5,
                                            width: double.infinity,
                                            child: busRoutePage_onAI(
                                              id: bus_data[itemIndex][1],
                                              number: bus_data[itemIndex][2]
                                                  .toString(),
                                              index: itemIndex,
                                              apiid: st.allocateapiid(),
                                            ),
                                          ),
                                        );
                                        st.updateStack(
                                          widget.maincontext,
                                          addw,
                                          2,
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: st._language == Language.Korean
                                          ? Text('아니오')
                                          : Text('No'),
                                      onPressed: () {
                                        Widget addw = Align(
                                          // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height:
                                                MediaQuery.of(
                                                  widget.maincontext,
                                                ).size.height *
                                                0.5,
                                            width: double.infinity,
                                            child: busRoutePage(
                                              id: bus_data[itemIndex][1],
                                              number: bus_data[itemIndex][2]
                                                  .toString(),
                                              index: itemIndex,
                                              apiid: st.allocateapiid(),
                                            ),
                                          ),
                                        );
                                        st.updateStack(
                                          widget.maincontext,
                                          addw,
                                          2,
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            Widget addw = Align(
                              // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height:
                                    MediaQuery.of(
                                      widget.maincontext,
                                    ).size.height *
                                    0.5,
                                width: double.infinity,
                                child: busRoutePage(
                                  id: bus_data[itemIndex][1],
                                  number: bus_data[itemIndex][2].toString(),
                                  index: itemIndex,
                                  apiid: st.allocateapiid(),
                                ),
                              ),
                            );
                            st.updateStack(widget.maincontext, addw, 2);
                          }
                        } else {
                          //정류장
                          if (st._aimode &&
                              (itemIndex == 122 ||
                                  itemIndex == 123 ||
                                  itemIndex == 124)) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: st._language == Language.Korean
                                      ? Text('AI모드 정류장')
                                      : Text('AI Mode Stop'),
                                  // content에 원하는 내용을 추가할 수 있습니다.
                                  content: st._language == Language.Korean
                                      ? Text('이 정류장은 AI모드를 지원해요. AI모드로 보실래요?')
                                      : Text(
                                          'This stop supports AI mode. Do you want to see it?',
                                        ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: st._language == Language.Korean
                                          ? Text('예')
                                          : Text('Yes'),
                                      onPressed: () {
                                        final selectstop = jsonEncode({
                                          "lati": stop_data[itemIndex][3],
                                          "long": stop_data[itemIndex][4],
                                        });
                                        _controller.runJavaScript(
                                          'selectstop_insearch($selectstop)',
                                        );
                                        Widget addw = Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height:
                                                MediaQuery.of(
                                                  widget.maincontext,
                                                ).size.height *
                                                0.5,
                                            width: double.infinity,
                                            child: DetailPage_onAI(
                                              id: stop_data[itemIndex][0],
                                              name: stop_data[itemIndex][1],
                                              index: itemIndex,
                                              apiid: st.allocateapiid(),
                                            ),
                                          ),
                                        );
                                        st.updateStack(
                                          widget.maincontext,
                                          addw,
                                          1,
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: st._language == Language.Korean
                                          ? Text('아니오')
                                          : Text('No'),
                                      onPressed: () {
                                        final selectstop = jsonEncode({
                                          "lati": stop_data[itemIndex][3],
                                          "long": stop_data[itemIndex][4],
                                        });
                                        _controller.runJavaScript(
                                          'selectstop_insearch($selectstop)',
                                        );

                                        Widget addw = Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height:
                                                MediaQuery.of(
                                                  widget.maincontext,
                                                ).size.height *
                                                0.5,
                                            width: double.infinity,
                                            child: DetailPage(
                                              id: stop_data[itemIndex][0],
                                              name: stop_data[itemIndex][1],
                                              index: itemIndex,
                                              apiid: st.allocateapiid(),
                                            ),
                                          ),
                                        );
                                        st.updateStack(
                                          widget.maincontext,
                                          addw,
                                          1,
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            final selectstop = jsonEncode({
                              "lati": stop_data[itemIndex][3],
                              "long": stop_data[itemIndex][4],
                            });
                            _controller.runJavaScript(
                              'selectstop_insearch($selectstop)',
                            );

                            Widget addw = Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height:
                                    MediaQuery.of(
                                      widget.maincontext,
                                    ).size.height *
                                    0.5,
                                width: double.infinity,
                                child: DetailPage(
                                  id: stop_data[itemIndex][0],
                                  name: stop_data[itemIndex][1],
                                  index: itemIndex,
                                  apiid: st.allocateapiid(),
                                ),
                              ),
                            );
                            st.updateStack(widget.maincontext, addw, 1);
                          }
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class accessibility extends StatefulWidget {
  const accessibility({super.key});

  @override
  State<accessibility> createState() => _accessibility();
}

class _accessibility extends State<accessibility> {
  var st;
  late Widget resultwidget;

  @override
  Widget build(BuildContext context) {
    st = Provider.of<Stackwid>(context, listen: true);
    TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: st._fontsize == Fontsize.Normal ? 18 : 25,
    );
    // 버튼의 현재 위치를 계산합니다. (buttons 메서드의 위치 계산과 동일하게)
    if (st._language == Language.Korean) {
      if (st.getlastwidget() == 0) {
        final double buttonBottomPosition =
            MediaQuery.of(context).size.height - 76.0;
        resultwidget = IgnorePointer(
          ignoring: true, // 항상 터치를 무시하도록 설정
          child: Stack(
            // 여러 위젯을 겹쳐야 하므로 Stack을 사용합니다.
            children: [
              // 1. 기존의 하단 안내 문구 (위치 조정 불필요)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                child: Align(
                  //const Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0, bottom: 50.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          color: Colors.black,
                          size: 50,
                        ),
                        Text(
                          '지도를 움직여 정류장을 찾고\n눌러서 정류장 정보를 확인하세요',
                          textAlign: TextAlign.start, // 왼쪽 정렬로 변경
                          style: textStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. 버튼 옆 설명 텍스트들을 추가합니다.
              // Positioned를 사용하여 각 설명의 위치를 버튼 옆으로 정확히 지정합니다.

              // 검색 버튼 설명
              Positioned(
                left: 75, // 아이콘 너비(50) + 여백(20)
                bottom: st._fontsize == Fontsize.Normal
                    ? buttonBottomPosition + 5
                    : buttonBottomPosition - 2, // 첫 번째 버튼의 높이에 맞춤
                child: Text('검색하기', style: textStyle),
              ),

              // 즐겨찾기 버튼 설명
              Positioned(
                left: 75,
                bottom: st._fontsize == Fontsize.Normal
                    ? buttonBottomPosition - 55
                    : buttonBottomPosition - 62,// 두 번째 버튼의 높이에 맞춤
                child: Text('즐겨찾기', style: textStyle),
              ),

              // 도움말 버튼 설명
              Positioned(
                left: 75,
                bottom: st._fontsize == Fontsize.Normal
                    ? buttonBottomPosition - 115
                    : buttonBottomPosition - 122,// 세 번째 버튼의 높이에 맞춤
                child: Text('도움말', style: textStyle),
              ),
              Positioned(
                right: 60,
                top: st._fontsize == Fontsize.Normal ? 37 : 30,
                child: Text('내 위치', style: textStyle),
              ),
            ],
          ),
        );
      } else if (st.getlastwidget() == 1) {
        resultwidget = IgnorePointer(
          ignoring: true, // 항상 터치를 무시하도록 설정
          child: Stack(
            // 여러 위젯을 겹쳐야 하므로 Stack을 사용합니다.
            children: [
              // Positioned 위젯으로 가이드 텍스트의 위치를 지정합니다.
              Positioned(
                top: MediaQuery.of(context).size.height * 0.5 + 10,
                right: 40,
                child: Text(
                  '즐겨찾기\n추가',
                  textAlign: TextAlign.right,
                  style: textStyle,
                ),
              ),
              Positioned(
                // 화면 가로 중앙에 위치하도록 설정합니다.
                left: 10,
                right: 0,
                // 화면 높이의 중앙보다 살짝 위쪽에 배치하여 DetailPage와 겹치지 않게 합니다.
                // 이 값을 조절하여 원하는 위치를 맞출 수 있습니다.
                //top: MediaQuery.of(context).size.height * 0.35,
                bottom: MediaQuery.of(context).size.height * 0.5 + 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: Colors.black, size: 50),
                    Text(
                      '버스 도착 정보를 볼 수 있고,\n누르면 버스 정보를 확인할 수 있어요',
                      textAlign: TextAlign.left,
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (st.getlastwidget() == 2) {
        resultwidget = IgnorePointer(
          ignoring: true, // 항상 터치를 무시하도록 설정
          child: Stack(
            // 여러 위젯을 겹쳐야 하므로 Stack을 사용합니다.
            children: [
              // Positioned 위젯으로 가이드 텍스트의 위치를 지정합니다.
              Positioned(
                top: MediaQuery.of(context).size.height * 0.5 + 10,
                right: 40,
                child: Text(
                  '즐겨찾기\n추가',
                  textAlign: TextAlign.right,
                  style: textStyle,
                ),
              ),
              Positioned(
                // 화면 가로 중앙에 위치하도록 설정합니다.
                left: 10,
                right: 0,
                // 화면 높이의 중앙보다 살짝 위쪽에 배치하여 DetailPage와 겹치지 않게 합니다.
                // 이 값을 조절하여 원하는 위치를 맞출 수 있습니다.
                bottom: MediaQuery.of(context).size.height * 0.5 + 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.directions_bus, // 즐겨찾기 아이콘
                      color: Colors.black,
                      size: 50,
                    ),
                    //SizedBox(height: 8),
                    Text(
                      '버스 노선을 볼 수 있고,\n누르면 정류장으로 이동해요',
                      textAlign: TextAlign.left,
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (st.getlastwidget() == 3) {
        resultwidget = IgnorePointer(
          ignoring: true, // 항상 터치를 무시하도록 설정
          child: Stack(
            // 여러 위젯을 겹쳐야 하므로 Stack을 사용합니다.
            children: [
              Positioned(
                // 화면 가로 중앙에 위치하도록 설정합니다.
                left: 15,
                right: 0,
                // 화면 높이의 중앙보다 살짝 위쪽에 배치하여 DetailPage와 겹치지 않게 합니다.
                // 이 값을 조절하여 원하는 위치를 맞출 수 있습니다.]
                top: MediaQuery.of(context).size.height * 0.5 + 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.search, // 즐겨찾기 아이콘
                      color: Colors.black,
                      size: 50,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '찾으시는 걸 입력하시고,\n누르면 정보를 볼 수 있어요',
                      textAlign: TextAlign.left,
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (st.getlastwidget() == 4) {
        resultwidget = IgnorePointer(
          ignoring: true, // 항상 터치를 무시하도록 설정
          child: Stack(
            // 여러 위젯을 겹쳐야 하므로 Stack을 사용합니다.
            children: [
              Positioned(
                // 화면 가로 중앙에 위치하도록 설정합니다.
                left: 20,
                right: 0,
                // 화면 높이의 중앙보다 살짝 위쪽에 배치하여 DetailPage와 겹치지 않게 합니다.
                // 이 값을 조절하여 원하는 위치를 맞출 수 있습니다.
                bottom: MediaQuery.of(context).size.height * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.star, // 즐겨찾기 아이콘
                      color: Colors.black,
                      size: 50,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '직접 찾지 않아도,\n바로 정보를 볼 수 있어요',
                      textAlign: TextAlign.left,
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    } else {
      if (st.getlastwidget() == 0) {
        final double buttonBottomPosition =
            MediaQuery.of(context).size.height - 76.0;
        resultwidget = IgnorePointer(
          ignoring: true, // 항상 터치를 무시하도록 설정
          child: Stack(
            // 여러 위젯을 겹쳐야 하므로 Stack을 사용합니다.
            children: [
              // 1. 기존의 하단 안내 문구 (위치 조정 불필요)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0, bottom: 50.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          color: Colors.black,
                          size: 50,
                        ),
                        Text(
                          //'지도를 움직여 정류장을 찾고\n눌러서 정류장 정보를 확인하세요',
                          'Move the map to find a stop\nTap to check stop information',
                          textAlign: TextAlign.start, // 왼쪽 정렬로 변경
                          style: textStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. 버튼 옆 설명 텍스트들을 추가합니다.
              // Positioned를 사용하여 각 설명의 위치를 버튼 옆으로 정확히 지정합니다.

              // 검색 버튼 설명
              Positioned(
                left: 75, // 아이콘 너비(50) + 여백(20)
                bottom: st._fontsize == Fontsize.Normal
                    ? buttonBottomPosition + 5
                    : buttonBottomPosition - 2, // 첫 번째 버튼의 높이에 맞춤
                child: Text('Search', style: textStyle),
              ),

              // 즐겨찾기 버튼 설명
              Positioned(
                left: 75,
                bottom: st._fontsize == Fontsize.Normal
                    ? buttonBottomPosition - 55
                    : buttonBottomPosition - 62, // 두 번째 버튼의 높이에 맞춤
                child: Text('Favorites', style: textStyle),
              ),

              // 도움말 버튼 설명
              Positioned(
                left: 75,
                bottom: st._fontsize == Fontsize.Normal
                    ? buttonBottomPosition - 115
                    : buttonBottomPosition - 122, // 세 번째 버튼의 높이에 맞춤
                child: Text('Help', style: textStyle),
              ),
              Positioned(
                right: 60,
                top: st._fontsize == Fontsize.Normal ? 37 : 30,
                child: Text('My Location', style: textStyle),
              ),
            ],
          ),
        );
      } else if (st.getlastwidget() == 1) {
        resultwidget = IgnorePointer(
          ignoring: true, // 항상 터치를 무시하도록 설정
          child: Stack(
            // 여러 위젯을 겹쳐야 하므로 Stack을 사용합니다.
            children: [
              // Positioned 위젯으로 가이드 텍스트의 위치를 지정합니다.
              Positioned(
                top: MediaQuery.of(context).size.height * 0.5 + 10,
                right: 40,
                child: Text(
                  'Add to\nFavorites',
                  textAlign: TextAlign.right,
                  style: textStyle,
                ),
              ),
              Positioned(
                // 화면 가로 중앙에 위치하도록 설정합니다.
                left: 10,
                right: 0,
                // 화면 높이의 중앙보다 살짝 위쪽에 배치하여 DetailPage와 겹치지 않게 합니다.
                // 이 값을 조절하여 원하는 위치를 맞출 수 있습니다.
                bottom: MediaQuery.of(context).size.height * 0.5 + 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on, // 즐겨찾기 아이콘
                      color: Colors.black,
                      size: 50,
                    ),
                    Text(
                      'Check arrival information\nTap to check bus information',
                      textAlign: TextAlign.left,
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (st.getlastwidget() == 2) {
        resultwidget = IgnorePointer(
          ignoring: true, // 항상 터치를 무시하도록 설정
          child: Stack(
            // 여러 위젯을 겹쳐야 하므로 Stack을 사용합니다.
            children: [
              // Positioned 위젯으로 가이드 텍스트의 위치를 지정합니다.
              Positioned(
                top: MediaQuery.of(context).size.height * 0.5 + 10,
                right: 40,
                child: Text(
                  'Add to\nFavorites',
                  textAlign: TextAlign.right,
                  style: textStyle,
                ),
              ),
              Positioned(
                // 화면 가로 중앙에 위치하도록 설정합니다.
                left: 10,
                right: 0,
                // 화면 높이의 중앙보다 살짝 위쪽에 배치하여 DetailPage와 겹치지 않게 합니다.
                // 이 값을 조절하여 원하는 위치를 맞출 수 있습니다.
                //top: MediaQuery.of(context).size.height * 0.35,
                bottom: MediaQuery.of(context).size.height * 0.5 + 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.directions_bus, // 즐겨찾기 아이콘
                      color: Colors.black,
                      size: 50,
                    ),
                    Text(
                      'Check bus route\nTap to move to stop',
                      textAlign: TextAlign.left,
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (st.getlastwidget() == 3) {
        resultwidget = IgnorePointer(
          ignoring: true, // 항상 터치를 무시하도록 설정
          child: Stack(
            // 여러 위젯을 겹쳐야 하므로 Stack을 사용합니다.
            children: [
              Positioned(
                // 화면 가로 중앙에 위치하도록 설정합니다.
                left: 15,
                right: 0,
                // 화면 높이의 중앙보다 살짝 위쪽에 배치하여 DetailPage와 겹치지 않게 합니다.
                // 이 값을 조절하여 원하는 위치를 맞출 수 있습니다.
                top: MediaQuery.of(context).size.height * 0.5 + 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.search, color: Colors.black, size: 50),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Enter what you are looking for Click to check the information',
                        textAlign: TextAlign.left,
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (st.getlastwidget() == 4) {
        resultwidget = IgnorePointer(
          ignoring: true, // 항상 터치를 무시하도록 설정
          child: Stack(
            // 여러 위젯을 겹쳐야 하므로 Stack을 사용합니다.
            children: [
              Positioned(
                // 화면 가로 중앙에 위치하도록 설정합니다.
                left: 20,
                right: 0,
                // 화면 높이의 중앙보다 살짝 위쪽에 배치하여 DetailPage와 겹치지 않게 합니다.
                // 이 값을 조절하여 원하는 위치를 맞출 수 있습니다.
                bottom: MediaQuery.of(context).size.height * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.star, // 즐겨찾기 아이콘
                      color: Colors.black,
                      size: 50,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'You can check the information immediately',
                        textAlign: TextAlign.left,
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }
    return resultwidget;
  }
}

class settings extends StatefulWidget {
  const settings({super.key});

  @override
  State<settings> createState() => _settings();
}

enum Language { Korean, English }

enum Fontsize { Normal, Big }

class _settings extends State<settings> {
  late Language _language;
  late Fontsize _fontsize;
  late bool _aimode;
  var st;

  Widget language_twooption(String title) {
    return Row(
      // 가로로 위젯들을 배치합니다.
      children: [
        // 1. 왼쪽에 '언어' 텍스트
        const SizedBox(width: 20),
        Text(title, style: TextStyle(fontSize: 20)),

        // 2. 남는 공간을 모두 차지하여 오른쪽으로 밀어내는 역할
        const Spacer(),

        // 3. 오른쪽에 언어 선택 버튼들
        // 선택된 언어에 따라 배경색과 글자색을 다르게 보여주기 위해
        // Material 위젯으로 감싸 디자인합니다.
        Material(
          color: _language == Language.Korean ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.0),
          child: InkWell(
            // 터치 효과를 주기 위해 InkWell 사용
            borderRadius: BorderRadius.circular(20.0),
            onTap: () {
              st.changeLanguage(Language.Korean);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                ' 한국어 ',
                style: TextStyle(
                  color: _language == Language.Korean
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8), // 버튼 사이의 간격

        Material(
          color: _language == Language.English ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20.0),
            onTap: () {
              st.changeLanguage(Language.English);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'English',
                style: TextStyle(
                  color: _language == Language.English
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget fontsize_twooption(String title, String normal, String big) {
    return Row(
      // 가로로 위젯들을 배치합니다.
      children: [
        // 1. 왼쪽에 '언어' 텍스트
        const SizedBox(width: 20),
        Text(title, style: TextStyle(fontSize: 20)),

        // 2. 남는 공간을 모두 차지하여 오른쪽으로 밀어내는 역할
        const Spacer(),

        // 3. 오른쪽에 언어 선택 버튼들
        // 선택된 언어에 따라 배경색과 글자색을 다르게 보여주기 위해
        // Material 위젯으로 감싸 디자인합니다.
        Material(
          color: _fontsize == Fontsize.Normal ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.0),
          child: InkWell(
            // 터치 효과를 주기 위해 InkWell 사용
            borderRadius: BorderRadius.circular(20.0),
            onTap: () {
              st.changeFontsize(Fontsize.Normal);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                normal,
                style: TextStyle(
                  color: _fontsize == Fontsize.Normal
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8), // 버튼 사이의 간격

        Material(
          color: _fontsize == Fontsize.Big ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20.0),
            onTap: () {
              st.changeFontsize(Fontsize.Big);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                big,
                style: TextStyle(
                  color: _fontsize == Fontsize.Big
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget ai_twooption(String title, String on, String off) {
    return Row(
      // 가로로 위젯들을 배치합니다.
      children: [
        // 1. 왼쪽에 '언어' 텍스트
        const SizedBox(width: 20),
        Text(title, style: TextStyle(fontSize: 20)),
        IconButton(
          //todo
          icon: Icon(Icons.help_outline, color: Colors.grey, size: 20),
          // 터치 영역을 너무 넓지 않게 조절
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: st._language == Language.Korean ? Text('AI 모드란?') : Text('What is AI Mode?'),
                  content: st._language == Language.Korean
                      ? Text(
                      'AI를 통해 예측된 버스 도착 정보입니다. 실제 정보와 차이가 있을 수 있으며, 참고용으로만 사용해주세요.\n\n서비스 정류장 : 금오공대종점, 금오공대입구(금오공대종점방면), 금오공대입구(옥계중학교방면)\n서비스 버스 : 10번(구미역(중앙시장) 방면), 196번(구미역(중앙시장) 방면), 960번(구미역(중앙시장) 방면), 80번(인동차고지 방면)')
                      : Text(
                      'This is bus arrival information predicted by AI. It may differ from the actual information and should be used for reference only.\n\n'
                          'Service Stops: Kumoh Institute of Technology terminal, Kumoh Institute of Technology entrance (towards Kumoh Institute of Technology terminal),, Kumoh Institute of Technology entrance (towards Okgye Middle School)\n'
                          'Service Buses: 10 (to Gumi Stn.), 196 (to Gumi Stn.), 960 (to Gumi Stn.), 80 (to Indong Garage)'),

                  actions: <Widget>[
                    TextButton(
                      child: st._language == Language.Korean ? Text('확인') : Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop(); // 다이얼로그 닫기
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),

        // 2. 남는 공간을 모두 차지하여 오른쪽으로 밀어내는 역할
        const Spacer(),

        // 3. 오른쪽에 언어 선택 버튼들
        // 선택된 언어에 따라 배경색과 글자색을 다르게 보여주기 위해
        // Material 위젯으로 감싸 디자인합니다.
        Material(
          color: _aimode == true ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.0),
          child: InkWell(
            // 터치 효과를 주기 위해 InkWell 사용
            borderRadius: BorderRadius.circular(20.0),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: st._language == Language.Korean
                        ? Text('주의!')
                        : Text('Caution!'),
                    // content에 원하는 내용을 추가할 수 있습니다.
                    content: st._language == Language.Korean
                        ? Text('AI 모드는 실제 정보와 다를 수 있습니다!\n사용하시겠어요?')
                        : Text(
                            'AI Mode may differ from the actual information!\nDo you want to use it?',
                          ),
                    actions: <Widget>[
                      TextButton(
                        child: st._language == Language.Korean
                            ? Text('예')
                            : Text('Yes'),
                        onPressed: () {
                          st.changeAImode(true);
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: st._language == Language.Korean
                            ? Text('아니오')
                            : Text('No'),
                        onPressed: () {
                          st.changeAImode(false);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                on,
                style: TextStyle(
                  color: _aimode == true ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8), // 버튼 사이의 간격

        Material(
          color: _aimode == false ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20.0),
            onTap: () {
              st.changeAImode(false);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                off,
                style: TextStyle(
                  color: _aimode == false ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    st = Provider.of<Stackwid>(context, listen: true);
    _language = st._language;
    _fontsize = st._fontsize;
    _aimode = st._aimode;
    //한국어
    if (_language == Language.Korean) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              st.hideSettings();
            },
          ),
          title: const Text('설정'),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            language_twooption('언어'),
            const SizedBox(height: 15),
            fontsize_twooption('글자 크기', '   보통   ', '   크게   '),
            const SizedBox(height: 15),
            ai_twooption('AI 모드', '   켜짐   ', '   꺼짐   '),
          ],
        ),
        //language_twooption('언어'),
      );
    }
    //in English
    else {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              st.hideSettings();
            },
          ),
          title: const Text('Settings'),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            language_twooption('Language'),
            const SizedBox(height: 15),
            fontsize_twooption('Font size', 'Normal', '    Big    '),
            const SizedBox(height: 15),
            ai_twooption('AI Mode', '   ON   ', '   OFF   '),
          ],
        ),
        //language_twooption('Language'),
      );
    }
  }
}

class Stackwid extends ChangeNotifier {
  late List<Widget> stacklist;
  List<Map<String, int>> favorite_list = [];
  Language _language = Language.Korean;
  Fontsize _fontsize = Fontsize.Normal;

  //0:첫화면, 1:정류장, 2:버스, 3:검색, 4: 즐겨찾기
  List<int> state_ofstack = [0];
  List<int> apistackid = [];
  int lastapiid = -1;

  Map<String, String> miniid = {};

  bool _miniarri = false;
  String? mini_nodeid, mini_routeid;
  int? mini_nodeindex;

  bool _aimode = false;

  void setminiarri(String nodeid, int nodeindex, String routeid) {
    _miniarri = true;
    mini_nodeid = nodeid;
    mini_nodeindex = nodeindex;
    mini_routeid = routeid;
    _saveSettings_miniarri();
  }

  void addminiarri() {
    if (mini_nodeid != null && mini_nodeindex != null && mini_routeid != null) {
      Widget mini = Positioned(
        top: 70,
        right: 15,
        child: Container(
          width: 280,
          height: 150,
          child: miniarrivepage(
            nodeid: mini_nodeid!,
            nodeindex: mini_nodeindex!,
            routeid: mini_routeid!,
          ),
        ),
      );
      stacklist.add(mini);
    }
  }

  void deleteminiarri() {
    if (_miniarri) {
      if (_showguide) {
        stacklist.removeLast();
      }
      stacklist.removeLast();
      _miniarri = false;
      mini_nodeid = null;
      mini_nodeindex = null;
      mini_routeid = null;
      _saveSettings_miniarri();
      if (_showguide) {
        stacklist.add(accessibility());
      }
      notifyListeners();
    }
  }

  int allocateapiid() {
    lastapiid++;
    apistackid.add(lastapiid);
    return lastapiid;
  }

  void freeapiid() {
    apistackid.removeLast();
    lastapiid--;
  }

  Future<void> _saveSettings_language() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('language', _language.index);
  }

  Future<void> _saveSettings_fontsize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fontsize', _fontsize.index);
  }

  Future<void> _saveSettings_showguide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('guide', _showguide);
  }

  Future<void> _saveSettings_miniarri() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mini_enabled', _miniarri);

    if (mini_nodeid != null) {
      await prefs.setString('mini_node', mini_nodeid!);
    } else {
      await prefs.remove('mini_node');
    }

    if (mini_nodeindex != null) {
      await prefs.setInt('mini_nodeindex', mini_nodeindex!);
    } else {
      await prefs.remove('mini_nodeindex');
    }

    if (mini_routeid != null) {
      await prefs.setString('mini_route', mini_routeid!);
    } else {
      await prefs.remove('mini_route');
    }
  }

  Future<void> _saveSettings_AImode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('aimode', _aimode);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    int languageIndex = prefs.getInt('language') ?? 0;
    _language = Language.values[languageIndex];

    if (_language == Language.Korean) {
      search_data = search_data_KR;
    } else {
      search_data = search_data_EN;
    }

    int fontsizeIndex = prefs.getInt('fontsize') ?? 0;
    _fontsize = Fontsize.values[fontsizeIndex];

    bool mini = prefs.getBool('mini_enabled') ?? false;
    _miniarri = mini;

    if (_miniarri) {
      mini_nodeid = prefs.getString('mini_node');
      mini_nodeindex = prefs.getInt('mini_nodeindex');
      mini_routeid = prefs.getString('mini_route');
      addminiarri();
    }

    bool ai = prefs.getBool('aimode') ?? false;
    _aimode = ai;

    bool guide = prefs.getBool('guide') ?? true;
    _showguide = guide;
    if (_showguide) {
      showguide();
    }
    notifyListeners();
  }

  //언어
  void changeLanguage(Language change) {
    _language = change;
    _saveSettings_language();
    if (_language == Language.Korean) {
      search_data = search_data_KR;
    } else {
      search_data = search_data_EN;
    }
    notifyListeners();
  }

  //크기
  void changeFontsize(Fontsize change) {
    _fontsize = change;
    _saveSettings_fontsize();
    notifyListeners();
  }

  void changeAImode(bool change) {
    _aimode = change;
    _saveSettings_AImode();
    notifyListeners();
  }

  //bool first;
  Stackwid(BuildContext context) {
    stacklist = [WebViewWidget(controller: _controller), buttons(context)];
    _loadFavorites();
    _loadSettings();
  }

  int getlastwidget() {
    return state_ofstack.last;
  }

  Future<void> _saveFavorites() async {
    // 1. SharedPreferences 인스턴스를 가져옵니다.
    final prefs = await SharedPreferences.getInstance();
    // 2. favorite_list (List<Map<String, int>>)를 JSON 문자열로 변환합니다.
    String favoriteJson = jsonEncode(favorite_list);
    // 3. 'favorites'라는 키(key)로 변환된 문자열을 저장합니다.
    await prefs.setString('favorites', favoriteJson);
    //print("즐겨찾기 저장 완료: $favoriteJson");
  }

  /// 로컬 저장소에서 즐겨찾기 목록을 불러오는 내부 메서드
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    // 'favorites' 키로 저장된 데이터가 있는지 확인합니다.
    if (prefs.containsKey('favorites')) {
      // 1. 저장된 JSON 문자열을 가져옵니다.
      String? favoriteJson = prefs.getString('favorites');
      if (favoriteJson != null) {
        // 2. JSON 문자열을 List<dynamic>으로 디코딩합니다.
        List<dynamic> decodedList = jsonDecode(favoriteJson);
        // 3. List<dynamic>을 List<Map<String, int>> 타입으로 변환합니다.
        favorite_list = decodedList
            .map((item) => Map<String, int>.from(item))
            .toList();

        //print("즐겨찾기 불러오기 완료: ${favorite_list}");
        notifyListeners(); // UI를 갱신해야 할 경우 호출
      }
    }
  }

  void addFavorite(Map<String, int> add) {
    favorite_list.add(add);
    _saveFavorites();
    print(favorite_list);
    //notifyListeners();
  }

  void deleteFavorite(int index) {
    favorite_list.removeAt(index);
    _saveFavorites();
    print(favorite_list);
    //notifyListeners();
  }

  Widget buttons(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 10,
          //bottom: MediaQuery.of(context).size.height - 210.0,
          top: 30,
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(5.0),
                height: 50,
                width: 50,
                child: FloatingActionButton(
                  onPressed: () {
                    addSearch(context);
                  },
                  child: Icon(Icons.search, color: Colors.black, size: 30),
                  backgroundColor: Colors.white,
                  shape: CircleBorder(),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                height: 50,
                width: 50,
                child: FloatingActionButton(
                  onPressed: () {
                    addFavoritepage(context);
                  },
                  child: Icon(Icons.star, color: Colors.yellow, size: 30),
                  backgroundColor: Colors.white,
                  shape: CircleBorder(),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                height: 50,
                width: 50,
                child: FloatingActionButton(
                  onPressed: () {
                    if (_showguide == false) {
                      showguide();
                    } else {
                      hideguide();
                    }
                  },
                  child: Icon(
                    Icons.accessibility_new,
                    color: Colors.blue,
                    size: 30,
                  ),
                  backgroundColor: Colors.white,
                  shape: CircleBorder(),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          //left: MediaQuery.of(context).size.width - 100.0,
          right: 30,
          bottom: 50,
          child: Container(
            margin: const EdgeInsets.all(5.0),
            height: 50,
            width: 50,
            child: FloatingActionButton(
              onPressed: () {
                addSettings();
              },
              child: Icon(Icons.settings, color: Colors.black, size: 30),
              backgroundColor: Colors.white,
              shape: CircleBorder(),
            ),
          ),
        ),
        Positioned(
          //left: MediaQuery.of(context).size.width - 100.0,
          right: 20,
          top: 30,
          //bottom: 50,
          child: Container(
            margin: const EdgeInsets.all(5.0),
            height: 30,
            width: 30,
            child: FloatingActionButton(
              onPressed: () async {
                try {
                  try {
                    final snackBar = SnackBar(
                      content: _language == Language.Korean
                          ? Text('위치 찾는 중...')
                          : Text('Locating...'), // 표시될 텍스트
                      duration: const Duration(seconds: 3), // 3초 동안 보여주고 사라집니다.
                    );

                    // ✨ 2. ScaffoldMessenger를 통해 SnackBar를 화면에 표시합니다.
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } catch (e) {
                    print('context error');
                  }
                  Position position = await _determinePosition();
                  final currentpos = jsonEncode({
                    "lati": position.latitude,
                    "long": position.longitude,
                  });
                  _controller.runJavaScript('movetopos($currentpos)');
                } catch (e) {
                  try {
                    final snackBar = SnackBar(
                      content: _language == Language.Korean
                          ? Text('위치 정보 사용에 문제가 발생하였습니다.')
                          : Text('An error occurred while locating.'),
                      // 표시될 텍스트
                      duration: const Duration(seconds: 2), // 1초 동안 보여주고 사라집니다.
                    );
                    // ✨ 2. ScaffoldMessenger를 통해 SnackBar를 화면에 표시합니다.
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } catch (e2) {
                    print('context error');
                  }
                  /*
                  final currentpos = jsonEncode({
                    "lati": 36.1430,
                    "long": 128.3941,
                  });
                  _controller.runJavaScript('movetopos($currentpos)');*/
                }
              },
              child: Icon(
                Icons.my_location_outlined,
                color: Colors.blue,
                size: 20,
              ),
              backgroundColor: Colors.white,
              shape: CircleBorder(),
            ),
          ),
        ),
      ],
    );
  }

  //bool first=true;
  bool search_visibility = true;

  void addSearch(BuildContext context) {
    stacklist = [WebViewWidget(controller: _controller)];
    state_ofstack.add(3);
    Widget addw = Padding(
      padding: EdgeInsets.fromLTRB(
        10,
        30,
        10,
        MediaQuery.of(context).size.height * 0.45,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          child: Searchpage(
            maincontext: context,
          ), //DetailPage(id:stop_data[stopindex][0],name:stop_data[stopindex][1],index:stopindex),
        ),
      ),
    );
    stacklist.add(addw);
    if (_showguide) {
      stacklist.add(accessibility());
    }
    notifyListeners();
  }

  bool favoritepage_visibility = true;

  void addFavoritepage(BuildContext context) {
    stacklist = [WebViewWidget(controller: _controller)];
    state_ofstack.add(4);
    Widget addw = Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Favoritepage(
          maincontext: context,
        ), //DetailPage(id:stop_data[stopindex][0],name:stop_data[stopindex][1],index:stopindex),
      ),
      //),
    );
    stacklist.add(addw);
    if (_showguide) {
      stacklist.add(accessibility());
    }
    notifyListeners();
  }

  bool _showguide = true;

  void showguide() {
    Widget guide = accessibility();
    stacklist.add(guide);
    _showguide = true;
    _saveSettings_showguide();
    notifyListeners();
  }

  void hideguide() {
    stacklist.removeLast();
    _showguide = false;
    _saveSettings_showguide();
    notifyListeners();
  }

  void addSettings() {
    stacklist.add(settings());
    notifyListeners();
  }

  void hideSettings() {
    stacklist.removeLast();
    notifyListeners();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화되어 있으면 오류 반환
      return Future.error('위치 서비스가 비활성화되었습니다.');
    }

    // 2. 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 권한이 거부된 경우, 권한 요청
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한 요청이 거부되면 오류 반환
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부된 경우, 오류 반환
      return Future.error('위치 권한이 영구적으로 거부되어 권한을 요청할 수 없습니다.');
    }

    // 3. 권한이 허용된 경우, 현재 위치 반환
    return await Geolocator.getCurrentPosition();
  }

  void resetStack(BuildContext context) {
    stacklist = [WebViewWidget(controller: _controller), buttons(context)];
    state_ofstack = [0];
    notifyListeners();
  }

  void onlymap() {
    stacklist = [WebViewWidget(controller: _controller)];
    state_ofstack = [0];
    notifyListeners();
  }

  void updateStack(BuildContext context, Widget add, int type) {
    if (state_ofstack.last == 0) {
      stacklist = [WebViewWidget(controller: _controller)];
    }
    if (state_ofstack.last == 3) {
      search_visibility = false;
    } else if (state_ofstack.last == 4) {
      favoritepage_visibility = false;
    }
    if (_showguide && state_ofstack.last != 0) {
      stacklist.removeLast();
    }

    stacklist.add(add);

    state_ofstack.add(type);
    stacklist.add(
      Positioned(
        left: 6,
        bottom: MediaQuery.of(context).size.height * 0.5 - 40.0, //355,
        child: Container(
          height: 30,
          width: 30,
          child: IconButton(
            onPressed: () {
              backStack(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.grey),
            //backgroundColor: Colors.grey,
          ),
        ),
      ),
    );
    if (_showguide) {
      stacklist.add(accessibility());
    }
    notifyListeners();
  }

  void backStack(BuildContext context) {
    if (_showguide) {
      stacklist.removeLast();
    }
    stacklist.removeLast();
    stacklist.removeLast();
    state_ofstack.removeLast();
    freeapiid();
    if (state_ofstack.last == 0) {
      stacklist.add(buttons(context));
      if (_miniarri) {
        addminiarri();
      }
    }
    if (state_ofstack.last == 3) {
      search_visibility = true;
    } else if (state_ofstack.last == 4) {
      favoritepage_visibility = true;
    }
    if (_showguide) {
      stacklist.add(accessibility());
    }
    notifyListeners();
  }

  void backStack1(BuildContext context) {
    if (_showguide) {
      stacklist.removeLast();
    }
    stacklist.removeLast();
    state_ofstack.removeLast();
    if (state_ofstack.last == 0) {
      stacklist.add(buttons(context));
      if (_miniarri) {
        addminiarri();
      }
    }
    if (_showguide) {
      stacklist.add(accessibility());
    }
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final String kakaoJavascriptKey;

  const MyApp({super.key, required this.kakaoJavascriptKey});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Stackwid>(
      create: (_) => Stackwid(context),
      child: MaterialApp(
        title: 'NavigatorDemo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: KakaoMapPage(kakaoJavascriptKey: kakaoJavascriptKey),
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
  var st;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isPopupShowing = false;

  // 시작 위치(금오공대 근처)

  double lat = 36.1430;
  double lng = 128.3941;

  Future<void> loadCsvData() async {
    final csvString0 = await rootBundle.loadString(
      'assets/csv/gumi_bus_stops_formap.csv',
    );
    stop_data_formap = const CsvToListConverter().convert(csvString0);
    final csvString1 = await rootBundle.loadString(
      'assets/csv/gumi_bus_stops(sortinno).csv',
    );
    stop_data = const CsvToListConverter().convert(csvString1); //한국어
    final csvString12 = await rootBundle.loadString(
      'assets/csv/gumi_bus_stops(sortinno)_inEng.csv',
    );
    stop_data_EN = const CsvToListConverter().convert(csvString12); //English
    final csvString2 = await rootBundle.loadString(
      'assets/csv/gumi_bus_stops_busindex.csv',
    );
    stop_buses_data = const CsvToListConverter().convert(csvString2);
    final csvString3 = await rootBundle.loadString(
      'assets/csv/gumi_buses(sortinid).csv',
    );
    bus_data = const CsvToListConverter().convert(csvString3); //한국어
    final csvString32 = await rootBundle.loadString(
      'assets/csv/gumi_buses(sortinid)_inEng.csv',
    );
    bus_data_EN = const CsvToListConverter().convert(csvString32); //English
    final csvString4 = await rootBundle.loadString(
      'assets/csv/gumi_buses_route.csv',
    );
    bus_route_data = const CsvToListConverter().convert(csvString4);
    final csvString5 = await rootBundle.loadString(
      'assets/csv/gumi_busnstop_search.csv',
    );
    List<List<dynamic>> before_String = const CsvToListConverter().convert(
      csvString5,
    );
    search_data_KR = before_String.map((row) {
      return row.map((cell) => cell.toString()).toList();
    }).toList(); //한국어
    final csvString52 = await rootBundle.loadString(
      'assets/csv/gumi_busnstop_search_inEng.csv',
    );
    search_data = search_data_KR;
    List<List<dynamic>> before_String2 = const CsvToListConverter().convert(
      csvString52,
    );
    search_data_EN = before_String2.map((row) {
      return row.map((cell) => cell.toString()).toList();
    }).toList(); //English
    final csvString6 = await rootBundle.loadString(
      'assets/csv/gumi_bus_routes_inroad.csv',
    );
    bus_route_inroad_data = const CsvToListConverter().convert(csvString6);
  }

  Future<void> _checkInitialConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none && !_isPopupShowing) {
      // 인터넷이 끊겨 있으면 _updateConnectionStatus 함수를 직접 호출하여 팝업 로직을 재사용합니다.
      _isPopupShowing = true;
      showPlatformDialog(
        // 이제 유효한 context를 사용할 수 있습니다.
        context: context,
        builder: (_) => BasicDialogAlert(
          title: const Text("네트워크 오류"),
          content: const Text("인터넷 연결을 확인한 후 다시 시도해 주세요."),
          actions: <Widget>[
            BasicDialogAction(
              title: const Text("앱 종료"),
              onPressed: () {
                exit(0);
              },
            ),
          ],
        ),
      ).then((_) => _isPopupShowing = false);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) && !_isPopupShowing) {
      _isPopupShowing = true;
      showPlatformDialog(
        // 이제 유효한 context를 사용할 수 있습니다.
        context: context,
        builder: (_) => BasicDialogAlert(
          title: const Text("네트워크 오류"),
          content: const Text("인터넷 연결을 확인한 후 다시 시도해 주세요."),
          actions: <Widget>[
            BasicDialogAction(
              title: const Text("앱 종료"),
              onPressed: () {
                exit(0);
              },
            ),
          ],
        ),
      ).then((_) => _isPopupShowing = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();

    // ✨ 2. 앱 사용 도중의 연결 상태 변화를 계속 감지합니다.
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );

    loadCsvData();

    Future.microtask(() async {
      // 위치 권한을 확인하고 현재 위치를 가져와 지도를 초기화합니다.
      try {
        final position = await _determinePosition();
        final html = _buildHtml(
          widget.kakaoJavascriptKey,
          position.latitude,
          position.longitude,
        );
        _controller.addJavaScriptChannel(
          'toFlutter',
          onMessageReceived: (message) {
            _handleJsMessage(message.message);
          },
        );
        _controller.loadHtmlString(html);
      } catch (e) {
        final html = _buildHtml(widget.kakaoJavascriptKey, lat, lng);
        _controller.addJavaScriptChannel(
          'toFlutter',
          onMessageReceived: (message) {
            _handleJsMessage(message.message);
          },
        );
        _controller.loadHtmlString(html);
      }
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화되어 있으면 오류 반환
      return Future.error('위치 서비스가 비활성화되었습니다.');
    }

    // 2. 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 권한이 거부된 경우, 권한 요청
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한 요청이 거부되면 오류 반환
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부된 경우, 오류 반환
      return Future.error('위치 권한이 영구적으로 거부되어 권한을 요청할 수 없습니다.');
    }

    // 3. 권한이 허용된 경우, 현재 위치 반환
    return await Geolocator.getCurrentPosition();
  }

  //for ver2

  int lookforlong(double long, int start, int end) {
    int mid = ((start + end) / 2).toInt();

    if ((stop_data_formap[mid][1] - long).abs() < 0.00011 || end - start < 2) {
      return mid;
    } else if (stop_data_formap[mid][1] > long) {
      return lookforlong(long, start, mid);
    } else {
      return lookforlong(long, mid, end);
    }
  }

  void lookformarkers(double startlati, double endlati, int start, int end) {
    for (int i = start; i <= end; i++) {
      if (stop_data_formap[i][0] > startlati &&
          stop_data_formap[i][0] < endlati) {
        final stopjson = jsonEncode({
          "lati": stop_data_formap[i][0],
          "long": stop_data_formap[i][1],
          "index": stop_data_formap[i][2],
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
        final int stopindex = data['stopindex'];
        if (st._aimode &&
            (stopindex == 122 || stopindex == 123 || stopindex == 124)) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: st._language == Language.Korean
                    ? Text('AI모드 정류장')
                    : Text('AI Mode Stop'),
                // content에 원하는 내용을 추가할 수 있습니다.
                content: st._language == Language.Korean
                    ? Text('이 정류장은 AI모드를 지원해요. AI모드로 보실래요?')
                    : Text(
                        'This stop supports AI mode. Do you want to see it?',
                      ),
                actions: <Widget>[
                  TextButton(
                    child: st._language == Language.Korean
                        ? Text('예')
                        : Text('Yes'),
                    onPressed: () {
                      if (st.state_ofstack.last == 1) {
                        st.backStack(this.context);
                      }
                      Widget addw = Align(
                        // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: MediaQuery.of(this.context).size.height * 0.5,
                          width: double.infinity,
                          child: DetailPage_onAI(
                            id: stop_data[stopindex][0],
                            name: stop_data[stopindex][1],
                            index: stopindex,
                            apiid: st.allocateapiid(),
                          ),
                        ),
                      );
                      st.updateStack(this.context, addw, 1);
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: st._language == Language.Korean
                        ? Text('아니오')
                        : Text('No'),
                    onPressed: () {
                      if (st.state_ofstack.last == 1) {
                        st.backStack(this.context);
                      }
                      Widget addw = Align(
                        // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: MediaQuery.of(this.context).size.height * 0.5,
                          width: double.infinity,
                          child: DetailPage(
                            id: stop_data[stopindex][0],
                            name: stop_data[stopindex][1],
                            index: stopindex,
                            apiid: st.allocateapiid(),
                          ),
                        ),
                      );
                      st.updateStack(this.context, addw, 1);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          if (st.state_ofstack.last == 1) {
            st.backStack(context);
          }
          Widget addw = Align(
            // 🌟 Align을 사용하여 다이얼로그를 하단(bottomCenter)에 배치
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              child: DetailPage(
                id: stop_data[stopindex][0],
                name: stop_data[stopindex][1],
                index: stopindex,
                apiid: st.allocateapiid(),
              ),
            ),
          );
          st.updateStack(context, addw, 1);
        }
      }
      //ver2
      else if (action == 'viewmove') {
        final double startlng = data['startlng'];
        final double endlng = data['endlng'];
        final double startlat = data['startlat'];
        final double endlat = data['endlat'];
        stopsinview(startlng, endlng, startlat, endlat);
      }
    } catch (e) {
      print('Error decoding JS message: $e');
    }
  }

  void stopsinview(
    double startlng,
    double endlng,
    double startlat,
    double endlat,
  ) {
    final int longstart = lookforlong(startlng, 0, 1566);
    final int longend = lookforlong(endlng, longstart, 1566);
    lookformarkers(startlat, endlat, longstart, longend);
  }

  @override
  void dispose() {
    //_mockTimer?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    st = Provider.of<Stackwid>(context, listen: true);
    st.getlastwidget();
    return WillPopScope(
      onWillPop: () async {
        if (st.getlastwidget() == 1 || st.getlastwidget() == 2) {
          st.backStack(this.context);
          return false;
        } else if (st.getlastwidget() == 3 || st.getlastwidget() == 4) {
          st.backStack1(this.context);
          return false;
        }
        final now = DateTime.now(); // 현재 시간
        // 마지막으로 누른 시간이 없거나, 누른 지 2초가 지났다면
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          // 현재 시간을 마지막으로 누른 시간으로 기록
          _lastBackPressed = now;

          // 화면 하단에 안내 메시지(SnackBar) 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                st._language == Language.Korean
                    ? '한 번 더 누르면 종료됩니다.'
                    : 'Press back again to exit.',
              ),
              duration: const Duration(seconds: 2), // 2초 동안 보여줌
            ),
          );

          // false를 반환하여 앱이 (아직) 종료되지 않도록 함
          return false;
        }

        // 2초 안에 다시 눌렀다면, true를 반환하여 앱을 정상적으로 종료함
        return true;
        /*
        else {
          return true;
        }*/
      },
      child: Scaffold(body: Stack(children: st.stacklist)),
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
        stopindex: data.index, // 이동할 페이지에 전달할 데이터 (예: 상세 정보 ID)
        //name: data.nodenm,
        //number: data.nodeno
      });
      toFlutter.postMessage(dataToSend);
      
      updateviewstops();
    });
    stops.push(busMarker);
  }
  function selectstop_insearch(stop) {
    const data = (typeof stop === 'string') ? JSON.parse(stop) : stop;
    const pos = new kakao.maps.LatLng(data.lati, data.long);
    selectcircle.setMap(null);
    selectcircle.setPosition(pos);
    selectcircle.setMap(map);
    
    if(map.getLevel()!=3) {
      map.setLevel(3);
    }
    const movepos = new kakao.maps.LatLng(data.lati-0.0015, data.long);
    map.panTo(movepos);
    
    updateviewstops();
  }
  
  function movetopos(currentpos) {
    const data=(typeof currentpos === 'string') ? JSON.parse(currentpos) : currentpos;
    const pos = new kakao.maps.LatLng(data.lati, data.long);
    if(map.getLevel()>3) {
      map.setLevel(3);
    }
    map.panTo(pos);
    
    updateviewstops();
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
