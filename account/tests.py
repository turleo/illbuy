from django.test import TestCase
from django.test import Client
from django.contrib import auth


class AccountTest(TestCase):
    def setUp(self):
        self.client = Client()

    def test_register(self):
        r = self.client.post("/accounts/register/check", {"email": "email@email.email", "password": "password"})
        user = auth.get_user(self.client)
        assert user.is_authenticated
        r = self.client.post("/accounts/logout")
        user = auth.get_user(self.client)
        assert not user.is_authenticated
    
    def test_login(self):
        self.test_register()
        r = self.client.post("/accounts/login/check", {"email": "email@email.email", "password": "password"})
        user = auth.get_user(self.client)
        assert user.is_authenticated
        r = self.client.post("/accounts/logout")
        user = auth.get_user(self.client)
        assert not user.is_authenticated

    def test_failed_login(self):
        r = self.client.post("/accounts/login/check", {"email": "fake@email.email", "password": "password"})
        user = auth.get_user(self.client)
        assert not user.is_authenticated
