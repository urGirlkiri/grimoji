import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimoji/features/map/models/level_node.dart';
import 'package:grimoji/features/map/widgets/engine.dart';
import 'package:logging/logging.dart';

class MapBuilderScreen extends StatefulWidget {
  const MapBuilderScreen({super.key});

  @override
  State<MapBuilderScreen> createState() => _MapBuilderScreenState();
}

class _MapBuilderScreenState extends State<MapBuilderScreen> {
  final Logger _logger = Logger('MapBuilderScreen');

  List<LevelNde> _nodes = [];
  bool _isLoading = true;

  double? _hoverPercentX;
  double? _hoverPercentY;

  @override
  void initState() {
    super.initState();
    _loadExistingMap();
  }

  Future<void> _loadExistingMap() async {
    try {
      final String response = await rootBundle.loadString('assets/data/map.json');
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      setState(() {
        _nodes = data.map((json) => LevelNde.fromJson(json as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } catch (e) {
      _logger.warning("No existing map found or error loading: $e");
      setState(() => _isLoading = false);
    }
  }

  void _handleMapTap(Offset localPosition, double mapWidth, double mapHeight) {
    final double percentX = localPosition.dx / mapWidth;
    final double percentY = localPosition.dy / mapHeight;

    final int nextLevel = _nodes.isEmpty ? 1 : _nodes.map((n) => n.level).reduce((a, b) => a > b ? a : b) + 1;

    setState(() {
      _nodes.add(LevelNde(level: nextLevel, x: percentX, y: percentY));
      _nodes.sort((a, b) => a.level.compareTo(b.level));
    });
  }

  void _deleteNode(LevelNde node) {
    setState(() {
      _nodes.remove(node);
      for (int i = 0; i < _nodes.length; i++) {
        _nodes[i] = LevelNde(level: i + 1, x: _nodes[i].x, y: _nodes[i].y);
      }
    });
  }

  Future<void> _copyJsonToClipboard() async {
    final jsonOutput = jsonEncode(_nodes.map((n) => n.toJson()).toList());
    await Clipboard.setData(ClipboardData(text: jsonOutput));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Map JSON copied!"), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double mapWidth = constraints.maxWidth;
          final double mapHeight = mapWidth * (mapImgHeight / mapImgWidth);
          final double nodeScale = mapWidth / mapImgWidth;

          return SingleChildScrollView(
            reverse: true,
            child: MouseRegion(
              onHover: (event) {
                setState(() {
                  _hoverPercentX = event.localPosition.dx / mapWidth;
                  _hoverPercentY = event.localPosition.dy / mapHeight;
                });
              },
              onExit: (_) => setState(() { _hoverPercentX = null; _hoverPercentY = null; }),
              child: GestureDetector(
                onTapDown: (details) => _handleMapTap(details.localPosition, mapWidth, mapHeight),
                child: MapEngine(
                  mapWidth: mapWidth,
                  nodes: _nodes,
                  nodeScale: nodeScale,
                  onDeleteNode: _deleteNode,
                  hoverPercentX: _hoverPercentX,
                  hoverPercentY: _hoverPercentY,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(heroTag: "copy", backgroundColor: Colors.blue, onPressed: _copyJsonToClipboard, child: const Icon(Icons.copy)),
          const SizedBox(height: 16),
          FloatingActionButton(heroTag: "clear", backgroundColor: Colors.red, onPressed: () => setState(() => _nodes.clear()), child: const Icon(Icons.delete_sweep)),
        ],
      ),
    );
  }
}