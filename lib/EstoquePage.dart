import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EstoquePage extends StatefulWidget {
  final String tipoUsuario;
  const EstoquePage({Key? key, required this.tipoUsuario}) : super(key: key);

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  List<dynamic> produtos = [];
  List<dynamic> produtosFiltrados = [];
  TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
    _buscaController.addListener(_filtrarProdutos);
  }

  Future<void> _carregarProdutos() async {
    try {
      final response = await http.get(Uri.parse('http://localhost/estoque.php'));
      final data = json.decode(response.body);
      setState(() {
        produtos = produtosFiltrados = List<Map<String, dynamic>>.from(data['produtos']);
      });
    } catch (e) {
      print('Erro ao carregar produtos: $e');
    }
  }

  void _filtrarProdutos() {
    final texto = _buscaController.text.toLowerCase();
    setState(() {
      produtosFiltrados = produtos.where((p) {
        final nome = p['nome'].toString().toLowerCase();
        return nome.contains(texto);
      }).toList();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estoque'),
        backgroundColor: Color(0xFFF4B000),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                labelText: 'Buscar produto...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: produtosFiltrados.length,
              itemBuilder: (_, index) {
                final p = produtosFiltrados[index];
                return ListTile(
                  title: Text(
                    p['nome'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Qtd: ${p['quantidade']}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.tipoUsuario == 'admin'
          ? FloatingActionButton(
              onPressed: () async {
                // Aguarda a página de adicionar produto e recarrega o estoque ao voltar
                await Navigator.pushNamed(context, '/adicionarProduto');
                await _carregarProdutos();
              },
              child: Icon(Icons.add),
              backgroundColor: Color(0xFFF4B000),
            )
          : null,
    );
  }
}
