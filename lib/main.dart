import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart' as background;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:point_in_polygon/point_in_polygon.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class NamedPolygonWithPoints {
  String name = '';
  List<Point> points = [];
  NamedPolygonWithPoints(String name, List<Point> points) {
    this.name = name;
    this.points = points;
  }
}

class _MyHomePageState extends State<MyHomePage> {

  Map<String, dynamic>? data;
  Position? position;
  String currentStadtteil = '';
  String lastStadtteil = '';
  int pingCount = 0;
  bool permissions = false;

  List<Polygon> polygons = [];
  List<NamedPolygonWithPoints> polygonsAsPoints = [];

  static AudioPlayer player = new AudioPlayer();

  Future<Map<String, dynamic>> readDataFromFile() async {
    final String response = await rootBundle.loadString('assets/data.geojson');
    final data = await json.decode(response);
    return data;
  }

  String getSoundFile(String stadtteil) {

    const Map mapping = {
      'Äußere Neustadt': 'Aeuaaere_Neustadt.mp3',
      'Gönnsdorf/Pappritz': '',
      'Südvorstadt-West': 'Suedvorstadt_West.mp3',
      'Löbtau-Süd': 'Loebtau_Sued.mp3',
      'Löbtau-Nord': 'Loebtau_Nord.mp3',
      'Prohlis-Süd': 'Prohlis_Sued.mp3',
      'Johannstadt-Süd': 'Johannstadt_Sued.mp3',
      'Striesen-West': 'Striesen_West.mp3',
      'Seevorstadt-Ost/Grosser Garten': '',
      'Gorbitz-Ost': 'Gorbitz_Ost.mp3',
      'Hellerau/Wilschdorf': 'Hellerau_Wilschdorf.mp3',
      'Johannstadt-Nord': 'Johannstadt_Nord.mp3',
      'Großzschachwitz': 'Grosszschachwitz.mp3',
      'Innere Altstadt': 'Innere_Altstadt.mp3',
      'Hellerberge': 'Hellerberge.mp3',
      'Leubnitz-Neuostra': 'Leubnitz_Neuostra.mp3',
      'Pirnaische Vorstadt': 'Pirnaische_Vorstadt.mp3',
      'Trachau': 'Trachau.mp3',
      'Albertstadt': 'Albertstadt.mp3',
      'Weißig': 'Weissig.mp3',
      'Kaditz': 'Kaditz.mp3',
      'Kleinpestitz/Mockritz': 'Kleinpestitz_Mockritz.mp3',
      'Friedrichstadt': 'Friedrichstadt.mp3',
      'Loschwitz/Wachwitz': 'Loschwitz_Wachwitz.mp3',
      'Striesen-Ost': 'Sriesen_Ost.mp3',
      'Lockwitz': 'Lockwitz.mp3',
      'Leuben': 'Leuben.mp3',
      'Prohlis-Nord': 'Prohlis_Nord.mp3',
      'Radeberger Vorstadt': 'Radeberger_Vorstadt.mp3',
      'Gorbitz-Süd': 'Gorbitz_Sued.mp3',
      'Dresdner Heide': 'Dresdner_Heide.mp3',
      'Strehlen': 'Strehlen.mp3',
      'Briesnitz': 'Briesnitz.mp3',
      'Gorbitz-Nord/Neu-Omsewitz': 'Gorbitz_Nord_Neu_Omsewitz.mp3',
      'Innere Neustadt': 'Innere_Neustadt.mp3',
      'Mickten': 'Mickten.mp3',
      'Wilsdruffer Vorstadt/Seevorstadt-West': 'Wilsdruffer_Vorstadt_Seevorstadt_West.mp3',
      'Hosterwitz/Pillnitz': 'Hosterwitz_Pillnitz.mp3',
      'Coschütz/Gittersee': 'Coschuetz_Gittersee.mp3',
      'Pieschen-Süd': 'Pieschen_Sued.mp3',
      'Striesen-Süd': 'Striesen_Sued.mp3',
      'Seidnitz/Dobritz': 'Seidnitz_Dobritz.mp3',
      'Cotta': 'Cotta.mp3',
      'Bühlau/Weißer Hirsch': 'Buehlau_Weisser_Hirsch.mp3',
      'Südvorstadt-Ost': 'Suedvorstadt_Ost.mp3',
      'Räcknitz/Zschertnitz': 'Raecknitz_Zschertnitz.mp3',
      'Plauen': 'Plauen.mp3',
      'Naußlitz': 'Nausslitz.mp3',
      'Schönfeld/Schullwitz': 'Schoenfeld_Schullwitz.mp3',
      'Kleinzschachwitz': 'Kleinschachwitz.mp3',
      'Blasewitz': 'Blasewitz.mp3',
      'Pieschen-Nord/Trachenberge': 'Pieschen_Nord_Trachenberge.mp3',
      'Niedersedlitz': 'Niedersedlitz.mp3',
      'Reick': 'Reick.mp3',
      'Klotzsche': 'Klotzsche.mp3',
      'Laubegast': 'Laubegast.mp3',
      'Tolkewitz/Seidnitz-Nord': 'Tolkewitz.mp3',
      'Gruna': 'Gruna.mp3',
      'Flughafen/Industriegebiet Klotzsche': 'Flughafen_Industriegebiet_Klotzsche.mp3',
      'Leipziger Vorstadt': 'Leipziger_Vorstadt.mp3',
      'Weixdorf': 'Weixdorf.mp3',
    };

    String soundPath = mapping[stadtteil];


    return 'Sounds/$soundPath';
  }

