import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dominio/entidades/treino.dart';
import '../../dominio/entidades/exercicios.dart';
import '../../dominio/entidades/treino_personalizado.dart';
import '../../dados/repositorios/exercicios_data.dart';
import '../controladores/treino_personalizado_controlador.dart';
import '../../../usuario/widgets/painel_usuario.dart';
import 'treino_personalizado_pagina.dart';

class TreinoPagina extends StatefulWidget {
  final String nivel;
  const TreinoPagina({super.key, required this.nivel});

  @override
  State<TreinoPagina> createState() => _TreinoPaginaState();
}

class _TreinoPaginaState extends State<TreinoPagina>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Número de treinos pré-definidos por nível (iniciante=3, intermediário=4, avançado=5).
  static const Map<String, int> _quantidadePorNivel = {
    'iniciante': 3,
    'intermediario': 4,
    'avancado': 5,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TreinoPersonalizadoControlador>().carregar();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Gera os treinos pré-definidos usando listas curadas por nível (não tags).
  List<Treino> _gerarTreinos() {
    final nivelNormalizado = widget.nivel.trim().toLowerCase();
    final int quantidade = _quantidadePorNivel[nivelNormalizado] ?? 3;
    const configuracoes = [
      {'titulo': 'Treino A', 'key': 'treinoa'},
      {'titulo': 'Treino B', 'key': 'treinob'},
      {'titulo': 'Treino C', 'key': 'treinoc'},
      {'titulo': 'Treino D', 'key': 'treinod'},
      {'titulo': 'Treino E', 'key': 'treinoe'},
    ];

    final gruposDoNivel =
        _kExerciciosPreDefinido[nivelNormalizado] ?? <String, List<String>>{};
    final treinos = <Treino>[];

    for (var i = 0; i < quantidade; i++) {
      final conf = configuracoes[i];

      final nomesCurados = gruposDoNivel[conf['key']!] ?? [];

      // Para cada nome curado, prefere a versão do nível do usuário; fallback para qualquer nível.
      final nomeToEx = <String, Exercicio>{};
      for (final ex in exercicios) {
        final nomeLower = ex.nome.trim().toLowerCase();
        if (!nomesCurados.contains(nomeLower)) continue;
        final exTags = ex.tags.map((t) => t.toLowerCase()).toList();
        if (exTags.contains(nivelNormalizado)) {
          nomeToEx[nomeLower] = ex;
        } else {
          nomeToEx.putIfAbsent(nomeLower, () => ex);
        }
      }

      final exerciciosDoTreino = nomesCurados
          .map((n) => nomeToEx[n.toLowerCase()])
          .whereType<Exercicio>()
          .toList();

      treinos.add(Treino(
        titulo: conf['titulo']!,
        botaoEscuro: i.isEven,
        exercicios: exerciciosDoTreino,
      ));
    }
    return treinos;
  }

  String _nivelLabel() {
    final n = widget.nivel.trim().toLowerCase();
    return n[0].toUpperCase() + n.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final treinos = _gerarTreinos();

    return Scaffold(
      backgroundColor: const Color(0xFF1B2B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2B2A),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seus Treinos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Nível ${_nivelLabel()}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFA8D5BA),
          indicatorWeight: 3,
          labelColor: const Color(0xFFA8D5BA),
          unselectedLabelColor: Colors.white38,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Pré-definido'),
            Tab(text: 'Personalizado'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TabPreDefinido(treinos: treinos, nivel: widget.nivel),
          _TabPersonalizado(nivel: widget.nivel),
        ],
      ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: Color(0xFF2E3D3C),
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              splashColor: Colors.white24,
              onTap: () => PainelUsuario.abrir(context),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.person, color: Colors.white54, size: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabPreDefinido extends StatelessWidget {
  final List<Treino> treinos;
  final String nivel;
  const _TabPreDefinido({required this.treinos, required this.nivel});

  // Labels dos grupos musculares por treino — variam por nível pois C e D mudam de significado.
  Map<String, String> get _grupos {
    final n = nivel.trim().toLowerCase();
    if (n == 'avancado') {
      return const {
        'Treino A': 'Peito • Tríceps',
        'Treino B': 'Costas • Bíceps',
        'Treino C': 'Ombros',
        'Treino D': 'Pernas',
        'Treino E': 'Braços',
      };
    }
    if (n == 'iniciante') {
      return const {
        'Treino A': 'Peito • Tríceps',
        'Treino B': 'Costas • Bíceps',
        'Treino C': 'Pernas • Ombros',
      };
    }
    // intermediario
    return const {
      'Treino A': 'Peito • Tríceps',
      'Treino B': 'Costas • Bíceps',
      'Treino C': 'Pernas',
      'Treino D': 'Ombros',
    };
  }

  static const List<List<Color>> _gradientes = [
    [Color(0xFF4A7B70), Color(0xFF2A4A45)],
    [Color(0xFF3E6B5E), Color(0xFF1F3832)],
    [Color(0xFF547A6D), Color(0xFF2E4D47)],
    [Color(0xFF4A7B70), Color(0xFF2A4A45)],
    [Color(0xFF3E6B5E), Color(0xFF1F3832)],
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      itemCount: treinos.length,
      itemBuilder: (context, index) {
        final treino = treinos[index];
        final gradiente = _gradientes[index % _gradientes.length];
        final grupo = _grupos[treino.titulo] ?? '';
        return _CardTreino(
          treino: treino,
          gradiente: gradiente,
          grupo: grupo,
          onPressed: () => Navigator.pushNamed(
            context,
            '/treino/exercicios',
            arguments: treino,
          ),
        );
      },
    );
  }
}

class _CardTreino extends StatelessWidget {
  final Treino treino;
  final List<Color> gradiente;
  final String grupo;
  final VoidCallback onPressed;

  const _CardTreino({
    required this.treino,
    required this.gradiente,
    required this.grupo,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradiente,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradiente[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          splashColor: Colors.white12,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        treino.titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        grupo,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${treino.exercicios.length} exercícios',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
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

class _TabPersonalizado extends StatelessWidget {
  final String nivel;
  const _TabPersonalizado({required this.nivel});

  @override
  Widget build(BuildContext context) {
    return Consumer<TreinoPersonalizadoControlador>(
      builder: (context, ctrl, _) {
        if (ctrl.carregando) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFA8D5BA)),
          );
        }

        if (!ctrl.temTreino) {
          return _CriarTreinoPrompt(
            onCriar: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TreinoPersonalizadoPagina()),
            ),
          );
        }

        return _TreinoPersonalizadoView(
          treino: ctrl.treino!,
          nivel: nivel,
          onEditar: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const TreinoPersonalizadoPagina()),
          ),
          onExcluir: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: const Color(0xFF2E3D3C),
                title: const Text('Excluir treino?',
                    style: TextStyle(color: Colors.white)),
                content: const Text(
                  'Seu treino personalizado será removido.',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Colors.white54)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Excluir',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
            if (confirm == true) ctrl.excluir();
          },
        );
      },
    );
  }
}

