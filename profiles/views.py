from rest_framework import viewsets, status, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from profiles.models import Profile
from profiles.serializers import ProfileSerializer
import os

class ProfileViewSet(viewsets.ModelViewSet):
    """
    API viewset for managing user profiles.
    """
    queryset = Profile.objects.all()
    serializer_class = ProfileSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    def get_permissions(self):
        """
        Override to allow creation without authentication.
        """
        if self.action == 'create':
            return [permissions.AllowAny()]
        return super().get_permissions()

@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def health_check(request):
    """
    Health check endpoint to verify the API is running.
    """
    return Response(
        {"status": "healthy", "message": "Profile Management Service is running"}, 
        status=status.HTTP_200_OK
    )

@api_view(['POST'])
@permission_classes([permissions.AllowAny])  # Be careful with this in production
def populate_profiles_api(request):
    """
    API endpoint to populate profiles - for development/testing only.
    """
    try:
        from django.core.management import call_command
        call_command('populate_profiles')
        return Response(
            {"status": "success", "message": "Profiles populated successfully"}, 
            status=status.HTTP_200_OK
        )
    except Exception as e:
        return Response(
            {"status": "error", "message": str(e)}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def database_info(request):
    """
    Check database configuration - for debugging.
    """
    from django.conf import settings
    db_config = settings.DATABASES['default']
    
    return Response({
        "database_engine": db_config.get('ENGINE', 'Not set'),
        "database_name": db_config.get('NAME', 'Not set'),
        "database_host": db_config.get('HOST', 'Not set'),
        "database_url_env": bool(os.environ.get("DATABASE_URL")),
        "database_url_value": os.environ.get("DATABASE_URL", "Not set")[:50] + "..." if os.environ.get("DATABASE_URL") else "Not set",
        "railway_env": bool(os.environ.get("RAILWAY_ENVIRONMENT")),
        "all_env_vars": list(os.environ.keys()),
    })
