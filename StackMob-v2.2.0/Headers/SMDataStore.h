/*
 * Copyright 2012-2013 StackMob
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <CoreData/CoreData.h>
#import "SMClient.h"
#import "SMResponseBlocks.h"

#define POST @"POST"
#define GET @"GET"
#define PUT @"PUT"
#define DELETE @"DELETE"

@class SMUserSession;
@class SMRequestOptions;
@class SMCustomCodeRequest;
@class SMQuery;

/**
 `SMDataStore` exposes an interface for performing CRUD operations on known StackMob objects and for executing an <SMQuery> or <SMCustomCodeRequest>.
 
 As a direct interface to StackMob, `SMDataStore` uses StackMob's terminology:
 
 * Operations are performed against a specific _schema_ (usually also the name of a model class or of an entity in a managed object model).
 * Objects sent via the API are expressed as a dictionary of _fields_.
 * The schema name string provided to any of the methods in this class is NOT case-sensitive. It will be converted and stored on StackMob as a lowercase string but returned in success/failure blocks in the same form it was received.
 
 **Accessing the Datastore**
 
 Using your `SMClient` defaultClient:
 
    [[[SMClient defaultClient] dataStore] createObject...];
 
 Creating an instance of `SMDataStore`:
 
    // Assuming you have an initialized SMClient call client
    SMDataStore *dataStore = [[self client] dataStore];
    
    [dataStore createObject...];
 
 */
@interface SMDataStore : NSObject

///-------------------------------
/// @name Properties
///-------------------------------

/**
 The StackMob API Version being used.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
@property(nonatomic, readonly, copy) NSString *apiVersion;

/**
 The instance of `SMUserSession` attached to this datastore.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
@property(nonatomic, readwrite, strong) SMUserSession *session;


///-------------------------------
/// @name Initialize
///-------------------------------

/**
 Initialize a Datastore.
 
 @param apiVersion The API version of your StackMob application which this `SMDataStore` instance should use.
 @param session An instance of <SMUserSession> configured with the proper credentials.  This is used to properly authenticate requests.
 
 @return An instance of `SMDataStore` configured with the supplied apiVersion and session.
 @since Available in iOS SDK 1.0.0 and later.
 */
- (id)initWithAPIVersion:(NSString *)apiVersion session:(SMUserSession *)session;


#pragma mark - Create an Object
///-------------------------------
/// @name Create an Object
///-------------------------------


/** 
 Create a new object in your StackMob Datastore.
 
 @param object A dictionary describing the object to create on StackMob. Keys should map to valid StackMob fields. Values should be JSON serializable objects.
 @param schema The StackMob schema in which to create this new object.
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread after the object is successfully created. Passed the dictionary representation of the response from StackMob and the schema in which the new object was created.
 @param failureBlock <i>typedef void (^SMDataStoreFailureBlock)(NSError *error, NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread if the Datastore fails to create the specified object. Passed the error returned by StackMob, the dictionary sent with this create request, and the schema in which the object was to be created.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)createObject:(NSDictionary *)object
            inSchema:(NSString *)schema
           onSuccess:(SMDataStoreSuccessBlock)successBlock
           onFailure:(SMDataStoreFailureBlock)failureBlock;

/** 
 Create a new object in your StackMob Datastore.
 
 @param object A dictionary describing the object to create on StackMob. Keys should map to valid StackMob fields. Values should be JSON serializable objects.
 @param schema The StackMob schema in which to create this new object.
 @param options An options object contains headers and other configuration for this request
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread after the object is successfully created. Passed the dictionary representation of the response from StackMob and the schema in which the new object was created.
 @param failureBlock <i>typedef void (^SMDataStoreFailureBlock)(NSError *error, NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread if the Datastore fails to create the specified object. Passed the error returned by StackMob, the dictionary sent with this create request, and the schema in which the object was to be created.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)createObject:(NSDictionary *)object
            inSchema:(NSString *)schema
         options:(SMRequestOptions *)options
           onSuccess:(SMDataStoreSuccessBlock)successBlock
           onFailure:(SMDataStoreFailureBlock)failureBlock;

/**
 Create a new object in your StackMob Datastore.
 
 @param object A dictionary describing the object to create on StackMob. Keys should map to valid StackMob fields. Values should be JSON serializable objects.
 @param schema The StackMob schema in which to create this new object.
 @param options An options object contains headers and other configuration for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully created. Passed the dictionary representation of the response from StackMob and the schema in which the new object was created.
 @param failureBlock <i>typedef void (^SMDataStoreFailureBlock)(NSError *error, NSDictionary* object, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to create the specified object. Passed the error returned by StackMob, the dictionary sent with this create request, and the schema in which the object was to be created.
 
 @since Available in iOS SDK 1.2.0 and later.
 */
