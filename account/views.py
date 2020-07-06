from django.shortcuts import render, redirect

from django.contrib.auth import login, logout, authenticate
from django.contrib.auth.models import User


def login_view(request):
    return render(request, 'login.html')


def login_handler(request):
    try:
        email = request.POST['email']
        password = request.POST['password']
        username = User.objects.get(email=email.lower()).username
        user = authenticate(username=username, password=password)
        login(request, user, backend="django.contrib.auth.backends.ModelBackend")
        return redirect("dashboard")
    except User.DoesNotExist:
        return redirect(".?incorrect=1")
