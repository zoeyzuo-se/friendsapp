import requests
from django.core.management.base import BaseCommand
from django.core.files.base import ContentFile
from profiles.models import Profile


class Command(BaseCommand):
    help = 'Populate the database with fake profiles'

    def handle(self, *args, **options):
        # Sample profile data with diverse, realistic information
        profiles_data = [
            {
                'name': 'Alex Johnson',
                'age': 28,
                'gender': 'M',
                'bio': 'Software engineer who loves hiking and photography. Always up for trying new restaurants and exploring the city!',
                'location': 'San Francisco, CA',
                'image_url': 'https://picsum.photos/400/400?random=1'
            },
            {
                'name': 'Maya Chen',
                'age': 25,
                'gender': 'F',
                'bio': 'Yoga instructor and travel enthusiast. Love dancing, cooking, and spending time in nature. Looking for genuine connections!',
                'location': 'Los Angeles, CA',
                'image_url': 'https://picsum.photos/400/400?random=2'
            },
            {
                'name': 'Jordan Williams',
                'age': 32,
                'gender': 'M',
                'bio': 'Marketing professional and weekend warrior. Passionate about rock climbing, craft beer, and live music. Let\'s grab coffee!',
                'location': 'Austin, TX',
                'image_url': 'https://picsum.photos/400/400?random=3'
            },
            {
                'name': 'Sophia Rodriguez',
                'age': 29,
                'gender': 'F',
                'bio': 'Artist and dog lover! I paint, sketch, and love long walks in the park. Always down for art galleries and cozy bookstores.',
                'location': 'Brooklyn, NY',
                'image_url': 'https://picsum.photos/400/400?random=4'
            },
            {
                'name': 'Sam Taylor',
                'age': 26,
                'gender': 'O',
                'bio': 'Freelance writer and coffee connoisseur. Love indie films, poetry nights, and discovering hidden gems around the city.',
                'location': 'Portland, OR',
                'image_url': 'https://picsum.photos/400/400?random=5'
            },
            {
                'name': 'Emma Davis',
                'age': 27,
                'gender': 'F',
                'bio': 'Nurse and fitness enthusiast. Love morning runs, CrossFit, and trying new healthy recipes. Looking for someone who shares my active lifestyle!',
                'location': 'Denver, CO',
                'image_url': 'https://picsum.photos/400/400?random=6'
            },
            {
                'name': 'Marcus Thompson',
                'age': 31,
                'gender': 'M',
                'bio': 'Chef and foodie who loves experimenting with fusion cuisine. When I\'m not in the kitchen, I\'m exploring farmers markets or playing guitar.',
                'location': 'Chicago, IL',
                'image_url': 'https://picsum.photos/400/400?random=7'
            },
            {
                'name': 'Luna Park',
                'age': 24,
                'gender': 'F',
                'bio': 'Graphic designer and vintage fashion lover. Obsessed with thrift shopping, indie music, and weekend art markets. Let\'s create something beautiful together!',
                'location': 'Seattle, WA',
                'image_url': 'https://picsum.photos/400/400?random=8'
            },
            {
                'name': 'Oliver Martinez',
                'age': 30,
                'gender': 'M',
                'bio': 'Environmental scientist and outdoor adventure enthusiast. Love camping, kayaking, and wildlife photography. Seeking someone who cares about our planet!',
                'location': 'Boulder, CO',
                'image_url': 'https://picsum.photos/400/400?random=9'
            },
            {
                'name': 'Zoe Kim',
                'age': 28,
                'gender': 'F',
                'bio': 'Data scientist by day, salsa dancer by night! Love solving complex problems and hitting the dance floor. Always up for learning something new!',
                'location': 'Miami, FL',
                'image_url': 'https://picsum.photos/400/400?random=10'
            }
        ]

        # Create profiles (will add new ones even if profiles already exist)
        existing_count = Profile.objects.count()
        self.stdout.write(f'Found {existing_count} existing profiles. Adding new profiles...')

        created_count = 0
        for profile_data in profiles_data:
            # Check if profile with this name already exists
            if Profile.objects.filter(name=profile_data['name']).exists():
                self.stdout.write(
                    self.style.WARNING(f'Profile for {profile_data["name"]} already exists, skipping...')
                )
                continue
                
            try:
                # Download the image
                response = requests.get(profile_data['image_url'])
                response.raise_for_status()

                # Create the profile
                profile = Profile(
                    name=profile_data['name'],
                    age=profile_data['age'],
                    gender=profile_data['gender'],
                    bio=profile_data['bio'],
                    location=profile_data['location']
                )

                # Save the image
                image_name = f"{profile_data['name'].lower().replace(' ', '_')}.jpg"
                profile.profile_picture.save(
                    image_name,
                    ContentFile(response.content),
                    save=False
                )

                profile.save()
                created_count += 1

                self.stdout.write(
                    self.style.SUCCESS(f'Created profile for {profile_data["name"]}')
                )

            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(f'Failed to create profile for {profile_data["name"]}: {str(e)}')
                )

        self.stdout.write(
            self.style.SUCCESS(f'Successfully created {created_count} new profiles! Total profiles in database: {Profile.objects.count()}')
        )