- (void)createObject:(NSDictionary *)object
            inSchema:(NSString *)schema
             options:(SMRequestOptions *)options
successCallbackQueue:(dispatch_queue_t)successCallbackQueue
failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue
           onSuccess:(SMDataStoreSuccessBlock)successBlock
           onFailure:(SMDataStoreFailureBlock)failureBlock;

#pragma mark - Create Objects
///-------------------------------
/// @name Create Objects
///-------------------------------

/**
 Creates a set of new objects in your StackMob Datastore.
 
 Can only be used to create top level object i.e. you can not send nested dictionary objects.
 
 @param objects The objects to create as dictionary instances.
 @param schema The StackMob schema in which to create the new objects.
 @param successBlock <i>typedef void (^SMDataStoreBulkSuccessBlock)(NSArray* succeeded, NSArray *failed, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the succeeded and failed object IDs in two separate arrays.
 @param failureBlock <i>typedef void (^SMDataStoreBulkFailureBlock)(NSError *error, NSArray *objects, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to update the specified object. Passed the error returned by StackMob, the objects to be created, and the schema.
 */
- (void)createObjects:(NSArray *)objects
            inSchema:(NSString *)schema
           onSuccess:(SMDataStoreBulkSuccessBlock)successBlock
           onFailure:(SMDataStoreBulkFailureBlock)failureBlock;

/**
 Creates a set of new objects in your StackMob Datastore.
 
 Can only be used to create top level object i.e. you can not send nested dictionary objects.
 
 @param objects The objects to create as dictionary instances.
 @param schema The StackMob schema in which to create the new objects.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock <i>typedef void (^SMDataStoreBulkSuccessBlock)(NSArray* succeeded, NSArray *failed, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the succeeded and failed object IDs in two separate arrays.
 @param failureBlock <i>typedef void (^SMDataStoreBulkFailureBlock)(NSError *error, NSArray *objects, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to update the specified object. Passed the error returned by StackMob, the objects to be created, and the schema.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
- (void)createObjects:(NSArray *)objects
             inSchema:(NSString *)schema
              options:(SMRequestOptions *)options
            onSuccess:(SMDataStoreBulkSuccessBlock)successBlock
            onFailure:(SMDataStoreBulkFailureBlock)failureBlock;

/**
 Creates a set of new objects in your StackMob Datastore.
 
 Can only be used to create top level object i.e. you can not send nested dictionary objects.
 
 @param objects The objects to create as dictionary instances.
 @param schema The StackMob schema in which to create the new objects.
 @param options An options object contains headers and other configuration for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMDataStoreBulkSuccessBlock)(NSArray* succeeded, NSArray *failed, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the succeeded and failed object IDs in two separate arrays.
 @param failureBlock <i>typedef void (^SMDataStoreBulkFailureBlock)(NSError *error, NSArray *objects, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to update the specified object. Passed the error returned by StackMob, the objects to be created, and the schema.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
- (void)createObjects:(NSArray *)objects
             inSchema:(NSString *)schema
              options:(SMRequestOptions *)options
 successCallbackQueue:(dispatch_queue_t)successCallbackQueue
 failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue
            onSuccess:(SMDataStoreBulkSuccessBlock)successBlock
            onFailure:(SMDataStoreBulkFailureBlock)failureBlock;


#pragma mark - Read an Object
///-------------------------------
/// @name Read an Object
///-------------------------------

/** 
 Read an existing object from your StackMob Datastore.
 
 @param objectId The object id (the value of the primary key field) for the object to read.
 @param schema The StackMob schema containing this object.
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread after the object is successfully read. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString* objectId, NSString *schema)</i>. A block object to invoke on the main thread if the Datastore fails to read the specified object. Passed the error returned by StackMob, the object id sent with this request, and the schema in which the object was to be found.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)readObjectWithId:(NSString *)objectId
                inSchema:(NSString *)schema
               onSuccess:(SMDataStoreSuccessBlock)successBlock
               onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/** 
 Read an existing object from your StackMob Datastore (with request options).
 
 @param objectId The object id (the value of the primary key field) for the object to read.
 @param schema The StackMob schema containing this object.
 @param options An options object contains headers and other configuration for this request
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread after the object is successfully read. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString* objectId, NSString *schema)</i>. A block object to invoke on the main thread if the Datastore fails to read the specified object. Passed the error returned by StackMob, the object id sent with this request, and the schema in which the object was to be found.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)readObjectWithId:(NSString *)objectId
                inSchema:(NSString *)schema
             options:(SMRequestOptions *)options
               onSuccess:(SMDataStoreSuccessBlock)successBlock
               onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/**
 Read an existing object from your StackMob Datastore (with request options).
 
 @param objectId The object id (the value of the primary key field) for the object to read.
 @param schema The StackMob schema containing this object.
 @param options An options object contains headers and other configuration for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully read. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString* objectId, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to read the specified object. Passed the error returned by StackMob, the object id sent with this request, and the schema in which the object was to be found.
 
 @since Available in iOS SDK 1.2.0 and later.
 */
