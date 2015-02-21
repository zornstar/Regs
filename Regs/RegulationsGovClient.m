//
//  RegulationsGovClient.m
//  Regs
//
//  Created by Matthew Zorn on 12/25/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "RegulationsGovClient.h"
#import <RaptureXML@Gilt/RXMLElement.h>
#import <MXLCalendarManager/MXLCalendarManager.h>

#define SUBSCRIBE_POST @"https://www.federalregister.gov/my/subscriptions"

#define PRES_DOC_URL(f) [NSString stringWithFormat:@"https://www.federalregister.gov/api/v1/articles.json?fields%%5B%%5D=citation&fields%%5B%%5D=pdf_url&fields%%5B%%5D=subtype&fields%%5B%%5D=title&fields%%5B%%5D=type&per_page=100&order=relevance&conditions%%5Bterm%%5D=%@&conditions%%5Btype%%5D%%5B%%5D=PRESDOCU", f]

#define EXECUTIVE_ORDER_URL(f) [NSString stringWithFormat:@"https://www.federalregister.gov/api/v1/articles.json?fields%%5B%%5D=citation&fields%%5B%%5D=pdf_url&fields%%5B%%5D=subtype&fields%%5B%%5D=title&fields%%5B%%5D=type&per_page=50&order=relevance&conditions%%5Bterm%%5D=%@&conditions%%5Btype%%5D%%5B%%5D=PRESDOCU&conditions%%5Bpresidential_document_type%%5D%%5B%%5D=executive_order", f]

#define DATE_REGISTER_URL @"https://www.federalregister.gov/api/v1/articles.json?per_page=1000&fields%5B%5D=abstract&fields%5B%5D=agencies&fields%5B%5D=agency_names&fields%5B%5D=citation&fields%5B%5D=document_number&fields%5B%5D=pdf_url&fields%5B%5D=title&fields%5B%5D=type&order=relevance&conditions%5Bpublication_date%5D%5Bis%5D="

#define FEDREGISTER_API @"https://www.federalregister.gov/api/v1/"

#define CURRENT_INSPECTION_URL @"https://www.federalregister.gov/api/v1/public-inspection-documents/current.json"

#define AGENCIES_URL @"http://www.federalregister.gov/api/v1/agencies"

#define AGENCY_EVENTS_URL @"https://www.federalregister.gov/events/search.ics?conditions%5Bagency_ids%5D="

@implementation RegulationsGovClient

+ (instancetype) sharedClient {
    static RegulationsGovClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[RegulationsGovClient alloc] init];
        [client reachability];
    });
    return client;
}

-(void) reachability {
    NSURL *baseURL = [NSURL URLWithString:FEDREGISTER_API];
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

-(void) getPublicInspectionDocument:(NSString *)str toPath:(NSString *)path
                            success:(void (^)(AFHTTPRequestOperation *, id))success
                            failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:str]];
    AFHTTPRequestOperation *request = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [((NSData *)responseObject) writeToFile:path atomically:YES];
    } failure:failure];
    [request start];
}

-(void) getCurrentInspectionsSuccess:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if(manager.operationQueue.suspended) {
        
    }
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    
    [manager GET:CURRENT_INSPECTION_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *results = [responseObject objectForKey:@"results"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDateFormatter *mediumFormatter = [[NSDateFormatter alloc] init];
        [mediumFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        NSMutableDictionary *inspections = [NSMutableDictionary dictionary];
        for(NSDictionary *result in results) {
            NSDate *date = [dateFormatter dateFromString:result[@"publication_date"]];
            
            if(inspections[date]) {
                [inspections[date] addObject:result];
            } else {
                [inspections setObject:[@[result] mutableCopy] forKey:date];
            }
        }
     
     NSArray *sortedKeys = [[inspections allKeys] sortedArrayUsingSelector: @selector(compare:)];
     NSMutableArray *sortedValues = [NSMutableArray array];
     for (NSDate *key in sortedKeys) {
         
         NSString *dateString = [mediumFormatter stringFromDate:key];
         [sortedValues addObject:@{@"date":dateString, @"values":inspections[key]}];
     }
     
     success(operation, sortedValues);
        
    } failure:failure];
}

-(void) searchPresidentialDocumentsWithTerm:(NSString *)term success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if(manager.operationQueue.suspended) {
        
    }
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:PRES_DOC_URL(term) parameters:nil success:success failure:failure];
    
}

-(void) searchExecutiveOrdersWithTerm:(NSString *)term success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if(manager.operationQueue.suspended) {
        
    }
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:EXECUTIVE_ORDER_URL(term) parameters:nil success:success failure:failure];
    
}

