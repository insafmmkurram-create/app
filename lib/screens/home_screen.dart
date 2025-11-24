import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/registration_form_screen.dart';
import 'package:flutter_application_1/screens/check_status_screen.dart';
import 'package:flutter_application_1/screens/payments_screen.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/services/registration_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _uploadedImageUrl;
  bool _isLoadingImage = true;
  final RegistrationService _registrationService = RegistrationService();

  @override
  void initState() {
    super.initState();
    _loadUploadedImage();
  }

  Future<void> _loadUploadedImage() async {
    try {
      final registrationData = await _registrationService.getRegistrationData();
      if (mounted) {
        setState(() {
          _uploadedImageUrl = registrationData?['imageUrl'] as String?;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  Widget _buildModernActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    int delay = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 180,
        decoration: AppTheme.modernCardDecoration(
          borderRadius: 24,
          hasShadow: true,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.subheadingStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms, delay: delay.ms)
          .scale(delay: delay.ms, duration: 600.ms, curve: Curves.elasticOut)
          .shimmer(delay: (delay + 600).ms, duration: 1000.ms, color: Colors.white.withOpacity(0.3)),
    );
  }

  Widget _buildFooterIcon({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTheme.bodyStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ).copyWith(
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
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/bg.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.white),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.85),
                ],
              ),
            ),
          ),
          Column(
            children: [
              // Modern Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.white.withOpacity(0.8)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _isLoadingImage
                                  ? const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    )
                                  : _uploadedImageUrl != null
                                      ? Image.network(
                                          _uploadedImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            // Fallback to photoURL if uploaded image fails to load
                                            return user?.photoURL != null
                                                ? Image.network(user!.photoURL!, fit: BoxFit.cover)
                                                : Icon(Icons.person, color: AppTheme.primaryColor);
                                          },
                                        )
                                      : user?.photoURL != null
                                          ? Image.network(user!.photoURL!, fit: BoxFit.cover)
                                          : Icon(Icons.person, color: AppTheme.primaryColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome',
                                style: AppTheme.bodyStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              Text(
                                user?.email?.split('@')[0] ?? 'User',
                                style: AppTheme.subheadingStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 300),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, end: 0, duration: 600.ms),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: AppTheme.headingStyle(fontSize: 28, color: Colors.black87),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideX(begin: -0.2, end: 0, duration: 600.ms, delay: 200.ms),
                      
                      const SizedBox(height: 24),
                      
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _buildModernActionCard(
                            icon: Icons.app_registration,
                            title: 'Registration\nForm',
                            color: AppTheme.primaryColor,
                            onTap: () async {
                              await Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const RegistrationFormScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 300),
                                ),
                              );
                              // Refresh image when returning from registration form
                              _loadUploadedImage();
                            },
                            delay: 300,
                          ),
                          _buildModernActionCard(
                            icon: Icons.check_circle,
                            title: 'Check\nStatus',
                            color: AppTheme.accentColor,
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const CheckStatusScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 300),
                                ),
                              );
                            },
                            delay: 500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Modern Footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFooterIcon(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        isSelected: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      _buildFooterIcon(
                        icon: Icons.article_outlined,
                        label: 'News',
                        isSelected: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      _buildFooterIcon(
                        icon: Icons.payment_rounded,
                        label: 'Payments',
                        isSelected: _selectedIndex == 2,
                        onTap: () {
                          setState(() => _selectedIndex = 2);
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const PaymentsScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 700.ms)
                  .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 700.ms),
            ],
          ),
        ],
      ),
    );
  }
}
