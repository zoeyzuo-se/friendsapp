from django.db import models
from django.utils.translation import gettext_lazy as _
import uuid

class Profile(models.Model):
    """User profile model for the Tinder-like app."""
    
    GENDER_CHOICES = [
        ('M', _('Male')),
        ('F', _('Female')),
        ('O', _('Other')),
        ('P', _('Prefer not to say')),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(_('Full Name'), max_length=100)
    age = models.PositiveIntegerField(_('Age'))
    gender = models.CharField(_('Gender'), max_length=1, choices=GENDER_CHOICES)
    bio = models.TextField(_('Biography'), max_length=500, blank=True)
    location = models.CharField(_('Location'), max_length=100, blank=True)
    profile_picture = models.ImageField(_('Profile Picture'), upload_to='profile_pictures/', blank=True, null=True)
    created_at = models.DateTimeField(_('Created At'), auto_now_add=True)
    updated_at = models.DateTimeField(_('Updated At'), auto_now=True)
    
    def __str__(self):
        return f"{self.name} ({self.age})"
    
    class Meta:
        verbose_name = _('Profile')
        verbose_name_plural = _('Profiles')
        ordering = ['-created_at']
