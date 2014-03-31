import checkopen as co
import classes as cl
client=cl.BaseClient("api.mob1.stackmob.com","4d770b35-0a4e-47f9-a85b-77c8d0f0e605", "07c826b0-ce40-4277-8ef1-d5574cdf7196")
if co.checkSEOpen():
	print "open"
	client._execute(1,"PUT","gamedata/1",{"marketopen":1}).read()

else:
	print "closed"
	client._execute(1,"PUT","gamedata/1",{"marketopen":0}).read()
