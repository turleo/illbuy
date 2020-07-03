from django.db import models
from django.contrib.auth.models import User

class Item(models.Model):
    name = models.CharField(max_length=100)
    checked = models.BooleanField(default=False)
    owner = models.ForeignKey(User, models.CASCADE)
    
    def __str__(self):
        return self.name


class List(models.Model):
    name = models.CharField(max_length=100)
    items = models.ManyToManyField(Item, blank=True)
    owner = models.ForeignKey(User, models.CASCADE)
