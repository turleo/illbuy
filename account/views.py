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
        return redirect(".?incorrect=1&mail=" + request.POST['email'])


def register_view(request):
    return render(request, 'register.html')


def register_handler(request):
    email = request.POST['email']
    username = email.replace('@', '')  # unique username for every user, generated from email
    password = request.POST['password']
    User.objects.create_user(username=username,
                             email=email,
                             password=password)
    user = authenticate(username=username, password=password)
    login(request, user, backend="django.contrib.auth.backends.ModelBackend")
    return redirect("dashboard")


def logout_view(request):
    logout(request)
    return redirect('login')
