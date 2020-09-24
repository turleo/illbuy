import json

from asgiref.sync import async_to_sync
from channels.generic.websocket import WebsocketConsumer

from lists.models import List, Item


class APIConsumer(WebsocketConsumer):
    def connect(self):
        self.list_id = 0
        self.room_group_name = f"u{self.scope['user'].id}"
        self.accept()
        if self.scope['user'].is_anonymous:
            self.send('403')
            self.disconnect(403)
        else:
            self.send_lists()
        async_to_sync(self.channel_layer.group_add)(
            self.room_group_name,
            self.channel_name
        )

    def disconnect(self, close_code):
        async_to_sync(self.channel_layer.group_discard)(
            self.room_group_name,
            self.channel_name
        )

    def receive(self, text_data):
        msg = json.loads(text_data)
        print(msg)
        if msg['type'] == 'new':
            if msg['id'] == 0:
                list = List(name=msg['name'], owner=self.scope['user'])
                list.save()
                self.send_lists()

            out = []  # output json
            lists = List.objects.filter(owner=self.scope['user'])
            for i in lists:
                out.append({"id": i.id, "name": i.name})
            async_to_sync(self.channel_layer.group_send)(
                self.room_group_name,
                {
                    'type': 'list_update'
                }
            )
        elif msg['type'] == 'change_list':
            self.list_id = msg['id']
            self.room_group_name = str(msg['id'])
            self.send_list()
        else:
            pass  # TODO: add items to lists

    def send_lists(self):
        out = []  # output json
        lists = List.objects.filter(owner=self.scope['user'])
        for i in lists:
            out.append({"id": i.id, "name": i.name})
        self.send(text_data=json.dumps({"id": 0, "lists": out}))  # id 0 means that it's list of lists

    def send_list(self, *args):
        out = []
        list = List.objects.get(pk=int(self.list_id))
        for i in list.items.all():
            out.append({'id': i.id, 'name': i.name, 'marked': i.checked})
        self.send(text_data=json.dumps(out))

    def list_update(self, event):
        self.send_lists()


class APIConsumerList(WebsocketConsumer):
    def connect(self):
        self.room_name = self.scope['url_route']['kwargs']['id']
        self.room_group_name = "lists"
        list = List.objects.get(pk=int(self.room_name))
        if not (list.public and list.owner == self.scope['user']):
            self.send('403')
            self.disconnect()

        async_to_sync(self.channel_layer.group_add)(
            self.room_group_name,
            self.channel_name
        )

        self.accept()
        self.send_list()

    def disconnect(self, close_code):
        # Leave room group
        async_to_sync(self.channel_layer.group_discard)(
            self.room_group_name,
            self.channel_name
        )

    def receive(self, text_data):
        msg = json.loads(text_data)
        if msg['type'] == 'new':
            name = msg['name']
            list = List.objects.get(pk=int(self.room_name))
            item = Item(name=name, owner=list.owner)
            item.save()
            list.items.add(item)
            list.save()
        elif msg['type'] == 'mark':
            item = Item.objects.get(pk=msg['id'])
            item.checked = not item.checked
            item.save()
        async_to_sync(self.channel_layer.group_send)(
            self.room_group_name,
            {
                'type': 'send_list'
            }
        )

    def send_list(self, *args):
        out = []
        list = List.objects.get(pk=int(self.room_name))
        for i in list.items.all():
            out.append({'id': i.id, 'name': i.name, 'marked': i.checked})
        self.send(text_data=json.dumps(out))
