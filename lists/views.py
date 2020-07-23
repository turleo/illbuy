from django.http import JsonResponse
from django.views.decorators.debug import sensitive_variables

from .models import Item, List


@sensitive_variables('out', 'list')
def lists_get(request):  # list of lists
    out = []  # output json
    lists = List.objects.filter(owner=request.user)
    for i in lists:
        out.append({"id": i.id, "name": i.name})
    return JsonResponse({"lists": out})


@sensitive_variables('name', 'list', 'user')
def list_new(request):  # create new list
    name = request.GET["name"]
    user = request.user
    list = List(name=name, owner=user)
    list.save()
    return JsonResponse({"id": list.id})


@sensitive_variables('list')
def list_delete(request):  # delete a list
    list = List.objects.get(pk=request.GET["id"])
    if request.user != list.owner:
        return JsonResponse({"error": 403}, status=403)
    list.delete()
    return JsonResponse({"ok": 1})


@sensitive_variables('list', 'out')
def item_get(request, id):  # list of items in list with pk=id
    out = []  # output json
    list = List.objects.get(pk=id)
    print(request.user != list.owner, list.public)
    if request.user != list.owner and not list.public:
        return JsonResponse({"error": 403}, status=403)
    for i in list.items.all():
        out.append({"id": i.id, "name": i.name, "marked": i.checked})
    return JsonResponse({"lists": out, "name": list.name, "public": list.public})


@sensitive_variables('list')
def list_change_property(request, id):  # list of items in list with pk=id
    list = List.objects.get(pk=id)
    if request.user != list.owner:
        return JsonResponse({"error": 403}, status=403)

    exec(f"list.{request.GET.get('prop')} = {request.GET.get('val')}")
    list.save()

    return JsonResponse({"ok": True})


@sensitive_variables('item')
def item_change(request, list, id):  # changing state of item
    list_ = List.objects.get(pk=list)
    item = Item.objects.get(pk=id)
    if request.user != item.owner and not list_.public:
        return JsonResponse({"error": 403}, status=403)
    item.checked = not item.checked
    item.save()
    return JsonResponse({"ok": 1})


@sensitive_variables('name', 'user', 'item', 'list')
def item_new(request, id):  # create new item
    name = request.GET["name"]
    list = List.objects.get(pk=id)
    item = Item(name=name, owner=list.owner)
    if request.user != list.owner and not list.public:
        return JsonResponse({"error": 403}, status=403)
    item.save()
    list.items.add(item)
    list.save()
    return JsonResponse({"id": list.id})


@sensitive_variables('item')
def item_delete(request, id):  # deletes an item
    item = Item.objects.get(pk=request.GET["id"])
    if request.user != item.owner:
        return JsonResponse({"error": 403}, status=403)
    item.delete()
    return JsonResponse({"ok": 1})
