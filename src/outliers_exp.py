# from:
# https://www.analyticsvidhya.com/blog/2021/05/feature-engineering-how-to-detect-and-remove-outliers-with-python-code/

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import warnings

filename = os.getcwd()+"/sommargagata_dev_11_temp_pm_30s.csv"
# Load the .csv file
df = pd.read_csv(filename)

df.sample(5)
warnings.filterwarnings('ignore')
plt.figure(figsize=(16,5))
plt.subplot(1,2,1)
sns.distplot(df['temperature'])
plt.subplot(1,2,2)
sns.distplot(df['pm_25'])
plt.show()


print("Highest allowed",df['pm_25'].mean() + 3*df['pm_25'].std())
