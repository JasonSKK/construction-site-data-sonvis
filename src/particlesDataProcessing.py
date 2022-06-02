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

#filename = os.getcwd()+"/sommargagata_dev_11_temp_pm_30s.csv"
# Load the .csv file
#df = pd.read_csv(filename)


# func to print matrix with date data
def print_Matrix(matx):
    print('\n');
    print('\n'.join([''.join(['{:5}'.format(item) for item in row])
                     for row in matx]))


# locate row with GIVEN-X date and extract time period
def t_period(start_date,end_date,dataframe):
    global datetime_selection # for access within run function
    datetime_selection = dataframe[  # create new dataframe from given time period
        dataframe.timestamp.between(
            start_date,end_date,inclusive=True)] # include given dates

# consider using this??
# def iter(i): # iteration function -- value update | i=count_argument
#     # --- DATA format --- df.iloc[row][column]
#     # set date format, df.iloc[0][0] is the row and column num
#     datepos = datetime_selection.iloc[i][0] # position for date
#     pm_25pos = datetime_selection.iloc[i][3] # position for pm_25 particles
#     pm_10pos = datetime_selection.iloc[i][4] # position for pm_10 particles
#     date = datetime.datetime.strptime(datepos, "%Y-%m-%d %H:%M:%S") # configure data format => store
#     timestamp_array = [ # create array with time data
#         date.year,
#         date.month,
#         date.day,
#         date.hour,
#         date.minute,
#         date.second]
#     matrix = [
#         timestamp_array, # actual data in int and float
#         ['year |month |day |hour |min |sec']] # setup matrix form
#     print(str(pm_25pos)+' pm_25pos ') # print pm 25 values AS STRING
#     print(str(pm_10pos)+' pm_10pos ') # print pm 10 values AS STRING
#     print_Matrix(matrix) # print time data in matrix form

def run(start_date=None,end_date=None,period=None):
    if (start_date is None) and (end_date is None) and (period is None):
        print("ERROR: run() missing 3 required positional arguments: 'start_date', 'end_date', 'period' DT in the format of %Y-%m-%d %H:%M:%S i.e. '2021-08-21 00:00:00' ")
    else:
        t_period(start_date,end_date,selected_dataframe)
        for i in range(len(datetime_selection)): # iteration loop
            if break_cycle is True:
                break;
            else:
                client.send_message("/pysc", datetime_selection.iloc[i])
                dt_selection_pos = datetime_selection.iloc[i]  # get current date-time
                #  split current date time to time and date
                currentDT = dt_selection_pos[0].split(" ")[1]+"   "+dt_selection_pos[0].split(" ")[0]  # display current time and date
                #  update text input widget to current date time
                text.value = currentDT
                print(datetime_selection.iloc[i])
            # t_period('2021-08-21 00:00:00','2021-08-21 00:11:30')
            # t_period(d_start,d_end,i)
            # row = datetime_selection.iloc[i]
            # print(row)
            time.sleep(period)
        #  when iteration ends set => text input the initially inputted value
        temp_start_time = start_date.split(" ")[1]  # get start time
        temp_end_time = end_date.split(" ")[1]  # get end time
        #  set to text input widget
        text.value = temp_start_time+"-"+temp_end_time

# e.g.
# run( '2021-08-21 00:00:00' ,  '2021-08-21 00:00:30', 0.9 )


# fix this -- asks first question and then stops
#def ask():
#    st_date = parser.parse(
#        input(
#            "Enter start date | format %YYYY,%m,%d]: "))
#    print(st_date.year, st_date.month, st_date.day)
#
#    st_time = parser.parse(
#        input(
#            "Enter start time | format %HH:%MM:%SS]: "))
#    print(st_date.year, st_date.month, st_date.day, st_time.hour, st_time.minute, st_time.second)
#
#    end_date = parser.parse(
#        input(
#            "Enter end date | format %YYYY,%m,%d]: "))
#    print(end_date.year, end_date.month, end_date.day)
#
#    end_time = parser.parse(
#        input(
#            "Enter end time | format %HH:%MM:%SS]: "))
#    print(end_date.year, end_date.month, end_date.day, end_time.hour, end_time.minute, end_time.second)

print("on-run functions loaded")

#pyosc
#client = udp_client.SimpleUDPClient("10.253.233.184", 57120)
#IP Address might change sometimes - CAREFULL IF ERROR

#for i in range(len(df)):
#for i in range(70):
#client.send_message("/send", df[i])
#    a = df[i]#[df[i,0], df[i,1], df[i,2], df[i,3], df[i,4]]
#date
#time
#temp
#Significant height (Ht)
#Zero up-crossing wave period (Tz)
#Max height (Hmax)
#    print(str(a))
#    time.sleep(0.05)#float(df[i,3]) / 16) # Seconds

#print("end")
