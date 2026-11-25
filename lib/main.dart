import 'package:flutter/material.dart';

import 'data/database.dart';
import 'screens/tareas_page.dart';

void main() {
  runApp(const GestorTareasApp());
}

/// Punto de entrada de la aplicación.
/// Aquí se abre la base de datos y se cierra al terminar la app.
class GestorTareasApp extends StatefulWidget {
  /// Base opcional: las pruebas automáticas le pasan una base en memoria.
  final AppDatabase? baseDatos;

  const GestorTareasApp({super.key, this.baseDatos});

  @override
  State<GestorTareasApp> createState() => _GestorTareasAppState();
}

class _GestorTareasAppState extends State<GestorTareasApp> {
  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = widget.baseDatos ?? AppDatabase();
  }

  @override
  void dispose() {
    // Libera la conexión a SQLite, solo si la abrió esta clase.
    if (widget.baseDatos == null) {
      _db.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TareasPage(db: _db),
    );
  }
}
