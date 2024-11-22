import 'package:get/state_manager.dart';

class BottomNavController extends GetxController{
  var selectedIndex = 0.obs;
  var textValue = 0.obs;

  void changeIndex(int index){
    selectedIndex.value = index;
  }

  void increaseValue(){
    textValue.value++;
  }
}