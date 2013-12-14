#HELLO: to install: on command line do easy_install oauth, then easy_install urllib2.

import oauth.oauth as oauth
import httplib
import json
import sys
import urllib2
import time
import classes as cl
from time import  sleep
def executeOrder(ticker,portfolio,price,amount,type,stockorder_id,client):
	print ticker+" "+portfolio+" "+str(price)+" "+str(amount)+" "+str(type)+" "+stockorder_id
	str1="coreportfolio/"+portfolio
	port= json.loads(client._execute(0,"GET",str1,None).read())
	foundstock=0
	if 'stocks' in port:
		for i in port['stocks']:
			if ticker == i['symbol']:
				print "match"
				foundstock=1
				if type<3:
					body={"amount":(amount+i['amount'])}
				if type>=3:
					body={"amount":(i['amount']-amount)}
				str2="corestock/"+i['corestock_id']
				client._execute(1,"PUT",str2,body).read()

				
	#NEED TO PUT STOCK IN ARRAY
	
	if foundstock is 0:
		print " didnt match stock"
	#now need to make trade event
	body={"actionid":type,"tradeamount":amount,"tradeprice":price,"ticker":ticker}
	str3="coretradeevent"
	client._execute(1,"PUT",str3,body).read()
	
	
	
	

		
	#break
	if foundstock==0:
		body={"amount":amount,"portfolio":port['coreportfolio_id'],"symbol":ticker,"sm_owner":port['sm_owner']}
		str2="corestock"
		client._execute(1,"POST",str2,body).read()
		
		
		sleep(.5)
		str1="corestock"
		body={"portfolio":portfolio ,"symbol":ticker }
		stock=json.loads(client._execute(0,"GET",str1,body).read())
		print port
		stockid=stock[0]['corestock_id']
		
		body=[stockid]
		str3="coreportfolio/"+portfolio+"/stocks"
		#print "BODY: " + body+ "STRING: " +str3 
		json.loads(client._execute(0,"PUT",str3,body).read())
		print "connected stock to portfolio"	
	#got stock id now need to put in portfolio's stocks
		
#

	if type<3:
		body={"totalcashvalue":port['totalcashvalue']-price*amount}
	else:
		body={"totalcashvalue":port['totalcashvalue']+price*amount}
	str2="coreportfolio/"+port['coreportfolio_id']
	client._execute(1,"PUT",str2,body).read()
	
	client._execute(1,"DELETE","stockorder/"+stockorder_id,None).read()
		 
if 2>0:
	try:
		sleep(.2)
		client=cl.BaseClient("api.mob1.stackmob.com","ef598654-95fb-4ecd-8f13-9309f2fcad0f", "9ac9ecaa-21eb-4ef2-8ddc-10ce40ca67e4")
		w=client._execute(1,"GET","stockorder",None)
		u= w.read()
		orders=json.loads(u)
		print "--------------"
		print orders
		print ""
		for i in orders:
			print i['symbol']
			if i['tradetype']==0 or i['tradetype']==3:
				executeOrder(i['symbol'],i['portfolio'],currprice,i['quantity'],i['tradetype'],i['stockorder_id'],client)
			else:
				currprice=float(cl.Pyql().lookup([i['symbol']])[0]['LastTradePriceOnly'])
				if (i['tradetype']==1 or i['tradetype']==5) and (currprice  <= i['price']):
					executeOrder(i['symbol'],i['portfolio'],currprice,i['quantity'],i['tradetype'],i['stockorder_id'],client)
			
				if (i['tradetype']==2 or i['tradetype']==4) and (currprice  >= i['price']):
					executeOrder(i['symbol'],i['portfolio'],currprice,i['quantity'],i['tradetype'],i['stockorder_id'],client)
			
	except:
		print "error", sys.exc_info()[0]
		raise
	
	#know that type is not market so need to check current price

