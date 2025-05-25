import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RelatorioVendasPage extends StatefulWidget {
  @override
  _RelatorioVendasPageState createState() => _RelatorioVendasPageState();
}

class _RelatorioVendasPageState extends State<RelatorioVendasPage> {
  DateTime? dataInicio;
  DateTime? dataFim;
  List vendas = [];
  double total = 0;

  Future<void> _selecionarDataInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dataInicio) {
      setState(() {
        dataInicio = picked;
      });
    }
  }

  Future<void> _selecionarDataFim(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dataFim) {
      setState(() {
        dataFim = picked;
      });
    }
  }

  Future<void> _buscarRelatorio() async {
    if (dataInicio == null || dataFim == null) return;

    final format = DateFormat('yyyy-MM-dd');
    final response = await http.post(
      Uri.parse('http://localhost/relatorio_vendas.php?data_inicio=$dataInicio&data_fim=$dataFim'),
      body: {
        'data_inicio': format.format(dataInicio!),
        'data_fim': format.format(dataFim!),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          vendas = data['vendas'];
          //total = vendas.fold(0, (sum, item) => sum + double.parse(item['preco'].toString()));
          ////////
          total = vendas.fold(0, (sum, item) {
          final preco = double.tryParse(item['preco'].toString()) ?? 0;
          final quantidade = int.tryParse(item['quantidade'].toString()) ?? 0;
          return sum + (preco * quantidade);
      });
      ///////
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: Text('Buscar vendas por data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.date_range),
                    label: Text(dataInicio == null ? 'Data Início' : format.format(dataInicio!)),
                    onPressed: () => _selecionarDataInicio(context),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.date_range),
                    label: Text(dataFim == null ? 'Data Fim' : format.format(dataFim!)),
                    onPressed: () => _selecionarDataFim(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _buscarRelatorio,
              child: Text("Buscar"),
            ),
            Divider(),
            Expanded(
              child: vendas.isEmpty
                  ? Center(child: Text('Nenhuma venda encontrada'))
                  : ListView.builder(
                      itemCount: vendas.length,
                      itemBuilder: (context, index) {
                        final venda = vendas[index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(Icons.shopping_cart),
                            title: Text('${venda['produto']} x${venda['quantidade']}'),
                            subtitle: Text('Por: ${venda['nome_usuario']}\n${venda['data']}'),
                            trailing: Text('XOF ${venda['preco']}'),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total: XOF $total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
