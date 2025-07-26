from django.urls import path, include
from rest_framework.routers import DefaultRouter
from profiles.views import ProfileViewSet, health_check, populate_profiles_api, database_info

router = DefaultRouter()
router.register(r'profiles', ProfileViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('health/', health_check, name='health-check'),
    path('admin/populate/', populate_profiles_api, name='populate-profiles'),
    path('admin/database/', database_info, name='database-info'),
]
