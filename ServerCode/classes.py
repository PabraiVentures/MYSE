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
		self.connection.set_debuglevel(0)
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
			
		pythonQuotes = []
		jsonQuote={}
		try:	   
			data = json.loads( result.read() )
			jsonQuotes = data['query']['results']['quote']

			#raise
			# To make sure the function returns a list
			if type( jsonQuotes ) == type ( dict() ):
				pythonQuotes.append( jsonQuotes )
			else:
				pythonQuotes = jsonQuotes
		except:
			i=2	
		return pythonQuotes

