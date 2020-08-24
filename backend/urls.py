from aiohttp.web import route, static

from .views import *

urls = [static('/static/', 'frontend/static')]
