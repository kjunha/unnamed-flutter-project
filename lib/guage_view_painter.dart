import 'package:flutter/material.dart';

class GuageViewPainter extends CustomPainter{
  @override
  void paint(Canvas c, Size size) {
      var paint = Paint();
      paint.color = Colors.black;
      Offset os = Offset(size.width/2, size.height/3*2);
      c.drawCircle(os, 50, paint);
    }
  
    @override
    bool shouldRepaint(CustomPainter old) {
      return false;
  }
  
}