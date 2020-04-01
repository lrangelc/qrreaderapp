import 'dart:async';

import 'package:qrreaderapp/src/providers/db_provider.dart';
import 'package:qrreaderapp/src/bloc/validator.dart';

class ScansBloc with Validators {
  static final ScansBloc _singleton = new ScansBloc._internal();

  factory ScansBloc() {
    return _singleton;
  }

  ScansBloc._internal() {
    //Obtener los scans de la db
    obtenerScans();
  }

  final _scansController = StreamController<List<ScanModel>>.broadcast();

  Stream<List<ScanModel>> get scansStream => _scansController.stream.transform(validarGeo);
  Stream<List<ScanModel>> get scansStreamHttp => _scansController.stream.transform(validarHttp);

  dispose() {
    _scansController?.close();
  }

  agregarScan(ScanModel scan) async {
    await DBProvider.db.addScan(scan);
    obtenerScans();
  }

  obtenerScans() async {
    _scansController.sink.add(await DBProvider.db.getAllScans());
  }

  borrarScan(int id) async {
    await DBProvider.db.deleteScan(id);
    obtenerScans();
  }

  borrarScanTodos() async {
    await DBProvider.db.deleteAll();
    obtenerScans();
  }
}
