import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// Este archivo lo crea build_runner automáticamente (paso 3.3).
part 'database.g.dart';

/// Tabla "tareas" en SQLite.
/// Drift crea a partir de ella la clase Tarea (una fila de la tabla).
class Tareas extends Table {
  // INTEGER PRIMARY KEY AUTOINCREMENT
  IntColumn get id => integer().autoIncrement()();

  // TEXT NOT NULL
  TextColumn get titulo => text()();

  // SQLite no tiene booleanos: lo guarda como INTEGER (0 = false, 1 = true)
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  // Si no le pasan una conexión, abre la base real del dispositivo.
  // En las pruebas automáticas le pasaremos una base en memoria.
  AppDatabase([QueryExecutor? conexion]) : super(conexion ?? _abrirConexion());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _abrirConexion() {
    return driftDatabase(
      name: 'gestor_tareas',
      // Archivos que necesita la versión web (los agregaremos en el paso 4)
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  /// SELECT: devuelve un Stream que avisa cada vez que la tabla cambia.
  Stream<List<Tarea>> observarTareas() {
    return (select(tareas)..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();
  }

  /// INSERT: guarda una tarea nueva. Rechaza títulos vacíos.
  Future<int> agregarTarea(String titulo) {
    final limpio = titulo.trim();
    if (limpio.isEmpty) {
      throw ArgumentError('El título no puede estar vacío');
    }
    return into(tareas).insert(TareasCompanion.insert(titulo: limpio));
  }
}
