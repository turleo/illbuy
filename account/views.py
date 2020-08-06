from django.contrib.auth import login, logout, authenticate
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.shortcuts import render, redirect
from django.views.decorators.csrf import ensure_csrf_cookie
from django.views.decorators.debug import sensitive_variables


@ensure_csrf_cookie
def login_view(request):
    return render(request, 'login.html')


@sensitive_variables('email', 'password', 'username')
def login_handler(request):
    try:
        email = request.POST['email']
        password = request.POST['password']
        user = User.objects.get(email=email.lower())
        if user.check_password(password):
            login(request, user, backend="django.contrib.auth.backends.ModelBackend")
        else:
            raise User.DoesNotExist
        return redirect("dashboard")
    except User.DoesNotExist:
        return redirect(".?incorrect=1&mail=" + request.POST['email'])


@ensure_csrf_cookie
def register_view(request):
    return render(request, 'register.html')


@sensitive_variables('email', 'password', 'username')
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


@login_required
def settings_view(request):
    return render(request, 'settings.html')


@login_required
@sensitive_variables('email', 'password', 'user')
def set_password(request):
    if request.POST.get('password', '') == request.POST.get('password1', '1')\
            and request.POST.get('password', '') != '':
        user = request.user
        user.set_password(request.POST.get('password'))
        user.save()
        return redirect('./')
    else:
        return redirect('./?wrong=password')
