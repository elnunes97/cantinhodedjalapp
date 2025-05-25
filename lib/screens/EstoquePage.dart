import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ninhodedjal/screens/EditarProdutoPage.dart';

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
      final lista = List<Map<String, dynamic>>.from(data['produtos']);

      setState(() {
        produtos = produtosFiltrados = lista;
      });

      final baixos = lista.where((p) =>
          int.tryParse(p['quantidade'].toString()) != null &&
          int.parse(p['quantidade'].toString()) < 5);

      if (baixos.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Atenção: Alguns produtos estão com estoque baixo!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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

  Future<void> _excluirProduto(int produtoId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/excluir_produto.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': produtoId}),
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto excluído com sucesso!')),
        );
        _carregarProdutos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir produto.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de comunicação com o servidor.')),
      );
    }
  }

  void _confirmarExclusao(int produtoId, String nomeProduto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Excluir Produto"),
        content: Text("Tem certeza que deseja excluir '$nomeProduto'?"),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Excluir", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              _excluirProduto(produtoId);
            },
          ),
        ],
      ),
    );
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
        title: Text(
          'Estoque',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Color(0xFFF4B000),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                labelText: 'Buscar produto...',
                prefixIcon: Icon(Icons.search, color: Color(0xFFF4B000)),
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
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4B000)),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Nenhum produto encontrado',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: produtosFiltrados.length,
                    itemBuilder: (_, index) {
                      final p = produtosFiltrados[index];
                      final quantidade = int.tryParse(p['quantidade'].toString()) ?? 0;
                      final isBaixo = quantidade < 5;

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          leading: Icon(Icons.inventory, color: Color(0xFFF4B000), size: 30),
                          title: Text(
                            p['nome'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                'Quantidade disponível: ${p['quantidade']}',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              if (isBaixo)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.warning, color: Colors.red, size: 18),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.tipoUsuario == 'admin') ...[
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmarExclusao(
                                    int.parse(p['id'].toString()),
                                    p['nome'],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.grey.shade700),
                                  onPressed: () async {
                                    final produtoId = int.tryParse(p['id'].toString());
                                    final preco = double.tryParse(p['preco'].toString());

                                    if (produtoId == null || preco == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erro: Produto com dados incompletos.')),
                                      );
                                      return;
                                    }

                                    final atualizado = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditarProdutoPage(
                                          id: produtoId,
                                          nome: p['nome'],
                                          precoAtual: preco,
                                          quantidade: quantidade,
                                        ),
                                      ),
                                    );

                                    if (atualizado == true) {
                                      _carregarProdutos();
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                          onTap: widget.tipoUsuario == 'admin'
                              ? () async {
                                  final produtoId = int.tryParse(p['id'].toString());
                                  final preco = double.tryParse(p['preco'].toString());

                                  if (produtoId == null || preco == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erro: Produto com dados incompletos.')),
                                    );
                                    return;
                                  }

                                  final atualizado = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditarProdutoPage(
                                        id: produtoId,
                                        nome: p['nome'],
                                        precoAtual: preco,
                                        quantidade: quantidade,
                                      ),
                                    ),
                                  );

                                  if (atualizado == true) {
                                    _carregarProdutos();
                                  }
                                }
                              : null,
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
              child: Icon(Icons.add, color: Colors.black),
              backgroundColor: Color(0xFFF4B000),
            )
          : null,
    );
  }
}
