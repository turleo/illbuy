from django.urls import path

from .views import *

urlpatterns = [
    path("", all_lists, name='dashboard'),
    path("<int:id>/", show_list),
]
