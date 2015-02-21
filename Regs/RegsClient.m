//
//  RegsClient.m
//  Regs
//
//  Created by Matthew Zorn on 11/9/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "RegsClient.h"
#import <NDHTMLtoPDF.h>
#import <SVProgressHUD/SVProgressHUD.h>

#define ROOT @"http://docketwrench.sunlightfoundation.com"
#define API @"http://docketwrench.sunlightfoundation.com/api/1.0"
#define API_KEY @"e4d9225e6ab64ffbaa17ad929ff95296"

typedef NS_ENUM(NSUInteger, RegsError) {
    RegsErrorNone = 0,
    RegsErrorNotConnected = 1,
    RegsErrorNoDocumentFound,
    RegsErrorConnectionFailed
};

@interface RegsClient ()

@property NDHTMLtoPDF *pdfCreator;

@end

@implementation RegsClient

+ (instancetype) sharedClient {
    static RegsClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[RegsClient alloc] init];
        [client reachability];
    });
    return client;
}

-(void) reachability {
    NSURL *baseURL = [NSURL URLWithString:API];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    NSOperationQueue *operationQueue = manager.operationQueue;
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
            [operationQueue setSuspended:NO];
            break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
            [operationQueue setSuspended:YES];
            break;
        }
    }];
    
    [manager.reachabilityManager startMonitoring];
}

-(NSString *) appendEnding:(NSString *)ending {
    
    NSMutableArray *components = [[ending componentsSeparatedByString:@"?"] mutableCopy];
    
    NSString *last;
    
    if(components.count > 1) {
        last = [components lastObject];
        [components removeObject:last];
    }
    
    ending = [components componentsJoinedByString:@"?"];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@?apikey=%@", API, ending, API_KEY];
    
    if(last) {
        url = [[url stringByAppendingString:@"&"] stringByAppendingString:last];
    }
    
    return url;
}

-(NSString *) addRoot:(NSString *)string {
    return [ROOT stringByAppendingPathComponent:string];
}

-(void) get:(NSString *)url success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure  {
    
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if(manager.operationQueue.suspended) {
        failure(nil, [NSError errorWithDomain:@"com.regs" code:RegsErrorNotConnected userInfo:nil]);
    }
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    
    if([url rangeOfString:@"?"].location != NSNotFound) {
        url = [NSString stringWithFormat:@"%@/%@&apikey=%@", ROOT, url, API_KEY];
    } else {
        url = [NSString stringWithFormat:@"%@/%@?apikey=%@", ROOT, url, API_KEY];
    }
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self sanitizeDictionary:responseObject];
        success(operation, responseObject);
    } failure:failure];
}

-(void) _get:(NSString *)url success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure  {
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if(manager.operationQueue.suspended) {
        failure(nil, [NSError errorWithDomain:@"com.regs" code:RegsErrorNotConnected userInfo:nil]);
    }
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    [manager GET:[self appendEnding:url] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self sanitizeDictionary:responseObject];
        success(operation, responseObject);
    } failure:failure];
}

-(void) getAgency:(NSString *)str success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self _get:[NSString stringWithFormat:@"agency/%@", str] success:success failure:failure];
}

-(void) getDocket:(NSString *)str success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self _get:[NSString stringWithFormat:@"docket/%@", str] success:success failure:failure];
    
}

-(void) getDocument:(NSString *)str success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self _get:[NSString stringWithFormat:@"document/%@", str] success:success failure:failure];
}

-(void)searchDocket:(NSString *)str success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self _get:[NSString stringWithFormat:@"search/docket/%@", str] success:success failure:failure];
}

-(void) searchDocument:(NSString *)str success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self _get:[NSString stringWithFormat:@"search/document/%@", str] success:success failure:failure];
}

-(void)searchEntity:(NSString *)str success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self _get:[NSString stringWithFormat:@"search/entity/%@", str] success:success failure:failure];
}

-(void)searchFederalRegister:(NSString *)str success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self _get:[NSString stringWithFormat:@"search/document-fr/%@", str] success:success failure:failure];
}

-(void)searchNonFederalRegister:(NSString *)str success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self _get:[NSString stringWithFormat:@"search/document-non-fr/%@", str] success:success failure:failure];
}

-(void) getFederalRegister:(NSString *)str success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self getDocument:str success:success failure:failure];
}

-(void) getNonFederalRegister:(NSString *)str success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self getDocument:str success:success failure:failure];
}
-(void)getEntity:(NSString *)str success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self _get:[NSString stringWithFormat:@"entity/%@", str] success:success failure:failure];
}

-(void) getDocumentURL:(NSString *)url toPath:(NSString *)path success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *request = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        NSString *contentType = operation.response.allHeaderFields[@"Content-Type"];
        
        if([contentType containsString:@"text/html"] || [contentType containsString:@"text/xml"] || [contentType containsString:@"text/plain"]) {
            self.pdfCreator = [NDHTMLtoPDF createPDFWithHTML:[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]  pathForPDF:path pageSize:kPaperSizeA4 margins:UIEdgeInsetsZero successBlock:^(NDHTMLtoPDF *htmlToPDF) {
                success(operation, path);
            } errorBlock:^(NDHTMLtoPDF *htmlToPDF) {
                failure(nil, nil);
            }];
        } else if ([contentType isEqualToString:@"application/pdf"]) {
            [((NSData *)responseObject) writeToFile:path atomically:YES];
            success(operation, path);
        } else failure(operation, [NSError errorWithDomain:@"com.regs.no-html-pdf" code:0 userInfo:nil]);
        
        
        
    } failure:failure];
    [request start];
}
-(void) sanitizeDictionary:(NSMutableDictionary *)responseObject {
    
    [responseObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isKindOfClass:[NSDictionary class]]) {
            [self sanitizeDictionary:obj];
        } else if ([obj isEqual:[NSNull null]]) {
            [responseObject setObject:@"" forKey:key];
        }
    }];
    
}

+ (BOOL) checkInternetConnection {
    if(![AFHTTPRequestOperationManager manager].reachabilityManager.isReachableViaWiFi && ![AFHTTPRequestOperationManager manager].reachabilityManager.isReachableViaWWAN) {
        [SVProgressHUD showErrorWithStatus:@"Check internet connection"];
        return FALSE;
    }
    return TRUE;
}

@end