-(void) getAgencyEvents:(NSString *)agencyID
                success:(void (^)(AFHTTPRequestOperation *, id))success
                       failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/calendar"]];
    NSString *url = [AGENCY_EVENTS_URL stringByAppendingString:agencyID];
    if(manager.operationQueue.suspended) {
        
    }
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MXLCalendarManager *calendarManager = [[MXLCalendarManager alloc] init];
        NSString *ics = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        ics = [ics stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        ics = [ics stringByReplacingOccurrencesOfString:@"\r\n " withString:@""];
        NSMutableDictionary *events = [NSMutableDictionary dictionary];
        [calendarManager parseICSString:ics withCompletionHandler:^(MXLCalendar *calendar, NSError *err) {
            NSDateFormatter *shortFormatter = [[NSDateFormatter alloc] init];
            [shortFormatter setDateStyle:NSDateFormatterShortStyle];
            
            for(MXLCalendarEvent *event in calendar.events) {
                
                NSDate *date;
                
                if (event.eventStartDate) date = event.eventStartDate;
                else if (event.eventEndDate) date = event.eventEndDate;
             
                if(!date) continue;
                
                NSString *dateString = [shortFormatter stringFromDate:date];
                NSDictionary *e = @{@"date":dateString, @"summary": (event.eventSummary.length > 0) ? event.eventSummary : @"", @"description": (event.eventDescription.length > 0) ? event.eventDescription : @""};
                
                if(events[date]) {
                    [events[date] addObject:e];
                } else {
                    [events setObject:[@[e] mutableCopy] forKey:date];
                }
            }
            
            NSArray *sortedKeys = [[events allKeys] sortedArrayUsingSelector: @selector(compare:)];
            NSMutableArray *sortedValues = [NSMutableArray array];
            for (id key in sortedKeys) {
                [sortedValues addObject:@{@"date":key, @"values":events[key]}];
            }
            
            success(operation, sortedValues);
        }];
        
        
        
    } failure:failure];
}
-(void) getAgenciesWithSuccess:(void (^)(AFHTTPRequestOperation *, id))success
                       failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    
    if(manager.operationQueue.suspended) {
        
    }
    
    [manager GET:AGENCIES_URL parameters:nil success:success failure:failure];
    
}

-(void) getRecentArticles:(NSString *)url success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    
    url = [url stringByAppendingString:@"&per_page=100"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    
    if(manager.operationQueue.suspended) {
        
    }
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *entries = [NSMutableDictionary dictionary];
        
        NSArray *results = responseObject[@"results"];
        
        if(results.count == 0) success(operation, @[]);
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSDateFormatter *shortFormatter = [[NSDateFormatter alloc] init];
        [shortFormatter setDateStyle:NSDateFormatterShortStyle];
       
        for(NSDictionary *result in results) {
            NSDate *pubDate = [df dateFromString:result[@"publication_date"]];
           
            NSString *dateString = [shortFormatter stringFromDate:pubDate];
            NSDictionary *r = @{
                                @"date":dateString,
                                @"document_number": result[@"abstract"] ? result[@"document_number"] : @"",
                                @"summary": result[@"abstract"] ? result[@"abstract"] : @"",
                                @"title": result[@"title"] ? result[@"title"] : @"",
                                @"pdf_url": result[@"pdf_url"] ? result[@"pdf_url"] : @"",
                                @"type": result[@"type"] ? result[@"type"] : @""};
            
            if(entries[pubDate]) {
                [entries[pubDate] addObject:r];
            } else {
                [entries setObject:[@[r] mutableCopy] forKey:pubDate];
            }
        }
        
        NSArray *sortedKeys = [[entries allKeys] sortedArrayUsingSelector: @selector(compare:)];
        sortedKeys = [[sortedKeys reverseObjectEnumerator] allObjects];
        NSMutableArray *sortedValues = [NSMutableArray array];
        NSString *nextPage = responseObject[@"next_page_url"] ? responseObject[@"next_page_url"] : @"";
        for (id key in sortedKeys) {
            [sortedValues addObject:@{@"date":key, @"values":entries[key], @"next": nextPage}];
        }
        
        success(operation, sortedValues);
    } failure:failure];
    
}


-(void)getRegisterByDay:(NSDate *)date success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *urlString = [DATE_REGISTER_URL stringByAppendingString:[dateFormatter stringFromDate:date]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    if(manager.operationQueue.suspended) {
        
    }
    
    
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        
        if(!responseObject[@"results"]) {
           success(operation, @{@"raw":@[], @"sorted":@[]});
            return;
        }
        
        for(NSDictionary *result in responseObject[@"results"]) {
            
            NSArray *agencies = result[@"agencies"];
            
            for(NSDictionary *agency in agencies) {
                
                
                NSString *name = agency[@"name"];
                
                if(!name) name = @"Other";
                
                if(resultDict[name]) {
                    [resultDict[name] addObject:result];
                } else {
                    [resultDict setObject:[@[result] mutableCopy] forKey:name];
                }
            }
        }
        
        NSArray *sortedKeys = [[resultDict allKeys] sortedArrayUsingSelector: @selector(compare:)];
        NSMutableArray *sortedValues = [NSMutableArray array];
        for (NSString *key in sortedKeys) {
            [sortedValues addObject:@{@"name":key, @"values":resultDict[key]}];
        }
        
        success(operation, @{@"raw":responseObject[@"results"], @"sorted":sortedValues});
    } failure:failure];
}

- (void) subscribeEmail:(NSString *)email toAgencyID:(NSString *)agencyID publicInspection:(BOOL)inspection success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    
    NSDictionary *parameters = @{@"subscription[search_conditions][agency_ids][]":agencyID,
                                 @"subscription[email]":email,
                                 @"subscription[search_type]": inspection ? @"Entry" : @"PublicInspectionDocument",
                                 @"Commit": @"Subscribe"
                                 };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:SUBSCRIBE_POST parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(operation.response.statusCode == 200) {
            success(operation, responseObject);
        }
        
        else failure(operation, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}
@end
