import 'dart:math';

import 'package:aulaflutter/second_screen.dart';
import 'package:aulaflutter/third_screen.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      initialRoute: MyHomePage.routeName,
      routes: {
        MyHomePage.routeName : (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        SecondScreen.routeName : (_) => const SecondScreen(),
        ThirdScreen.routeName : (_) => const ThirdScreen(),

      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  static const String routeName = '/';

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Color _color = Colors.orange;

  @override
  void initState(){
    super.initState();
    print('initState');
  }


  @override
  void didUpdateWidget(covariant MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget');
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('didChange');
  }

  int _inc=1;
  void changeInc(int inc) { setState(() {_inc = inc;}); }
  void _incrementCounter() { setState(() {_counter+=_inc; }); }

  void _decrementCounter() {
    _counter--;
    //setState(() { });
    _changeColor();
    print("Valor: $_counter \n");
  }

  void _changeColor(){
    var r = Random().nextInt(256);
    var g = Random().nextInt(256);
    var b = Random().nextInt(256);
    _color = Color.fromARGB(255,r,g,b);
    setState((){});
  }

  Location location = new Location();

  bool _serviceEnabled=false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData _locationData = LocationData.fromMap({
    'latitude' : 40.1925,
    'longitude' : -8.4128
  });

  Future<void> initLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    getLocation();
  }

  Future<void> getLocation() async {
    if (!_serviceEnabled ||
        _permissionGranted != PermissionStatus.granted) {
      return;
    }
    _locationData = await location.getLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      backgroundColor: _color,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
           // if(_counter > 10)
           // FlutterLogo(size: MediaQuery.of(context).size.width/6,),
            FlutterLogo(size: _counter > 10 ? MediaQuery.of(context).size.width/6 : 0),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Increment:',
                hintText: 'Value to increment',
              ),
              onChanged: (value) => changeInc(int.tryParse(value) ?? 1),
            ),
            const SizedBox(height: 16,),
            ElevatedButton(
                onPressed: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context){
                          return const SecondScreen();
                        },
                        settings: RouteSettings(
                          arguments: _counter
                        )
                    )
                  );
                },
                child: const Text('Go to second screen')
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Lat: ${_locationData.latitude}'),
                Text('Lon: ${_locationData.longitude}')
              ],
            ),
            ElevatedButton(
                onPressed: getLocation,
                child: const Text('Get location')
            ),
            ElevatedButton(
                onPressed: () {
                  location.onLocationChanged.listen(
                          (LocationData currentLocation) {
                        setState(() {_locationData = currentLocation;});
                      }
                  );
                },
                child: const Text('Activate continuous location')
            ),
            StreamBuilder(
                stream: location.onLocationChanged,
                builder: (context, location) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Lat: ${location.data?.latitude}'),
                    Text('Lon: ${location.data?.longitude}')
                  ],
                )
            ),
            ElevatedButton(
                onPressed: () async {
                  var value = await Navigator.of(context).pushNamed(
                    ThirdScreen.routeName,
                    arguments: _counter
                  );
                  if(value is int){
                    setState(() {
                      _counter = value;
                    });
                  }
                },
                child: const Text('Go to third screen'))
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32,0,0,0),
              child: FloatingActionButton(
                heroTag: 'incbtn',
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                child: const Icon(Icons.add),),
            ),
            FloatingActionButton(
              heroTag: 'resbtn',
              onPressed: () { setState(() {_counter = 0; });},
              tooltip: 'Reset',
              child: const Icon(Icons.replay),),
            FloatingActionButton(
              heroTag: 'decbtn',
              onPressed: _decrementCounter,
              tooltip: 'Decrement',
              child: const Icon(Icons.remove),)
          ]

      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
