import 'package:flutter/material.dart';

import '../data/database.dart';

class TareasPage extends StatefulWidget {
  final AppDatabase db;

  const TareasPage({super.key, required this.db});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();

  // El Stream se crea UNA sola vez aquí (no dentro de build()).
  // Cada vez que la tabla cambia, el Stream manda la lista nueva.
  late final Stream<List<Tarea>> _streamTareas;

  @override
  void initState() {
    super.initState();
    _streamTareas = widget.db.observarTareas();
  }

  Future<void> _agregarTarea() async {
    final titulo = _tituloController.text.trim();
    if (titulo.isEmpty) {
      _mostrarMensaje('Escribe un título antes de agregar la tarea');
      return;
    }
    try {
      await widget.db.agregarTarea(titulo);
      _tituloController.clear();
    } catch (e) {
      _mostrarMensaje('No se pudo guardar la tarea: $e');
    }
  }

  Future<void> _alternarCompletada(Tarea tarea, bool completada) async {
    try {
      await widget.db.cambiarEstado(tarea.id, completada);
    } catch (e) {
      _mostrarMensaje('No se pudo actualizar la tarea: $e');
    }
  }

  Future<void> _editarTarea(Tarea tarea) async {
    // Abre una ventanita con el título actual. Devuelve el texto nuevo,
    // o null si la persona presionó "Cancelar".
    final nuevoTitulo = await showDialog<String>(
      context: context,
      builder: (context) => _DialogoEditar(tituloActual: tarea.titulo),
    );
    if (nuevoTitulo == null) return;

    if (nuevoTitulo.trim().isEmpty) {
      _mostrarMensaje('El título no puede quedar vacío');
      return;
    }
    try {
      await widget.db.editarTitulo(tarea.id, nuevoTitulo);
    } catch (e) {
      _mostrarMensaje('No se pudo editar la tarea: $e');
    }
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    try {
      await widget.db.eliminarTarea(tarea.id);
      _mostrarMensaje('Tarea eliminada');
    } catch (e) {
      _mostrarMensaje('No se pudo eliminar la tarea: $e');
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Tarea>>(
                stream: _streamTareas,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al leer las tareas: ${snapshot.error}',
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tareas = snapshot.data!;
                  if (tareas.isEmpty) {
                    return const Center(
                      child: Text('Todavía no hay tareas guardadas'),
                    );
                  }
                  return ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (context, index) {
                      final tarea = tareas[index];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: tarea.completada,
                            onChanged: (valor) {
                              if (valor != null) {
                                _alternarCompletada(tarea, valor);
                              }
                            },
                          ),
                          title: Text(tarea.titulo),
                          subtitle: Text(
                            'ID: ${tarea.id} · '
                            '${tarea.completada ? 'Completada' : 'Pendiente'}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Editar',
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editarTarea(tarea),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _eliminarTarea(tarea),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ventanita para editar el título de una tarea.
/// Es un StatefulWidget para poder liberar (dispose) su controlador de texto.
class _DialogoEditar extends StatefulWidget {
  final String tituloActual;

  const _DialogoEditar({required this.tituloActual});

  @override
  State<_DialogoEditar> createState() => _DialogoEditarState();
}

class _DialogoEditarState extends State<_DialogoEditar> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.tituloActual,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar tarea'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Título'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
