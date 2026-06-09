class Exercicio {
  final String nome;
  final String imagem;
  final String tipoEquipamento;
  final String? linkYoutube;
  final List<String> tags;
  final String reps;
  final String? descricao;

  Exercicio({
    required this.nome,
    required this.imagem,
    required this.tipoEquipamento,
    this.linkYoutube,
    this.tags = const [],
    this.reps = '3 x 12',
    this.descricao,
  });
}
