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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFFF4B000),
        centerTitle: true,
        title: Text("Recibo de Compra", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo e título
                Row(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 60,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Recibo de Compra",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "Atendente: $nomeUsuario",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 20),
                Divider(thickness: 2),

                // Lista de Itens
                Expanded(
                  child: ListView.separated(
                    itemCount: itens.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (context, index) {
                      final item = itens[index];
                      return ListTile(
                        leading: Icon(Icons.shopping_bag_outlined, color: Colors.grey[700]),
                        title: Text("${item['produto']}", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${item['quantidade']} x ${item['preco'].toStringAsFixed(2)} XOF"),
                        trailing: Text(
                          "${item['total'].toStringAsFixed(2)} XOF",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),

                Divider(thickness: 2),
                SizedBox(height: 10),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total da Compra:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "${total.toStringAsFixed(2)} XOF",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF4B000)),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Agradecimento
                Center(
                  child: Text(
                    "Obrigado pela preferência!",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
