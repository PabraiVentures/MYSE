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

@class SMRequestOptions;
@class SMGeoPoint;
@class AFHTTPRequestOperation;

/**
 A success block that returns nothing.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^SMSuccessBlock)();

/**
 The block parameters expected for a success response which returns an `NSDictionary`.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^SMResultSuccessBlock)(NSDictionary *result);

/**
 The block parameters expected for a success response which returns an `NSArray`.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^SMResultsSuccessBlock)(NSArray *results);

/**
 The block parameters expected for any failure response.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^SMFailureBlock)(NSError *error);

/**
 The block parameters expected for a success response which returns an `SMGeoPoint`.
 
 @since Available in iOS SDK 1.3.0 and later.
 */
typedef void (^SMGeoPointSuccessBlock)(SMGeoPoint *geoPoint);

/**
 The block parameters expected for a success response that needs the raw request, response, and response body.
 
 @note Parameter 'id JSON' was changed to 'id responseBody' in v2.0.0.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^SMFullResponseSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id responseBody);

/**
 The block parameters expected for a failure response that needs the raw request, response, and response body.
 
 @note Parameter 'id JSON' was changed to 'id responseBody' in v2.0.0.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^SMFullResponseFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseBody);

/**
 The block parameters expected for a success response from a call to the Datastore which returns the full object and schema. 
 
 @param object An updated dictionary representation of the requested object.
 @param schema The schema to which the object belongs.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^SMDataStoreSuccessBlock)(NSDictionary* object, NSString *schema);

/**
 The block parameters expected for a success response from a call to the Datastore which returns the object ID and schema.
 
 @param objectId The object id used in this operation.
 @param schema The schema to which the object belongs.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^SMDataStoreObjectIdSuccessBlock)(NSString* objectId, NSString *schema);

/**
 The block parameters expected for a success response from a call to the Datastore which returns the an array of successed and failed IDs.
 
 This is used for some of the append-based relational methods.
 
 @param succeeded An array of object IDs for those objects that were successfully persisted.
 @param failed An array of object IDs for those objects that were not successfully persisted.
 @param schema The schema to which the objects belong.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
typedef void (^SMDataStoreBulkSuccessBlock)(NSArray* succeeded, NSArray *failed, NSString *schema);

/**
 The block parameters expected for a failure response from a call to the Datastore which returns the error, array of objects and schema.
 
 This is used for the bulk creation methods.
 
 @param error The request error.
 @param objects The objects used in this operation.
 @param schema The schema to which the objects belongs.
 
 @since Available in iOS SDK 2.1.0 and later.
 */
typedef void (^SMDataStoreBulkFailureBlock)(NSError *error, NSArray* objects, NSString *schema);

/** 
 The block parameters expected for a failure response from a call to the Datastore which returns the error, full object and schema.
 
 @param error An error object describing the failure.
 @param object The dictionary representation of the object sent as part of the failed operation.
 @param schema The schema to which the object belongs.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^SMDataStoreFailureBlock)(NSError *error, NSDictionary* object, NSString *schema);

/** 
 The block parameters expected for a failure response from a call to the Datastore which returns the error, object ID and schema.
 
 @param error An error object describing the failure.
 @param objectId The object id sent as part of the failed operation.
 @param schema The schema to which the object belongs.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *error, NSString* objectId, NSString *schema);

/** 
 The block parameters expected for a success response from query count call.
 
 @param count The number of objects returned by the query.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^SMCountSuccessBlock)(NSNumber *count);

/**
 When executing custom code requests, you can optionally define your own retry blocks in the event of a 503 `SMServiceUnavailable` response.  To do this pass a `SMFailureRetryBlock` instance to <SMRequestOptions> method `addSMErrorServiceUnavailableRetryBlock:`.
 
 @param request The original request in `NSURLRequest` form.
 @param response The response from the server.
 @param error The error, if any.
 @param responseBody the body of the response.
 @param options The SMRequestOption instance passed to the request.
 @param successBlock The block to invoke on success.
 @param failureBlock The block to invoke on failure.
 
 @since Available in iOS SDK 1.0.0 and later.
 */
typedef void (^SMFailureRetryBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseBody, SMRequestOptions *options, SMFullResponseSuccessBlock successBlock, SMFullResponseFailureBlock failureBlock);

/**
 Used internally for requests that fail during a core data save.
 
 @param theRequest The original request in `NSURLRequest` form.
 @param error The error, if any.
 @param object The original object being saved.
 @param theOptions The SMRequestOption instance passed to the request.
 @param originalSuccessBlock The block passed to original request.
 
 @since Available in iOS SDK 1.2.0 and later.
 */
typedef void (^SMCoreDataSaveFailureBlock)(NSURLRequest *theRequest, NSError *error, NSDictionary *object, SMRequestOptions *theOptions, SMResultSuccessBlock originalSuccessBlock);

/**
 Used interally for custom code requests.
 
 @since Available in iOS SDK 2.0.0 and later.
 */
typedef void (^AFHTTPOperationSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);

/**
 Used interally for custom code requests.
 
 @since Available in iOS SDK 2.0.0 and later.
 */
typedef void (^AFHTTPOperationFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);

