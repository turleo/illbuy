from django.contrib import admin
from django.conf import settings

from .models import *

if settings.DEBUG:
    admin.site.register(Item)
    admin.site.register(List)
