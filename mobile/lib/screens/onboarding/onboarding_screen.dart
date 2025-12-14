import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/app_gradient_background.dart';
import '../../widgets/onboarding/onboarding_progress_bar.dart';
import '../../widgets/onboarding/continue_button.dart';
import '../main_navigation.dart';
import 'steps/language_step.dart';
import 'steps/age_step.dart';
import 'steps/mezhep_step.dart';
import 'steps/translation_step.dart';
import 'steps/goals_step.dart';
import 'steps/interests_step.dart';
import 'steps/widget_setup_step.dart';
import 'steps/journey_preview_step.dart';
import 'paywall_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // User selections
  String? _selectedLanguage;
  String? _selectedAge;
  String? _selectedMezhep;
  String? _selectedTranslation;
  final Set<String> _selectedGoals = {};
  String? _userInterests;

  static const int _totalSteps = 8;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showPaywall();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    // Save user preferences
    if (_selectedLanguage != null) await prefs.setString('user_language', _selectedLanguage!);
    if (_selectedAge != null) await prefs.setString('user_age', _selectedAge!);
    if (_selectedMezhep != null) await prefs.setString('user_mezhep', _selectedMezhep!);
    if (_selectedTranslation != null) await prefs.setString('user_translation', _selectedTranslation!);
    await prefs.setStringList('user_goals', _selectedGoals.toList());
    if (_userInterests != null) await prefs.setString('user_interests', _userInterests!);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  void _showPaywall() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(
          language: _selectedLanguage,
          onContinue: () {
            Navigator.of(context).pop();
            _completeOnboarding();
          },
          onSkip: () {
            Navigator.of(context).pop();
            _completeOnboarding();
          },
        ),
      ),
    );
  }

  bool get _canContinue {
    switch (_currentStep) {
      case 0:
        return _selectedLanguage != null;
      case 1:
        return _selectedAge != null;
      case 2:
        return _selectedMezhep != null;
      case 3:
        return _selectedTranslation != null;
      case 4:
        return _selectedGoals.isNotEmpty;
      case 5:
      case 6:
      case 7:
        return true; // Optional steps
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              
              // Progress bar
              OnboardingProgressBar(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
              ),
              
              const SizedBox(height: 24),
              
              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Step 1: Language
                    LanguageStep(
                      selectedLanguage: _selectedLanguage,
                      onLanguageSelected: (language) {
                        setState(() => _selectedLanguage = language);
                      },
                    ),
                    
                    // Step 2: Age
                    AgeStep(
                      selectedAge: _selectedAge,
                      onAgeSelected: (age) {
                        setState(() => _selectedAge = age);
                      },
                      language: _selectedLanguage,
                    ),
                    
                    // Step 3: Mezhep (Denomination)
                    MezhepStep(
                      selectedMezhep: _selectedMezhep,
                      onMezhepSelected: (mezhep) {
                        setState(() => _selectedMezhep = mezhep);
                      },
                      language: _selectedLanguage,
                    ),
                    
                    // Step 4: Translation
                    TranslationStep(
                      selectedTranslation: _selectedTranslation,
                      onTranslationSelected: (translation) {
                        setState(() => _selectedTranslation = translation);
                      },
                      language: _selectedLanguage,
                    ),
                    
                    // Step 5: Goals
                    GoalsStep(
                      selectedGoals: _selectedGoals,
                      onGoalToggled: (goal) {
                        setState(() {
                          if (_selectedGoals.contains(goal)) {
                            _selectedGoals.remove(goal);
                          } else {
                            _selectedGoals.add(goal);
                          }
                        });
                      },
                      language: _selectedLanguage,
                    ),
                    
                    // Step 6: Interests (text input)
                    InterestsStep(
                      interests: _userInterests,
                      onInterestsChanged: (interests) {
                        setState(() => _userInterests = interests);
                      },
                      language: _selectedLanguage,
                    ),
                    
                    // Step 7: Widget setup instructions
                    WidgetSetupStep(language: _selectedLanguage),
                    
                    // Step 8: Journey preview
                    JourneyPreviewStep(language: _selectedLanguage),
                  ],
                ),
              ),
              
              // Continue button
              Padding(
                padding: const EdgeInsets.all(24),
                child: ContinueButton(
                  onPressed: _canContinue ? _nextStep : null,
                  isEnabled: _canContinue,
                  text: _currentStep == _totalSteps - 1 
                      ? (_selectedLanguage == 'en' ? 'Start' : 'Başla') 
                      : (_selectedLanguage == 'en' ? 'Continue' : 'Devam'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
