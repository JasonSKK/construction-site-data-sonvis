#data iteration
import os
import numpy as np
import pandas as pd

#pyosc
#from pythonosc import osc_message_builder
#from pythonosc import udp_client
import time
import datetime

filename = os.getcwd()+"/sommargagata_dev_11_temp_pm_30s.csv"

# Load the .csv file
df = pd.read_csv(filename)

# --- DATA format --- df.iloc[row][column]
# set date format, df.iloc[0][0] is the row and column num
datepos = df.iloc[0][0] # position for date
pm_25pos = df.iloc[0][3] # position for pm_25 particles
pm_25pos = df.iloc[0][4] # position for pm_10 particles

date = datetime.datetime.strptime(datepos, "%Y-%m-%d %H:%M:%S") # configure data format => store

timestamp_array = [date.year,date.month,date.day,date.hour,date.minute,date.second]


matrix = [timestamp_array, ['year |month |day |hour |min |sec']]
print("\n")
print('\n'.join([''.join(['{:5}'.format(item) for item in row])
                 for row in matrix]))

#print(" ")
#print([timestamp_array])
#print(['year, month, day, hour, minute, second'])


#print(pm_25pos)


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
