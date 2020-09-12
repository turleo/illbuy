import json

from asgiref.sync import async_to_sync
from channels.generic.websocket import WebsocketConsumer

from lists.models import List


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
        else:
            pass  # TODO: add items to lists

    def send_lists(self):
        out = []  # output json
        lists = List.objects.filter(owner=self.scope['user'])
        for i in lists:
            out.append({"id": i.id, "name": i.name})
        self.send(text_data=json.dumps({"id": 0, "lists": out}))  # id 0 means that it's list of lists

    def list_update(self, event):
        self.send_lists()
