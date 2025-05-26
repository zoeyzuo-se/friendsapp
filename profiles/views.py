from rest_framework import viewsets, status, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from profiles.models import Profile
from profiles.serializers import ProfileSerializer

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
