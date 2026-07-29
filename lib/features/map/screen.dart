import 'package:flutter/material.dart';
import 'package:grimoji/features/map/models/projection_result.dart';
import 'package:grimoji/features/map/utils/globe_math.dart';
import 'package:grimoji/utils/context_data.dart';

class LevelsMapScreen extends StatefulWidget {
  const LevelsMapScreen({super.key});

  @override
  State<LevelsMapScreen> createState() => _LevelsMapScreenState();
}

class _LevelsMapScreenState extends State<LevelsMapScreen> {
  double _cameraZ = 0.0; 

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _cameraZ -= details.delta.dy * 2.0; 
      
      if (_cameraZ < 0) _cameraZ = 0; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF48484f), 
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;

          final ProjectionResult testNode = GlobeMath.project(
            worldX: 0,
            worldZ: 1000, 
            cameraZ: _cameraZ,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          );

          return GestureDetector(
            onVerticalDragUpdate: _handlePanUpdate,
            child: Container(
              color: Colors.transparent, 
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  if (testNode.isVisible)
                    Positioned(
                      left: testNode.x - (50 * testNode.scale), 
                      top: testNode.y - (50 * testNode.scale),
                      child: Transform.scale(
                        scale: testNode.scale,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: context.palette.crimson,
                            shape: BoxShape.circle,
                            border: Border.all(color: context.palette.trueWhite, width: 4),
                          ),
                          child:  Center(
                            child: Text(
                              "Node",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.palette.trueWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}