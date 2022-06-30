from bokeh.models import CustomJS, Slider
from bokeh.plotting import figure, show
from bokeh.models import BoxAnnotation
from bokeh.layouts import layout, widgetbox, column, row
import panel as pn


plot = figure(plot_width=300, plot_height=300)
plot.line([0,1],[0,1], line_width=3, line_alpha=0.6)

box_l = BoxAnnotation(top=0.4,
                      fill_alpha=0.1, fill_color='red')
box_m = BoxAnnotation(bottom = 0.4,top=0.6,
                      fill_alpha=0.1, fill_color='green')
box_h = BoxAnnotation(bottom=0.6,
                      fill_alpha=0.1, fill_color='red')
plot.renderers.extend([box_l, box_m, box_h])

callb_low = CustomJS(args=dict(box_l=box_l,box_m=box_m,plot=plot),
    code="""
        var level = cb_obj.get('value')
        box_l.set({"top":level})
        box_m.set({"bottom":level})
        plot.trigger('change');
    """)

callb_high = CustomJS(args=dict(box_m=box_m,box_h=box_h,plot=plot),
    code="""
        var level = cb_obj.get('value')
        box_m.set({"top":level})
        box_h.set({"bottom":level})
        plot.trigger('change');
    """)

slider1 = Slider(start=0.1, end=1, value=0.4, step=.01, title="low")
slider2 = Slider(start=0.1, end=1, value=0.6, step=.01, title="high")

slider1.js_on_change('value', callb_low)
slider2.js_on_change('value', callb_high)

layout = column(slider1,slider2, plot)

pn.serve(layout)  #  render created grid

#show(layout)
