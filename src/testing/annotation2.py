# Working example

from bokeh.plotting import curdoc, figure, show
from bokeh.layouts import row
import panel as pn


p1 = figure(width=150, height=230, active_scroll="wheel_zoom")

layout = row(p1)



p2 = figure(width=150, height=500, active_scroll="wheel_zoom")
#layout.children[0] = p2

def do(event): # killall button fuction
    layout.children[0] = p2
    print("yo")


button = pn.widgets.Button(
    name='yo',
    button_type='primary',
    width=150,
    disabled=False)

button.on_click(do) # on click post selected data & evaluate run function


#show(layout)

pn.serve(pn.Column(layout, button)) # render everything | outdated old version
