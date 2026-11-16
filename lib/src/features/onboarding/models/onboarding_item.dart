class OnboardingItem {
  final String title;
  final String description;
  final String image;
  final bool hasFloatingHearts;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    this.hasFloatingHearts = false,
  });
}

