from rest_framework import serializers
from profiles.models import Profile

class ProfileSerializer(serializers.ModelSerializer):
    """Serializer for the Profile model."""
    
    class Meta:
        model = Profile
        fields = ['id', 'name', 'age', 'gender', 'bio', 'location', 
                  'profile_picture', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']
