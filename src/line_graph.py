from bokeh.plotting import figure
from bokeh.models import BoxAnnotation

# store processed df to variable
dfplot = df

# pandas to datetime
dfplot['timestamp'] = pd.to_datetime(dfplot['timestamp'])

# plot with a date-time x axis
plotpm10 = figure(title="PM10", width=700, height=250, x_axis_type="datetime")
plotpm25 = figure(title="PM25", width=700, height=250, x_axis_type="datetime")
plotnoise = figure(title="noise levels db", width=700, height=250, x_axis_type="datetime")
plothumid = figure(title="humidity %", width=700, height=250, x_axis_type="datetime")
plotcount = figure(title="truck count", width=700, height=250, x_axis_type="datetime")

# line graphs
plotpm10.line(dfplot['timestamp'], dfplot['pm_10'], color='navy', alpha=0.5)
plotpm25.line(dfplot['timestamp'], dfplot['pm_25'], color='navy', alpha=0.5)
plotnoise.line(dfplot['timestamp'], dfplot['db'], color='navy', alpha=0.5)
plothumid.line(dfplot['timestamp'], dfplot['humidity'], color='navy', alpha=0.5)
plotcount.line(dfplot['timestamp'], dfplot['count'], color='navy', alpha=0.5)
