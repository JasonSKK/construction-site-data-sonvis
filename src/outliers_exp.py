# Svoronos Kanavas Iason -- initial data processing
#  --- load df and identify and replace outliers pm_25, pm_10 ---
# LiU Apr. 2022 -- construction site data SonVis

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
# import seaborn as sns
# import warnings
import random

filename = os.getcwd()+"/sommargagata_dev_11_temp_pm_30s.csv"
# Load the .csv file
df = pd.read_csv(filename,skiprows=[0])

# save first column
timestamp = df['timestamp']

# set figure size
fig = plt.figure(figsize=(7, 4))

# create data frame and set its columns
df = pd.DataFrame(df, columns=['temperature', 'humidity', 'pm_25', 'pm_10'])
pd.DataFrame.boxplot(df)

# show stats and calculate IQR from Q1 Q3 as a skewed distribution
stats = df.describe()
print(stats)

# store q1 and q3 for pm_25 & pm_10
pm25_q1 = stats['pm_25'][4] # store q1 val for pm_25
pm25_q3 = stats['pm_25'][6] # store q3 val for pm_25
pm10_q1 = stats['pm_10'][4] # store q1 val for pm_10
pm10_q3 = stats['pm_10'][6] # store q3 val for pm_10

# calculate IQRange for pm_25 from q1 and q3
iqr_pm25 = pm25_q3-pm25_q1
iqr_pm10 = pm10_q3-pm10_q1

# calculate thresholds from IQR -- acc. skewed distribution
# max_thresh: Q3+1.5IQR
# min_thresh: Q1-1.5IQR
max_thresh_pm_25 = pm25_q3+(1.5*iqr_pm25)
min_thresh_pm_25 = pm25_q1-(1.5*iqr_pm25)
max_thresh_pm_10 = pm10_q3+(1.5*iqr_pm10)
min_thresh_pm_10 = pm10_q1-(1.5*iqr_pm10)
thresholds = {'min thresh_pm_25': min_thresh_pm_25,
         'max thresh_pm_25': max_thresh_pm_25,
         'min thresh_pm_10': min_thresh_pm_10,
         'max thresh_pm_10': max_thresh_pm_10}
print(thresholds)


# boxplot -- for tests
# create the boxplot
#plt.boxplot(df)
# show it
#plt.show()

def replaceOutliers(col,minimum_thres,maximum_thres):
    for i in [col]: # replace outliers with nan value
        min = minimum_thres
        max = maximum_thres
        df.loc[df[i] < min, i] = np.nan  # if value is < min_thresh_pm25: nan it
        df.loc[df[i] > max, i] = np.nan  # if value is > max_thresh_pm25: nan it
        df.loc[df[i] == 0, i] = 0.1  # if zero: replace it with 0.1 (smallest val)

        print( # print how many null values are in the specified column
            'sum of null replaced values',
            df[col].isnull().sum())
        global des_col
        des_col = [col] # specify column

        # old to replace nan values with median
        # replace null values with median for the specified column
        #for i in des_col:
            # random factor for use in replacing values
            #rand_factor = random.uniform(minRand, maxRand)
            #df.loc[ # locate value and replace
                #df.loc[:,i].isnull(),i]=df.loc[:,i].median()#+rand_factor

# replace nan values with sample values from the same column for the full data-set
df = df.apply(
    lambda x: np.where(x.isnull(), x.dropna().sample(len(x), replace=True), x))

# replace outliers pm_25 -- max thresh: changed with observed box plot value
# max and min thresh from IQR was deleting too many values both pm_25 & pm_10
replaceOutliers('pm_25',min_thresh_pm_25,45)#max_thresh_pm_25)
# replace outliers pm_10
replaceOutliers('pm_10',min_thresh_pm_10,65)#max_thresh_pm_10)

# insert timestamp column
df.insert(0, "timestamp", timestamp, True)

# adds db column
exec(open("soundDataProcessing.py").read()) # load functional script SOUND
replaceOutliers('db',20,100) # exclude the min value which is 5.444976

trucks_df = pd.read_csv(  # read truck data file
    "./fake_passage_time.csv",
    delimiter=';', skiprows=[0])
# add column to main df with trucks, many are nil, will be replaced by next action
df['count'] = trucks_df['count']

df = df.apply( # replace NaN values from random samples same column
    lambda x: np.where(x.isnull(), x.dropna().sample(len(x), replace=True), x))

# write new df to file -- replaced outliers
df.to_csv('./df_out/particles_processed.csv', index = False)
processed_df = pd.read_csv('./df_out/particles_processed.csv')

# defined here but used in particleDataProcessing.py
global selected_dataframe
selected_dataframe = processed_df  #  initialisation with 30S

# data were processed
print('data processing done -- replaced outliers with median + random factor')
