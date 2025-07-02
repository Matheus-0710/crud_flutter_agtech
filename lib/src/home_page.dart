import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _box = Hive.box('usuarios');

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();

  int? _editingIndex;

  void _limparCampos() {
    _nomeController.clear();
    _emailController.clear();
    _editingIndex = null;
  }

  void _salvarUsuario() {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();

    if (nome.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome e email')),
      );
      return;
    }

    if (_editingIndex == null) {
      // Adicionar
      _box.add({'nome': nome, 'email': email});
    } else {
      // Editar
      _box.putAt(_editingIndex!, {'nome': nome, 'email': email});
    }

    setState(() {
      _limparCampos();
    });
  }

  void _editarUsuario(int index) {
    final user = _box.getAt(index) as Map;
    _nomeController.text = user['nome'];
    _emailController.text = user['email'];
    setState(() {
      _editingIndex = index;
    });
  }

  void _deletarUsuario(int index) {
    _box.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Usuários AGTech'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _salvarUsuario,
                  child: Text(_editingIndex == null ? 'Adicionar' : 'Salvar'),
                ),
                const SizedBox(width: 10),
                if (_editingIndex != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _limparCampos();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Cancelar'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder<Box>(
                valueListenable: _box.listenable(),
                builder: (context, box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text('Nenhum usuário cadastrado.'));
                  }
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final user = box.getAt(index) as Map;
                      return ListTile(
                        title: Text(user['nome'] ?? ''),
                        subtitle: Text(user['email'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editarUsuario(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deletarUsuario(index),
                            ),
                          ],
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
