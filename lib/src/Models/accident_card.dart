import 'package:flutter/material.dart';

class Accidentcard extends StatelessWidget {
  const Accidentcard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Card(
        elevation: 2,
        child: ListTile(
          title: const Text('USER123'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Accidents at location1'),
              const Text('date and time posted'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Severity:'),
                  const SizedBox(width: 5),
                  _buildSeverityBar(), // Custom function to build the severity bar
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBar() {
    // TODO: Calculate severity percentage elsewhere
    return Row(
      children: [
        Container(
          width: 20,
          height: 30,
          color: Colors.green,
        ),
        const SizedBox(width: 5),
        Container(
          width: 20,
          height: 50,
          color: Colors.yellow,
        ),
        const SizedBox(width: 5),
        Container(
          width: 20,
          height: 60,
          color: Colors.red,
        ),
      ],
    );
  }
}