- (void)readObjectWithId:(NSString *)objectId
                inSchema:(NSString *)schema
                 options:(SMRequestOptions *)options
    successCallbackQueue:(dispatch_queue_t)successCallbackQueue
    failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue
               onSuccess:(SMDataStoreSuccessBlock)successBlock
               onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

#pragma mark - Update an Object
///-------------------------------
/// @name Update an Object
///-------------------------------

/** 
 Update an existing object in your StackMob Datastore.
 
 @param objectId The object id (the value of the primary key field) for the object to update.
 @param schema The StackMob schema containing this object.
 @param updatedFields A dictionary describing the object. Keys should map to valid StackMob fields. Values should be JSON serializable objects.
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread after the object is successfully updated. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock <i>typedef void (^SMDataStoreFailureBlock)(NSError *error, NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread if the Datastore fails to update the specified object. Passed the error returned by StackMob, the dictionary sent with this request, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)updateObjectWithId:(NSString *)objectId
                  inSchema:(NSString *)schema
                    update:(NSDictionary *)updatedFields
                 onSuccess:(SMDataStoreSuccessBlock)successBlock
                 onFailure:(SMDataStoreFailureBlock)failureBlock;

/** 
 Update an existing object in your StackMob Datastore (with request options).
 
 @param objectId The object id (the value of the primary key field) for the object to update.
 @param schema The StackMob schema containing this object.
 @param updatedFields A dictionary describing the object. Keys should map to valid StackMob fields. Values should be JSON serializable objects.
 @param options An options object contains headers and other configuration for this request
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread after the object is successfully updated. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock <i>typedef void (^SMDataStoreFailureBlock)(NSError *error, NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread if the Datastore fails to update the specified object. Passed the error returned by StackMob, the dictionary sent with this request, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)updateObjectWithId:(NSString *)objectId
                  inSchema:(NSString *)schema
                    update:(NSDictionary *)updatedFields
               options:(SMRequestOptions *)options
                 onSuccess:(SMDataStoreSuccessBlock)successBlock
                 onFailure:(SMDataStoreFailureBlock)failureBlock;

/**
 Update an existing object in your StackMob Datastore (with request options).
 
 @param objectId The object id (the value of the primary key field) for the object to update.
 @param schema The StackMob schema containing this object.
 @param updatedFields A dictionary describing the object. Keys should map to valid StackMob fields. Values should be JSON serializable objects.
 @param options An options object contains headers and other configuration for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock <i>typedef void (^SMDataStoreFailureBlock)(NSError *error, NSDictionary* object, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to update the specified object. Passed the error returned by StackMob, the dictionary sent with this request, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 1.2.0 and later.
 */
- (void)updateObjectWithId:(NSString *)objectId
                  inSchema:(NSString *)schema
                    update:(NSDictionary *)updatedFields
                   options:(SMRequestOptions *)options
      successCallbackQueue:(dispatch_queue_t)successCallbackQueue
      failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue
                 onSuccess:(SMDataStoreSuccessBlock)successBlock
                 onFailure:(SMDataStoreFailureBlock)failureBlock;

/** 
 Do an atomic update on a particular value.
 
 @param objectId The object id (the value of the primary key field) for the object to update.
 @param field the field in the schema that represents the counter.
 @param schema The StackMob schema containing the counter.
 @param increment The value (positive or negative) to increment the counter by.
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread after the object is successfully updated. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock <i>typedef void (^SMDataStoreFailureBlock)(NSError *error, NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread if the Datastore fails to update the specified object. Passed the error returned by StackMob, the dictionary sent with this request, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)updateAtomicCounterWithId:(NSString *)objectId
                            field:(NSString *)field
                         inSchema:(NSString *)schema
                               by:(int)increment
                        onSuccess:(SMDataStoreSuccessBlock)successBlock
                        onFailure:(SMDataStoreFailureBlock)failureBlock;

/** 
 Do an atomic update on a particular value (with request options).
 
 @param objectId The object id (the value of the primary key field) for the object to update.
 @param field the field in the schema that represents the counter.
 @param schema The StackMob schema containing the counter.
 @param increment The value (positive or negative) to increment the counter by.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread after the object is successfully updated. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock <i>typedef void (^SMDataStoreFailureBlock)(NSError *error, NSDictionary* object, NSString *schema)</i>. A block object to invoke on the main thread if the Datastore fails to update the specified object. Passed the error returned by StackMob, the dictionary sent with this request, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)updateAtomicCounterWithId:(NSString *)objectId
                            field:(NSString *)field
                         inSchema:(NSString *)schema
                               by:(int)increment
                      options:(SMRequestOptions *)options
                        onSuccess:(SMDataStoreSuccessBlock)successBlock
                        onFailure:(SMDataStoreFailureBlock)failureBlock;

/**
 Do an atomic update on a particular value (with request options).
 
 @param objectId The object id (the value of the primary key field) for the object to update.
 @param field the field in the schema that represents the counter.
 @param schema The StackMob schema containing the counter.
 @param increment The value (positive or negative) to increment the counter by.
 @param options An options object contains headers and other configuration for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock <i>typedef void (^SMDataStoreFailureBlock)(NSError *error, NSDictionary* object, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to update the specified object. Passed the error returned by StackMob, the dictionary sent with this request, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 1.2.0 and later.
 */
