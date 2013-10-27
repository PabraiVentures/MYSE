#HELLO: to install: on command line do easy_install oauth, then easy_install urllib2.

import oauth.oauth as oauth
import httplib
import json
import sys
import urllib2
import time
class BaseClient:
	
	def __init__(self, baseURL, key, secret):
		self.url = baseURL
		self.connection = httplib.HTTPConnection(baseURL)
		self.consumer = oauth.OAuthConsumer(key, secret)
	def _execute(self,m, httpmethod, path, body):
		request = oauth.OAuthRequest.from_consumer_and_token(self.consumer, http_method=httpmethod, http_url="http://" + self.url + "/" + path)
		request.sign_request(oauth.OAuthSignatureMethod_HMAC_SHA1(), self.consumer, None)
		headers = request.to_header()
		headers["Accept"] = "application/vnd.stackmob+json; version=0"
		headers["X-StackMob-API-Key"]="ef598654-95fb-4ecd-8f13-9309f2fcad0f"
		if (m is 0) :
			headers["X-Stackmob-Expand"]="1"
		headers["Content-Type"] = "application/json"
		#headers["Version"]="0"
		self.connection.set_debuglevel(1)
		bodyString = ""
		if(body != None):
			bodyString = json.dumps(body)
		self.connection.request(request.http_method, "/"+path, body=bodyString, headers=headers)
		return self.connection.getresponse()

	def get(self, path):
		self._execute("GET", path, None)
	def post(self, path, body):
		self._execute("POST", path, body)
	def put(self, path, body):
		self._execute("PUT", path, body)
	def delete(self, path):
		self._execute("DELETE", path, None)

class APIClient(BaseClient):
	def __init__(self, key, secret):
		super.__init__("api.mob1.stackmob.com", key, secret)

class PushAPIClient(BaseClient):
	def __init__(self, key, secret):
		super.__init__("push.mob1.stackmob.com", key, secret)
		
class Pyql:

	def lookup(self,symbols):
		yql = "select * from yahoo.finance.quotes where symbol in (" \
						+ '\'' \
						+ '\',\''.join( symbols ) \
						+ '\'' \
						+ ")"
					
		url = "http://query.yahooapis.com/v1/public/yql?q=" \
				+ urllib2.quote( yql ) \
				+ "&format=json&env=http%3A%2F%2Fdatatables.org%2Falltables.env&callback="
	
		try: 
			result = urllib2.urlopen(url)
		except urllib2.HTTPError, e:        
			print ("HTTP error: ", e.code)        
		except urllib2.URLError, e:
			print ("Network error: ", e.reason)
	   
		data = json.loads( result.read() )
		jsonQuotes = data['query']['results']['quote']
	
		# To make sure the function returns a list
		pythonQuotes = []
		if type( jsonQuotes ) == type ( dict() ):
			pythonQuotes.append( jsonQuotes )
		else:
			pythonQuotes = jsonQuotes
	
		return pythonQuotes
try:

	client=BaseClient("api.mob1.stackmob.com","ef598654-95fb-4ecd-8f13-9309f2fcad0f", "9ac9ecaa-21eb-4ef2-8ddc-10ce40ca67e4")
	w=client._execute(0,"GET","coreportfolio",None)
	u= w.read()
	portfolios=json.loads(u)
	print "--------------"
	print portfolios
	print ""
	rankings={}#key=porfolioID, value= totalportfoliovalue
	histforport={}   
	for port in portfolios:
		#for each portfolio
        #calculate the current portfoliov value
		total=port['totalcashvalue']
		for stock in port['stocks']:
			total=total+ float(Pyql().lookup([stock['symbol']])[0]['LastTradePriceOnly']) *stock['amount']
		if ('portfoliohistory' not in port):
			port['portfoliohistory']="{}"
		hist=json.loads(port['portfoliohistory'])
		hist[time.strftime('%m-%d-%Y')]=total
		histjson=json.dumps(hist)
		
		
		body1={"value":total, "portfolio":port['coreportfolio_id'], "sm_owner":port['sm_owner']}
		string2="coreportfoliohistory"
		corehist= json.loads(client._execute(1,"POST",string2,body1).read())
		
		#build table of portf and portfhistory to link together later
		#body={"totalportfoliovalue":total , "portfoliohistory":histjson}
		body={"totalportfoliovalue":total}
		histforport[port['coreportfolio_id'] ]=corehist[u'coreportfoliohistory_id']
		print corehist[u'coreportfoliohistory_id']
	
		rankings[port['coreportfolio_id']]=total #add data into rankings
		
		string1="coreportfolio/"+port['coreportfolio_id']
		client._execute(1,"PUT",string1,body).read()
        #now the totalportfoliovalues have been updated

except :
	raise
sortedrankings=sorted(rankings)
print sortedrankings
rank=1

for i in sortedrankings:
	body={"ranking":rank}
	string1="coreportfolio/"+i
	client._execute(1,"PUT",string1,body).read()
	rankings[i]=rank
	rank=rank+1

w=client._execute(0,"GET","coreportfolio",None)
u= w.read()
portfolios=json.loads(u)
print "------rank--------"
print ""
for port in portfolios:
	body={"ranking":rankings[port['coreportfolio_id']]}
	string="coreportfoliohistory/"+histforport[port['coreportfolio_id']]
	client._execute(1,"PUT",string,body).read()

