import 'package:flutter/material.dart';
import '../animations/splash_animation_controller.dart';

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
    
    // Start animations
    _animationController.startAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _animationController.mainController,
          _animationController.textController,
          _animationController.contentController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
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
                            
                            // Animated FinDAR text with slide
                            SlideTransition(
                              position: _animationController.textSlideAnimation,
                              child: _buildFinDARText(),
                            ),
                            
                            // Content that fades in
                            _buildContent(),
                            
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
                color: const Color(0xFF0066FF).withValues(alpha: 0.05),
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
                color: Colors.blue.withValues(alpha: 0.05),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinDARText() {
    const letters = ['F', 'i', 'n', 'D', 'A', 'R'];
    
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
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
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

  Widget _buildContent() {
    return Column(
      children: [
        // Welcome heading
        FadeTransition(
          opacity: _animationController.welcomeFadeAnimation,
          child: const Text(
            'Welcome',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Subtitle
        FadeTransition(
          opacity: _animationController.subtitleFadeAnimation,
          child: const Text(
            'Your property marketplace',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: Colors.blue,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
