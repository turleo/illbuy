from django.shortcuts import render
from django.contrib.auth.decorators import login_required


@login_required
def all_lists(request):
    return render(request, 'all.html')


def show_list(request, id):
    return render(request, 'list.html', {'id': id})

