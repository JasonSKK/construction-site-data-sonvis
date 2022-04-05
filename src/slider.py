from __future__ import print_function
from datetime import timedelta
from bokeh.models import CustomJS, DateRangeSlider
from ipywidgets.embed import embed_minimal_html
import datetime as dt
import panel as pn
import param # for FormatDateRangeSlider

exec(open("particlesDataProcessing.py").read()) # load functional script

pn.extension()


# slider
#date_range_slider = pn.widgets.DateRangeSlider(
#    name='Date Range Slider',
#    start=dt.datetime(2017, 1, 1, 0, 0), end=dt.datetime(2019, 1, 1, 0, 0),
#    value=(dt.datetime(2017, 1, 1, 0, 0), dt.datetime(2018, 1, 10, 0, 0)),
    #format="%Y%m%d"
#)


class FormatDateRangeSlider(pn.widgets.DateRangeSlider):
    format = param.String(r"%m%Y")

    def _process_property_change(self, msg):
        msg = super()._process_property_change(msg)
        if "value" in msg:
            v1, v2 = msg["value"]
            v1 = dt.datetime.strptime(v1.strftime(self.format), self.format)
            v2 = dt.datetime.strptime(v2.strftime(self.format), self.format)
            msg["value"] = (v1, v2)

        if "value_throttled" in msg:
            v1, v2 = msg["value_throttled"]
            v1 = dt.datetime.strptime(v1.strftime(self.format), self.format)
            v2 = dt.datetime.strptime(v2.strftime(self.format), self.format)
            msg["value_throttled"] = (v1, v2)

        return msg


# slider
date_range_slider = FormatDateRangeSlider(
    name='Date Range Slider',
    width=666,
    start=dt.datetime(2021, 8, 1), end=dt.datetime(2021, 8, 31),
    value=(dt.datetime(2021, 8, 1), dt.datetime(2021, 8, 1)),
    format="%d/%m/%Y",
)

# dataset starts: 2021-08-01
# dataset ends: 2021-08-31 23:59:30


# button
button = pn.widgets.Button(name='Start', button_type='primary')
text = pn.widgets.TextInput(value='00:00:00-00:02:00')


def do(event):
    startdt = date_range_slider.value[0].date()
    enddt = date_range_slider.value[1].date()
    time_split = text.value.split("-")
    sttime = time_split[0]
    endtime = time_split[1]
    print('\n',
          'Start Date '+str(startdt), # print start date
          '\n',
          'End Date '+str(enddt), # print end date
          '\n',
          'Start Time '+str(sttime), # print start time
          '\n',
          'End Time '+str(endtime), # print start time
          )
    timedate_formating = [
        str(startdt)+' '+str(sttime),
        str(enddt)+' '+str(endtime),
    ]
    print(timedate_formating)
    # format: run( '2021-08-21 00:00:00' ,  '2021-08-21 00:00:30', 0.9 )
    run( # run function defined in particlesDataProcessing
        timedate_formating[0],
        timedate_formating[1],
        0.02 # iteration frequency
    )


button.on_click(do) # on click post selected data & evaluate run function



# run > python slider.py
pn.serve(pn.Row(button, text, date_range_slider))
