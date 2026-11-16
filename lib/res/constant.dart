class AppStrings {
  AppStrings._();

  static const String appName = 'Sera';
  static const String splashTagline = 'Your daily recovery companion';

  static const String onboardingTitle1 = 'Welcome to the Sera app!';
  static const String onboardingDesc1 =
      'A daily companion platform to help you plan your recovery and activities more safely.';

  static const String onboardingTitle2 = 'Plan and conquer your schedule';
  static const String onboardingDesc2 =
      'Sera helps you plan, prepare, and monitor adherence in one single app.';

  static const String onboardingTitle3 = 'Connect directly with doctors';
  static const String onboardingDesc3 =
      'Sera synchronizes your health data directly with the hospital in real-time.';

  static const String next = 'Next';
  static const String back = 'Back';
  static const String getStarted = 'Get Started';

  static const String authHeaderTitle = 'Start your healthy journey today.';
  static const String authHeaderSubtitle =
      'Sign in to access care plans tailored specifically for you by trusted doctors.';

  static const String signInTitle = 'Welcome back';
  static const String signInSubtitle = 'Sign in to continue your care plan';

  static const String signUpTitle = 'Create an account';
  static const String signUpSubtitle =
      'Register to organize and develop your healthy routine with us';

  static const String nameLabel = 'Full Name';
  static const String namePlaceholder = 'Enter your full name';

  static const String emailLabel = 'Email';
  static const String emailPlaceholder = 'Enter your email address';

  static const String passwordLabel = 'Password';
  static const String passwordPlaceholder = 'Enter your password';

  static const String termsAgreement =
      'I agree to all terms and conditions';
  static const String termsRequiredError =
      'You must agree to the terms and conditions to proceed';

  static const String signIn = 'Sign In';
  static const String signingIn = 'Signing In...';
  static const String signUp = 'Sign Up';
  static const String signingUp = 'Signing Up...';

  static const String orContinueWith = 'Or continue with';
  static const String noAccountPrompt = "Don't have an account? ";
  static const String haveAccountPrompt = 'Already have an account? ';
  static const String registerNow = 'Sign Up';
  static const String signInNow = 'Sign In';

  static const String nameRequired = 'Please enter your name';
  static const String emailRequired = 'Please enter your email';
  static const String emailInvalid = 'Please enter a valid email address';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordTooShort =
      'Password must be at least 6 characters';

  static const String loginSuccess = 'Signed in successfully';
  static const String registerSuccess = 'Account registered successfully';
  static const String networkError =
      'Unable to connect to the server. Please check your network connection.';
  static const String errorGeneral = 'Something went wrong. Please try again.';
  static const String successGeneral = 'Operation completed successfully.';

  static const String homePlaceholderTitle = 'Patient Home';
  static const String homePlaceholderSubtitle =
      'You have successfully logged in. Dashboard features will be available in the next step.';
}

class EndpointStrings {
  EndpointStrings._();

  static const String patientLogin = '/auth/patient/login';
  static const String patientRegister = '/auth/patient/register';
  static const String me = '/auth/me';
}
