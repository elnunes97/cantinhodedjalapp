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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Estoque'),
        backgroundColor: Color(0xFFF4B000),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                labelText: 'Buscar produto...'
                    ,
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: produtosFiltrados.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4B000)),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Nenhum produto encontrado'),
                    ],
                  ),
                  )
                : ListView.builder(
                    itemCount: produtosFiltrados.length,
                    itemBuilder: (_, index) {
                      final p = produtosFiltrados[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: Icon(Icons.inventory, color: Color(0xFFF4B000)),
                          title: Text(
                            p['nome'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Quantidade disponível: ${p['quantidade']}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: widget.tipoUsuario == 'admin'
          ? FloatingActionButton(
              onPressed: () async {
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