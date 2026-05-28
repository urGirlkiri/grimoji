import 'dart:convert';
import 'dart:io';
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

  bool _isPlacementMode = true;
  final FocusNode _focusNode = FocusNode();

  double? _hoverPercentX;
  double? _hoverPercentY;

  @override
  void initState() {
    super.initState();
    _loadExistingMap();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadExistingMap() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/map.json',
      );
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      setState(() {
        _nodes = data
            .map((json) => LevelNde.fromJson(json as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      _logger.warning("No existing map found or error loading: $e");
      setState(() => _isLoading = false);
    }
  }

  void _handleMapTap(Offset localPosition, double mapWidth, double mapHeight) {
    if (!_isPlacementMode) return;

    final double percentX = localPosition.dx / mapWidth;
    final double percentY = localPosition.dy / mapHeight;

    final int nextLevel = _nodes.isEmpty
        ? 1
        : _nodes.map((n) => n.level).reduce((a, b) => a > b ? a : b) + 1;

    setState(() {
      _nodes.add(LevelNde(level: nextLevel, x: percentX, y: percentY));
      _nodes.sort((a, b) => a.level.compareTo(b.level));
    });
  }

  void _deleteNode(LevelNde node) {
    if (_isPlacementMode) return;

    setState(() {
      _nodes.remove(node);
      for (int i = 0; i < _nodes.length; i++) {
        _nodes[i] = LevelNde(level: i + 1, x: _nodes[i].x, y: _nodes[i].y);
      }
    });
  }

  void _toggleMode() {
    setState(() {
      _isPlacementMode = !_isPlacementMode;
      if (!_isPlacementMode) {
        _hoverPercentX = null;
        _hoverPercentY = null;
      }
    });
  }

  Future<void> _saveMapData() async {
    try {
      final jsonOutput = jsonEncode(_nodes.map((n) => n.toJson()).toList());
      Directory current = Directory.current;
      final filePath = '${current.path}/assets/data/map.json';
      final file = File(filePath);

      await file.parent.create(recursive: true);
      await file.writeAsString(jsonOutput);

      await Clipboard.setData(ClipboardData(text: jsonOutput));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Updated!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height -200,
            ),
          ),
        );
      }
    } catch (e) {
      _logger.severe("Error saving map data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text("Failed to save map data."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height -200,
            ),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.keyC) {
          _toggleMode();
            return KeyEventResult.handled;
          } 
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double mapWidth = constraints.maxWidth;
            final double mapHeight = mapWidth * (mapImgHeight / mapImgWidth);
            final double nodeScale = mapWidth / mapImgWidth;

            return SingleChildScrollView(
              reverse: true,
              child: MouseRegion(
                onHover: (event) {
                  if (!_isPlacementMode) return;
                  setState(() {
                    _hoverPercentX = event.localPosition.dx / mapWidth;
                    _hoverPercentY = event.localPosition.dy / mapHeight;
                  });
                },
                onExit: (_) => setState(() {
                  _hoverPercentX = null;
                  _hoverPercentY = null;
                }),
                child: GestureDetector(
                  onTapDown: (details) =>
                      _handleMapTap(details.localPosition, mapWidth, mapHeight),
                  child: MapEngine(
                    mapWidth: mapWidth,
                    nodes: _nodes,
                    nodeScale: nodeScale,
                    onDeleteNode: _deleteNode,
                    hoverPercentX: _isPlacementMode ? _hoverPercentX : null,
                    hoverPercentY: _isPlacementMode ? _hoverPercentY : null,
                    isPlacementMode: _isPlacementMode,
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "mode_toggle",
              backgroundColor: _isPlacementMode
                  ? Colors.blue[300]
                  : Colors.red[300],
              onPressed: _toggleMode,
              child: Icon(
                _isPlacementMode ? Icons.add_location_alt : Icons.ads_click,
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "copy",
              backgroundColor: Colors.green[400],
              onPressed: _saveMapData,
              child: const Icon(Icons.save),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "clear",
              backgroundColor: Colors.red,
              onPressed: () => setState(() => _nodes.clear()),
              child: const Icon(Icons.delete_sweep),
            ),
          ],
        ),
      ),
    );
  }
}
