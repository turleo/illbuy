from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User

from .models import Item, List


def lists_get(request):  # list of lists
    out = []  # output json
    lists = List.objects.filter(owner=request.user)
    for i in lists:
        out.append({"id": i.id, "name": i.name})
    return JsonResponse({"lists": out})


def list_new(request):  # create new list
    name = request.GET["name"]
    user = request.user
    list = List(name=name, owner=user)
    list.save()
    return JsonResponse({"id": list.id})


def list_delete(request):  # delete a list
    List.objects.get(pk=request.GET["id"]).delete()
    return JsonResponse({"ok": 1})


def item_get(request, id):  # list of items in list with pk=id
    out = []  # output json
    list = List.objects.get(pk=id)
    for i in list.items.all():
        out.append({"id": i.id, "name": i.name, "marked": i.checked})
    return JsonResponse({"lists": out, "name": list.name})


def item_change(request, id):  # changing state of item
    item = Item.objects.get(pk=id)
    item.checked = not item.checked
    item.save()
    return JsonResponse({"ok": 1})


def item_new(request, id):  # create new item
    name = request.GET["name"]
    user = request.user
    item = Item(name=name, owner=user)
    item.save()
    list = List.objects.get(pk=id)
    list.items.add(item)
    return JsonResponse({"id": list.id})


def item_delete(request, id):  # deletes an item
    Item.objects.get(pk=request.GET["id"]).delete()
    return JsonResponse({"ok": 1})
