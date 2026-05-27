import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grimoji/features/map/models/node.dart';
import 'package:logging/logging.dart';

class MapBuilderScreen extends StatefulWidget {
  const MapBuilderScreen({super.key});

  @override
  State<MapBuilderScreen> createState() => _MapBuilderScreenState();
}

class _MapBuilderScreenState extends State<MapBuilderScreen> {
  final Logger _logger = Logger('MapBuilderScreen');

  final List<MapNode> _nodes = [];

  void _handleMapTap(TapDownDetails details, Size mapSize) {
    final double percentX = details.localPosition.dx / mapSize.width;
    final double percentY = details.localPosition.dy / mapSize.height;

    final newNode = MapNode(level: _nodes.length + 1, x: percentX, y: percentY);

    setState(() {
      _nodes.add(newNode);
    });

    final jsonOutput = jsonEncode(_nodes.map((n) => n.toJson()).toList());
    _logger.info(jsonOutput);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: SingleChildScrollView(
        reverse: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapDown: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                _handleMapTap(details, box.size);
              },
              child: SizedBox(
                width: screenWidth, 
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/map/map_visual.png',
                      fit: BoxFit.fitWidth, 
                    ),

                    ..._nodes.map((node) {
                      final double alignX = (node.x * 2) - 1;
                      final double alignY = (node.y * 2) - 1;

                      return Positioned.fill(
                        child: Align(
                          alignment: Alignment(alignX, alignY),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete),
        onPressed: () {
          setState(() => _nodes.clear());
          _logger.info("Map Cleared!");
        },
      ),
    );
  }
}
