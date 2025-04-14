import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginPage.dart';
import 'ReciboPage.dart';

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

  void _calcularTotal() {
    double preco = double.tryParse(_precoController.text) ?? 0.0;
    int quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    setState(() {
      totalVenda = preco * quantidade;
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
      print("Carrinho atualizado: $carrinho"); // Depuração
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
        Uri.parse('https://localhost/vender.php'),
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

    print("Carrinho antes de navegar para o recibo: $carrinho"); // Depuração

    final copiaCarrinho = List<Map<String, dynamic>>.from(carrinho); // Cria uma cópia independente
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReciboPage(
          itens: copiaCarrinho, // Passa a cópia
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
    final response = await http.get(Uri.parse('https://localhost/estoque.php'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF4B000),
        centerTitle: true,
        title: Text("Sistema de Vendas", 
        style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/logo.png',
              height: 40, // Ajuste o tamanho conforme necessário
            ),
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
                  CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.blue)),
                  SizedBox(height: 10),
                  Text(nomeUsuario, style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text(emailUsuario, style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
            ListTile(leading: Icon(Icons.exit_to_app), title: Text('Sair'), onTap: _logout),
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
                Container(
                  color: Colors.red,
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(child: Text(_mensagemErro!, style: TextStyle(color: Colors.white))),
                    ],
                  ),
                ),
              TabBar(
                tabs: [
                  Tab(text: "Vendas"),
                  if (tipoUsuario == 'admin') Tab(text: "Total de Vendas do Dia"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView(
                      children: [
                        TextField(controller: _produtoController, decoration: InputDecoration(labelText: 'Produto')),
                        TextField(controller: _quantidadeController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Quantidade')),
                        TextField(controller: _precoController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Preço')),
                        SizedBox(height: 10),
                        Text("Subtotal: ${totalVenda.toStringAsFixed(2)} XOF"),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: ElevatedButton(onPressed: _adicionarAoCarrinho, child: Text("Adicionar ao Carrinho"))),
                            SizedBox(width: 10),
                            Expanded(child: ElevatedButton(onPressed: _isLoading ? null : _registrarVenda, child: _isLoading ? CircularProgressIndicator() : Text("Finalizar Venda"))),
                          ],
                        ),
                        Divider(height: 30),
                        Row(
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              "Carrinho:",
                              style: TextStyle(
                                fontSize: 18,
                                backgroundColor: Color(0xFFF4B000),
                              ),
                            ),
                          ],
                        ),
                        ...carrinho.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return ListTile(
                            title: Text("${item['produto']} - ${item['quantidade']}x ${item['preco']} XOF"),
                            subtitle: Text("Total: ${item['total'].toStringAsFixed(2)}  XOF"),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removerDoCarrinho(index),
                            ),
                          );
                        }).toList(),
                        Divider(height: 30),
                        Text('Estoque atual:', style: TextStyle(fontSize: 18)),
                        ...produtos.map((p) => ListTile(title: Text(p['nome']), subtitle: Text("Qtd: ${p['quantidade']}"))),
                      ],
                    ),
                    if (tipoUsuario == 'admin')
                      Center(
                        child: Text("Total de vendas de hoje: XOF ${totalVendasDia.toStringAsFixed(2)}", style: TextStyle(fontSize: 20)),
                      )
                    else
                      Center(
                        child: Text("Acesso restrito. Apenas administradores podem ver as vendas do dia.", style: TextStyle(fontSize: 20, color: Colors.red)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}