//
//  DocumentManager.m
//  Regs
//
//  Created by Matthew Zorn on 11/28/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "DocumentManager.h"
#import "RegsClient.h"

#define DOCUMENTS_PATH @"saved_documents/"
#define DOCUMENT_STORE_PATH @"store/"

@implementation DocumentManager

+ (instancetype) sharedManager {
    static DocumentManager *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[DocumentManager alloc] init];
        client.needsUpdate = FALSE;
    });
    return client;
}

-(NSMutableDictionary *)documents {
    
    self.needsUpdate = FALSE;
    
    if(!_documents) {
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:[self savePath]]) {
            NSMutableDictionary *primer = [@{@"documents":[@[] mutableCopy]} mutableCopy];
            _documents = primer;
            NSData *data = [NSJSONSerialization dataWithJSONObject:_documents options:NSJSONWritingPrettyPrinted error:nil];
            [data writeToFile:[self savePath] atomically:YES];
            return _documents;
        }
        
        NSData *data = [NSData dataWithContentsOfFile:[self savePath]];
        _documents = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    
    return _documents;
}

-(NSArray *) documentsSortedBy:(DocumentSortType)type {
    
    if(type == DocumentSortTypeAlpha) {
        
        if([self.documents[@"documents"] count] == 0) return @[ ];
        
        return [self.documents[@"documents"] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1[@"title"] compare:obj2[@"title"] options:NSCaseInsensitiveSearch];
        }];
        
    } else if (type == DocumentSortTypeDocket) {
        
        if([self.documents[@"documents"] count] == 0) return @[ @[ ] ];
        
        NSMutableDictionary *dockets = [@{} mutableCopy];
        
        for(NSDictionary *document in self.documents[@"documents"]) {
            NSMutableArray *docketComponents = [[document[@"id"] componentsSeparatedByString:@"-"] mutableCopy];
            [docketComponents removeLastObject];
            NSString *docket = [docketComponents componentsJoinedByString:@""];
            
            if(!dockets[docket]) {
                [dockets setObject:[@[] mutableCopy] forKey:docket];
            }
        }
        
        NSArray *docketKeys = [dockets.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSMutableArray *returnKeys = [NSMutableArray array];
        
        for(NSString *key in docketKeys) {
            [returnKeys addObject:dockets[key]];
        }
        
        return [NSArray arrayWithArray:returnKeys];
    }
    
    return self.documents[@"documents"];
}
-(NSString *) savePath {
    NSURL *url = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    return [url.path stringByAppendingPathComponent:DOCUMENTS_PATH];
}

-(NSString *) storePath {
    return [[self storePath] stringByAppendingPathComponent:DOCUMENT_STORE_PATH];
}

-(void) write {
    // do this async
    self.needsUpdate = TRUE;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.documents options:NSJSONWritingPrettyPrinted error:nil];
    [data writeToFile:[self savePath] atomically:YES];
}


-(void)save:(id)info {
    NSMutableDictionary *documents = self.documents;
    [documents[@"documents"] addObject:info];
    self.documents = documents;
    [self write];
    if([info[@"views"] count] > 0 && [info[@"views"][0][@"url"] length] > 0) {
        NSString *savePath = [[self storePath] stringByAppendingPathComponent:info[@"id"]];
        [[RegsClient sharedClient] getDocumentURL:info[@"views"][0][@"url"] toPath:savePath success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSMutableDictionary *document = [[DocumentManager sharedManager] getDocumentById:info[@"title"]];
            [document setObject:savePath forKey:@"local"];
            [self write];
            

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    
    if([info[@"attachments"] count] > 0) {
        
        for(NSMutableDictionary *attachment in info[@"attachments"]) {
            if([attachment[@"url"] length] > 0 && attachment[@"title"] > 0) {
                NSString *fileName = [NSString stringWithFormat:@"%@ - %@", info[@"id"], attachment[@"title"]];
                NSString *savePath = [[self storePath] stringByAppendingPathComponent:fileName];
                
                [[RegsClient sharedClient] getDocumentURL:attachment[@"url"] toPath:savePath success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSMutableDictionary *document = [[DocumentManager sharedManager] getDocumentById:info[@"title"]];
                    
                    for(NSMutableDictionary *_attachment in document[@"attachments"]) {
                        if([_attachment[@"title"] isEqualToString:attachment[@"title"]]) {
                            [_attachment setObject:savePath forKey:@"local"];
                        }
                    }
                    [document setObject:savePath forKey:@"local"];
                    [self write];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
            }
        }
    }
}

-(void)delete:(id)info {
    for(NSMutableDictionary *document in self.documents[@"documents"]) {
        if([document[@"id"] isEqualToString:info[@"id"]]) {
            [self.documents[@"documents"] removeObject:document];
        }
    }
}

-(NSMutableDictionary *) getDocumentById:(NSString *)_id {
    for(NSMutableDictionary *document in self.documents[@"documents"]) {
        if([document[@"id"] isEqualToString:_id]) return document;
    }
    return nil;
}

@end
