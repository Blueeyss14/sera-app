import 'package:flutter/material.dart';

class PageeTest extends StatelessWidget {
  const PageeTest({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 0.5,
                color: const Color.fromRGBO(0, 0, 0, 0.2),
              ),
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: const Color.fromARGB(29, 0, 0, 0),

            //     offset: Offset(2, 1),
            //   ),
            // ],
          ),
          child: Row(
            children: [
              Icon(Icons.abc),
              const SizedBox(width: 10),
              Text("Sera"),
            ],
          ),
        ),
      ),
    );
  }
}
