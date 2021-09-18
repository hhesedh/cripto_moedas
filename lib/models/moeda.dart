class Moeda {
  String baseId;
  String icone;
  String nome;
  String sigla;
  double preco;
  DateTime timestamp;
  double mudancaHora;
  double mudancaDia;
  double mudancaSemana;
  double mudancaMes;
  double mudancaAno;
  double mudancaPeriodoTotal;

  Moeda({
    required this.baseId,
    required this.icone,
    required this.nome,
    required this.sigla,
    required this.preco,
    required this.timestamp,
    required this.mudancaHora,
    required this.mudancaDia,
    required this.mudancaSemana,
    required this.mudancaMes,
    required this.mudancaAno,
    required this.mudancaPeriodoTotal,
  });

  factory Moeda.fromJson(Map<String, dynamic> json) {
    return Moeda(
      baseId: json['baseId'],
      icone: json['icone'],
      sigla: json['sigla'],
      nome: json['nome'],
      preco: double.parse(json['preco']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      mudancaHora: double.parse(json['mudancaHora']),
      mudancaDia: double.parse(json['mudancaDia']),
      mudancaSemana: double.parse(json['mudancaSemana']),
      mudancaMes: double.parse(json['mudancaMes']),
      mudancaAno: double.parse(json['mudancaAno']),
      mudancaPeriodoTotal: double.parse(json['mudancaPeriodoTotal']),
    );
  }
}
