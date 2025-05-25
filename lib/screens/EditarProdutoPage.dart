import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditarProdutoPage extends StatefulWidget {
  final int id;
  final String nome;
  final double precoAtual;
  final int quantidade;

  const EditarProdutoPage({
    Key? key,
    required this.id,
    required this.nome,
    required this.precoAtual,
    required this.quantidade,
  }) : super(key: key);

  @override
  _EditarProdutoPageState createState() => _EditarProdutoPageState();
}

class _EditarProdutoPageState extends State<EditarProdutoPage> {
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _precoController.text = widget.precoAtual.toStringAsFixed(2);
    _quantidadeController.text = widget.quantidade.toString();
  }

  Future<void> _salvarAlteracoes() async {
    final preco = double.tryParse(_precoController.text.replaceAll(',', '.'));
    final quantidade = int.tryParse(_quantidadeController.text);

    if (preco == null || quantidade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verifique os valores inseridos.')),
      );
      return;
    }

    setState(() => _carregando = true);

    final response = await http.post(
      Uri.parse('http://localhost/editar_produto.php'),
      body: {
        'id': widget.id.toString(),
        'preco': preco.toString(),
        'quantidade': quantidade.toString(),
      },
    );

    setState(() => _carregando = false);

    if (response.statusCode == 200 && response.body.contains('"success":true')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto atualizado com sucesso!')),
      );
      Navigator.pop(context, true); // sinaliza que houve alteração
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar alterações.')),
      );
    }
  }

  @override
  void dispose() {
    _precoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Produto'),
        backgroundColor: Color(0xFFF4B000),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nome,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _precoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Novo Preço (XOF)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _quantidadeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nova Quantidade',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text(_carregando ? 'Salvando...' : 'Salvar'),
                onPressed: _carregando ? null : _salvarAlteracoes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF4B000),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
