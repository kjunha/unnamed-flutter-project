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
        icon: Icon(Icons.swap_horiz),
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
      switch(index){
        case 0:
          Navigator.popUntil(context, (route) => route.isFirst);
          if(Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          break;
        case 1:
          Navigator.pushNamed(context, '/records');
          break;
        case 2:
          Navigator.pushNamed(context, '/transfer');
          break;
        case 3:
          Navigator.pushNamed(context, '/methods');
          break;
        case 4:
          //setting
          break;
        default :
          //404 page not found
          break;
      }
    },
  );
}