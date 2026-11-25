import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/database.dart';

void main() {
  group('Con base en memoria', () {
    // Antes de cada prueba de este grupo se crea una base nueva en memoria,
    // y al terminar se cierra. Así cada prueba empieza limpia.
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    group('Validación de entradas', () {
      test('rechaza un título vacío o con solo espacios', () async {
        expect(() => db.agregarTarea(''), throwsArgumentError);
        expect(() => db.agregarTarea('   '), throwsArgumentError);

        final tareas = await db.select(db.tareas).get();
        expect(tareas, isEmpty);
      });

      test('quita los espacios al inicio y al final del título', () async {
        await db.agregarTarea('  Estudiar  ');

        final tareas = await db.select(db.tareas).get();
        expect(tareas.single.titulo, 'Estudiar');
      });

      test('no permite dejar vacío el título al editar', () async {
        final id = await db.agregarTarea('Original');

        await expectLater(db.editarTitulo(id, '   '), throwsArgumentError);

        final tareas = await db.select(db.tareas).get();
        expect(tareas.single.titulo, 'Original');
      });
    });

    group('Operaciones CRUD', () {
      test('agregar, editar, cambiar estado y eliminar una tarea', () async {
        // INSERT
        final id = await db.agregarTarea('Comprar pan');
        var tareas = await db.select(db.tareas).get();
        expect(tareas.single.completada, isFalse);

        // UPDATE (título y estado)
        await db.editarTitulo(id, 'Comprar tortillas');
        await db.cambiarEstado(id, true);
        tareas = await db.select(db.tareas).get();
        expect(tareas.single.titulo, 'Comprar tortillas');
        expect(tareas.single.completada, isTrue);

        // DELETE
        await db.eliminarTarea(id);
        tareas = await db.select(db.tareas).get();
        expect(tareas, isEmpty);
      });

      test('observarTareas devuelve la lista actualizada', () async {
        await db.agregarTarea('A');
        await db.agregarTarea('B');

        final lista = await db.observarTareas().first;
        expect(lista.map((t) => t.titulo), ['A', 'B']);
      });
    });
  });

  test('los datos siguen ahí al cerrar y volver a abrir la base', () async {
    // Esta prueba usa un archivo real (no memoria) en una carpeta temporal.
    final carpeta = await Directory.systemTemp.createTemp('tareas_test');
    final archivo = File('${carpeta.path}/prueba.sqlite');

    final primera = AppDatabase(NativeDatabase(archivo));
    await primera.agregarTarea('Persistente');
    await primera.close();

    final segunda = AppDatabase(NativeDatabase(archivo));
    final tareas = await segunda.select(segunda.tareas).get();
    expect(tareas.single.titulo, 'Persistente');
    await segunda.close();

    await carpeta.delete(recursive: true);
  });
}
