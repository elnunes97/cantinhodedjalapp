import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VendasDoDiaPage extends StatefulWidget {
  @override
  _VendasDoDiaPageState createState() => _VendasDoDiaPageState();
}

class _VendasDoDiaPageState extends State<VendasDoDiaPage> {
  List<dynamic> vendasPorDia = [];
  bool _isLoading = true;
  String _erroMensagem = '';

  @override
  void initState() {
    super.initState();
    _carregarVendasPorDia();
  }

  Future<void> _carregarVendasPorDia() async {
    final response = await http.get(Uri.parse(
      'https://localhost/vendas_por_dia.php'
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          vendasPorDia = data['vendas'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _erroMensagem = 'Não há vendas registradas.';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _erroMensagem = 'Erro ao carregar as vendas.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vendas por Dia')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _erroMensagem.isNotEmpty
                ? Center(child: Text(_erroMensagem, style: TextStyle(color: Colors.red)))
                : ListView.builder(
                    itemCount: vendasPorDia.length,
                    itemBuilder: (context, index) {
                      final venda = vendasPorDia[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text('Data: ${venda['data_venda']}'),
                          subtitle: Text('Total de Vendas: XOF ${venda['total_vendas'].toStringAsFixed(2)}'),
                          trailing: Text('Quantidade: ${venda['total_quantidade']}'),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
