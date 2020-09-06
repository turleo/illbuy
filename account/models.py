import uuid

from django.contrib.auth.models import User
from django.db import models


class Token(models.Model):
    user = models.ForeignKey(User, models.CASCADE)
    token = models.UUIDField(primary_key=True, default=uuid.uuid4(), editable=False, unique=True)
