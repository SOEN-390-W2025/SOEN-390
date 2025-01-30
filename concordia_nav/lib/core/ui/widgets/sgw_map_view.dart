import 'package:flutter/material.dart';
import 'package:concordia_nav/core/ui/widgets/custom_appbar.dart';

class SgwMapPage extends StatefulWidget {
  const SgwMapPage({super.key});

  @override
  State<SgwMapPage> createState() => SgwMapPageState();
}

class SgwMapPageState extends State<SgwMapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'SGW Map'),
      body: Center(
        child: Column(
          children: const [
            Text("data")
          ],
        ),
      )
    );
  }
}