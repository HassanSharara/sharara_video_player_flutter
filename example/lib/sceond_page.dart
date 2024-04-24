
import 'package:flutter/material.dart';


class TestBindingObserver extends StatefulWidget {
  const TestBindingObserver({super.key});
  @override
  State<TestBindingObserver> createState() => _TestBindingObserverState();
}
class _TestBindingObserverState extends
State<TestBindingObserver>  with WidgetsBindingObserver{

  @override
  void initState() {
    WidgetsBinding.instance
    .addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance
    .removeObserver(this);
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return const Scaffold(

    );
  }
}
