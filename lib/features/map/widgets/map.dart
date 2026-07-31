import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/features/map/painters/ground.dart';
import 'package:grimoji/features/map/painters/decorations.dart';
import 'package:grimoji/features/map/painters/road/index.dart';
import 'package:grimoji/features/map/painters/road/stripe.dart';
import 'package:grimoji/features/map/state.dart';
import 'package:grimoji/features/map/widgets/level_nodes/index.dart';
import 'package:grimoji/features/map/widgets/sky.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  static const double _roadCenter = 2;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MapState>().goToCurrentLv(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final state = context.watch<MapState>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        return GestureDetector(
          onVerticalDragUpdate: state.handlePanUpdate,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: mapSkyColor,
            child: Stack(
              children: [
                const Sky(),

                CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: GroundPainter(),
                ),
                Decorations(width: screenWidth, height: screenHeight),
                CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: RoadPainter(
                    center: MapWidget._roadCenter,
                    maxZ: state.maxWorldZ,
                    cameraZ: state.cameraZ,
                    scale: scale,
                  ),
                ),
                CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: RoadStripePainter(
                    center: MapWidget._roadCenter,
                    maxZ: state.maxWorldZ,
                    cameraZ: state.cameraZ,
                    scale: scale,
                  ),
                ),
                LevelNodes(
                  roadCenter: MapWidget._roadCenter,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
