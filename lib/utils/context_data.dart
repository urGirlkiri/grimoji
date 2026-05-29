import 'package:flutter/material.dart';
import 'package:grimoji/config/palette.dart';
import 'package:provider/provider.dart';

extension ContextData on BuildContext {
  ThemeData get theme => Theme.of(this); 
  Palette get palette =>  read<Palette>();
  
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isLargeScreen => screenWidth > 600;
  double get globalScale => isLargeScreen ? 1.5 : 1.0;
}