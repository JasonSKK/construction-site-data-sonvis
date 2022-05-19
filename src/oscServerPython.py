# Svoronos Kanavas Iason -- osc server
# LiU Apr. 2022 -- construction site sonification


from pythonosc.osc_server import AsyncIOOSCUDPServer
from pythonosc.dispatcher import Dispatcher
import asyncio


def filter_handler(address, *args):
    start_button.disabled = False
    kill_button.disabled = False
    date_range_slider.disabled = False
    pm_10_button.disabled = False
    pm_25_button.disabled = False
    temp_button.disabled = False
    print(f"{address}:"+" sclang responded, interface enabled")



dispatcher = Dispatcher()
dispatcher.map("/startup/*", filter_handler)

port = 1234

server = AsyncIOOSCUDPServer((ip, port), dispatcher, asyncio.get_event_loop())
server.serve()

# THIS IS A BLOCKING SERVER -- not used anymore
# ------------------------------------------------------------------------------
# from pythonosc.dispatcher import Dispatcher
# from pythonosc.osc_server import BlockingOSCUDPServer
#
#
# def print_handler(address, *args):
#     #for i in xrange(20, len(arr)):
#     #arr[i] = 0
#     start_button.disabled = True
#     kill_button.disabled = True
#     date_range_slider.disabled = True
#     pm_10_button.disabled = True
#     pm_25_button.disabled = True
#     temp_button.disabled = True
#     print(f"{address}: {args}")
#
#
# def default_handler(address, *args):
#     start_button.disabled = True
#     kill_button.disabled = True
#     date_range_slider.disabled = True
#     pm_10_button.disabled = True
#     pm_25_button.disabled = True
#     temp_button.disabled = True
#     print(f"DEFAULT {address}: {args}")
#
#
# dispatcher = Dispatcher()
# dispatcher.map("/startup/*", print_handler)
# dispatcher.set_default_handler(default_handler)
#
# port = 1234
#
# server = BlockingOSCUDPServer((ip, port), dispatcher)
# server.serve_forever()  # Blocks forever
