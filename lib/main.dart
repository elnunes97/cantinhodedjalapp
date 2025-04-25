import 'package:flutter/material.dart';
import 'screens/HomePage.dart';
import 'screens/LandingPage.dart';
import 'screens/AdicionarProdutoPage.dart'; // Importe sua nova página aqui
import 'screens/RegisterPage.dart';
import 'screens/relatorio_vendas_screen.dart'; // Importe sua nova página aqui
import 'screens/EstoquePage.dart'; // Importe sua nova página aqui


void main() {
  runApp(MaterialApp(
    home: LandingPage(),
    //home: AdicionarProdutoPage(),
    debugShowCheckedModeBanner: false,
    routes: {
      '/home': (_) => HomePage(),
      '/adicionarProduto': (_) => AdicionarProdutoPage(),
      '/relatorioVendas': (_) => RelatorioVendasPage(),
      'register': (_) => RegisterPage(),
      //'estoque': (_) => EstoquePage(tipoUsuario: 'tipoUsuario'),
    },
  ));
}
