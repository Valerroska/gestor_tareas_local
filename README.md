# Gestor de tareas con SQLite

Aplicación Flutter que administra tareas guardándolas en una base de datos SQLite local
(sin servidor, sin internet). Práctica de Programación de Dispositivos Móviles, UAA.

Funciones: agregar, listar, editar título, marcar como completada/pendiente y eliminar tareas.
Los títulos vacíos o con solo espacios se rechazan. Los datos se conservan al cerrar y volver
a abrir la app.

## Tecnología de persistencia

Se usa **Drift** junto con **drift_flutter**:

- **Drift** permite definir tablas en Dart y hacer consultas a SQLite con tipos seguros.
- **drift_flutter** abre la base en la ubicación correcta de cada plataforma con el mismo código.
- **build_runner** + **drift_dev** generan `lib/data/database.g.dart` a partir de la tabla.
- En web, SQLite corre como WebAssembly (`web/sqlite3.wasm`) dentro de un worker (`web/drift_worker.js`).

La interfaz se actualiza con un **Stream** (`observarTareas()`): cada vez que la tabla cambia,
la lista se vuelve a dibujar sola. El Stream se crea en `initState()`, no dentro de `build()`.

## Diseño de la tabla `tareas`

| Columna      | Tipo en SQLite | Descripción                                   |
|--------------|----------------|-----------------------------------------------|
| `id`         | INTEGER        | Llave primaria, autoincremental.              |
| `titulo`     | TEXT           | Título de la tarea. No puede estar vacío.     |
| `completada` | INTEGER (0/1)  | 0 = pendiente, 1 = completada (por defecto 0). |

## Estructura

```
lib/
├── main.dart                 # Abre la base de datos y la cierra al terminar
├── data/
│   ├── database.dart         # Tabla Tareas y operaciones CRUD
│   └── database.g.dart       # Código generado por build_runner (no editar)
└── screens/
    └── tareas_page.dart      # Pantalla con la lista y los botones
test/
├── widget_test.dart          # La pantalla inicial se muestra
└── database_test.dart        # Validación, CRUD y persistencia
web/
├── sqlite3.wasm              # SQLite para el navegador
└── drift_worker.js           # Worker de Drift para el navegador
```

## Cómo ejecutar

Requisitos: Flutter instalado (`flutter doctor`). Probado con Flutter 3.47.7 y drift 2.35.4.

```bash
git clone https://github.com/Valerroska/gestor_tareas_local.git
cd gestor_tareas_local
flutter pub get
```

`database.g.dart` ya está incluido en el repositorio. Si se modifica la tabla, hay que regenerarlo con:

```bash
dart run build_runner build
```

**Web:**

```bash
flutter run -d web-server --web-port=8080
```

Abrir `http://localhost:8080` en Chrome. Se usa `web-server` con puerto fijo porque
`flutter run -d chrome` abre un perfil temporal del navegador y los datos pueden perderse
entre ejecuciones (cambia el perfil), lo que no permite comprobar la persistencia.

**Android:** conectar el celular con depuración USB y ejecutar `flutter devices` y luego
`flutter run -d <id>`.

**macOS:** `flutter run -d macos` (requiere Xcode).

## Pruebas automáticas

```bash
flutter test
```

- `widget_test.dart`: la pantalla inicial se muestra sin errores (usa una base en memoria).
- `database_test.dart`:
  - rechaza títulos vacíos o con solo espacios, y quita espacios sobrantes;
  - no permite dejar vacío un título al editar;
  - INSERT, UPDATE (título y estado) y DELETE funcionan;
  - el Stream devuelve la lista actualizada;
  - una tarea guardada en un archivo sigue ahí al cerrar y volver a abrir la base.

## Plataformas

| Plataforma | Estado |
|---|---|
| Web (Chrome) | Verificada |
| Android | Pendiente de verificar |
| macOS (escritorio) | Pendiente de verificar |
| iOS, Windows, Linux |