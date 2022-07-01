# Svoronos Kanavas Iason -- calculate min max script
# ---- runs in ./particleSonification.scd ----
# LiU Apr. 2022 -- construction site data SonVis

import sys
import pandas as pd
print(sys.argv[0]) # prints python_script.py
print(sys.argv[1]) # prints data file
print(sys.argv[2]) # prints column

# filename: load the processed df from ./df_out/ directory
filename = sys.argv[1]

# Load the .csv file
df = pd.read_csv(filename)
col = sys.argv[2] # column is the last argument (3rd)

def minmax():
    #temperature,humidity,pm_25,pm_10
    #if  not isinstance(col, str):
    #    col = str(col)
    #else:
    global min, max
    min = df[col].min()
    max = df[col].max()
    print(str(min),str(max))
    return([min,max])

minmax()
