# Svoronos Kanavas Iason -- data iteration functions patch
# LiU Apr. 2022 -- construction site sonification

import os
import numpy as np
import pandas as pd
import time
import datetime
from dateutil import parser
# Python osc
from pythonosc import udp_client
# run shell commands
import subprocess

break_cycle = False  # break cycle on kill button


# get IP address
def getip():
    global ip
    ip = subprocess.Popen(
        'ipconfig getifaddr en0', shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)
    ip, _ = ip.communicate()
    ip = ip.decode('utf-8')
    ip = ip.strip()
    print(ip)


# Python osc
getip() # run getip function
client = udp_client.SimpleUDPClient(ip, 57120)

exec(open("outliers_exp.py").read()) # load functional script


# func to print matrix with date data
def print_Matrix(matx):
    print('\n');
    print('\n'.join([''.join(['{:5}'.format(item) for item in row])
                     for row in matx]))


# locate row with GIVEN-X date and extract time period
def t_period(start_date,end_date,dataframe):
    global datetime_selection # for access within run function
    global start_closest, end_closest
    #if current_checkbox_ticks == [0]: # if 30S freq
    datetime_selection = dataframe[  # create new dataframe from given time period
        dataframe.timestamp.between(
            start_date,end_date,inclusive=True)] # include given dates


def updateBox(dt1):
    box.document.add_next_tick_callback(lambda: box.update(left=parser.parse(str(datetime_selection.iloc[0].timestamp)), right=dt1))


def run(start_date=None,end_date=None,period=None):
    if (start_date is None) and (end_date is None) and (period is None):
        print("ERROR: run() missing 3 required positional arguments: 'start_date', 'end_date', 'period' DT in the format of %Y-%m-%d %H:%M:%S i.e. '2021-08-21 00:00:00' ")
    else:
        t_period(start_date,end_date,selected_dataframe)

        for i in range(len(datetime_selection)): # iteration loop
            if break_cycle is True:
                break;
            else:
                global msg
                msg = datetime_selection.iloc[i]
                client.send_message("/pysc", msg)
                #  update BoxAnnotation
                dt1 = parser.parse(str(msg.timestamp))  # convert to date-time
                updateBox(dt1)
                dt_selection_pos = datetime_selection.iloc[i]  # get current date-time
                currentDT = str(  #  split current date time to time and date
                    dt_selection_pos[0]).split(" ")[1]+"   "+str(
                        dt_selection_pos[0]).split(" ")[0]  # display current time and date
                # update text input widget to current date time
                text.value = currentDT
                print(datetime_selection.iloc[i])  # print current position
            time.sleep(period)
        #  when iteration ends set => text input the initially inputted value
        temp_start_time = start_date.split(" ")[1]  # get start time
        temp_end_time = end_date.split(" ")[1]  # get end time
        #  set to text input widget
        text.value = temp_start_time+"-"+temp_end_time

print("on-run functions loaded")
