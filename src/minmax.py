import sys
import pandas as pd
print(sys.argv[0]) # prints python_script.py
print(sys.argv[1]) # prints data file
print(sys.argv[2]) # prints column

filename = sys.argv[1]#os.getcwd()+"/sommargagata_dev_11_temp_pm_30s.csv"

# Load the .csv file
df = pd.read_csv(filename)
col = sys.argv[2]

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

# previous version non-script implemented
# def minmax(ds,col):
#     #temperature,humidity,pm_25,pm_10
#     #if  not isinstance(col, str):
#     #    col = str(col)
#     #else:
#     min = ds[col].min()
#     max = ds[col].max()
#     print('\n', 'min '+str(min),'\n','max '+str(max))
