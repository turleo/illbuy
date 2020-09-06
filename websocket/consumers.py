import json
from channels.generic.websocket import WebsocketConsumer
from django.contrib.auth import authenticate

from lists.models import List


class APIConsumer(WebsocketConsumer):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.user = None

    def connect(self):
        self.accept()

    def disconnect(self, close_code):
        pass

    def receive(self, text_data):
        if self.user is None:
            try:
                username, password = text_data.split(':')  # TODO: do not send plain password
                user = authenticate(username=username, password=password)
                if user is None:
                    self.send(text_data='403')
                else:
                    self.user = user
                    out = []  # output json
                    lists = List.objects.filter(owner=self.user)
                    for i in lists:
                        out.append({"id": i.id, "name": i.name})
                    self.send(text_data=json.dumps(out))
            except IndexError:
                self.send(text_data='403')
