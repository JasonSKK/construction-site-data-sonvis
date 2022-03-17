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




#timestamp_array = [date.year,date.month,date.day,date.hour,date.minute,date.second] # create array with data

#matrix = [timestamp_array, ['year |month |day |hour |min |sec']]
# func print matrix
def print_Matrix(matx):
    print('\n');
    print('\n'.join([''.join(['{:5}'.format(item) for item in row])
                     for row in matx]))

def iter(i): # iteration function -- value update | i=count_argument
    # --- DATA format --- df.iloc[row][column]
    # set date format, df.iloc[0][0] is the row and column num
    datepos = df.iloc[i][0] # position for date
    pm_25pos = df.iloc[i][3] # position for pm_25 particles
    pm_10pos = df.iloc[i][4] # position for pm_10 particles

    date = datetime.datetime.strptime( # configure data format => store
        datepos, "%Y-%m-%d %H:%M:%S")
    timestamp_array = [ # create array with time data
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
        date.second]
    matrix = [
        timestamp_array, # actual data in int and float
        ['year |month |day |hour |min |sec']] # setup matrix form
    print(str(pm_25pos)+' pm_25pos ') # print pm 25 values AS STRING
    print(str(pm_10pos)+' pm_10pos ') # print pm 10 values AS STRING
    print_Matrix(matrix) # print time data in matrix form

for i in range(70):
    #iter(str(i))
    #print(i)
    iter(i)


    #print_Matrix()
    time.sleep(0.05)

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
