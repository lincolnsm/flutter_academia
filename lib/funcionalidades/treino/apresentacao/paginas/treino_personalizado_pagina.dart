import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dominio/entidades/treino_personalizado.dart';
import '../controladores/treino_personalizado_controlador.dart';

class TreinoPersonalizadoPagina extends StatefulWidget {
  const TreinoPersonalizadoPagina({super.key});

  @override
  State<TreinoPersonalizadoPagina> createState() =>
      _TreinoPersonalizadoPaginaState();
}

class _TreinoPersonalizadoPaginaState extends State<TreinoPersonalizadoPagina>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _etapa = 0;
  int _quantidadeDias = 3;

  static const Map<int, List<String>> _distribuicaoPadrao = {
    2: ['Seg', 'Qui'],
    3: ['Seg', 'Qua', 'Sex'],
    4: ['Seg', 'Ter', 'Qui', 'Sex'],
    5: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'],
    6: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'],
  };

  List<String> _diasSelecionados = ['Seg', 'Qua', 'Sex'];
  Map<String, GrupoMuscular?> _gruposPorDia = {};

  @override
  void initState() {
    super.initState();
    _atualizarDias(3);
  }

  void _atualizarDias(int quantidade) {
    _quantidadeDias = quantidade;
    _diasSelecionados =
        List<String>.from(_distribuicaoPadrao[quantidade] ?? ['Seg', 'Qua', 'Sex']);
    _gruposPorDia = {for (final d in _diasSelecionados) d: null};
  }

  void _toggleDia(String dia) {
    setState(() {
      if (_diasSelecionados.contains(dia)) {
        if (_diasSelecionados.length > 1) {
          _diasSelecionados.remove(dia);
          _gruposPorDia.remove(dia);
        }
      } else if (_diasSelecionados.length < _quantidadeDias) {
        _diasSelecionados.add(dia);
        _diasSelecionados.sort((a, b) =>
            ordemDiasSemana.indexOf(a).compareTo(ordemDiasSemana.indexOf(b)));
        _gruposPorDia[dia] = null;
      }
    });
  }

  void _aplicarTemplate(SplitTemplate template) {
    final dias = List<String>.from(
        _distribuicaoPadrao[template.dias] ?? ['Seg', 'Qua', 'Sex']);
    final novosGrupos = <String, GrupoMuscular?>{};
    for (var i = 0; i < dias.length && i < template.gruposIds.length; i++) {
      novosGrupos[dias[i]] = GrupoMuscular.porId(template.gruposIds[i]);
    }
    setState(() {
      _quantidadeDias = template.dias;
      _diasSelecionados = dias;
      _gruposPorDia = novosGrupos;
    });
    _proximaEtapa();
  }

  bool get _etapa2Valida =>
      _gruposPorDia.values.every((g) => g != null) &&
      _diasSelecionados.length == _quantidadeDias;

  Future<void> _salvar() async {
    final ctrl = context.read<TreinoPersonalizadoControlador>();
    final diasOrdenados = List<String>.from(_diasSelecionados)
      ..sort((a, b) =>
          ordemDiasSemana.indexOf(a).compareTo(ordemDiasSemana.indexOf(b)));

    final dias = diasOrdenados.map((d) {
      return DiaPersonalizado(
        diaSemana: d,
        grupo: _gruposPorDia[d]!,
      );
    }).toList();

    final ok = await ctrl.salvar(TreinoPersonalizado(dias: dias));
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar treino. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _proximaEtapa() {
    setState(() => _etapa = 1);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _etapaAnterior() {
    setState(() => _etapa = 0);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed:
              _etapa == 0 ? () => Navigator.pop(context) : _etapaAnterior,
        ),
        title: const Text(
          'Treino Personalizado',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _IndicadorEtapa(etapa: _etapa),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _EtapaDias(
                  quantidadeDias: _quantidadeDias,
                  diasSelecionados: _diasSelecionados,
                  distribuicaoPadrao: _distribuicaoPadrao,
                  onQuantidadeChanged: (q) =>
                      setState(() => _atualizarDias(q)),
                  onToggleDia: _toggleDia,
                  onProximo: _proximaEtapa,
                  onAplicarTemplate: _aplicarTemplate,
                ),
                _EtapaGrupos(
                  diasSelecionados: _diasSelecionados,
                  gruposPorDia: _gruposPorDia,
                  onGrupoSelecionado: (dia, grupo) =>
                      setState(() => _gruposPorDia[dia] = grupo),
                  onSalvar: _salvar,
                  valido: _etapa2Valida,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicadorEtapa extends StatelessWidget {
  final int etapa;
  const _IndicadorEtapa({required this.etapa});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: List.generate(2, (i) {
          final ativo = i == etapa;
          final concluido = i < etapa;
          return Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: concluido || ativo
                        ? const Color(0xFFA8D5BA)
                        : Colors.white12,
                  ),
                  child: Center(
                    child: concluido
                        ? const Icon(Icons.check,
                            size: 14, color: Color(0xFF1B2B2A))
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: ativo
                                  ? const Color(0xFF1B2B2A)
                                  : Colors.white38,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                if (i < 1)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 2,
                      color: concluido
                          ? const Color(0xFFA8D5BA)
                          : Colors.white12,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _EtapaDias extends StatelessWidget {
  final int quantidadeDias;
  final List<String> diasSelecionados;
  final Map<int, List<String>> distribuicaoPadrao;
  final ValueChanged<int> onQuantidadeChanged;
  final ValueChanged<String> onToggleDia;
  final VoidCallback onProximo;
  final ValueChanged<SplitTemplate> onAplicarTemplate;

  const _EtapaDias({
    required this.quantidadeDias,
    required this.diasSelecionados,
    required this.distribuicaoPadrao,
    required this.onQuantidadeChanged,
    required this.onToggleDia,
    required this.onProximo,
    required this.onAplicarTemplate,
  });

  @override
  Widget build(BuildContext context) {
    final templates = SplitTemplate.paraDias(quantidadeDias);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Quantos dias por semana\nvocê vai treinar?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escolha a frequência ideal para seu objetivo.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 28),
          Row(
            children: List.generate(5, (i) {
              final dias = i + 2;
              final sel = dias == quantidadeDias;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onQuantidadeChanged(dias),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 52,
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFA8D5BA)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: sel ? null : Border.all(color: Colors.white12),
                    ),
                    child: Center(
                      child: Text(
                        '$dias',
                        style: TextStyle(
                          color: sel
                              ? const Color(0xFF1B2B2A)
                              : Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '$quantidadeDias dias / semana',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),

          // ── Split templates ──────────────────────────────────────
          if (templates.isNotEmpty) ...[
            const SizedBox(height: 36),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8D5BA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Splits sugeridos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Toque em um para começar com a divisão pré-configurada',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: templates.length,
                itemBuilder: (context, i) {
                  final t = templates[i];
                  final dias = distribuicaoPadrao[t.dias] ?? [];
                  return _TemplateCard(
                    template: t,
                    dias: dias,
                    onTap: () => onAplicarTemplate(t),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(child: Divider(color: Colors.white12)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'ou configure manualmente',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11),
                  ),
                ),
                const Expanded(child: Divider(color: Colors.white12)),
              ],
            ),
          ],

          // ── Manual day selection ─────────────────────────────────
          const SizedBox(height: 28),
          const Text(
            'Escolha os dias',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecione exatamente $quantidadeDias dias',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: ordemDiasSemana.map((dia) {
              final sel = diasSelecionados.contains(dia);
              final podeSelecionar =
                  sel || diasSelecionados.length < quantidadeDias;
              return Expanded(
                child: GestureDetector(
                  onTap: podeSelecionar ? () => onToggleDia(dia) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFA8D5BA)
                          : Colors.white.withValues(
                              alpha: podeSelecionar ? 0.08 : 0.03),
                      borderRadius: BorderRadius.circular(10),
                      border: sel
                          ? null
                          : Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          dia.substring(0, 1),
                          style: TextStyle(
                            color: sel
                                ? const Color(0xFF1B2B2A)
                                : podeSelecionar
                                    ? Colors.white70
                                    : Colors.white24,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (sel)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1B2B2A),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  diasSelecionados.length == quantidadeDias ? onProximo : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA8D5BA),
                disabledBackgroundColor: Colors.white12,
                foregroundColor: const Color(0xFF1B2B2A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                'Próximo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final SplitTemplate template;
  final List<String> dias;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.dias,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 168,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E4A45), Color(0xFF1B3530)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: const Color(0xFFA8D5BA).withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template.nome,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              template.descricao,
              style: const TextStyle(color: Colors.white38, fontSize: 10.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(template.gruposIds.length, (i) {
                  final grupo = GrupoMuscular.porId(template.gruposIds[i]);
                  final dia = i < dias.length ? dias[i] : '—';
                  if (grupo == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Icon(grupo.icone,
                            size: 11,
                            color: const Color(0xFFA8D5BA)
                                .withValues(alpha: 0.8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$dia · ${grupo.nome}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFA8D5BA),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'Usar',
                  style: TextStyle(
                    color: Color(0xFF1B2B2A),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EtapaGrupos extends StatelessWidget {
  final List<String> diasSelecionados;
  final Map<String, GrupoMuscular?> gruposPorDia;
  final void Function(String dia, GrupoMuscular grupo) onGrupoSelecionado;
  final VoidCallback onSalvar;
  final bool valido;

  const _EtapaGrupos({
    required this.diasSelecionados,
    required this.gruposPorDia,
    required this.onGrupoSelecionado,
    required this.onSalvar,
    required this.valido,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Configure cada dia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escolha o foco muscular para cada dia.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 28),
          ...diasSelecionados.map((dia) {
            final grupoSel = gruposPorDia[dia];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: grupoSel != null
                      ? const Color(0xFFA8D5BA).withValues(alpha: 0.5)
                      : Colors.white12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA8D5BA)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dia,
                          style: const TextStyle(
                            color: Color(0xFFA8D5BA),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (grupoSel != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(grupoSel.icone,
                                size: 14, color: Colors.white38),
                            const SizedBox(width: 4),
                            Text(
                              grupoSel.descricao,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: GrupoMuscular.todos.map((grupo) {
                      final sel = grupoSel?.id == grupo.id;
                      return GestureDetector(
                        onTap: () => onGrupoSelecionado(dia, grupo),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFFA8D5BA)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                grupo.icone,
                                size: 15,
                                color: sel
                                    ? const Color(0xFF1B2B2A)
                                    : Colors.white54,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                grupo.nome,
                                style: TextStyle(
                                  color: sel
                                      ? const Color(0xFF1B2B2A)
                                      : Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Consumer<TreinoPersonalizadoControlador>(
            builder: (context, ctrl, _) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: valido && !ctrl.carregando ? onSalvar : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8D5BA),
                    disabledBackgroundColor: Colors.white12,
                    foregroundColor: const Color(0xFF1B2B2A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: ctrl.carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF1B2B2A)),
                        )
                      : const Text(
                          'Salvar Treino',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
