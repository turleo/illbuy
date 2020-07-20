from django.urls import path

from .views import *

urlpatterns = [
    path("list/", lists_get),
    path("list/new", list_new),
    path("list/del", list_delete),
    path("list/<int:id>/", item_get),
    path("list/<int:id>/new", item_new),
    path("list/<int:id>/del", item_delete),
    path("list/<int:list>/change/<int:id>", item_change),
]
