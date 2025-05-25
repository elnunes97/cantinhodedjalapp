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

  Future<void> _selecionarData(BuildContext context, bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          dataInicio = picked;
        } else {
          dataFim = picked;
        }
      });
    }
  }

  Future<void> _buscarRelatorio() async {
    if (dataInicio == null || dataFim == null) return;

    final format = DateFormat('yyyy-MM-dd');
    final response = await http.post(
      Uri.parse('http://localhost/relatorio_vendas.php'),
      body: {
        'data_inicio': format.format(dataInicio!),
        'data_fim': format.format(dataFim!),
      },
    );
    //print('Data Início: ${format.format(dataInicio!)}');
    //print('Data Fim: ${format.format(dataFim!)}');
    //print(response.body); // <-- Adicione isso para ver a resposta do servidor

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          vendas = data['vendas'];
          total = vendas.fold(0, (sum, item) =>
            sum + double.parse(item['preco'].toString()) * int.parse(item['quantidade'].toString()));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('dd/MM/yyyy');
    final themeColor = Color(0xFFF4B000);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Relatório de Vendas'),
        backgroundColor: themeColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () => _selecionarData(context, true),
                    icon: Icon(Icons.calendar_today, color: themeColor),
                    label: Text(dataInicio == null ? 'Data Início' : format.format(dataInicio!)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () => _selecionarData(context, false),
                    icon: Icon(Icons.calendar_today, color: themeColor),
                    label: Text(dataFim == null ? 'Data Fim' : format.format(dataFim!)),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _buscarRelatorio,
            icon: Icon(Icons.search),
            label: Text("Buscar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: vendas.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma venda encontrada.',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: vendas.length,
                    itemBuilder: (context, index) {
                      final venda = vendas[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          leading: Icon(Icons.shopping_bag, color: themeColor, size: 30),
                          title: Text(
                            '${venda['produto']} x${venda['quantidade']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Por: ${venda['nome_usuario']}\n${venda['data']}'),
                          trailing: Text(
                            'XOF ${(double.parse(venda['preco'].toString()) * int.parse(venda['quantidade'].toString())).toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, //fontWeight: FontWeight.w500,
                  fontWeight: FontWeight.bold, color: const Color.fromARGB(229, 2, 48, 10)),
                ),
                Text(
                  'XOF ${total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeColor),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
