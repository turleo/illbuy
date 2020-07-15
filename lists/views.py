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
    list = List.objects.get(pk=request.GET["id"])
    if request.user != list.owner:
        return JsonResponse({"error": 403}, status=403)
    list.delete()
    return JsonResponse({"ok": 1})


def item_get(request, id):  # list of items in list with pk=id
    out = []  # output json
    list = List.objects.get(pk=id)
    if request.user != list.owner:
        return JsonResponse({"error": 403}, status=403)
    for i in list.items.all():
        out.append({"id": i.id, "name": i.name, "marked": i.checked})
    return JsonResponse({"lists": out, "name": list.name})


def item_change(request, id):  # changing state of item
    item = Item.objects.get(pk=id)
    if request.user != item.owner:
        return JsonResponse({"error": 403}, status=403)
    item.checked = not item.checked
    item.save()
    return JsonResponse({"ok": 1})


def item_new(request, id):  # create new item
    name = request.GET["name"]
    user = request.user
    item = Item(name=name, owner=user)
    list = List.objects.get(pk=id)
    if request.user != list.owner:
        return JsonResponse({"error": 403}, status=403)
    item.save()
    list.items.add(item)
    list.save()
    return JsonResponse({"id": list.id})


def item_delete(request, id):  # deletes an item
    item = Item.objects.get(pk=request.GET["id"])
    if request.user != item.owner:
        return JsonResponse({"error": 403}, status=403)
    item.delete()
    return JsonResponse({"ok": 1})
