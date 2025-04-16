import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> gerarEImprimirRecibo({
  required List<Map<String, dynamic>> itens,
  required double total,
  required String nomeUsuario,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Recibo de Compra', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Atendente: $nomeUsuario'),
            pw.SizedBox(height: 10),
            pw.Divider(),

            // Lista de Itens
            ...itens.map((item) {
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Text("${item['produto']}")),
                  pw.Text("${item['quantidade']} x ${item['preco'].toStringAsFixed(2)}"),
                  pw.Text("${item['total'].toStringAsFixed(2)} XOF"),
                ],
              );
            }),

            pw.Divider(),
            pw.SizedBox(height: 10),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Total: ${total.toStringAsFixed(2)} XOF",
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Center(child: pw.Text("Obrigado pela preferência!", style: pw.TextStyle(fontStyle: pw.FontStyle.italic))),
          ],
        );
      },
    ),
  );

  // Imprimir o PDF diretamente
  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}
