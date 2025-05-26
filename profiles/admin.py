from django.contrib import admin
from profiles.models import Profile

@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('name', 'age', 'gender', 'location', 'created_at')
    list_filter = ('gender', 'age')
    search_fields = ('name', 'bio', 'location')
    readonly_fields = ('id', 'created_at', 'updated_at')
