# Svoronos Kanavas Iason -- initial data processing
#  --- load df and identify and replace outliers pm_25, pm_10 ---
# LiU Apr. 2022 -- construction site sonification

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
# import seaborn as sns
# import warnings
import random

filename = os.getcwd()+"/sommargagata_dev_11_temp_pm_30s.csv"
# Load the .csv file
df = pd.read_csv(filename)

# save first column
timestamp = df['timestamp']

#
# df.sample(5)
# warnings.filterwarnings('ignore')
# plt.figure(figsize=(16,5))
# plt.subplot(1,2,1)
# sns.distplot(df['temperature'])
# plt.subplot(1,2,2)
# sns.distplot(df['pm_25'])
# plt.show()
#
# print("Highest allowed",df['pm_25'].mean() + 3*df['pm_25'].std())

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


# create the boxplot
#plt.boxplot(df)

# show
#plt.show()

def replaceOutliers_Median(col,minimum_thres,maximum_thres):
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

#def median_windows(col,n): # n is the number that the window will contain
#    n = 200000  #chunk row size
#    list_df = [df[i:i+n] for i in range(0,df.shape[0],n)]
    #for i in [col]:
    #    tempdf =


# replace outliers pm_25 -- max thresh: changed with observed box plot value
# max and min thresh from IQR was deleting too many values both pm_25 & pm_10
replaceOutliers_Median('pm_25',min_thresh_pm_25,45)#max_thresh_pm_25)
# replace outliers pm_10
replaceOutliers_Median('pm_10',min_thresh_pm_10,65)#max_thresh_pm_10)

# insert timestamp column
df.insert(0, "timestamp", timestamp, True)

# write new df to file -- replaced outliers
df.to_csv('./df_out/particles_processed.csv', index = False)

# data were processed
print('data processing done -- replaced outliers with median + random factor')
