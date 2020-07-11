from django.urls import path

from .views import *

urlpatterns = [
    path("login/", login_view),
    path("login/check", login_handler),
    path("register/", register_view),
    path("register/check", register_handler),
]
