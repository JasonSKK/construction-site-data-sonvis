from __future__ import print_function
from datetime import date

from bokeh.io import show
from bokeh.models import CustomJS, DateRangeSlider

from ipywidgets.embed import embed_minimal_html


import datetime as dt
import panel as pn


import param

pn.extension()


# slider
date_range_slider = pn.widgets.DateRangeSlider(
    name='Date Range Slider',
    start=dt.datetime(2017, 1, 1, 0, 0), end=dt.datetime(2019, 1, 1, 0, 0),
    value=(dt.datetime(2017, 1, 1, 0, 0), dt.datetime(2018, 1, 10, 0, 0)),
    #format="%Y%m%d"
)


class FormatDateRangeSlider(pn.widgets.DateRangeSlider):
    format = param.String(r"%m%Y")

    def _process_property_change(self, msg):
        msg = super()._process_property_change(msg)
        if "value" in msg:
            v1, v2 = msg["value"]
            v1 = datetime.strptime(v1.strftime(self.format), self.format)
            v2 = datetime.strptime(v2.strftime(self.format), self.format)
            msg["value"] = (v1, v2)

        if "value_throttled" in msg:
            v1, v2 = msg["value_throttled"]
            v1 = datetime.strptime(v1.strftime(self.format), self.format)
            v2 = datetime.strptime(v2.strftime(self.format), self.format)
            msg["value_throttled"] = (v1, v2)

        return msg

# slider
date_range_slider = FormatDateRangeSlider(
    name='Date Range Slider',
    start=dt.datetime(2017, 1, 1, 0, 0), end=dt.datetime(2019, 1, 1, 0, 0),
    value=(dt.datetime(2017, 1, 1, 0, 0), dt.datetime(2018, 1, 10, 0, 0)),
    format="%d/%m/%Y/%H/%M",
)

# button
button = pn.widgets.Button(name='Start', button_type='primary')
text = pn.widgets.TextInput(value='Ready')

def b(event):
    startdt = date_range_slider.value[0]
    enddt = date_range_slider.value[1]
    print(startdt, enddt)
    #print(date_range_slider.value)


button.on_click(b)



# run > python slider.py
pn.serve(pn.Row(button, date_range_slider))

# date_range_slider.param.watch(print, 'value')
