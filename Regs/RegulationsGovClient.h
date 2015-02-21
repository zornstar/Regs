//
//  RegulationsGovClient.h
//  Regs
//
//  Created by Matthew Zorn on 12/25/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface RegulationsGovClient : NSObject

-(void) getCurrentInspectionsSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(void) getPublicInspectionDocument:(NSString *)str toPath:(NSString *)path
                            success:(void (^)(AFHTTPRequestOperation *, id))success
                            failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;

-(void) getAgenciesWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *err))failure;

-(void) getAgencyEvents:(NSString *)agencyID
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *err))failure;

-(void) getRegisterByDay:(NSDate *)date
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *err))failure;

-(void) getRecentArticles:(NSString *)url
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *err))failure;

- (void) subscribeEmail:(NSString *)email
             toAgencyID:(NSString *)agencyID
       publicInspection:(BOOL)inspection
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *err))failure;

-(void) searchPresidentialDocumentsWithTerm:(NSString *)term
                           success:(void (^)(AFHTTPRequestOperation *, id))success
                           failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;

-(void) searchExecutiveOrdersWithTerm:(NSString *)term
                                 success:(void (^)(AFHTTPRequestOperation *, id))success
                                 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;

+(instancetype) sharedClient;
-(void) reachability;

@end
