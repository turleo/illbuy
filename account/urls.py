from django.urls import path

from .views import *

urlpatterns = [
    path("login/", login_view),
    path("login/check", login_handler),
]
