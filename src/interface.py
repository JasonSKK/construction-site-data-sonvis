# Svoronos Kanavas Iason -- interface patch & loader
# LiU Apr. 2022 -- construction site sonification

from __future__ import print_function
import datetime as dt
import panel as pn
import param  # for FormatDateRangeSlider
import subprocess  # to run SC
import threading  # stop iteration cycle when kill button pressed
#from pythonosc import udp_client
from bokeh.models import Slider


exec(open("particlesDataProcessing.py").read()) # load functional script PM

# Python osc
#getip() # run getip function
#client = udp_client.SimpleUDPClient(ip, 57120)

pn.extension()


class FormatDateRangeSlider(pn.widgets.DateRangeSlider):
    format = param.String(r"%m%Y")

    def _process_property_change(self, msg):
        msg = super()._process_property_change(msg)
        if "value" in msg:
            v1, v2 = msg["value"]
            v1 = dt.datetime.strptime(v1.strftime(self.format), self.format)
            v2 = dt.datetime.strptime(v2.strftime(self.format), self.format)
            msg["value"] = (v1, v2)

        if "value_throttled" in msg:
            v1, v2 = msg["value_throttled"]
            v1 = dt.datetime.strptime(v1.strftime(self.format), self.format)
            v2 = dt.datetime.strptime(v2.strftime(self.format), self.format)
            msg["value_throttled"] = (v1, v2)

        return msg


# create datetime slider
date_range_slider = FormatDateRangeSlider(
    name='Date Range Slider',
    width=666,
    start=dt.datetime(2021, 8, 1), end=dt.datetime(2021, 8, 31),
    value=(dt.datetime(2021, 8, 1), dt.datetime(2021, 8, 1)),
    format="%d/%m/%Y",
)

# create iteration period slider
period_slider = Slider(
    start=1,
    end=2000,
    value=10,
    step=1,
    width=666,
    title="Values/sec"
)
#  formula: 60 / Values Per Second = iteration cycle delay

# dataset starts: 2021-08-01
# dataset ends: 2021-08-31 23:59:30

# create start button
start_button = pn.widgets.Button(
    name='Start',
    button_type='warning',  # Orange-ish
    width=200,
    disabled=True)
text = pn.widgets.TextInput(value='00:00:00-00:02:00',width=200)
kill_button = pn.widgets.Button(
    name='KillAll',
    button_type='danger',  # red
    width=200,
    disabled=True)
pm_10_button = pn.widgets.Button(
    name='PM10',
    button_type='primary',  # blue
    width=150,
    disabled=True)
pm_25_button = pn.widgets.Button(
    name='PM25',
    button_type='primary',
    width=150,
    disabled=True)
noise_button = pn.widgets.Button(
    name='Noise Levels',
    button_type='primary',
    width=150,
    disabled=True)
humid_button = pn.widgets.Button(
    name='Humidity',
    button_type='primary',
    width=150,
    disabled=True,
)

# on start button event
def do(event):
    client.send_message("/startEnd", 1) # send to SC start playing synth:gate 1
    startdt = date_range_slider.value[0].date() # get start date from range slider
    enddt = date_range_slider.value[1].date() # get end date
    time_split = text.value.split("-") # split time into two objects (%H,%M)
    sttime = time_split[0] # get start time
    endtime = time_split[1] # get end time
    print('\n',
          'Start Date '+str(startdt), # print start date
          '\n',
          'End Date '+str(enddt), # print end date
          '\n',
          'Start Time '+str(sttime), # print start time
          '\n',
          'End Time '+str(endtime), # print start time
          )
    timedate_formating = [ # combine date and time into datetime formating
        str(startdt)+' '+str(sttime),
        str(enddt)+' '+str(endtime),
    ]
    print(timedate_formating)  # print everything as datetime formating
    # format: run(
        #'2021-08-21 00:00:00' ,  '2021-08-21 00:00:30', 0.9 ) # original command syntax
    #run( # run function defined in particlesDataProcessing with given datetime from slider
    #    timedate_formating[0],  # start datetime
    #    timedate_formating[1],  # end datetime
    #    0.02 # iteration frequency
    #)
    global break_cycle
    break_cycle = False
    threading.Thread(target=run, args=(
        timedate_formating[0],  # start datetime
        timedate_formating[1],  # end datetime
        # 0.07 # fixed iteration frequency
        1/period_slider.value
    )).start()
    #threading.Thread(target=update, args=(currentDT[0])).start()


def killall(event): # killall button fuction
    #command = sys.exit("Error message") # actually kill python sesh
    client.send_message("/startEnd", '0')  # send to SC stop synth: gate 0
    global break_cycle #added global
    break_cycle = True # Change break_cicle to False
    print("Everything Stopped")


def pm_10_synth(event): # pm 10 synth
    client.send_message("/synths", 'pm10_synth')  # send to SC
    print("PM 10 synth")


def pm_25_synth(event): # pm 25 synth
    client.send_message("/synths", 'pm25_synth')  # send to SC
    print("PM 25 synth")


def noise_synth(event): # noise synth
    client.send_message("/synths", 'noise_synth')  # send to SC
    print("noise synth")

def humid_synth(event): # humid synth
    client.send_message("/synths", 'humid_synth')  # send to SC
    print("humid synth")


start_button.on_click(do) # on click post selected data & evaluate rxun function
kill_button.on_click(killall)
pm_10_button.on_click(pm_10_synth)
pm_25_button.on_click(pm_25_synth)
noise_button.on_click(noise_synth)
humid_button.on_click(humid_synth)

# run sonification patch
sclang = subprocess.Popen(
    'sclang particleSonification.scd', shell=True,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT)

# --outdated version--
# run > python slider.py
#pn.serve(pn.Row(button, text, date_range_slider)) # render everything
# --------------------

# create grid
gspec = pn.GridSpec(sizing_mode='stretch_both', max_height=800)

gspec[0:3, 2] = pn.Column(  # render column
    start_button,
    kill_button,
    pn.Row(text),
    date_range_slider,
    period_slider,
    pn.Row(pm_10_button,  # insert Row with synth items
           pm_25_button,
           noise_button,
           humid_button)
)

exec(open("oscServerPython.py").read())  # OSC server setup

pn.serve(gspec)  #  render created grid
#pn.serve() # render everything | outdated old version
