import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

import 'LoginPage.dart';
import 'ReciboPage.dart';
import 'EstoquePage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _produtoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();

  double totalVenda = 0.0;
  double totalVendasDia = 0.0;
  List<Map<String, dynamic>> produtos = [];
  List<Map<String, dynamic>> carrinho = [];

  bool _isLoading = false;
  String nomeUsuario = '';
  String emailUsuario = '';
  String? _mensagemErro;
  String tipoUsuario = '';

  @override
  void initState() {
    super.initState();
    _getUserData();
    _atualizarEstoque();
  }

  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nomeUsuario = prefs.getString('nome') ?? 'Nome não disponível';
      emailUsuario = prefs.getString('email') ?? 'Email não disponível';
      tipoUsuario = prefs.getString('tipo') ?? 'usuario';
    });
  }

  void _mostrarErro(String mensagem) {
    setState(() {
      _mensagemErro = mensagem;
    });
    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        _mensagemErro = null;
      });
    });
  }

  void _adicionarAoCarrinho() {
    final produto = _produtoController.text.trim();
    final quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    final preco = double.tryParse(_precoController.text) ?? 0.0;

    if (produto.isEmpty || quantidade <= 0 || preco <= 0.0) {
      _mostrarErro("Preencha todos os campos corretamente.");
      return;
    }

    final produtoEstoque = produtos.firstWhere(
      (p) => (p['nome'] ?? '').toString().toLowerCase().trim() == produto.toLowerCase(),
      orElse: () => {},
    );

    if (produtoEstoque.isEmpty || quantidade > (int.tryParse(produtoEstoque['quantidade'].toString()) ?? 0)) {
      _mostrarErro("Produto não disponível ou estoque insuficiente.");
      return;
    }

    setState(() {
      carrinho.add({
        'produto': produto,
        'quantidade': quantidade,
        'preco': preco,
        'total': preco * quantidade,
      });
      _produtoController.clear();
      _quantidadeController.clear();
      _precoController.clear();
      totalVenda = 0.0;
    });
  }

  void _removerDoCarrinho(int index) {
    setState(() {
      carrinho.removeAt(index);
    });
  }

  Future<void> _registrarVenda() async {
    if (carrinho.isEmpty) {
      _mostrarErro("O carrinho está vazio.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    for (var item in carrinho) {
      final response = await http.post(
        Uri.parse('http://localhost/vender.php'),
        body: {
          'produto': item['produto'],
          'quantidade': item['quantidade'].toString(),
          'preco': item['preco'].toString(),
        },
      );

      final data = json.decode(response.body);
      if (data['status'] != 'success') {
        setState(() {
          _isLoading = false;
        });
        _mostrarErro("Erro ao registrar venda de ${item['produto']}.");
        return;
      }

      _registrarVendasDia(item['total']);
    }

    await _atualizarEstoque();

    final total = carrinho.fold(0.0, (sum, item) => sum + item['total']);
    final copiaCarrinho = List<Map<String, dynamic>>.from(carrinho);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReciboPage(
          itens: copiaCarrinho,
          total: total,
          nomeUsuario: nomeUsuario,
        ),
      ),
    );

    setState(() {
      carrinho.clear();
      _isLoading = false;
    });
  }

  Future<void> _registrarVendasDia(double venda) async {
    setState(() {
      totalVendasDia += venda;
    });
  }

  Future<void> _atualizarEstoque() async {
    final response = await http.get(Uri.parse('http://localhost/estoque.php'));
    final data = json.decode(response.body);
    setState(() {
      produtos = List<Map<String, dynamic>>.from(data['produtos']);
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _abrirPaginaEstoque() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EstoquePage(tipoUsuario: tipoUsuario)),
    );
    await _atualizarEstoque();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF4B000),
        centerTitle: true,
        title: Text("Sistema de Vendas", style: TextStyle(color: Colors.white, fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(Icons.inventory, color: Colors.white),
            onPressed: _abrirPaginaEstoque,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('assets/logo.png', height: 40),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFF4B000)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.blue)),
                  SizedBox(height: 10),
                  Text(nomeUsuario, style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text(emailUsuario, style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              if (_mensagemErro != null)
                Card(
                  color: Colors.red.shade400,
                  child: ListTile(
                    leading: Lottie.asset('assets/error.json', width: 40),
                    title: Text(_mensagemErro!, style: TextStyle(color: Colors.white)),
                  ),
                ),
              TabBar(
                labelColor: Colors.black,
                indicatorColor: Color(0xFFF4B000),
                tabs: [
                  Tab(text: "Vendas"),
                  Tab(text: "Total do Dia"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  _inputField("Produto", _produtoController),
                                  _inputField("Quantidade", _quantidadeController, isNumber: true),
                                  _inputField("Preço", _precoController, isNumber: true),
                                  SizedBox(height: 10),
                                  Text("Subtotal: ${totalVenda.toStringAsFixed(2)} XOF", style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(child: ElevatedButton.icon(onPressed: _adicionarAoCarrinho, icon: Icon(Icons.add_shopping_cart), label: Text("Adicionar"))),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _isLoading ? null : _registrarVenda,
                                          icon: Icon(Icons.check_circle),
                                          label: _isLoading
                                              ? Lottie.asset('assets/loading.json', width: 40)
                                              : Text("Finalizar"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text("Carrinho", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ...carrinho.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Card(
                              child: ListTile(
                                leading: Icon(Icons.shopping_bag),
                                title: Text("${item['produto']} - ${item['quantidade']} x ${item['preco']}"),
                                subtitle: Text("Total: ${item['total'].toStringAsFixed(2)} XOF"),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removerDoCarrinho(index),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        "Total de vendas de hoje:\nXOF ${totalVendasDia.toStringAsFixed(2)}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
