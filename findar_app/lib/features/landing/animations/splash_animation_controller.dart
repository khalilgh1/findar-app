import 'package:flutter/material.dart';

class SplashAnimationController {
  late AnimationController mainController;
  late AnimationController textController;
  late AnimationController contentController;
  
  // Letter animations
  late List<Animation<double>> letterScaleAnimations;
  late List<Animation<double>> letterOpacityAnimations;
  
  // Sound wave animations
  late List<Animation<double>> soundWaveAnimations;
  
  // Text movement animation
  late Animation<Offset> textSlideAnimation;
  
  // Content fade animations
  late Animation<double> welcomeFadeAnimation;
  late Animation<double> subtitleFadeAnimation;
  late Animation<double> badgesFadeAnimation;
  late Animation<double> loadingDotsFadeAnimation;
  late Animation<double> buttonFadeAnimation;
  
  // Loading dots bounce animations
  late List<Animation<double>> dotBounceAnimations;
  
  // Background circle animations
  late Animation<double> circle1Animation;
  late Animation<double> circle2Animation;
  
  // Controllers list for proper disposal
  final List<AnimationController> _dotControllers = [];
  late AnimationController _circle1Controller;
  late AnimationController _circle2Controller;
  
  void initialize(TickerProvider vsync) {
    // Main controller for the entire sequence (5 seconds total)
    mainController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 5000),
    );
    
    // Text controller for letter animations (2 seconds)
    textController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Content controller for remaining content (2 seconds)
    contentController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 2000),
    );
    
    _initializeLetterAnimations();
    _initializeSoundWaveAnimations();
    _initializeTextMovementAnimation();
    _initializeContentAnimations();
    _initializeLoadingDotsAnimations(vsync);
    _initializeBackgroundAnimations(vsync);
  }
  
  void _initializeLetterAnimations() {
    const letters = 6; // "FinDAR"
    letterScaleAnimations = [];
    letterOpacityAnimations = [];
    
    for (int i = 0; i < letters; i++) {
      final startTime = i * 0.15; // 0.15s delay between each letter
      final endTime = startTime + 0.4; // 0.4s animation duration
      
      // Scale animation with bounce effect
      final scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 60,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.3, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 40,
        ),
      ]).animate(
        CurvedAnimation(
          parent: textController,
          curve: Interval(
            startTime,
            endTime.clamp(0.0, 1.0),
            curve: Curves.easeInOut,
          ),
        ),
      );
      
      // Opacity animation
      final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: textController,
          curve: Interval(
            startTime,
            (startTime + 0.2).clamp(0.0, 1.0),
            curve: Curves.easeIn,
          ),
        ),
      );
      
      letterScaleAnimations.add(scaleAnimation);
      letterOpacityAnimations.add(opacityAnimation);
    }
  }
  
  void _initializeSoundWaveAnimations() {
    soundWaveAnimations = [];
    const bars = 5;
    
    for (int i = 0; i < bars; i++) {
      final animation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.3, end: 1.0),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.3),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: textController,
          curve: Interval(
            0.3 + (i * 0.05),
            1.0,
            curve: Curves.easeInOut,
          ),
        ),
      );
      
      soundWaveAnimations.add(animation);
    }
  }
  
  void _initializeTextMovementAnimation() {
    textSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.8),
    ).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.4, 0.6, curve: Curves.easeInOut),
      ),
    );
  }
  
  void _initializeContentAnimations() {
    // Welcome text fades in
    welcomeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: contentController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    
    // Subtitle fades in
    subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: contentController,
        curve: const Interval(0.1, 0.4, curve: Curves.easeIn),
      ),
    );
    
    // Badges fade in
    badgesFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: contentController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
    
    // Loading dots fade in
    loadingDotsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: contentController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );
    
    // Button fades in
    buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: contentController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );
  }
  
  void _initializeLoadingDotsAnimations(TickerProvider vsync) {
    dotBounceAnimations = [];
    
    for (int i = 0; i < 3; i++) {
      final controller = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 1000),
      )..repeat(reverse: true);
      
      _dotControllers.add(controller);
      
      final animation = Tween<double>(begin: 0.0, end: -10.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            i * 0.2,
            0.6 + (i * 0.2),
            curve: Curves.easeInOut,
          ),
        ),
      );
      
      dotBounceAnimations.add(animation);
    }
  }
  
  void _initializeBackgroundAnimations(TickerProvider vsync) {
    _circle1Controller = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    _circle2Controller = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 5),
    )..repeat();
    
    circle1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _circle1Controller, curve: Curves.linear),
    );
    
    circle2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _circle2Controller, curve: Curves.linear),
    );
  }
  
  Future<void> startAnimation() async {
    // Start text animation first
    textController.forward();
    
    // Wait for text animation to complete
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Start the main controller (for text movement)
    mainController.forward();
    
    // Start content animation after text starts moving
    await Future.delayed(const Duration(milliseconds: 500));
    contentController.forward();
  }
  
  void dispose() {
    mainController.dispose();
    textController.dispose();
    contentController.dispose();
    
    // Dispose loading dot controllers
    for (var controller in _dotControllers) {
      controller.dispose();
    }
    
    // Dispose background circle controllers
    _circle1Controller.dispose();
    _circle2Controller.dispose();
  }
}
