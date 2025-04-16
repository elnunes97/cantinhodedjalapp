import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdicionarProdutoPage extends StatefulWidget {
  @override
  _AdicionarProdutoPageState createState() => _AdicionarProdutoPageState();
}

class _AdicionarProdutoPageState extends State<AdicionarProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();

  bool _isLoading = false;
  String? _mensagemSucesso;
  String? _mensagemErro;
  bool _mostrarMensagemSucesso = false;
  bool _mostrarMensagemErro = false;

  Future<void> _adicionarProduto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _mensagemSucesso = null;
      _mensagemErro = null;
      _mostrarMensagemSucesso = false;
      _mostrarMensagemErro = false;
    });

    final url = Uri.parse('http://localhost/adicionar_produto.php');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nome": _nomeController.text.trim(),
        "quantidade": int.parse(_quantidadeController.text),
        "preco": double.parse(_precoController.text.replaceAll(',', '.')),
      }),
    );

    setState(() => _isLoading = false);

    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      setState(() {
        _mensagemSucesso = data['message'];
        _mostrarMensagemSucesso = true;
        _nomeController.clear();
        _quantidadeController.clear();
        _precoController.clear();
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() => _mostrarMensagemSucesso = false);
      });
    } else {
      setState(() {
        _mensagemErro = data['message'];
        _mostrarMensagemErro = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() => _mostrarMensagemErro = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("Adicionar Produto"),
        backgroundColor: Color(0xFFF4B000),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          width: isTablet ? 500 : double.infinity,
          child: Column(
            children: [
              // Mensagem Sucesso
              AnimatedOpacity(
                opacity: _mostrarMensagemSucesso ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: _mensagemSucesso != null
                    ? Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _mensagemSucesso!,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ),

              // Mensagem Erro
              AnimatedOpacity(
                opacity: _mostrarMensagemErro ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: _mensagemErro != null
                    ? Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _mensagemErro!,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(labelText: 'Nome do Produto'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _quantidadeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Quantidade'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obrigatório';
                        final val = int.tryParse(value);
                        if (val == null || val <= 0) return 'Quantidade inválida';
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _precoController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Preço'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obrigatório';
                        final val = double.tryParse(value.replaceAll(',', '.'));
                        if (val == null || val <= 0) return 'Preço inválido';
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _adicionarProduto,
                            icon: Icon(Icons.add),
                            label: Text("Adicionar ao Estoque"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF4B000),
                              padding:
                                  EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
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