- (void)updateAtomicCounterWithId:(NSString *)objectId
                            field:(NSString *)field
                         inSchema:(NSString *)schema
                               by:(int)increment
                          options:(SMRequestOptions *)options
             successCallbackQueue:(dispatch_queue_t)successCallbackQueue
             failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue
                        onSuccess:(SMDataStoreSuccessBlock)successBlock
                        onFailure:(SMDataStoreFailureBlock)failureBlock;

#pragma mark - Delete an Object
///-------------------------------
/// @name Delete an Object
///-------------------------------

/** 
 Delete an existing object from your StackMob Datastore.
 
 @param objectId The object id (the value of the primary key field) for the object to delete.
 @param schema The StackMob schema containing this object.
 @param successBlock <i>typedef void (^SMDataStoreObjectIdSuccessBlock)(NSString* objectId, NSString *schema)</i>. A block object to invoke on the main thread after the object is successfully deleted. Passed the object id of the deleted object and the object's schema.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString* objectId, NSString *schema)</i>. A block object to invoke on the main thread if the Datastore fails to read the specified object. Passed the error returned by StackMob, the object id sent with this request, and the schema in which the object was to be found.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)deleteObjectId:(NSString *)objectId
              inSchema:(NSString *)schema
             onSuccess:(SMDataStoreObjectIdSuccessBlock)successBlock
             onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/** 
 Delete an existing object from your StackMob Datastore (with request options).
 
 @param objectId The object id (the value of the primary key field) for the object to delete.
 @param schema The StackMob schema containing this object.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock <i>typedef void (^SMDataStoreObjectIdSuccessBlock)(NSString* objectId, NSString *schema)</i>. A block object to invoke on the main thread after the object is successfully deleted. Passed the object id of the deleted object and the object's schema.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString* objectId, NSString *schema)</i>. A block object to invoke on the main thread if the Datastore fails to read the specified object. Passed the error returned by StackMob, the object id sent with this request, and the schema in which the object was to be found.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)deleteObjectId:(NSString *)objectId
              inSchema:(NSString *)schema
           options:(SMRequestOptions *)options
             onSuccess:(SMDataStoreObjectIdSuccessBlock)successBlock
             onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/**
 Delete an existing object from your StackMob Datastore (with request options).
 
 @param objectId The object id (the value of the primary key field) for the object to delete.
 @param schema The StackMob schema containing this object.
 @param options An options object contains headers and other configuration for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMDataStoreObjectIdSuccessBlock)(NSString* objectId, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully deleted. Passed the object id of the deleted object and the object's schema.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString* objectId, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to read the specified object. Passed the error returned by StackMob, the object id sent with this request, and the schema in which the object was to be found.
 
 @since Available in iOS SDK 1.2.0 and later.
 */
- (void)deleteObjectId:(NSString *)objectId
              inSchema:(NSString *)schema
               options:(SMRequestOptions *)options
  successCallbackQueue:(dispatch_queue_t)successCallbackQueue
  failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue
             onSuccess:(SMDataStoreObjectIdSuccessBlock)successBlock
             onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

#pragma mark - Create and Append Related Objects
///-------------------------------
/// @name Create and Append Related Objects
///-------------------------------

