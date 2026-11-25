# Gestor de tareas con SQLite

Aplicación Flutter que administra tareas guardándolas en una base de datos SQLite local
(sin servidor, sin internet). Práctica de Programación de Dispositivos Móviles, UAA.

## Tecnología de persistencia

Se usa **Drift** junto con **drift_flutter**:

- **Drift** permite definir tablas en Dart y hacer consultas a SQLite de forma segura.
- **drift_flutter** abre la base de datos en la ubicación correcta de cada plataforma
  (Android, iOS, macOS, Windows, Linux y web) con el mismo código.
- En web, SQLite funciona mediante WebAssembly (`sqlite3.wasm` y `drift_worker.js` en la carpeta `web/`).

Se descartó guardar una lista en memoria o JSON en `shared_preferences`, porque no es una base
de datos SQLite real.

## Diseño de la tabla `tareas`

| Columna      | Tipo en SQLite | Descripción                                   |
|--------------|----------------|-----------------------------------------------|
| `id`         | INTEGER        | Llave primaria, autoincremental. Identifica cada tarea. |
| `titulo`     | TEXT           | Título de la tarea. No puede estar vacío.     |
| `completada` | INTEGER (0/1)  | SQLite no tiene booleano: 0 = pendiente, 1 = completada. |

## Cómo ejecutar

```bash
flutter pub get
flutter run -d chrome   # web
flutter run -d macos    # escritorio
```

## Estado

En desarrollo.