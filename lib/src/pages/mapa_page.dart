import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:qrreaderapp/src/models/scan_model.dart';

class MapaPage extends StatefulWidget {
  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final map = MapController();
  String tipoMapa = 'streets';
  List<String> tiposMapa = [
    'streets',
    'dark',
    'light',
    'outdoors',
    'satellite'
  ];
  int indexTipoMapa = 0;

  @override
  Widget build(BuildContext context) {
    final ScanModel scan = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Coordenadas QR'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () {
              map.move(scan.getLatLng(), 13);
            },
          )
        ],
      ),
      body: _crearFlutterMap(scan),
      floatingActionButton: _crearBotonFlotante(context),
    );
  }

  Widget _crearBotonFlotante(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        indexTipoMapa++;
        if (indexTipoMapa == tiposMapa.length) {
          indexTipoMapa = 0;
        }

        tipoMapa = tiposMapa[indexTipoMapa];
        setState(() {});
      },
      child: Icon(Icons.repeat),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  Widget _crearFlutterMap(ScanModel scan) {
    return FlutterMap(
      mapController: map,
      options: MapOptions(center: scan.getLatLng(), zoom: 13),
      layers: [
        _crearMapa(),
        _crearMarcadores(scan),
      ],
    );
  }

  _crearMapa() {
    return TileLayerOptions(
        urlTemplate: "https://api.mapbox.com/v4/"
            "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
        additionalOptions: {
          'accessToken':
              'pk.eyJ1IjoibHVpc3JhbmdlbGMiLCJhIjoiY2s4Z3RqampmMDVhOTNocnlnamExODB3aCJ9.UGb9cdBjL8Im9S9F14qs6Q',
          'id': 'mapbox.$tipoMapa'
          // streets, dark, light, outdoors, satellite
        });
  }

  _crearMarcadores(ScanModel scan) {
    return MarkerLayerOptions(markers: <Marker>[
      Marker(
          width: 100.0,
          height: 100.0,
          point: scan.getLatLng(),
          builder: (context) => Container(
                child: Icon(
                  Icons.location_on,
                  size: 45.0,
                  color: Colors.red,
                ),
              )),
    ]);
  }
}
