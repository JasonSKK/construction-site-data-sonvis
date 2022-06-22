# Svoronos Kanavas Iason -- plots initialisation and setup
# LiU Apr. 2022 -- construction site sonification

from bokeh.plotting import figure
from bokeh.models import BoxAnnotation
from bokeh.palettes import Spectral11

# store processed df to variable
dfplot = df
dfplot['timestamp'] = pd.to_datetime(dfplot['timestamp'])
dfplot = dfplot.resample('5Min', on='timestamp').max()  # re-sampled plot-ed df
#  for the sake of speed and efficiency

# pandas to datetime
dfplot['timestamp'] = pd.to_datetime(dfplot['timestamp'])

# plot with a date-time x axis
plotpm10 = figure(title="PM10:blue, PM25:green", width=700, height=250, x_axis_type="datetime")
#plotpm25 = figure(title="PM25", width=700, height=250, x_axis_type="datetime")
plotnoise = figure(title="noise levels db", width=700, height=250, x_axis_type="datetime",x_range=plotpm10.x_range)
plothumid = figure(title="humidity %", width=700, height=250, x_axis_type="datetime",x_range=plotpm10.x_range)
plotcount = figure(title="truck count", width=700, height=250, x_axis_type="datetime",x_range=plotpm10.x_range)

#numlines=len(dfplot)
#mypalette=Spectral11[0:numlines]

# line graphs
plotpm10.line(dfplot['timestamp'], dfplot['pm_10'], color='navy', alpha=0.9)
#plotpm25.multi_line(xs=[dfplot['pm_10']],
#                ys=[dfplot['pm_25']],
#                line_color=mypalette,
#                line_width=5)
plotpm10.line(dfplot['timestamp'], dfplot['pm_25'], color='seagreen', alpha=0.9)
plotnoise.line(dfplot['timestamp'], dfplot['db'], color='navy', alpha=0.5)
plothumid.line(dfplot['timestamp'], dfplot['humidity'], color='navy', alpha=0.5)
plotcount.line(dfplot['timestamp'], dfplot['count'], color='navy', alpha=0.5)
