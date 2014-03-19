import datetime
import calendar
import time


def checkSEOpen():
	now = datetime.datetime.now()
# 	print "Current date and time using instance attributes:"
# 	print "Current year: %d" % now.year
# 	print "Current month: %d" % now.month
# 	print "Current day: %d" % now.day
# 	print "Current hour: %d" % now.hour
# 	print "Current minute: %d" % now.minute
# 	print "Current second: %d" % now.second
# 	print "Current microsecond: %d" % now.microsecond
# 	print "Current date and time using strftime:"
# 	print now.strftime("%Y-%m-%d %H:%M")
	
	year = now.year
	month = now.month
	day = now.day
	hour = now.hour
	minute = now.minute
	
	open = datetime.time(9,30)
	closed = datetime.time(16,00)
	current = datetime.time(hour, minute)
	today = calendar.weekday(year,month,day)
	#print today
	#print hour
	
	if today < 5:
		if current > open and current < closed:
			return True
#checkSEOpen()