/**
 Create and save related objects, then subsequently save them to another object's relationship value, all in one call.
 
 @param objects An array of dictionary objects to create and append.
 @param objectId The primary key of the object with the relationship being edited.
 @param schema The primary object's schema.
 @param field The name of the primary object's related field.
 @param successBlock <i>typedef void (^SMDataStoreBulkSuccessBlock)(NSArray* succeeded, NSArray *failed, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the succeeded and failed object IDs in two separate arrays.
 @param failureBlock <i>typedef void (^SMDataStoreArrayFailureBlock)(NSError *error, NSString *objectId, NSArray* objects, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to update the specified object. Passed the error returned by StackMob, the primary key, the objects to be created and appended, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
- (void)createAndAppendRelatedObjects:(NSArray *)objects toObjectWithId:(NSString *)objectId inSchema:(NSString *)schema relatedField:(NSString *)field onSuccess:(SMDataStoreBulkSuccessBlock)successBlock onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/**
 Create and save related objects, then subsequently save them to another object's relationship value, all in one call.
 
 Includes parameter for request options.
 
 @param objects An array of dictionary objects to create and append.
 @param objectId The primary key of the object with the relationship being edited.
 @param schema The primary object's schema.
 @param field The name of the primary object's related field.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock <i>typedef void (^SMDataStoreBulkSuccessBlock)(NSArray* succeeded, NSArray *failed, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the succeeded and failed object IDs in two separate arrays.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString *objectId, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to update the specified object. Passed the error returned by StackMob, the primary key, the objects to be created and appended, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
- (void)createAndAppendRelatedObjects:(NSArray *)objects toObjectWithId:(NSString *)objectId inSchema:(NSString *)schema relatedField:(NSString *)field options:(SMRequestOptions *)options onSuccess:(SMDataStoreBulkSuccessBlock)successBlock onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/**
 Create and save related objects, then subsequently save them to another object's relationship value, all in one call.
 
 Includes parameters for request options and callback queues.
 
 @param objects An array of dictionary objects to create and append.
 @param objectId The primary key of the object with the relationship being edited.
 @param schema The primary object's schema.
 @param field The name of the primary object's related field.
 @param options An options object contains headers and other configuration for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMDataStoreBulkSuccessBlock)(NSArray* succeeded, NSArray *failed, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the succeeded and failed object IDs in two separate arrays.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString *objectId, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to update the specified object. Passed the error returned by StackMob, the primary key, the objects to be created and appended, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
- (void)createAndAppendRelatedObjects:(NSArray *)objects toObjectWithId:(NSString *)objectId inSchema:(NSString *)schema relatedField:(NSString *)field options:(SMRequestOptions *)options successCallbackQueue:(dispatch_queue_t)successCallbackQueue failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue onSuccess:(SMDataStoreBulkSuccessBlock)successBlock onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

#pragma mark - Append Existing Objects
///-------------------------------
/// @name Append Existing Objects
///-------------------------------

/**
 Append objects to an array without needing to update the entire object at once. This goes for fields of type `Array` as well as one-to-many relationships.
 
 This method also handles any concurrency issues if two users are modifying the same object at the same time by doing atomic appending.
 
 If the field is an array, the objects will be appended to it with no uniqueness constraint.
 
 If the field is a relationship, just append the object primary IDs to the array, not the objects themselves. The resulting array will be deduped so that there are no duplicate references to related object IDs.
 
 @param objects An array of IDs to append to the related field's value.
 @param objectId The primary key of the object being updated.
 @param schema The primary object's schema.
 @param field The name of the primary object's related field.
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the succeeded and failed objects in two separate arrays.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString *objectId, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to update the specified object. Passed the error returned by StackMob, the primary key, the objects to be and appended, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
- (void)appendObjects:(NSArray *)objects toObjectWithId:(NSString *)objectId inSchema:(NSString *)schema field:(NSString *)field onSuccess:(SMDataStoreSuccessBlock)successBlock onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/**
 Append objects to an array without needing to update the entire object at once. This goes for fields of type `Array` as well as one-to-many relationships.
 
 This method also handles any concurrency issues if two users are modifying the same object at the same time by doing atomic appending.
 
 If the field is an array, the objects will be appended to it with no uniqueness constraint.
 
 If the field is a relationship, just append the object primary IDs to the array, not the objects themselves. The resulting array will be deduped so that there are no duplicate references to related object IDs.
 
 Includes parameter for request options.
 
 @param objects An array of IDs to append to the related field's value.
 @param objectId The primary key of the object being updated.
 @param schema The primary object's schema.
 @param field The name of the primary object's related field.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the succeeded and failed objects in two separate arrays.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString *objectId, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to update the specified object. Passed the error returned by StackMob, the primary key, the objects to be and appended, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
- (void)appendObjects:(NSArray *)objects toObjectWithId:(NSString *)objectId inSchema:(NSString *)schema field:(NSString *)field options:(SMRequestOptions *)options onSuccess:(SMDataStoreSuccessBlock)successBlock onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/**
 Append objects to an array without needing to update the entire object at once. This goes for fields of type `Array` as well as one-to-many relationships.
 
 This method also handles any concurrency issues if two users are modifying the same object at the same time by doing atomic appending.
 
 If the field is an array, the objects will be appended to it with no uniqueness constraint.
 
 If the field is a relationship, just append the object primary IDs to the array, not the objects themselves. The resulting array will be deduped so that there are no duplicate references to related object IDs.
 
 Includes parameters for request options and callback queues.
 
 @param objects An array of IDs to append to the related field's value.
 @param objectId The primary key of the object being updated.
 @param schema The primary object's schema.
 @param field The name of the primary object's related field.
 @param options An options object contains headers and other configuration for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema)</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the succeeded and failed objects in two separate arrays.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString *objectId, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to update the specified object. Passed the error returned by StackMob, the primary key, the objects to be and appended, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
- (void)appendObjects:(NSArray *)objects toObjectWithId:(NSString *)objectId inSchema:(NSString *)schema field:(NSString *)field options:(SMRequestOptions *)options successCallbackQueue:(dispatch_queue_t)successCallbackQueue failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue onSuccess:(SMDataStoreSuccessBlock)successBlock onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

#pragma mark - Delete Existing Objects
///-------------------------------
/// @name Delete Existing Objects
///-------------------------------

/**
 Delete objects or relationship references from an array without needing to update the entire object at once.
 
 Includes the option of deleting the objects themselves in the same call (for relationship fields only). If you are deleting from a field of `Array` type, pass `NO` to the `cascadeDelete` parameter, as this option is only applicable to relationship fields.
 
 @param objects An array of IDs to delete.
 @param objectId The primary key of the object with the relationship being edited.
 @param schema The primary object's schema.
 @param field The name of the primary object's related field.
 @param cascadeDelete Whether or not to delete the objects themselves after removing the references in the relationship value.
 @param successBlock <i>typedef void (^SMSuccessBlock)()</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the succeeded and failed objects in two separate arrays.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString *objectId, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to delete the specified objects. Passed the error returned by StackMob, the primary key, the objects to be deleted, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
- (void)deleteObjects:(NSArray *)objects fromObjectWithId:(NSString *)objectId inSchema:(NSString *)schema field:(NSString *)field cascadeDelete:(BOOL)cascadeDelete onSuccess:(SMSuccessBlock)successBlock onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/**
 Delete objects or relationship references from an array without needing to update the entire object at once.
 
 Includes the option of deleting the objects themselves in the same call (for relationship fields only). If you are deleting from a field of `Array` type, pass `NO` to the `cascadeDelete` parameter, as this option is only applicable to relationship fields.
 
 Includes parameter for request options.
 
 @param objects An array of IDs to delete.
 @param objectId The primary key of the object with the relationship being edited.
 @param schema The primary object's schema.
 @param field The name of the primary object's related field.
 @param cascadeDelete Whether or not to delete the objects themselves after removing the references in the relationship value.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock <i>typedef void (^SMSuccessBlock)()</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the succeeded and failed objects in two separate arrays.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString *objectId, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to delete the specified objects. Passed the error returned by StackMob, the primary key, the objects to be deleted, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
- (void)deleteObjects:(NSArray *)objects fromObjectWithId:(NSString *)objectId inSchema:(NSString *)schema field:(NSString *)field cascadeDelete:(BOOL)cascadeDelete options:(SMRequestOptions *)options onSuccess:(SMSuccessBlock)successBlock onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/**
 Delete objects or relationship references from an array without needing to update the entire object at once.
 
 Includes the option of deleting the objects themselves in the same call (for relationship fields only). If you are deleting from a field of `Array` type, pass `NO` to the `cascadeDelete` parameter, as this option is only applicable to relationship fields.
 
 Includes parameters for request options and callback queues.
 
 @param objects An array of IDs to delete.
 @param objectId The primary key of the object with the relationship being edited.
 @param schema The primary object's schema.
 @param field The name of the primary object's related field.
 @param cascadeDelete Whether or not to delete the objects themselves after removing the references in the relationship value.
 @param options An options object contains headers and other configuration for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMSuccessBlock)()</i>. A block object to invoke on the successCallbackQueue after the object is successfully updated. Passed the succeeded and failed objects in two separate arrays.
 @param failureBlock <i>typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString *objectId, NSString *schema)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to delete the specified objects. Passed the error returned by StackMob, the primary key, the objects to be deleted, and the schema in which the object was to be updated.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
- (void)deleteObjects:(NSArray *)objects fromObjectWithId:(NSString *)objectId inSchema:(NSString *)schema field:(NSString *)field cascadeDelete:(BOOL)cascadeDelete options:(SMRequestOptions *)options successCallbackQueue:(dispatch_queue_t)successCallbackQueue failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue onSuccess:(SMSuccessBlock)successBlock onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;


#pragma mark - Queries
///-------------------------------
/// @name Performing Queries
///-------------------------------


/** 
 Execute a query against your StackMob Datastore.
  
 @param query An `SMQuery` object describing the query to perform.
 @param successBlock <i>typedef void (^SMResultsSuccessBlock)(NSArray *results)</i>. A block object to invoke on the main thread after the query succeeds. Passed an array of object dictionaries returned from StackMob (if any).
 @param failureBlock <i>typedef void (^SMFailureBlock)(NSError *error)</i>. A block object to invoke on the main thread if the Datastore fails to perform the query. Passed the error returned by StackMob.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)performQuery:(SMQuery *)query onSuccess:(SMResultsSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

/** 
 Execute a query against your StackMob Datastore (with request options).
  
 @param query An `SMQuery` object describing the query to perform.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock <i>typedef void (^SMResultsSuccessBlock)(NSArray *results)</i>. A block object to invoke on the main thread after the query succeeds. Passed an array of object dictionaries returned from StackMob (if any).
 @param failureBlock <i>typedef void (^SMFailureBlock)(NSError *error)</i>. A block object to invoke on the main thread if the Datastore fails to perform the query. Passed the error returned by StackMob.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)performQuery:(SMQuery *)query options:(SMRequestOptions *)options onSuccess:(SMResultsSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

/**
 Execute a query against your StackMob Datastore (with request options).
 
 @param query An `SMQuery` object describing the query to perform.
 @param options An options object contains headers and other configuration for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMResultsSuccessBlock)(NSArray *results)</i>. A block object to invoke on the successCallbackQueue after the query succeeds. Passed an array of object dictionaries returned from StackMob (if any).
 @param failureBlock <i>typedef void (^SMFailureBlock)(NSError *error)</i>. A block object to invoke on the failureCallbackQueue if the Datastore fails to perform the query. Passed the error returned by StackMob.
 
 @since Available in iOS SDK 1.2.0 and later.
 */
