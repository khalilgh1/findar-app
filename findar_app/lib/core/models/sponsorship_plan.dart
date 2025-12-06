class SponsorshipPlan {
  final String id;
  final String name;
  final int durationMonths;
  final int priceDZD;
  final int maxProperties;
  final List<String> features;

  SponsorshipPlan({
    required this.id,
    required this.name,
    required this.durationMonths,
    required this.priceDZD,
    required this.maxProperties,
    required this.features,
  });

  // Static list of available sponsorship plans
  static List<SponsorshipPlan> getPlans() {
    return [
      SponsorshipPlan(
        id: 'basic',
        name: 'Basic Sponsor',
        durationMonths: 1,
        priceDZD: 1000,
        maxProperties: 1,
        features: [
          'Featured placement for 1 month',
          'Priority in search results',
          'Basic analytics',
        ],
      ),
      SponsorshipPlan(
        id: 'premium',
        name: 'Premium Sponsor',
        durationMonths: 3,
        priceDZD: 2000,
        maxProperties: 3,
        features: [
          'Featured placement for 3 months',
          'Top priority in search results',
          'Advanced analytics',
          'Featured badge',
        ],
      ),
      SponsorshipPlan(
        id: 'agency',
        name: 'Agency Sponsor Plan',
        durationMonths: 6,
        priceDZD: 4000,
        maxProperties: 10,
        features: [
          'Featured placement for 6 months',
          'Highest priority in search',
          'Premium analytics dashboard',
          'Agency verification badge',
          'Dedicated support',
        ],
      ),
    ];
  }

  // Get plan by id
  static SponsorshipPlan? getPlanById(String id) {
    try {
      return getPlans().firstWhere((plan) => plan.id == id);
    } catch (e) {
      return null;
    }
  }
}
