import numpy as np
import pandas as pd
from datetime import datetime
from bokeh.models import ColumnDataSource, DatetimeTickFormatter, HoverTool
from bokeh.models.widgets import DateRangeSlider
from bokeh.layouts import layout, column
from bokeh.models.callbacks import CustomJS
from bokeh.plotting import figure, output_file, show, save
import param  # for FormatDateRangeSlider
import datetime as dt
import panel as pn

datesX = pd.date_range(start='2021-08-01 00:00:00', end='2021-08-31 23:59:30', freq="30s")
valuesY = df#pd.DataFrame(np.random.randint(0,25,size=(100, 1)), columns=list('A'))

# keep track of the unchanged, y-axis values
source = ColumnDataSource(data={'x': datesX, 'y': valuesY['pm_10']})
source2 = ColumnDataSource(data={'x': datesX, 'y': valuesY['pm_10']})

# output to static HTML file
output_file('file.html')

hover = HoverTool(
    tooltips=[('Timestamp', '@x{%Y-%m-%d %H:%M:%S}'), ('Value', '@y')],
    formatters={'x': 'datetime'},)

#date_range_slider = DateRangeSlider(
#    title="Zeitrahmen", start=datesX[0], end=datesX[30],
#    value=(datesX[0], datesX[30]), step=1, width=300)
# create slider

########

date_range_slider = DateRangeSlider(
    name='Date Range Slider',
    width=666,
    start=dt.datetime(2021, 8, 1, 0, 0, 0), end=dt.datetime(2021, 8, 31, 0, 0, 0),
    value=(dt.datetime(2021, 8, 1, 0, 0, 0), dt.datetime(2021, 8, 1, 0, 0, 0)),
    format="%d/%m/%Y %H:%M:%S",
)

########


# create a new plot with a title and axis labels
p = figure(
    title='file1', x_axis_label='Date', y_axis_label='yValue',
    y_range=(0, 30), x_axis_type='datetime',
    tools="pan, wheel_zoom, box_zoom, reset",
    plot_width=1600, plot_height=520)

# add a line renderer with legend and line thickness

p.line(x='x', y='y', source=source, line_width=2)
p.add_tools(hover)

callback = CustomJS(args=dict(source=source, ref_source=source2), code="""

// print out array of date from, date to
console.log(cb_obj.value);

// dates returned from slider are not at round intervals and include time;
const date_from = Date.parse(new Date(cb_obj.value[0]).toDateString());
const date_to = Date.parse(new Date(cb_obj.value[1]).toDateString());
console.log(date_from, date_to)

// Creating the Data Sources
const data = source.data;
const ref = ref_source.data;

// Creating new Array and appending correctly parsed dates
let new_ref = []
ref["x"].forEach(elem => {
    elem = Date.parse(new Date(elem).toDateString());
    new_ref.push(elem);
    console.log(elem);
})

// Creating Indices with new Array
const from_pos = new_ref.indexOf(date_from);
const to_pos = new_ref.indexOf(date_to) + 1;


// re-create the source data from "reference"
data["y"] = ref["y"].slice(from_pos, to_pos);
data["x"] = ref["x"].slice(from_pos, to_pos);

source.change.emit();
    """)

date_range_slider.js_on_change('value', callback)
layout = column(p, date_range_slider)

# show the results
show(layout)
