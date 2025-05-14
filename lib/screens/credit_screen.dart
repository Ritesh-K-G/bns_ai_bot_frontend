import 'package:flutter/material.dart';

class CreditScreen extends StatelessWidget {
  const CreditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Credits',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            CreditCard(
              name: 'Prof. Vrijendra Singh',
              role: 'Project Guide',
              description:
              'He proposed this project and gave invaluable guidance throughout the development process.',
              imagePath: 'assets/Prof_Vrij_Sir.png',
            ),
            SizedBox(height: 20),
            CreditCard(
              name: 'Ashok Yadav',
              role: 'Teaching Assistant',
              description:
              'He mentored the project and provided invaluable support to shape it into its final form.',
              imagePath: 'assets/Ashok_Sir.png',
            ),
          ],
        ),
      ),
    );
  }
}

class CreditCard extends StatelessWidget {
  final String name;
  final String role;
  final String description;
  final String imagePath;

  const CreditCard({
    super.key,
    required this.name,
    required this.role,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              imagePath,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(role,
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Text(description,
                    style: TextStyle(color: Colors.grey[300], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
