import 'package:flutter/material.dart';

class AdicionarProdutoPage extends StatefulWidget {
  @override
  _AdicionarProdutoPageState createState() => _AdicionarProdutoPageState();
}

class _AdicionarProdutoPageState extends State<AdicionarProdutoPage> {
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();

  List<Produto> _produtos = [];

  void _adicionarProdutoNaLista() {
    final nome = _nomeController.text.trim();
    final quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    final preco = double.tryParse(_precoController.text) ?? 0.0;

    if (nome.isEmpty || quantidade <= 0 || preco <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha os campos corretamente')),
      );
      return;
    }

    final novoProduto = Produto(nome: nome, quantidade: quantidade, preco: preco);
    setState(() {
      _produtos.add(novoProduto);
      _nomeController.clear();
      _quantidadeController.clear();
      _precoController.clear();
    });
  }

  double get _totalGeral {
    return _produtos.fold(0.0, (soma, p) => soma + p.subtotal);
  }

  void _finalizarVenda() {
    if (_produtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum produto adicionado')),
      );
      return;
    }

    // Aqui você pode enviar os produtos para o backend ou ir pra outra tela de recibo
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Venda Finalizada"),
        content: Text("Total: R\$ ${_totalGeral.toStringAsFixed(2)}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _produtos.clear());
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nova Venda')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nomeController, decoration: InputDecoration(labelText: 'Nome do Produto')),
            TextField(controller: _quantidadeController, decoration: InputDecoration(labelText: 'Quantidade'), keyboardType: TextInputType.number),
            TextField(controller: _precoController, decoration: InputDecoration(labelText: 'Preço'), keyboardType: TextInputType.number),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _adicionarProdutoNaLista,
              child: Text("Adicionar à Lista"),
            ),
            Divider(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: _produtos.length,
                itemBuilder: (_, index) {
                  final p = _produtos[index];
                  return ListTile(
                    title: Text("${p.nome} (${p.quantidade}x)"),
                    subtitle: Text("Preço: R\$ ${p.preco.toStringAsFixed(2)}"),
                    trailing: Text("Subtotal: R\$ ${p.subtotal.toStringAsFixed(2)}"),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Text("Total: R\$ ${_totalGeral.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _finalizarVenda,
              child: Text("Finalizar Venda"),
            ),
          ],
        ),
      ),
    );
  }
}

class Produto {
  final String nome;
  final int quantidade;
  final double preco;

  Produto({required this.nome, required this.quantidade, required this.preco});

  double get subtotal => quantidade * preco;
}
