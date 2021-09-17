import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cripto_moedas/database/db_firestore.dart';
import 'package:cripto_moedas/models/moeda.dart';
import 'package:cripto_moedas/repositories/moeda_repository.dart';
import 'package:cripto_moedas/services/auth_service.dart';
import 'package:flutter/material.dart';

class FavoritasRepository extends ChangeNotifier {
  final List<Moeda> _lista = [];
  late FirebaseFirestore db;
  late AuthService auth;

  FavoritasRepository({required this.auth}) {
    _startRepository();
  }

  _startRepository() async {
    _startFirestore();
    await _readFavoritas();
  }

  void _startFirestore() {
    db = DBFirestore.get();
  }

  Future<void> _readFavoritas() async {
    if (auth.usuario != null && _lista.isEmpty) {
      final snapshot =
          await db.collection('usuarios/${auth.usuario!.uid}/favoritas').get();

      snapshot.docs.forEach((doc) {
        Moeda moeda = MoedaRepository.tabela
            .firstWhere((m) => m.sigla == doc.get('sigla'));
        _lista.add(moeda);
        notifyListeners();
      });
    }
  }

  UnmodifiableListView<Moeda> get lista => UnmodifiableListView(_lista);

  Future<void> saveAll(List<Moeda> moedas) async {
    moedas.forEach((moeda) async {
      if (!_lista.any((atual) => atual.sigla == moeda.sigla)) {
        _lista.add(moeda);
        await db
            .collection('usuarios/${auth.usuario!.uid}/favoritas')
            .doc(moeda.sigla)
            .set({
          'moeda': moeda.nome,
          'sigla': moeda.sigla,
          'preco': moeda.preco,
        });
      }
    });

    notifyListeners();
  }

  Future<void> remove(Moeda moeda) async {
    await db
        .collection('usuarios/${auth.usuario!.uid}/favoritas')
        .doc(moeda.sigla)
        .delete();
    _lista.remove(moeda);

    notifyListeners();
  }
}
