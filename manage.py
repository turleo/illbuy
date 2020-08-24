import logging
import sys

from aiohttp import web

import backend.urls

logging.basicConfig(level=logging.NOTSET, format='%(asctime)s - %(name)s(%(levelname)s): %(message)s',
                    datefmt='%d-%b-%y %H:%M:%S')

if 'test' in sys.argv:
    print('Ok')

app = web.Application()
app.add_routes(backend.urls.urls)

if __name__ == '__main__':
    web.run_app(app)
