import ipywidgets as widgets
import pandas as pd
from datetime import datetime

start_date = datetime(2018, 4, 24)
end_date = datetime(2018, 5, 24)

dates = pd.date_range(start_date, end_date, freq='D')

options = [(date.strftime(' %d %b %Y '), date) for date in dates]
index = (0, len(options)-1)

selection_range_slider = widgets.SelectionRangeSlider(
    options=options,
    index=index,
    description='Dates',
    orientation='horizontal',
    layout={'width': '500px'}
)

selection_range_slider
