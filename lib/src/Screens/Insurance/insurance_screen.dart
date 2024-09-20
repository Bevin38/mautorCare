import 'package:flutter/material.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceMainState();
}

class _InsuranceMainState extends State<InsuranceScreen> {
  bool touchAndPayEnabled = true;
  bool internationalTransactionsEnabled = true;
  bool onlineTransactionsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 189, 218),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(207, 47, 10, 116),
        title: const Text(
          "INSURANCE",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          children: [
            SizedBox(
              height: 120,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 10,
                child: const Align(
                  child: ListTile(
                    leading: Icon(Icons.shield_sharp, size: 50),
                    title: Text(
                      'Insurance Name',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    subtitle: Text(
                      'Person Name\nInsurance ID',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(
              color: Color.fromARGB(29, 0, 0, 0),
            ),
            ListTile(
              title: const Text('Change Insurance'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Action when tapped
              },
            ),
            const Divider(
              color: Color.fromARGB(29, 0, 0, 0),
            ),
            ListTile(
              title: const Text('Accidents Report'),
              subtitle: const Text("know where your case has reached"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Action when tapped
              },
            ),
            const Divider(
              color: Color.fromARGB(29, 0, 0, 0),
            ),
            const SizedBox(height: 20),
            // SwitchListTile(
            //   title: const Text('Touch & Pay'),
            //   subtitle: const Text('Use your card for contactless payments.'),
            //   value: touchAndPayEnabled,
            //   onChanged: (bool value) {
            //     setState(() {
            //       touchAndPayEnabled = value;
            //     });
            //   },
            // ),
            // SwitchListTile(
            //   title: const Text('International transactions'),
            //   subtitle: const Text('Use your card overseas.'),
            //   value: internationalTransactionsEnabled,
            //   onChanged: (bool value) {
            //     setState(() {
            //       internationalTransactionsEnabled = value;
            //     });
            //   },
            // ),
            // SwitchListTile(
            //   title: const Text('Online transaction'),
            //   subtitle: const Text(
            //       'Use your card for online transactions. Your user ID is 1267463.'),
            //   value: onlineTransactionsEnabled,
            //   onChanged: (bool value) {
            //     setState(() {
            //       onlineTransactionsEnabled = value;
            //     });
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
