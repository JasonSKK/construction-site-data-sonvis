# Svoronos Kanavas Iason -- Particle HTML interface patch
# LiU Apr. 2022 -- construction site sonification

from __future__ import print_function
from datetime import timedelta
from bokeh.models import CustomJS, DateRangeSlider
from ipywidgets.embed import embed_minimal_html
import datetime as dt
import panel as pn
import param  # for FormatDateRangeSlider
import subprocess  # to run SC
import sys  # stop evaluation: killall function
import threading  # stop iteration cycle when kill button pressed

exec(open("particlesDataProcessing.py").read()) # load functional script

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


# create slider
date_range_slider = FormatDateRangeSlider(
    name='Date Range Slider',
    width=666,
    start=dt.datetime(2021, 8, 1), end=dt.datetime(2021, 8, 31),
    value=(dt.datetime(2021, 8, 1), dt.datetime(2021, 8, 1)),
    format="%d/%m/%Y",
)

# dataset starts: 2021-08-01
# dataset ends: 2021-08-31 23:59:30


# create start button
start_button = pn.widgets.Button(name='Start', button_type='primary',width=200)
text = pn.widgets.TextInput(value='00:00:00-00:02:00',width=200)
kill_button = pn.widgets.Button(name='killall', button_type='primary',width=200)


# on start button event
def do(event):
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
    print(timedate_formating) # print everything as datetime formating
    # format: run(
        #'2021-08-21 00:00:00' ,  '2021-08-21 00:00:30', 0.9 ) # original command syntax
    #run( # run function defined in particlesDataProcessing with given datetime from slider
    #    timedate_formating[0], # start datetime
    #    timedate_formating[1], # end datetime
    #    0.02 # iteration frequency
    #)
    global break_cycle
    break_cycle = False
    threading.Thread(target=run, args=(
        timedate_formating[0], # start datetime
        timedate_formating[1], # end datetime
        0.02 # iteration frequency
    )).start()


def killall(event): # killall button fuction
    #command = sys.exit("Error message") # actually kill python sesh
    global break_cycle #added global
    break_cycle = True # Change break_cicle to False
    print ("Stopped")


start_button.on_click(do) # on click post selected data & evaluate rxun function
kill_button.on_click(killall)

# run sonification patch
sclang = subprocess.Popen(
    'sclang particleSonification.scd', shell=True,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT)

# run > python slider.py
#pn.serve(pn.Row(button, text, date_range_slider)) # render everything

# create grid
gspec = pn.GridSpec(sizing_mode='stretch_both', max_height=800)

gspec[0:3, 2] = pn.Column(
    start_button,
    kill_button,
    text,
    date_range_slider,
)

pn.serve(gspec)  # render created grid
#pn.serve()) # render everything
