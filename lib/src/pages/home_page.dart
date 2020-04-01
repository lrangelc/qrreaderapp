import 'dart:io';

import 'package:flutter/material.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:qrreaderapp/src/bloc/scans_bloc.dart';
import 'package:qrreaderapp/src/models/scan_model.dart';

import 'package:qrreaderapp/src/pages/direcciones_page.dart';
import 'package:qrreaderapp/src/pages/mapas_page.dart';
import 'package:qrreaderapp/src/utils/utils.dart' as utils;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scansBloc = new ScansBloc();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner - RPApos'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () => _borrarAlert(context),
          )
        ],
      ),
      body: _callPage(currentIndex),
      bottomNavigationBar: _crearBottomNavigationBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.filter_center_focus),
        onPressed: () => _scanQR(context),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _borrarAlert(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('QR Scanner - RPApos'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Desea eliminar todos los registros?'),
                Icon(
                  Icons.delete_forever,
                  size: 100.0,
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text('No'),
                  onPressed: () => Navigator.of(context).pop()),
              FlatButton(
                  child: Text('Si'),
                  onPressed: () {
                    scansBloc.borrarScanTodos();
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  _scanQR(BuildContext context) async {
    //geo:40.67634085948375,-73.93178358515628
    //https://fernando-herrera.com

    print('scan QR...');
    String futureString;
    // String futureString = 'https://fernando-herrera.com';

    try {
      futureString = await BarcodeScanner.scan();

      if (futureString != null) {
        if (futureString.contains('http') || futureString.contains('geo')) {
          final scan = ScanModel(value: futureString);

          // DBProvider.db.addScan(scan);
          scansBloc.agregarScan(scan);

          if (Platform.isIOS) {
            Future.delayed(Duration(milliseconds: 750), () {
              utils.abrirScan(context, scan);
            });
          } else {
            utils.abrirScan(context, scan);
          }
        } else {
          showDialog(
              context: context,
              child: new AlertDialog(
                title: new Text("QR Scanner - RPApos"),
                content: new Text(futureString),
              ));
        }
        print('Tenemos informacion: $futureString');
      }
    } catch (error) {
      futureString = error.toString();
    }
  }

  Widget _callPage(int paginaActual) {
    switch (paginaActual) {
      case 0:
        return MapasPage();

      case 1:
        return DireccionesPage();

      default:
        return MapasPage();
    }
  }

  Widget _crearBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.map), title: Text('Mapas')),
        BottomNavigationBarItem(
            icon: Icon(Icons.cloud_circle), title: Text('Direcciones')),
      ],
    );
  }
}
