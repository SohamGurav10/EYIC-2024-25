import 'package:flutter/material.dart';

class ProfileSidebar extends StatelessWidget {
  const ProfileSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.6, // Sidebar width is 60% of screen width
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: Colors.teal.shade400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Profile Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Colors.teal),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Your Name",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Menu Items
                buildMenuItem(context, "Home", Icons.home, () {}),
                buildMenuItem(context, "Pill Details", Icons.medication, () {}),
                buildMenuItem(context, "Add Pill", Icons.add, () {}),
                buildMenuItem(context, "Profile", Icons.person, () {}),
                buildMenuItem(context, "Log Out", Icons.logout, () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build menu item
  Widget buildMenuItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
