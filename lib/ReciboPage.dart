import 'package:flutter/material.dart';

class ReciboPage extends StatelessWidget {
  final List<Map<String, dynamic>> itens;
  final double total;
  final String nomeUsuario;

  ReciboPage({
    required this.itens,
    required this.total,
    required this.nomeUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recibo de Compra")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recibo de Compra",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text("Atendente: $nomeUsuario", style: TextStyle(fontSize: 16)),
            Divider(height: 30, thickness: 2),
            Expanded(
              child: ListView.separated(
                itemCount: itens.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, index) {
                  final item = itens[index];
                  return ListTile(
                    title: Text("${item['produto']}"),
                    subtitle: Text("${item['quantidade']} x XOF ${item['preco'].toStringAsFixed(2)}"),
                    trailing: Text("XOF ${item['total'].toStringAsFixed(2)}"),
                  );
                },
              ),
            ),
            Divider(thickness: 2),
            SizedBox(height: 10),
            Text(
              "Total da Compra: XOF ${total.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                "Obrigado pela preferência!",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
