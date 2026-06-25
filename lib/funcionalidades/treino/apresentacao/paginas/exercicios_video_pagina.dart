import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../usuario/apresentacao/widgets/painel_usuario.dart';

class ExercicioVideoPagina extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final String urlVideo;
  final String imagem;
  final String? reps;
  final String? descricao;

  const ExercicioVideoPagina({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.urlVideo,
    required this.imagem,
    this.reps,
    this.descricao,
  });

  @override
  State<ExercicioVideoPagina> createState() => _ExercicioVideoPaginaState();
}

class _ExercicioVideoPaginaState extends State<ExercicioVideoPagina> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.urlVideo,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        playsInline: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) {
        return _buildScaffold(context, player);
      },
    );
  }

  Scaffold _buildScaffold(BuildContext context, Widget player) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2B2A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.titulo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: player,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.reps != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA8D5BA).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.repeat,
                              size: 14, color: Color(0xFFA8D5BA)),
                          const SizedBox(width: 6),
                          Text(
                            widget.reps!,
                            style: const TextStyle(
                              color: Color(0xFFA8D5BA),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (widget.descricao != null &&
                      widget.descricao!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 14, color: Colors.white38),
                              SizedBox(width: 6),
                              Text(
                                'Execução',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.descricao!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        color: const Color(0xFF2E3D3C),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              splashColor: Colors.white24,
              highlightColor: Colors.white10,
              onTap: () => PainelUsuario.abrir(context),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  Icons.person,
                  color: Colors.white70,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}