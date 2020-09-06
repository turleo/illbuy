import json
import uuid

from channels.generic.websocket import WebsocketConsumer
from django.contrib.auth import authenticate

from account.models import Token
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
                username, password = text_data.split(':')
                user = authenticate(username=username, password=password)
                if user is None:
                    self.send(text_data='403')
                else:
                    self.user = user
                    token = Token(user=self.user)
                    token.save()
                    self.send(text_data=json.dumps({'token': str(token.token)}))
                    out = []  # output json
                    lists = List.objects.filter(owner=self.user)
                    for i in lists:
                        out.append({"id": i.id, "name": i.name})
                    self.send(text_data=json.dumps(out))
            except ValueError:
                try:
                    token = uuid.UUID(text_data)
                    try:
                        token_model = Token.objects.get(token=token)
                        self.user = token_model.user
                        out = []  # output json
                        lists = List.objects.filter(owner=self.user)
                        for i in lists:
                            out.append({"id": i.id, "name": i.name})
                        self.send(text_data=json.dumps(out))
                    except Token.DoesNotExist:
                        self.send('403')

                except ValueError:
                    self.send(text_data='403')
