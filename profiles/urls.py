from django.urls import path, include
from rest_framework.routers import DefaultRouter
from profiles.views import ProfileViewSet, health_check

router = DefaultRouter()
router.register(r'profiles', ProfileViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('health/', health_check, name='health-check'),
]
