import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_form_screen.dart';
import 'check_status_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildFooterIcon({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.white),
          ),
          Container(color: Colors.black.withOpacity(0.25)),
          Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profile Icon on the left
                      const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Colors.blue),
                          ),
                        ],
                      ),
                    
                      // Logout button on the right
                      TextButton.icon(
                        icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                        label: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 160,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegistrationFormScreen(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.blue.shade50,
                              child: const Icon(Icons.app_registration, color: Colors.blue, size: 32),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Registration form',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      height: 160,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CheckStatusScreen(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.green.shade50,
                              child: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Check status',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Navigation Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFooterIcon(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isSelected: true,
                      onTap: () {
                        // Handle home tap
                      },
                    ),
                    _buildFooterIcon(
                      icon: Icons.article_outlined,
                      label: 'News',
                      isSelected: false,
                      onTap: () {
                        // Handle news tap
                      },
                    ),
                    _buildFooterIcon(
                      icon: Icons.payment_rounded,
                      label: 'Payments',
                      isSelected: false,
                      onTap: () {
                        // Handle payments tap
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          ],
        ),
        ],
      ),
    );
  }
}
