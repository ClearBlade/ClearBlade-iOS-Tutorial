/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "CBQuery.h"
#import "CBHTTPClient.h"
#import <AFNetworking/AFNetworking.h>
#import "CBItem.h"
#import "ClearBlade.h"

@interface CBQuery ()
-(NSDictionary *)dictionaryValuesToStrings:(NSDictionary *)dictionary;
@end

@implementation CBQuery

@synthesize OR = _OR;
@synthesize query = _query;
@synthesize collectionID = _collectionID;

+(CBQuery *)queryWithCollectionID:(NSString *)collectionID {
    return [[CBQuery alloc] initWithCollectionID:collectionID];
}

-(CBQuery *) initWithCollectionID:(NSString *)colID {
    self = [super init];
    if (self) {
        self.collectionID = colID;
    }
    return self;
}

-(NSMutableDictionary *)query {
    if (!_query) {
        _query = [[NSMutableDictionary alloc] init];
    }
    return _query;
}
-(NSMutableArray *)OR {
    if (!_OR) {
        _OR = [NSMutableArray arrayWithObject:self.query];
    }
    return _OR;
}
-(void) setCollectionID:(NSString *) colID {
    _collectionID = colID;
}

-(CBQuery *) equalTo:(NSString *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"EQ"];
    return self;
}

-(CBQuery *) notEqualTo:(NSString *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"NEQ"];
}

-(CBQuery *) greaterThan:(NSString *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"GT"];
}

-(CBQuery *) lessThan:(NSString *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"LT"];
}

-(CBQuery *) greaterThanEqualTo:(NSString *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"GTE"];
}

-(CBQuery *) lessThanEqualTo:(NSString *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"LTE"];
}

-(CBQuery *) addParameterWithValue:(NSString *)value forKey:(NSString *)key inQueryParameter:(NSString *)parameter {
    NSMutableDictionary * query = self.query;
    NSDictionary * keyValuePair = [self dictionaryValuesToStrings:@{key: value}];
    NSMutableArray * parameterArray = [query objectForKey:parameter];
    if (parameterArray) {
        [parameterArray addObject:keyValuePair];
    } else {
        parameterArray = [NSMutableArray arrayWithObject:keyValuePair];
        [query setObject:parameterArray forKey:parameter];
    }
    return self;
}

-(NSMutableURLRequest *)requestWithMethod:(NSString *)method withParameters:(NSDictionary *)parameters {
    CBHTTPClient *client = [[CBHTTPClient alloc] initWithClearBladeSettings:[ClearBlade settings]];
    return [client requestWithMethod:method path:self.collectionID parameters:parameters];
}

-(void)executeRequest:(NSURLRequest *)apiRequest
  withSuccessCallback:(CBQuerySuccessCallback)successCallback
  withFailureCallback:(CBQueryErrorCallback)failureCallback {
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:apiRequest
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse * response, id JSON) {
        NSMutableArray * responseItems = [NSMutableArray array];
        if ([JSON isKindOfClass:[NSDictionary class]]) {
            NSDictionary * jsonDictionary = (NSDictionary *)JSON;
            for (id value in [jsonDictionary objectEnumerator]) {
                [responseItems addObject:value];
            }
        } else {
            responseItems = JSON;
        }
        NSMutableArray * itemArray = [CBItem arrayOfCBItemsFromArrayOfDictionaries:responseItems withCollectionID:self.collectionID];
        if (successCallback) {
            successCallback(itemArray);
        }
    } failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON) {
        if (failureCallback) {
            failureCallback(error, JSON);
        }
    }];
    [operation start];
}

-(void) fetchWithSuccessCallback:(CBQuerySuccessCallback)successCallback
               withErrorCallback:(CBQueryErrorCallback)failureCallback {
    NSString* jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@[self.OR] options:0 error:NULL]
                                                 encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *fetchRequest = [self requestWithMethod:@"GET" withParameters:@{@"query": jsonString}];
    [self executeRequest:fetchRequest withSuccessCallback:successCallback withFailureCallback:failureCallback];
}

-(void) updateWithChanges:(NSMutableDictionary *)changes
      withSuccessCallback:(CBQuerySuccessCallback)successCallback
        withErrorCallback:(CBQueryErrorCallback)failureCallback {
    NSMutableURLRequest *updateRequest = [self requestWithMethod:@"PUT" withParameters:nil];
    updateRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"query": @[self.OR], @"$set": changes}
                                                             options:0
                                                               error:NULL];
    [updateRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [updateRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self executeRequest:updateRequest withSuccessCallback:successCallback withFailureCallback:failureCallback];
}


-(void) removeWithSuccessCallback:(CBQuerySuccessCallback)successCallback
                withErrorCallback:(CBQueryErrorCallback)failureCallback {
    NSString* jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@[self.OR] options:0 error:NULL]
                                                 encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *removeRequest = [self requestWithMethod:@"DELETE" withParameters:@{@"query": jsonString}];
    [self executeRequest:removeRequest withSuccessCallback:successCallback withFailureCallback:failureCallback];
}

-(NSDictionary *)dictionaryValuesToStrings:(NSDictionary *)dictionary {
    NSMutableDictionary * stringDictionary = [NSMutableDictionary dictionary];
    for (id key in dictionary.keyEnumerator) {
        id value = [dictionary objectForKey:key];
        [stringDictionary setObject:[value description] forKey:key];
    }
    return stringDictionary;
}
-(void)insertItem:(CBItem *)item
withSuccessCallback:(CBQuerySuccessCallback)successCallback
  withErrorCallback:(CBQueryErrorCallback)errorCallback {
    NSMutableURLRequest *insertRequest = [self requestWithMethod:@"POST" withParameters:nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[self dictionaryValuesToStrings:item.data] options:0 error:NULL];
    [insertRequest setHTTPBody:jsonData];
    [insertRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [insertRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self executeRequest:insertRequest withSuccessCallback:successCallback withFailureCallback:errorCallback];
}

@end