import 'package:flutter/material.dart';
import 'package:findar/features/landing/animations/splash_animation_controller.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/core/services/auth_manager.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late SplashAnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = SplashAnimationController();
    _animationController.initialize(this);
  
    _checkAuthAndStart();
  }

  Future<void> _checkAuthAndStart() async {
    final authmanger = AuthManager();
    final isLoggedIn = authmanger.isAuthenticated;

    if (!mounted) return;

    if (isLoggedIn) {
      // Small delay to avoid frame issues
      await Future.delayed(const Duration(milliseconds: 100));

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _animationController.startAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _animationController.mainController,
          _animationController.textController,
          _animationController.contentController,
        ]),
        builder: (context, child) {
          final backgroundColor = Theme.of(context).colorScheme.background;
          
          return Container(
            decoration: BoxDecoration(
              color: backgroundColor,
            ),
            child: Stack(
              children: [
                // Animated background circles
                _buildBackgroundCircles(),
                
                // Main content
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const Spacer(flex: 2),
                            
                            
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: _buildFinDARText(),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            
                            FadeTransition(
                              opacity: _animationController.subtitleFadeAnimation,
                              child: Image.asset(
                                'assets/Findar.png',
                                width: MediaQuery.of(context).size.width * 0.32,
                                height: MediaQuery.of(context).size.width * 0.32,
                                fit: BoxFit.contain,
                              ),
                            ),
                            
                            // Content that fades in
                            _buildContent(l10n),
                            
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundCircles() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Transform.rotate(
            angle: _animationController.circle1Animation.value * 2 * 3.14159,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: isDark ? 0.1 : 0.05),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Transform.rotate(
            angle: _animationController.circle2Animation.value * 2 * 3.14159,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: isDark ? 0.1 : 0.05),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinDARText() {
    const letters = ['F', 'i', 'n', 'D', 'A', 'R'];
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(letters.length, (index) {
            return AnimatedBuilder(
              animation: Listenable.merge([
                _animationController.letterScaleAnimations[index],
                _animationController.letterOpacityAnimations[index],
              ]),
              builder: (context, child) {
                return Opacity(
                  opacity: _animationController
                      .letterOpacityAnimations[index].value,
                  child: Transform.scale(
                    scale: _animationController
                        .letterScaleAnimations[index].value,
                    child: Text(
                      letters[index],
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 24),
        
        // Welcome heading
        FadeTransition(
          opacity: _animationController.welcomeFadeAnimation,
          child: Text(
            l10n.welcome,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Subtitle
        FadeTransition(
          opacity: _animationController.subtitleFadeAnimation,
          child: Text(
            l10n.yourPropertyMarketplace,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Glassmorphic badges
        FadeTransition(
          opacity: _animationController.badgesFadeAnimation,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGlassBadge('Buy'),
              const SizedBox(width: 12),
              _buildGlassBadge('Sell'),
              const SizedBox(width: 12),
              _buildGlassBadge('Rent'),
            ],
          ),
        ),
        
        const SizedBox(height: 150),
        
        // Get Started button
        FadeTransition(
          opacity: _animationController.buttonFadeAnimation,
          child: _buildGetStartedButton(),
        ),
      ],
    );
  }

  Widget _buildGlassBadge(String label) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.4 : 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor,
          width: 2,
        ),
      ),
      child: TextButton(
        onPressed: () {
          //since we don't go back to splash screen we use pushReplacement
          Navigator.pushReplacementNamed(context, '/login');
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Get Started',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ),
    );
  }
}
