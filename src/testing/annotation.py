from bokeh.models import BoxAnnotation
from bokeh.plotting import figure, show
from bokeh.sampledata.glucose import data
from datetime import datetime



data = data.loc['2010-10-04':'2010-10-04']
#datetime_object = datetime.strptime('2010-10-04 00:03:00', '%Y %b %d %I:%M%p')
datetime_object = datetime.fromisoformat('2010-10-04 00:03:00')
datetime_object2 = datetime.fromisoformat('2010-10-04 00:23:00')

p = figure(title="Glocose Readings, Oct 4th\n(Red = Outside Range)",
           x_axis_type="datetime", tools="pan,wheel_zoom,box_zoom,reset,save")
p.background_fill_color = "#efefef"
p.xgrid.grid_line_color=None
p.xaxis.axis_label = 'Time'
p.yaxis.axis_label = 'Value'

#  https://stackoverflow.com/questions/38982276/how-to-refresh-bokeh-document
# p2 = BoxAnnotation(left=datetime_object, right=datetime_object, fill_alpha=0.0, fill_color='red', line_color='red')
# p3 = BoxAnnotation(left=datetime_object2, right=datetime_object, fill_alpha=0.0, fill_color='red', line_color='red')
# new_layout = row(p2, p3)
# layout.children = new_layout.children
#
#


p.line(data.index, data.glucose, line_color='grey')
p.scatter(data.index, data.glucose, color='grey', size=1)

p.add_layout(BoxAnnotation(left=datetime_object, right=datetime_object, fill_alpha=0.0, fill_color='red', line_color='red'))
#p.add_layout(BoxAnnotation(right=50, fill_alpha=0.1, fill_color='red', line_color='red'))




show(p)


#
# #from bokeh.io import vform
# from bokeh.models import CustomJS, Slider
# from bokeh.plotting import figure, show
# from bokeh.models import BoxAnnotation
# from bokeh.layouts import layout, widgetbox, column, row
#
#
# plot = figure(plot_width=300, plot_height=300)
# plot.line([0,1],[0,1], line_width=3, line_alpha=0.6)
#
# box_l = BoxAnnotation(top=0.4,
#                       fill_alpha=0.1, fill_color='red')
# box_m = BoxAnnotation(bottom = 0.4,top=0.6,
#                       fill_alpha=0.1, fill_color='green')
# box_h = BoxAnnotation(bottom=0.6,
#                       fill_alpha=0.1, fill_color='red')
# plot.renderers.extend([box_l, box_m, box_h])
#
# callb_low = CustomJS(args=dict(box_l=box_l,box_m=box_m,plot=plot),
#     code="""
#         var level = cb_obj.get('value')
#         box_l.set({"top":level})
#         box_m.set({"bottom":level})
#         plot.trigger('change');
#     """)
#
# callb_high = CustomJS(args=dict(box_m=box_m,box_h=box_h,plot=plot),
#     code="""
#         var level = cb_obj.get('value')
#         box_m.set({"top":level})
#         box_h.set({"bottom":level})
#         plot.trigger('change');
#     """)
#
# slider1 = Slider(start=0.1, end=1, value=0.4, step=.01, title="low")
#
# slider2 = Slider(start=0.1, end=1, value=0.6, step=.01, title="high")
#
# slider1.js_on_change('value', callb_low)
# slider2.js_on_change('value', callb_high)
#
# layout = column(slider1,slider2, plot)
# show(layout)
#