  Future<bool> runInBackground() async {
    final androidConfig = background.FlutterBackgroundAndroidConfig(
      notificationTitle: "Breuler App",
      notificationText: "Breuler weist dir den Weg!",
      notificationImportance: background.AndroidNotificationImportance.Default,
      notificationIcon: background.AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    bool success = await background.FlutterBackground.initialize(androidConfig: androidConfig);
    return success;
  }

  @override
  void initState() {
    super.initState();
    if(!permissions) {
      _determinePosition().then((value) {
        setState(() {
          permissions = true;
        });
      });

    }


    runInBackground().then((value) {
      background.FlutterBackground.enableBackgroundExecution();
    });


    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: LocationSettings())
         .listen((Position position) {
            polygons = getPolygons();
            for(NamedPolygonWithPoints np in polygonsAsPoints) {
              final Point point = Point(x: position.latitude, y: position.longitude);
              if(Poly.isPointInPolygon(point, np.points)) {

                if(lastStadtteil != np.name) {
                  setState(() {
                    pingCount = 0;
                    lastStadtteil = np.name;
                  });
                } else {
                  if(pingCount < 3) {
                    setState(() {
                      pingCount = pingCount + 1;
                    });
                  }
                }

                print("PingCount:  $pingCount");


                if(pingCount > 2) {

                  if(currentStadtteil != lastStadtteil) {
                    setState(() {
                      currentStadtteil = lastStadtteil;
                    });

                    player.play(AssetSource(getSoundFile(lastStadtteil)), volume: 1.0);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                              'Dein neuer Stadteil ist: $currentStadtteil'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Bestätigen'),
                              onPressed: () {
                                // Hier passiert etwas anderes
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              }
            }
            setState(() {
              this.position = position;
            });
         });

    readDataFromFile().then((value) {
      setState(() {
        data = value;
        polygons = getPolygons();
      });
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }


  List<Polygon> getPolygons() {
    if (this.polygons.isEmpty) {
      List<Polygon> polygons = [];
      if (data != null) {
        for (Map<String, dynamic> feature in data!['features']) {
          var coords = feature['geometry']['coordinates'];
          List<LatLng> notFilledDotedPoints = [];
          for (var coordsPair in coords[0]) {
            notFilledDotedPoints.add(LatLng(coordsPair[1], coordsPair[0]));
          }

          Polygon polygon = Polygon(
            points: notFilledDotedPoints,
            isFilled: false,
            isDotted: true,
            borderColor: Colors.green,
            borderStrokeWidth: 4,
            key: ValueKey(feature['properties']['name']),
            // label: feature['name'],
            // labelPlacement: PolygonLabelPlacement.centroid,
            // labelStyle: TextStyle(color: Colors.black, fontSize: 12.0)
          );

          polygons.add(polygon);
        }
      }
      ConvertToNamedPolygonsWithPoints(polygons);
      return polygons;
    } else {
      return this.polygons;
    }
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Polygons')),
      //drawer: buildDrawer(context, PolygonPage.route),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  center: position != null ? LatLng(position!.latitude, position!.longitude): LatLng(51.050407, 13.737262),
                  zoom: 14,
                  maxZoom: 17,
                  minZoom: 10,
                  interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  PolygonLayer(polygons: this.polygons),
                  CurrentLocationLayer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void ConvertToNamedPolygonsWithPoints(List<Polygon> polygons) {
    List<NamedPolygonWithPoints> npList = [];
    for(Polygon poly in polygons) {
      List<Point> points = [];
      for(LatLng coords in poly.points) {
        points.add(Point(x: coords.latitude, y: coords.longitude));
      }

      ValueKey valueKey = poly.key as ValueKey;
      NamedPolygonWithPoints tmpNP = NamedPolygonWithPoints(valueKey.value, points);
      npList.add(tmpNP);
    }

    setState(() {
      polygonsAsPoints = npList;
    });
  }
}