- (void)performQuery:(SMQuery *)query options:(SMRequestOptions *)options successCallbackQueue:(dispatch_queue_t)successCallbackQueue
failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue onSuccess:(SMResultsSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

#pragma mark - Performing Count Queries
///-------------------------------
/// @name Performing Count Queries
///-------------------------------

/** 
 Count the results that would be returned by a query against your StackMob Datastore.
  
 @param query An `SMQuery` object describing the query to perform.
 @param successBlock <i>typedef void (^SMCountSuccessBlock)(NSNumber *count)</i>. A block object to invoke on the main thread when the count is complete.  Passed the number of objects returned that would by the query.
 @param failureBlock <i>typedef void (^SMFailureBlock)(NSError *error)</i>. A block object to invoke on the main thread if the Datastore fails to perform the query. Passed the error returned by StackMob.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)performCount:(SMQuery *)query onSuccess:(SMCountSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

/** 
 Count the results that would be returned by a query against your StackMob Datastore (with request options).
  
 @param query An `SMQuery` object describing the query to perform.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock <i>typedef void (^SMCountSuccessBlock)(NSNumber *count)</i>. A block object to invoke on the main thread when the count is complete.  Passed the number of objects that would be returned by the query.
 @param failureBlock <i>typedef void (^SMFailureBlock)(NSError *error)</i>. A block object to invoke on the main thread if the Datastore fails to perform the query. Passed the error returned by StackMob.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)performCount:(SMQuery *)query options:(SMRequestOptions *)options onSuccess:(SMCountSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

/**
 Count the results that would be returned by a query against your StackMob Datastore (with request options).
 
 @param query An `SMQuery` object describing the query to perform.
 @param options An options object contains headers and other configuration for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMCountSuccessBlock)(NSNumber *count)</i>. A block object to invoke on the successCallbackQueue when the count is complete.  Passed the number of objects that would be returned by the query.
 @param failureBlock <i>typedef void (^SMFailureBlock)(NSError *error)</i>. A block object to on the invoke failureCallbackQueue if the Datastore fails to perform the query. Passed the error returned by StackMob.
 
 @since Available in iOS SDK 1.2.0 and later.
 */
- (void)performCount:(SMQuery *)query options:(SMRequestOptions *)options successCallbackQueue:(dispatch_queue_t)successCallbackQueue failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue onSuccess:(SMCountSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

#pragma mark - Custom Code
///-------------------------------
/// @name Performing Custom Code Methods
///-------------------------------

/**
 Calls <performCustomCodeRequest:options:onSuccess:onFailure:> with `[SMRequestOptions options]` for the parameter `options`.
 
 You can expect the **responseBody** parameter of the success callback to be in the form of:
 
 * Serialized JSON (NSDictionary/NSArray) if the content type of the response is application/vnd.stackmob+json or application/json.
 * A string (NSString) if the content type of the response is text/plain.
 * Raw data (NSData) for any other response content type.
 
 To get started writing custom code methods, check out the <a href="https://developer.stackmob.com/customcode-sdk/developer-guide" target="_blank">Custom Code Developer Guide</a>.
 
 @param customCodeRequest The request to execute.
 @param successBlock <i>typedef void (^SMFullResponseSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id responseBody)</i>. A block object to call on the main thread upon success.
 @param failureBlock <i>typedef void (^SMFullResponseFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseBody)</i>. A block object to call on the main thread upon failure.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)performCustomCodeRequest:(SMCustomCodeRequest *)customCodeRequest onSuccess:(SMFullResponseSuccessBlock)successBlock onFailure:(SMFullResponseFailureBlock)failureBlock;
/**
 Execute a custom code method on StackMob.
 
 You can expect the **responseBody** parameter of the success callback to be in the form of:
 
 * Serialized JSON (NSDictionary/NSArray) if the content type of the response is application/vnd.stackmob+json or application/json.
 * A string (NSString) if the content type of the response is text/plain.
 * Raw data (NSData) for any other response content type.
 
 To get started writing custom code methods, check out the <a href="https://developer.stackmob.com/customcode-sdk/developer-guide" target="_blank">Custom Code Developer Guide</a>.
 
 @param customCodeRequest The request to execute.
 @param options The options for this request.
 @param successBlock <i>typedef void (^SMFullResponseSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id responseBody)</i>. A block object to call on the main thread upon success.
 @param failureBlock <i>typedef void (^SMFullResponseFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseBody)</i>. A block object to call on the main thread upon failure.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)performCustomCodeRequest:(SMCustomCodeRequest *)customCodeRequest options:(SMRequestOptions *)options onSuccess:(SMFullResponseSuccessBlock)successBlock onFailure:(SMFullResponseFailureBlock)failureBlock;

/**
 Execute a custom code method on StackMob.
 
 You can expect the **responseBody** parameter of the success callback to be in the form of:
 
 * Serialized JSON (NSDictionary/NSArray) if the content type of the response is application/vnd.stackmob+json or application/json.
 * A string (NSString) if the content type of the response is text/plain.
 * Raw data (NSData) for any other response content type.
 
 To get started writing custom code methods, check out the <a href="https://developer.stackmob.com/customcode-sdk/developer-guide" target="_blank">Custom Code Developer Guide</a>.
 
 @param customCodeRequest The request to execute.
 @param options The options for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMFullResponseSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id responseBody)</i>. A block object to call on the successCallbackQueue upon success.
 @param failureBlock <i>typedef void (^SMFullResponseFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseBody)</i>. A block object to call on the failureCallbackQueue upon failure.
 
 @since Available in iOS SDK 1.2.0 and later.
 */
- (void)performCustomCodeRequest:(SMCustomCodeRequest *)customCodeRequest options:(SMRequestOptions *)options successCallbackQueue:(dispatch_queue_t)successCallbackQueue failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue onSuccess:(SMFullResponseSuccessBlock)successBlock onFailure:(SMFullResponseFailureBlock)failureBlock;

/**
 Retry executing a custom code method on StackMob.
 
 This method should only be called by developers defining their own custom code retry blocks.  See <SMRequestOptions> method `addSMErrorServiceUnavailableRetryBlock:`.
 
 @param request The request to execute.
 @param options The options for this request.
 @param successBlock <i>typedef void (^SMFullResponseSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id responseBody)</i>. A block object to call on the main thread upon success.
 @param failureBlock <i>typedef void (^SMFullResponseFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseBody)</i>. A block object to call on the main thread upon failure.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
- (void)retryCustomCodeRequest:(NSURLRequest *)request options:(SMRequestOptions *)options onSuccess:(SMFullResponseSuccessBlock)successBlock onFailure:(SMFullResponseFailureBlock)failureBlock;

/**
 Retry executing a custom code method on StackMob.
 
 This method should only be called by developers defining their own custom code retry blocks.  See <SMRequestOptions> method `addSMErrorServiceUnavailableRetryBlock:`.
 
 @param request The request to execute.
 @param options The options for this request.
 @param successCallbackQueue The dispatch queue used to execute the success block. If nil is passed, the main queue is used.
 @param failureCallbackQueue The dispatch queue used to execute the failure block. If nil is passed, the main queue is used.
 @param successBlock <i>typedef void (^SMFullResponseSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id responseBody)</i>. A block object to call on the successCallbackQueue upon success.
 @param failureBlock <i>typedef void (^SMFullResponseFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseBody  )</i>. A block object to call on the failureCallbackQueue upon failure.
 
 @since Available in iOS SDK 1.2.0 and later.
 */
- (void)retryCustomCodeRequest:(NSURLRequest *)request options:(SMRequestOptions *)options successCallbackQueue:(dispatch_queue_t)successCallbackQueue failureCallbackQueue:(dispatch_queue_t)failureCallbackQueue onSuccess:(SMFullResponseSuccessBlock)successBlock onFailure:(SMFullResponseFailureBlock)failureBlock;

@end
