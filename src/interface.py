# Svoronos Kanavas Iason -- interface patch & loader
# LiU Apr. 2022 -- construction site sonification

from __future__ import print_function
import datetime as dt
import panel as pn
import param  # for FormatDateRangeSlider
import subprocess  # to run SC
import threading  # stop iteration cycle when kill button pressed
from bokeh.models import Slider, CheckboxGroup, CustomJS, Label
from dateutil import parser  # convert str() to datetime
from bokeh.layouts import row, layout  # to update BoxAnnotation
#from pythonosc import udp_client

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
    end=1000,
    value=1000,
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
temperature_button = pn.widgets.Button(
    name='Temperature',
    button_type='default',
    width=150,
    disabled=True,
)
trucks_button = pn.widgets.Button(
    name='Truck count',
    button_type='primary',
    width=150,
    disabled=True,
)
instructions = pn.widgets.Button(
    name='Documentation',
    button_type='default',
    width=200,
    disabled=False)


global current_checkbox_ticks
current_checkbox_ticks = [0]

global flagResample
flagResample = False

# Your callback function
def resample_func(attr):
    # Go get the new selection
    new_ticks = resample_box.active
    if len(new_ticks) > 1:
        # If more than 2, set it to the previous selection
        global current_checkbox_ticks
        resample_box.active = current_checkbox_ticks
    else:
        # If up to 2 now, update the stored variable
        current_checkbox_ticks = resample_box.active
    print(current_checkbox_ticks)
    if len(current_checkbox_ticks) > 0:
        if max(current_checkbox_ticks) == 0:
            global flagResample
            flagResample = False
            resample(processed_df,'30S')
            client.send_message("/resample", '30S')
            #df.to_csv('./df_out/particles_processed.csv', index = False)
            #resample(df,'30S')
            print("resample 30S")
        if max(current_checkbox_ticks) == 1:
            flagResample = True
            client.send_message("/resample", 'T')
            resample(processed_df,'T')
            print("resample T")
        #if max(current_checkbox_ticks) == 2:  # this is out
            #flagResample = True
            #client.send_message("/resample", '30M')
            #resample(processed_df,'30M')
            #print("resample 30M")
        if max(current_checkbox_ticks) == 2:
            flagResample = True
            client.send_message("/resample", 'H')
            resample(processed_df,'H')
            print("resample H")
        if max(current_checkbox_ticks) == 3:
            flagResample = True
            client.send_message("/resample", 'D')
            resample(processed_df,'D')
            print("resample D")
        if max(current_checkbox_ticks) == 4:
            flagResample = True
            client.send_message("/resample", 'W')
            resample(processed_df,'W')
            print("resample W")
        # this is out because it is month  (data dur 1 month)
        #if max(current_checkbox_ticks) == 6:
            #flagResample = True
            #client.send_message("/resample", 'M')
            #resample(processed_df,'M')
            #print("resample Month")
    else:
        flagResample = False
        client.send_message("/resample", '30S')
        resample(processed_df,'30S')
        #df.to_csv('./df_out/particles_processed.csv', index = False)
        print("nothing selected, use non-resampled df (30s)")






LABELS = ["30s", "T", "H", "D", "W"]
resample_box = CheckboxGroup(labels=LABELS, active=[0],inline = True)
#resample_box.js_on_click(CustomJS(code="""
#   console.log('checkbox_group: active=' + this.active, this.toString())
#"""))
resample_box.on_click(resample_func)
#resample_box.on_click(checkbox_ticks())

# on start button event
def do(event):
    global timedate_formating
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







def temperature_synth(event): # temperature synth
    client.send_message("/synths", 'temperature_synth')  # send to SC
    print("temperature synth")
    dt1 = parser.parse(str(msg.timestamp))
    box.right = dt1
    box.left = dt1
    #plotpm10.add_layout(BoxAnnotation(left=dt1, right=dt1, fill_alpha=0.0, fill_color='red', line_color='red'))



def truck_synth(event): # truck synth
    client.send_message("/synths", 'truck_synth')  # send to SC
    print("truck synth")
    #layout.children.pop() # TEEEEEEEEEEST REMOVE LATER







#  Text, on interface instructions
def inst_open(event): # truck synth
    subprocess.Popen(
        'open ./HTML_documentation/instructions.html', shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)
    print("instructions opened")



start_button.on_click(do) # on click post selected data & evaluate run function
kill_button.on_click(killall)
pm_10_button.on_click(pm_10_synth)
pm_25_button.on_click(pm_25_synth)
noise_button.on_click(noise_synth)
humid_button.on_click(humid_synth)
temperature_button.on_click(temperature_synth)
trucks_button.on_click(truck_synth)
instructions.on_click(inst_open)


# re-sample
def resample(dataframe,freq):
    # concert to datetime
    dataframe['timestamp'] = pd.to_datetime(dataframe['timestamp'])
    # resample it and write the max values
    resampled_df = dataframe.resample(freq, on='timestamp').max()
    # write to disk
    resampled_df.to_csv('./df_out/particles_processed'+freq+'.csv', index = False)
    global selected_dataframe  # write re-sampled df to global var
    selected_dataframe = resampled_df
    selected_dataframe = pd.read_csv('./df_out/particles_processed'+freq+'.csv')


# run sonification patch
sclang = subprocess.Popen(
'sclang sonification.scd', shell=True,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT)

# --outdated version--
# run > python slider.py
#pn.serve(pn.Row(button, text, date_range_slider)) # render everything
# --------------------

exec(open("line_graph.py").read()) # prepare line plots

#datetime_object = datetime.isoformat('2021-08-01 00:01:30')
#datetime_object2 = datetime.isoformat('2021-08-08 00:01:30')

# Box Annotations
dt1 = parser.parse(str(df.iloc[0].timestamp))
box = BoxAnnotation(left=dt1, right=dt1, fill_alpha=0.0, fill_color='red', line_color='red')
plotpm10.add_layout(box)

#text.js_on_change()

# create grid
gspec = pn.GridSpec(sizing_mode='stretch_both', max_height=800)

gspec[0:3, 2] = pn.Row(pn.Column(  # render column
    instructions,
    start_button,
    kill_button,
    pn.Row(text),
    pn.Row(date_range_slider),
    resample_box,
    period_slider,
    pn.Row(pm_10_button,  # insert Row with synth items
           pm_25_button,
           noise_button),
    pn.Row(trucks_button,
           humid_button,
           temperature_button),
    pn.Row(plotpm10), # defined in line_graph.py
    pn.Column(plotpm25),
),
pn.Column(plotnoise,plothumid,plotcount))

exec(open("oscServerPython.py").read())  # OSC server setup

pn.serve(gspec)  #  render created grid
#pn.serve() # render everything | outdated old version
