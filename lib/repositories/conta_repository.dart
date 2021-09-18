import 'package:collection/src/iterable_extensions.dart';
import 'package:cripto_moedas/database/db.dart';
import 'package:cripto_moedas/models/historico.dart';
import 'package:cripto_moedas/models/moeda.dart';
import 'package:cripto_moedas/models/posicao.dart';
import 'package:cripto_moedas/repositories/moeda_repository.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class ContaRepository extends ChangeNotifier {
  late Database db;
  final List<Posicao> _carteira = [];
  final List<Historico> _historico = [];
  double _saldo = 0;
  MoedaRepository moedas;

  get saldo => _saldo;

  List<Posicao> get carteira => _carteira;
  List<Historico> get historico => _historico;

  ContaRepository({required this.moedas}) {
    _initRepository();
  }

  Future<void> _initRepository() async {
    await _getSaldo();
    await _getCarteira();
    await _getHistorico();
  }

  Future<void> _getSaldo() async {
    db = await DB.instance.database;
    List conta = await db.query('conta', limit: 1);
    _saldo = conta.first['saldo'];
    notifyListeners();
  }

  Future<void> setSaldo(double valor) async {
    db = await DB.instance.database;
    db.update('conta', {'saldo': valor});
    _saldo = valor;
    notifyListeners();
  }

  Future<void> comprar(Moeda moeda, double valor) async {
    db = await DB.instance.database;
    await db.transaction((txn) async {
      // Verificar se a moeda já foi comprada antes;
      final posicaoMoeda = await txn.query(
        'carteira',
        where: 'sigla = ?',
        whereArgs: [moeda.sigla],
      );

      // Se não tem a moeda em carteira
      if (posicaoMoeda.isEmpty) {
        await txn.insert('carteira', {
          'sigla': moeda.sigla,
          'moeda': moeda.nome,
          'quantidade': (valor / moeda.preco).toString(),
        });

        // Já tem a moeda em carteira
      } else {
        final atual = double.parse(posicaoMoeda.first['quantidade'].toString());

        await txn.update(
          'carteira',
          {'quantidade': (atual + (valor / moeda.preco)).toString()},
          where: 'sigla = ?',
          whereArgs: [moeda.sigla],
        );
      }

      // Inserir a compra no histórico

      await txn.insert('historico', {
        'sigla': moeda.sigla,
        'moeda': moeda.nome,
        'quantidade': (valor / moeda.preco).toString(),
        'valor': valor,
        'tipo_operacao': 'compra',
        'data_operacao': DateTime.now().microsecondsSinceEpoch
      });

      // Atualizar o saldo

      await txn.update('conta', {'saldo': saldo - valor});
    });

    await _initRepository();
    notifyListeners();
  }

  _getCarteira() async {
    _carteira.clear();
    List posicoes = await db.query('carteira');
    for (var posicao in posicoes) {
      Moeda? moeda =
          moedas.tabela.firstWhereOrNull((m) => m.sigla == posicao['sigla']);
      if (moeda != null) {
        _carteira.add(
          Posicao(
              moeda: moeda, quantidade: double.parse(posicao['quantidade'])),
        );
      }
    }
    notifyListeners();
  }

  _getHistorico() async {
    _historico.clear();
    List operacoes = await db.query('historico');
    for (var operacao in operacoes) {
      Moeda? moeda =
          moedas.tabela.firstWhereOrNull((m) => m.sigla == operacao['sigla']);

      if (moeda != null) {
        _historico.add(
          Historico(
            dataOperacao:
                DateTime.fromMicrosecondsSinceEpoch(operacao['data_operacao']),
            tipoOperacao: operacao['tipo_operacao'],
            moeda: moeda,
            valor: operacao['valor'],
            quantidade: double.parse(operacao['quantidade']),
          ),
        );
      }
    }
    notifyListeners();
  }
}
