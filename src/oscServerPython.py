# Svoronos Kanavas Iason -- OSC Async Server
# LiU Apr. 2022 -- construction site sonification

from pythonosc.osc_server import AsyncIOOSCUDPServer
from pythonosc.dispatcher import Dispatcher
import asyncio

def filter_handler(address, *args):  # enables buttons on the interface
    start_button.disabled = False
    kill_button.disabled = False
    date_range_slider.disabled = False
    pm_10_button.disabled = False
    pm_25_button.disabled = False
    noise_button.disabled = False
    humid_button.disabled = False
    temperature_button.disabled = False
    trucks_button.disabled = False
    print(f"{address}:"+" sclang responded, interface enabled")

dispatcher = Dispatcher()
dispatcher.map("/startup/*", filter_handler)  # OSC listening address

# indicate port
port = 1234

# Async for parallel execution -- Exclusive Mode (https://bit.ly/38x1iA4)
server = AsyncIOOSCUDPServer((ip, port), dispatcher, asyncio.get_event_loop())
server.serve()
