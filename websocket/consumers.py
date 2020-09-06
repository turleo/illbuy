import json

from channels.generic.websocket import WebsocketConsumer

from lists.models import List


class APIConsumer(WebsocketConsumer):
    def connect(self):
        self.accept()
        if self.scope['user'].is_anonymous:
            self.send('403')
            self.disconnect(403)
        else:
            out = []  # output json
            lists = List.objects.filter(owner=self.scope['user'])
            for i in lists:
                out.append({"id": i.id, "name": i.name})
            self.send(text_data=json.dumps(out))

    def disconnect(self, close_code):
        pass

    def receive(self, text_data):
        pass