class _CriarTreinoPrompt extends StatelessWidget {
  final VoidCallback onCriar;
  const _CriarTreinoPrompt({required this.onCriar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFFA8D5BA),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Crie seu treino',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Monte um plano com os dias da semana e os grupos musculares que você quer trabalhar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCriar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA8D5BA),
                  foregroundColor: const Color(0xFF1B2B2A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Criar Treino Personalizado',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Exercícios curados por nível e treino. Substituem o filtro por tags que tinha contaminação cruzada.
const Map<String, Map<String, List<String>>> _kExerciciosPreDefinido = {
  'iniciante': {
    'treinoa': [
      'supino reto barra', 'supino inclinado halter', 'flexão de braço',
      'tríceps corda polia', 'crucifixo inclinado halter',
    ],
    'treinob': [
      'barra fixa assistida', 'remada unilateral halter', 'pulldown polia alta',
      'rosca direta barra', 'remada sentado polia', 'rosca na polia',
    ],
    'treinoc': [
      'agachamento livre barra', 'leg press', 'cadeira extensora',
      'panturrilha em pé', 'desenvolvimento militar halter', 'elevação lateral halter',
    ],
  },
  'intermediario': {
    'treinoa': [
      'supino reto barra', 'supino inclinado halter', 'crucifixo inclinado halter',
      'crossover polia alta', 'tríceps corda polia', 'pec deck (voador máquina)',
    ],
    'treinob': [
      'barra fixa', 'remada curvada barra', 'remada unilateral halter',
      'pulldown polia alta', 'rosca alternada halter', 'rosca direta barra',
      'remada sentado polia',
    ],
    'treinoc': [
      'agachamento livre barra', 'leg press', 'cadeira extensora', 'cadeira flexora',
      'panturrilha em pé', 'hip thrust', 'stiff / terra romeno',
    ],
    'treinod': [
      'desenvolvimento militar barra', 'elevação lateral halter',
      'elevação frontal halter', 'encolhimento barra', 'arnold press',
    ],
  },
  'avancado': {
    'treinoa': [
      'supino reto barra', 'supino inclinado halter', 'crucifixo inclinado halter',
      'crossover polia alta', 'dips (paralelas)', 'tríceps testa barra',
      'tríceps corda polia',
    ],
    'treinob': [
      'levantamento terra', 'barra fixa', 'remada curvada barra',
      'remada unilateral halter', 'pulldown polia alta',
      'rosca direta barra', 'rosca alternada halter', 'chin-up (barra supinada)',
    ],
    'treinoc': [
      'desenvolvimento militar barra', 'arnold press', 'elevação lateral halter',
      'elevação frontal halter', 'encolhimento barra', 'face pull',
    ],
    'treinod': [
      'agachamento livre barra', 'leg press', 'stiff / terra romeno',
      'agachamento búlgaro', 'hip thrust', 'cadeira extensora',
      'cadeira flexora', 'panturrilha em pé',
    ],
    'treinoe': [
      'rosca direta barra', 'rosca scott', 'rosca martelo',
      'rosca alternada halter', 'tríceps testa barra',
      'tríceps corda polia', 'tríceps francês halter',
    ],
  },
};

// Nomes canônicos por grupo muscular (compostos primeiro). Base do treino personalizado.
const Map<String, List<String>> _kNomesGrupo = {
  'peito': [
    'supino reto barra',
    'supino inclinado halter',
    'dips (paralelas)',
    'crucifixo inclinado halter',
    'pec deck (voador máquina)',
    'crossover polia alta',
    'flexão de braço',
    'tríceps corda polia',
    'tríceps testa barra',
    'tríceps francês halter',
  ],
  'costas': [
    'levantamento terra',
    'barra fixa',
    'chin-up (barra supinada)',
    'barra fixa assistida',
    'remada curvada barra',
    'remada unilateral halter',
    'remada sentado polia',
    'pulldown polia alta',
    'face pull',
    'rosca direta barra',
    'rosca alternada halter',
    'rosca na polia',
  ],
  'pernas': [
    'agachamento livre barra',
    'leg press',
    'hack squat',
    'agachamento búlgaro',
    'agachamento sumô',
    'stiff / terra romeno',
    'hip thrust',
    'cadeira extensora',
    'cadeira flexora',
    'panturrilha em pé',
    'panturrilha sentado',
  ],
  'ombros': [
    'desenvolvimento militar barra',
    'arnold press',
    'desenvolvimento militar halter',
    'elevação lateral halter',
    'elevação frontal halter',
    'encolhimento barra',
    'face pull',
    'desenvolvimento máquina',
  ],
  'bracos': [
    'rosca direta barra',
    'rosca scott',
    'rosca martelo',
    'rosca alternada halter',
    'rosca na polia',
    'tríceps testa barra',
    'tríceps corda polia',
    'tríceps francês halter',
    'dips (paralelas)',
  ],
};

// Retorna até 8 exercícios para um grupo muscular (pré-seleção padrão do treino personalizado).
List<Exercicio> _exerciciosParaGrupo(GrupoMuscular grupo) {
  final List<String> nomes;
  if (_kNomesGrupo.containsKey(grupo.id)) {
    nomes = _kNomesGrupo[grupo.id]!;
  } else if (grupo.id == 'upper') {
    nomes = [
      ..._kNomesGrupo['peito']!.take(3),
      ..._kNomesGrupo['costas']!.take(3),
      ..._kNomesGrupo['ombros']!.take(2),
    ];
  } else if (grupo.id == 'lower') {
    nomes = _kNomesGrupo['pernas']!;
  } else if (grupo.id == 'fullbody') {
    nomes = [
      ..._kNomesGrupo['peito']!.take(2),
      ..._kNomesGrupo['costas']!.take(2),
      ..._kNomesGrupo['pernas']!.take(2),
      ..._kNomesGrupo['ombros']!.take(2),
      ..._kNomesGrupo['bracos']!.take(2),
    ];
  } else {
    return [];
  }

  final nomesLower = nomes.map((n) => n.toLowerCase()).toList();
  final nomesSet = nomesLower.toSet();
  final found = exercicios
      .where((e) => nomesSet.contains(e.nome.trim().toLowerCase()))
      .toList();

  // Dedup por nome (o mesmo exercício existe em múltiplos níveis no banco).
  final seen = <String>{};
  final deduped = found
      .where((e) => seen.add(e.nome.trim().toLowerCase()))
      .toList();

  // Restaura a ordem definida em _kNomesGrupo (compostos primeiro).
  deduped.sort((a, b) {
    final ia = nomesLower.indexOf(a.nome.trim().toLowerCase());
    final ib = nomesLower.indexOf(b.nome.trim().toLowerCase());
    return ia.compareTo(ib);
  });

  return deduped.take(8).toList();
}

// Todos os exercícios agrupados por seção muscular para o sheet de edição.
List<MapEntry<String, List<Exercicio>>> _exerciciosPorSecao() {
  final ordemSecoes = [
    MapEntry('Peito & Tríceps', 'peito'),
    MapEntry('Costas & Bíceps', 'costas'),
    MapEntry('Pernas', 'pernas'),
    MapEntry('Ombros', 'ombros'),
    MapEntry('Braços', 'bracos'),
  ];

  final seen = <String>{};
  final result = <MapEntry<String, List<Exercicio>>>[];

  for (final entry in ordemSecoes) {
    final grupo = GrupoMuscular.porId(entry.value);
    if (grupo == null) continue;
    final exs = _todosExerciciosParaGrupo(grupo)
        .where((ex) => seen.add(ex.nome.trim().toLowerCase()))
        .toList();
    if (exs.isNotEmpty) result.add(MapEntry(entry.key, exs));
  }
  return result;
}

// Igual a _exerciciosParaGrupo, sem o limite de 8.
List<Exercicio> _todosExerciciosParaGrupo(GrupoMuscular grupo) {
  final List<String> nomes;
  if (_kNomesGrupo.containsKey(grupo.id)) {
    nomes = _kNomesGrupo[grupo.id]!;
  } else if (grupo.id == 'upper') {
    nomes = [
      ..._kNomesGrupo['peito']!,
      ..._kNomesGrupo['costas']!,
      ..._kNomesGrupo['ombros']!,
    ];
  } else if (grupo.id == 'lower') {
    nomes = _kNomesGrupo['pernas']!;
  } else if (grupo.id == 'fullbody') {
    nomes = [
      for (final g in ['peito', 'costas', 'pernas', 'ombros', 'bracos'])
        ..._kNomesGrupo[g]!,
    ];
  } else {
    return [];
  }

  final nomesLower = nomes.map((n) => n.toLowerCase()).toList();
  final nomesSet = nomesLower.toSet();
  final found = exercicios
      .where((e) => nomesSet.contains(e.nome.trim().toLowerCase()))
      .toList();
  final seen = <String>{};
  final deduped = found
      .where((e) => seen.add(e.nome.trim().toLowerCase()))
      .toList();
  deduped.sort((a, b) {
    final ia = nomesLower.indexOf(a.nome.trim().toLowerCase());
    final ib = nomesLower.indexOf(b.nome.trim().toLowerCase());
    return ia.compareTo(ib);
  });
  return deduped;
}

class _TreinoPersonalizadoView extends StatelessWidget {
  final TreinoPersonalizado treino;
  final String nivel;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _TreinoPersonalizadoView({
    required this.treino,
    required this.nivel,
    required this.onEditar,
    required this.onExcluir,
  });

  // Abre o sheet com todos os exercícios; pré-seleciona os do grupo do dia.
  void _abrirEdicaoExercicios(
      BuildContext context, DiaPersonalizado dia, int diaIndex) {
    final secoes = _exerciciosPorSecao();
    final todos = secoes.expand((s) => s.value).toList();
    final iniciais = dia.exerciciosSelecionados.isEmpty
        ? _exerciciosParaGrupo(dia.grupo).map((e) => e.nome).toSet()
        : Set<String>.from(dia.exerciciosSelecionados);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditarExerciciosSheet(
        dia: dia,
        todosExercicios: todos,
        secoes: secoes,
        selecionadosIniciais: iniciais,
        onSalvar: (novos) async {
          final ctrl = context.read<TreinoPersonalizadoControlador>();
          final novaLista = List<DiaPersonalizado>.from(ctrl.treino!.dias);
          novaLista[diaIndex] =
              dia.copyWith(exerciciosSelecionados: novos.toList());
          await ctrl.salvar(TreinoPersonalizado(dias: novaLista));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Seu plano semanal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: onEditar,
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.white54, size: 20),
              tooltip: 'Editar dias',
            ),
            IconButton(
              onPressed: onExcluir,
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 20),
              tooltip: 'Excluir',
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...treino.dias.asMap().entries.map((entry) {
          final diaIndex = entry.key;
          final dia = entry.value;
          final todos = _exerciciosParaGrupo(dia.grupo);
          final lista = dia.exerciciosSelecionados.isEmpty
              ? todos
              : todos
                  .where((e) =>
                      dia.exerciciosSelecionados.contains(e.nome))
                  .toList();
          final treinoGerado = Treino(
            titulo: '${dia.diaSemana} — ${dia.grupo.nome}',
            botaoEscuro: false,
            exercicios: lista,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                // Main tap area → open exercises list
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18)),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/treino/exercicios',
                      arguments: treinoGerado,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFA8D5BA)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(dia.grupo.icone,
                                color: const Color(0xFFA8D5BA), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dia.diaSemana,
                                  style: const TextStyle(
                                    color: Color(0xFFA8D5BA),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dia.grupo.descricao,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${lista.length} exercícios',
                                  style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.white24, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
                // Edit exercises button
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(18)),
                    onTap: () =>
                        _abrirEdicaoExercicios(context, dia, diaIndex),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.tune,
                              color: Colors.white38, size: 14),
                          const SizedBox(width: 6),
                          const Text(
                            'Editar exercícios',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _EditarExerciciosSheet extends StatefulWidget {
  final DiaPersonalizado dia;
  final List<Exercicio> todosExercicios;
  final List<MapEntry<String, List<Exercicio>>> secoes;
  final Set<String> selecionadosIniciais;
  final Future<void> Function(Set<String>) onSalvar;

  const _EditarExerciciosSheet({
    required this.dia,
    required this.todosExercicios,
    required this.secoes,
    required this.selecionadosIniciais,
    required this.onSalvar,
  });

  @override
  State<_EditarExerciciosSheet> createState() =>
      _EditarExerciciosSheetState();
}

class _EditarExerciciosSheetState extends State<_EditarExerciciosSheet> {
  late Set<String> _selecionados;
  bool _salvando = false;

  // Lista plana intercalando String (cabeçalho de seção) e Exercicio (linha com checkbox).
  late final List<Object> _itens;

  @override
  void initState() {
    super.initState();
    _selecionados = Set<String>.from(widget.selecionadosIniciais);
    _itens = [
      for (final secao in widget.secoes) ...[secao.key, ...secao.value],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1B2B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8D5BA).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.dia.diaSemana,
                    style: const TextStyle(
                        color: Color(0xFFA8D5BA),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.dia.grupo.descricao,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${_selecionados.length} selecionados',
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _itens.length,
              itemBuilder: (context, i) {
                final item = _itens[i];

                if (item is String) { // cabeçalho de seção
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFFA8D5BA),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  );
                }

                final ex = item as Exercicio;
                final sel = _selecionados.contains(ex.nome);
                return CheckboxListTile(
                  value: sel,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selecionados.add(ex.nome);
                      } else if (_selecionados.length > 1) {
                        _selecionados.remove(ex.nome);
                      }
                    });
                  },
                  title: Text(
                    ex.nome,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.white54,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    ex.reps,
                    style: const TextStyle(
                        color: Color(0xFFA8D5BA), fontSize: 12),
                  ),
                  secondary: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      ex.imagem,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 44,
                        height: 44,
                        color: Colors.white.withValues(alpha: 0.05),
                        child: const Icon(Icons.fitness_center,
                            color: Colors.white24, size: 20),
                      ),
                    ),
                  ),
                  activeColor: const Color(0xFFA8D5BA),
                  checkColor: const Color(0xFF1B2B2A),
                  tileColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                );
              },
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvando
                    ? null
                    : () async {
                        setState(() => _salvando = true);
                        final nav = Navigator.of(context);
                        await widget.onSalvar(_selecionados);
                        if (mounted) nav.pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA8D5BA),
                  foregroundColor: const Color(0xFF1B2B2A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _salvando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF1B2B2A)),
                      )
                    : const Text('Salvar',
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
