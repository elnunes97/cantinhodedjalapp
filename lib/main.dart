import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'LandingPage.dart';
import 'AdicionarProdutoPage.dart'; // Importe sua nova página aqui

void main() {
  runApp(MaterialApp(
    home: LandingPage(),
    //home: AdicionarProdutoPage(),
    debugShowCheckedModeBanner: false,
    routes: {
      '/home': (_) => HomePage(),
      '/adicionarProduto': (_) => AdicionarProdutoPage(),
    },
  ));
}
