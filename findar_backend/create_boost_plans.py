import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from api.models import BoostingPlan

print("--- Creating Boosting Plans ---")

# Create boost plans matching the Flutter app plans
plans_data = [
    {
        'id': 1,
        'plan_type': 'Basic',
        'target_audience': 'Individual',
        'credit_cost': 1000.0,
        'duration': 1,  # 1 month
    },
    {
        'id': 2,
        'plan_type': 'Premium',
        'target_audience': 'Individual',
        'credit_cost': 2000.0,
        'duration': 3,  # 3 months
    },
    {
        'id': 3,
        'plan_type': 'Agency',
        'target_audience': 'Business',
        'credit_cost': 4000.0,
        'duration': 6,  # 6 months
    },
]

for plan_data in plans_data:
    plan, created = BoostingPlan.objects.update_or_create(
        id=plan_data['id'],
        defaults={
            'plan_type': plan_data['plan_type'],
            'target_audience': plan_data['target_audience'],
            'credit_cost': plan_data['credit_cost'],
            'duration': plan_data['duration'],
        }
    )
    status = "Created" if created else "Updated"
    print(f'Plan {plan.id} ({plan.plan_type}): {status}')

print(f'\nTotal Boosting Plans: {BoostingPlan.objects.count()}')
