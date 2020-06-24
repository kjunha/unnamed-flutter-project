import 'package:flutter/material.dart';
int currentIndex = 0;
BottomNavigationBar loadBottomNavigator(BuildContext context) {
  return BottomNavigationBar (
    type: BottomNavigationBarType.fixed,
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        title: SizedBox(height: 0,)
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.receipt),
        title: SizedBox(height: 0,)
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.credit_card),
        title: SizedBox(height: 0,)
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        title: SizedBox(height: 0,)
      ),
    ],
    currentIndex: currentIndex,
    onTap: (index) {
      currentIndex = index;
      if(index == 0) {
        Navigator.popUntil(context, (route) => route.isFirst);
        if(Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else if(index == 1) {
        Navigator.pushNamed(context, '/records');
      } else if(index == 2) {
        Navigator.pushNamed(context, '/methods');
      } else if(index == 3) {
        Navigator.pushNamed(context, '/sand');
      }
    },
  );
}