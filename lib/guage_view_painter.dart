import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import './source_common.dart';

class GuageViewPainter extends CustomPainter{
  double percent;
  GuageViewPainter(this.percent);
  @override
  void paint(Canvas c, Size size) {
      var warning = Paint();
      warning.color = Colors.yellow;
      var danger = Paint();
      danger.color = Colors.red;
      var safe = Paint();
      safe.color = Colors.green;
      var bgColor = Paint();
      bgColor.color = Colors.white;
      var black = Paint();
      black.color = Colors.black;
      black.strokeWidth = 1.2;
      Offset os = Offset(size.width/2, size.height/5*3);
      Rect arcPosition = Rect.fromCircle(center: os, radius: 100);
      Rect arcInner = Rect.fromCircle(center: os, radius: 95);
      c.drawArc(arcPosition, 0.611, -4.363, true, safe);
      c.drawArc(arcPosition, 0.611, -1.634, true, warning);
      c.drawArc(arcPosition, 0.611, -0.726, true, danger);
      c.drawArc(arcInner, 0.611, -4.363, false, bgColor);
      c.drawCircle(os, 4, black);
      Offset base = getOnArc(-3.752, 0.036*percent, 80, os);
      c.drawLine(os, base, black);
      for(int i = 0; i < 13; i++) {
        Offset p1 = getOnArc(-3.752, 0.363*i, 95, os);
        Offset p2 = getOnArc(-3.752, 0.363*i, 90, os);
        c.drawLine(p1, p2, black);
      }
      final textPainter = TextPainter(text: TextSpan(text: '총 지출 미터\n'+nf.format(percent)+'%', style: TextStyle(color: Colors.black, fontSize: 18)), textDirection: TextDirection.ltr,textAlign: TextAlign.center);
      textPainter.layout(minWidth:0, maxWidth:size.width);
      textPainter.paint(c, Offset(size.width/2 - 40, size.height/5*3+30));
    }

    Offset getOnArc(double baseRad,double antiClockRad, double radius, Offset center) {
      return Offset(radius*cos(baseRad+antiClockRad)+center.dx,radius*sin(baseRad+antiClockRad)+center.dy);
    }
  
    @override
    bool shouldRepaint(CustomPainter old) {
      return true;
  }
  
}