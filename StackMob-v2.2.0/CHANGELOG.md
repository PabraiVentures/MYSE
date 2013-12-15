<h2>StackMob iOS SDK Change Log</h2>

<h3>v2.2.0 - October 9, 2013</h3>

**Features**

* 64-bit architecture support (arm64).
* Save policies. With the `SMSavePolicy` property in `SMCoreDataStore` you can direct save requests to the network only (results are not cached), to the cache only (objects are marked for the next time syncWithServer is called), or the default behavior which is to the network then cache (the current behavior you're used to). See the <a href="https://developer.stackmob.com/ios-sdk/offline-sync-guide#WritingtotheCache">Writing to the Cache</a> section of the Caching and Offline Sync Guide.
* Remove `primaryKeyField` exceptions. You might have seen the "No attribute which matches to primary key field" exceptions when you have an "All Exceptions" breakpoint set, and we've removed them so they don't interrupt your debugging sessions.

**Fixes**

* When fetching from the cache, object data is properly updated in-memory. This handled the issue of fetching from the cache and not seeing updated server values from the previous save operation.
* Proper query string encoding for Custom Code requests. Query string parameters with special characters were causing mismatches in OAuth signatures. 

**Update Notes**

* `SMCachePolicy` has been deprecated in favor of `SMFetchPolicy`. The new fetch policies, which work exactly like their cache policy counterparts, are: `SMFetchPolicyCacheOnly`, `SMFetchPolicyNetworkOnly`, `SMFetchPolicyNetworkElseCache`, `SMFetchPolicyCacheElseNetwork`. Notice the word "Try" has been removed from the ...CacheOnly and ...NetworkOnly policies.
* Other properties/methods such as `cachePolicy` in `SMRequestOptions` are also deprecated for their fetch policy equivalent. This usually means simply replacing the word `cache` with `fetch` to get the updated name.
* The `apiHost` property of `SMClient` has been deprecated. Use the `getHttpHost` and `getHttpsHost` methods of the `session` property.


<h3>v2.1.1 - August 22, 2013</h3>

**Features**

* Performance improvements when caching fetched objects from the network.

**Fixes**

* Fix where syncing was corrupting to-many relationship references.
* Server base last mod dates are properly translated to NSDate instances.
* Fix <code>optionsWithCachePolicy</code> method initialization.


<h3>v2.1.0 - July 30, 2013</h3>

**Features**

* Per request cache policy. Suppose you generally fetch from the cache, but occasionally you want to update your cache with the latest objects from the server. Rather then needing to change the cache policy before a specific request, and then change it back afterwards, you can pass in a option to define a cache policy just for the duration of one fetch request. See the <a href="https://developer.stackmob.com/ios-sdk/offline-sync-guide#PerRequestCachePolicy" target="_blank">Per Request Cache Policy</a> section of the Offline Sync Guide.
* Per request option to cache or not cache the results of fetch. See the <a href="https://developer.stackmob.com/ios-sdk/offline-sync-guide#OtherUtilityPropertiesMethods" target="_blank">Other Utility Properties/Methods</a> section of the Offline Sync Guide.
* Async/Sync methods for Core Data <code>countForFetchRequest:error:</code> method. See <a href="http://stackmob.github.io/stackmob-ios-sdk/Categories/NSManagedObjectContext+Concurrency.html" target="_blank">NSManagedObjectContext+Concurrency category</a>.
* New datastore <code>createObjects:...</code> method for bulk object creation. See <a href="https://developer.stackmob.com/ios-sdk/datastore-api-guide#CreatingObjectsinBulk" target="_blank">Creating Objects in Bulk</a>. (issue #22)
* New datastore methods for working with relationships and array field types: <code>createAndAppendRelatedObjects:...</code>, <code>appendExistingObjects:...</code>, and <code>deleteObjects:...</code>. See <a href="https://developer.stackmob.com/ios-sdk/datastore-api-guide#Relationships" target="_blank">Datastore Relationships API</a>.
* Support for upsert. With upsert you can create or update objects as well create or update nested related objects, all in one call. See <a href="https://developer.stackmob.com/ios-sdk/datastore-api-guide#UpsertwithNestedObjects" target="_blank">Upsert with Nested Objects</a>.
* Automatic host redirect for dedicated datastores. When your production apps use v2.1.0+ of the iOS SDK and you switch to one of the <a href="https://www.stackmob.com/product/pricing/" target="_blank">pro or enterprise solutions</a>, the SDK will automatically update the domain for all requests. This way your production apps can start talking to your dedicated datastore without the need to roll out an immediate update for your app.
* Xcode 5 and iOS 7 compatibility. Compiled and tested in sample app using Xcode 5 Developer Preview 4.

**Fixes**

* Sync success callback return all inserted/updated/deleted objects.
* Dates before 1970 are properly converted.
* Add parsing of compound predicates. (issue #46)
* Add empty array checks for IN/NIN.
* Fetch offset and limit translate properly to request header.
* Fix <code>primaryKeyField</code> method memory leak.
* Fields are properly sent in request when set to nil.
* Background created managed objects are not assigned primary keys.


<h3>v2.0.0 - June 6, 2013</h3>

**Features**

* Offline Sync - Save and read data when a device is offline. When network connection is restored, data will be synced with the server. Includes fully customizable conflict resolution behavior. Visit the <a href="https://developer.stackmob.com/ios-sdk/offline-sync-guide" target="blank">Offline Sync Guide</a> for all the details and available settings.
* Add SM_ALLOW_CACHE_RESET flag. Use during development when changing your Core Data model often to allow the local Core Data stack to reset itself.
* Updates to Custom Code methods to support custom response content types. 
* Support NOT IN queries and predicates. 
* Support Core Data attribute default values. **Check your attributes with number types** because they automatically default to 0 unless you deselect the `Default` checkbox. (issue #41)

**Fixes**

* Delete propagation fix for relationships with Cascade delete rule.
* Improvements to purge methods.

**Upgrade Notes**

This is a major upgrade. If you are currently using the cache functionality, you should either call the <code>SMCoreDataStore</code> <code><i>resetCache</i></code> method once or remove the application from the device, as v2.0.0+ includes a new and improved cache structure.

<h3>v2.0.0beta.1 - May 13, 2013</h3>

**Features**

* Offline Sync - Save and read data when a device is offline. When network connection is restored, data will be synced with the server. Includes fully customizable conflict resolution behavior. Visit the <a href="https://developer.stackmob.com/ios-sdk/offline-sync-guide" target="blank">Offline Sync Guide</a> for all the details and available settings.
* Add <code><i>initWithEntityName:insertIntoManagedObjectContext:</i></code> method to <code>SMUserManagedObject</code> class, which takes an entity name in string form versus an instance of <code>NSEntityDescription</code>
* Support "ordered" property on one-to-many relationships. (issue #39)
* CocoaPods file has been updated to include OSX support for 10.7+. Include <code>platform :osx, '10.7'</code> in your Podfile. Be sure to add `#import <SystemConfiguration/SystemConfiguration.h>` to your <code>.pch</code> file.

**Fixes**

* Boolean predicates fix.  Add boolean predicates to fetch requests in the form <code>[NSPredicate predicateWithFormat:@"field == %@", [NSNumber numberWithBool:YES]]</code>. (issue #31)
* Fix where predicates arguments containing instances of <code>NSManagedObject</code> or <code>NSManagedObjectID</code> were not properly translated for cache fetches. The cache currently only accepts Comparison Predicates of this form.  
* Forgot password API always sends "username" key. (issue #37)

**Upgrade Notes**

This is a major upgrade. If you are currently using the cache functionality, you should either call the <code>SMCoreDataStore</code> <code><i>resetCache</i></code> method once or remove the application from the device, as v2.0.0+ includes a new and improved cache structure.   

<h3>v1.4.0 - March 27, 2013</h3>

**Features**

* OR query support, allowing, for example, the ability to query "todo where A AND (B OR (C AND D) OR E)". See <a href="http://developer.stackmob.com/tutorials/ios/Advanced-Queries" target="_blank">Advanced Query Tutorial</a> for all details.
* Support for querying where field equals / does not equal the empty string. Using core data, use [NSPredicate predicateWithFormat:@"field == ''"]. Using lower level datastore API, use [query where:field isEqualTo:@""].
* New method loginWithFacebookToken:createUserIfNeeded:usernameForCreate:onSuccess:onFailure:. Allows login to StackMob using Facebook credentials and optionally create a StackMob user if one doesn't already exist that is linked to the credentials used.
* New method loginWithTwitterToken:twitterSecret:createUserIfNeeded:usernameForCreate:onSuccess:onFailure:. Allows login to StackMob using Twitter credentials and optionally create a StackMob user if one doesn't already exist that is linked to the credentials used.
* Token unlinking for Facebook and Twitter - See <a href="http://stackmob.github.com/stackmob-ios-sdk/Classes/SMClient.html" target="_blank">SMClient class reference</a> for method definitions.
* New SMClient / SMUserSession method setTokenRefreshFailureBlock:.  See <a href="http://stackmob.github.com/stackmob-ios-sdk/Classes/SMUserSession.html#//api/name/setTokenRefreshFailureBlock:" target="_blank">SMUserSession class reference</a> for method definition and examples.
* Every SMClient method now has an additional method definition which has parameter options for success and failure callback queues. This is used a lot internally so callbacks are not run on the main thread, but is exposed so you can do the same.
* Availability section to all methods in API reference.

**Update Notes**

* Updated AFNetworking dependency to 1.1.0 for Xcode 4.6 support.
* Deprecated SMClient method loginWithFacebookToken:options:onSuccess:onFailure:, use loginWithFacebookToken:createUserIfNeeded:usernameForCreate:options:onSuccess:onFailure:.
* Deprecated SMClient method loginWithTwitterToken:twitterSecret:options:onSuccess:onFailure:, use loginWithTwitterToken:twitterSecret:createUserIfNeeded:usernameForCreate:options:onSuccess:onFailure:.

<h3>v1.3.0 - February 14, 2013</h3>

**Features**

* Support for saving and querying geo points through the Core Data integration. Be sure to include the `CoreLocation` framework in your project.
* `SMGeoPoint` class for easily working with geo points through StackMob.
* `SMLocationManager` class for abstracting out `CLLocationManager` boiler plate code when working with geo data.
* Save and Fetch methods with `SMRequestOptions` parameter (options) to allow for custom options per Core Data request - See `NSManagedObjectContext+Concurrency.h` for method details.
* New `globalRequestOptions` property in `SMCoreDataStore` to set default request options used globally during StackMob calls from Core Data.
* Additional support for building source code with OSX targets (issue #34).
* Login support using Gigya credentials.

**Fixes**

* Fix in internal cache fetch method.
* Predicates with `NSDate` values works properly (issue #30).


<h3>v1.2.0 - January 24, 2013</h3>

All the details on the features of this release can be found in <a href="https://blog.stackmob.com/2013/01/ios-sdk-v1-2-0-released/">this blogpost</a>.

**Features**

* Caching system to allow for local fetching of objects which have previously been fetched from the server. See SMCoreDataStore class reference for how to.
* Introduce additional methods for interacting with Core Data. See new methods in SMCoreDataStore and NSManagedObjectContext+Concurrency class references.
* Update to internal network request algorithms for improved performance of Core Data saves and fetches.
* All NSDate attributes are saved on StackMob as integers in ms, rather than seconds. This allows there not be a mismatch in translation when you also have attributes for createddate and lastmoddate.
* Every Datastore API method (SMDataStore class reference) now has an additional method definition which has parameter options for success and failure callback queues. This is used a lot internally so callbacks are not run on the main thread, but is exposed so you can do the same.

**Fixes**
  
* Fix in updateTwitterStatusWithMessage:onSuccess:onFailure method.
* Fix in createUserWithFacebookToken:username:onSuccess:onFailure: to properly send request as a POST operation.
* Fix in encoding query string parameters when logged in to ensure proper request signature.

<h3>v1.1.3 - Nov 20, 2012</h3>

**Features**

* Integrate Push Notifications into core SDK. Separate Push SDK still exists for those using StackMob only for push notifications.
* Expose [SMNetworkReachability](http://stackmob.github.com/stackmob-ios-sdk/Classes/SMNetworkReachability.html) interface for developers to manually monitor network status changes.
* Requests will return SMError with code -105 (SMNetworkNotReachable) when device has no network connection.
* Now dependent on SystemConfiguration and MobileCoreServices frameworks, make sure to add them to the "Link Binary With Libraries" section of your target's Build Phases as well as import them somewhere in your project (such as your .pch file).

**Fixes**

* Support nil success and failure blocks.
* Update to Core Data fetch algorithm to populate internal storage with retrieved attribute values.
* URL encode primary key values on read/update/delete to support special characters.
* Add expand depth support for queries.

<h3>v1.1.2 - Oct 29, 2012</h3>

**Features**

* Updated SMQuery Geopoint method to take distance in kilometers instead of meters. New method is _where:isWithin:kilometersOf:_.
* Add _optionsWithExpandDepth:_ and _optionsWithReturnedFieldsRestrictedTo:_ methods to SMRequestOptions class. 
* Provide error message when creating an object with null values for fields. If you receive an error which states that a field was sent with a value of null and the type cannot be inferred, simply go online to the Manage Schemas section of your StackMob Dashboard and manually add the field with correct data type. This happens occasionally when working with number types in Core Data.

**Fixes**

* Allow setting of Core Data relationships to nil.
* Add proper SMRequestOptions headers dictionary initialization.   
* Change default merge policy of SMCoreDataStore _managedObjectContext_ property to NSMergeByPropertyObjectTrumpMergePolicy. This translates to "client wins" when there are conflicts for particular objects. Feel free to change the merge policy at any time by calling the _setMergePolicy:_ method on the managed object context of your SMCoreDataStore instance.

<h3>v1.1.1 - Oct 24, 2012</h3>

**Features**

* Full support for Core Data Boolean Data Types. A Core Data Boolean attribute will map to a Boolean field on StackMob.
* Removal of 'sm_' prefix for NSManagedObject category helper methods. Use [managedObject assignObjectId] and [managedObject primaryKeyField].
* Update SMClient user schema field property names. **userPrimaryKeyField** and **userPasswordField** describe the primary key and password field names for the user schema, respectively.

**Fixes**

* Update fetch request algorithm to support SMUserManagedObject change.
* Update Core Data object serialization algorithm. Serialized dictionary sent in request now includes only fields which have been updated since insert or the last call to save.
* Update SMRequestOptions for proper headers dictionary initialization.

<h3>v1.1.0 - Oct 17, 2012</h3>

**Features**

* Removal of SMModel Protocol.  
* Addition of SMUserManagedObject. Your managed object subclass corresponding to user objects should inherit from this class. SMUserManagedObject provides methods to securely set passwords for user objects without storing them in Core Data attributes. For all the information on how to update your current code [see this blogpost](http://blog.stackmob.com/?p=3547).
* Built for armv7 and armv7s architectures.

<h3>v1.0.1 - Oct 1, 2012</h3>

**Features**

* Can query whether fields are or are not nil. Thanks to combinatorial for the pull request.

**Fixes**

* Address error in serialization algorithm for one-to-one relationship camel cased attributes.
* Address error in request sent when reading from schemas with permissions set.

<h3>v1.0.0 - Sep 26, 2012</h3>

**Features**

* Support for iOS preferred camelCase Core Data property names.
* Support non case-sensitive schema names in datastore API.
* Support Core Data Date attribute type.
* API version and public key provided to SMClient during initialization must be correct format and non-nil.
* Core Data integration debug logging available by setting SM\_CORE\_DATA\_DEBUG = YES. See the Debugging section on the main page of the iOS SDK Reference for more info.

**Fixes**

* Edits to dictionary serialization algorithms for improved performance.
* NewValueForRelationship incremental store method correctly returns empty array for to-many with no objects.

<h3>v1.0.0beta.3 - Aug 24, 2012</h3>

**Fixes** 

* The method save: to the managed object context will return NO if StackMob calls fail.
* Fetch requests not returning errors.

<h3>v1.0.0beta.2 - Aug 20, 2012</h3>

**Features**

* Performing custom code methods is now available through the `SMCustomCodeRequest` class.
* Binary Data can be converted into an NSString using the `SMBinaryDataConversion` class and persisted to a StackMob field with Binary Data type.


<h3>v1.0.0beta.1 - Aug 10, 2012</h3>

**Features**

* Initial release of new and improved iOS SDK. Core Data integration serves as the biggest change to the way developers interact with the SDK. See [iOS SDK v1.0 beta](https://www.stackmob.com/devcenter/docs/iOS-SDK-v1.0-beta) for more information.
