//
//  BookmarkManager.m
//  Regs
//
//  Created by Matthew Zorn on 11/25/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "BookmarkManager.h"

#define BOOKMARKS_PATH @"bookmarks.json"

@implementation BookmarkManager

+ (instancetype) sharedManager {
    static BookmarkManager *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[BookmarkManager alloc] init];
        client.needsUpdate = FALSE;
    });
    return client;
}

-(void) write {
    // do this async
    self.needsUpdate = TRUE;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.bookmarks options:NSJSONWritingPrettyPrinted error:nil];
    [data writeToFile:[self path] atomically:YES];
}

-(void) add:(id)info as:(BookmarkType)type {
    
    
    NSMutableDictionary *bookmarks = self.bookmarks;
    
    NSMutableArray *target;
    
    switch (type) {
        case BookmarkTypeDocket:
        target = bookmarks[@"Dockets"];
        break;
        case BookmarkTypeDocument: {
            NSString *agency = [info[@"id"] componentsSeparatedByString:@"-"][0];
            
            if(!bookmarks[@"_Documents"][agency]) {
                [bookmarks[@"_Documents"] setObject:[NSMutableArray array] forKey:agency];
            }
            target = bookmarks[@"_Documents"][agency];
        }
        break;
        case BookmarkTypeEntity:
            target = bookmarks[@"Entities"];
            break;
        default:
        
        break;
    }
    
    for(NSDictionary *item in target) {
        if([item[@"id"] isEqualToString:info[@"id"]]) {
            return;
        }
    }
    
    [target addObject:info];
    
    [self sortDocuments];
    
    self.bookmarks = bookmarks; //do this to trigger kv observers
    
    [self write];
}

-(BOOL) delete:(id)info as:(BookmarkType)type {
    
    NSMutableDictionary *bookmarks = self.bookmarks;
    
    NSMutableArray *target;
    
    switch (type) {
        case BookmarkTypeDocket:
        target = bookmarks[@"Dockets"];
        break;
        case BookmarkTypeDocument:{
            NSString *agency = [info[@"id"] componentsSeparatedByString:@"-"][0];
            
            if(!bookmarks[@"_Documents"][agency]) {
                [bookmarks[@"_Documents"] setObject:[NSMutableArray array] forKey:agency];
            }
            target = bookmarks[@"_Documents"][agency];
        }        break;
            
        case BookmarkTypeEntity:
            target = bookmarks[@"Entities"];
        default:
        break;
    }
    
    for(NSDictionary *item in target) {
        if([item[@"id"] isEqualToString:info[@"id"]]) {
            [target removeObject:item];
            [self sortDocuments];
            self.bookmarks = bookmarks; //do this to trigger kv observers
            [self write];
            return TRUE;
        }
    }
    return FALSE;
    
}

-(void) sortDocuments {
    
    if(self.bookmarks[@"Documents"]) {
        [self.bookmarks[@"Documents"] removeAllObjects];
    } else {
        [self.bookmarks setObject:[NSMutableArray array] forKey:@"Documents"];
    }
    
    
    NSMutableDictionary *documents = self.bookmarks[@"_Documents"];
    NSArray *keys = [documents.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for(NSString *key in keys) {
        [self.bookmarks[@"Documents"] addObject:documents[key]];
    }
}

-(NSMutableDictionary *)bookmarks {
    
    if(!_bookmarks) {
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:[self path]]) {
            NSMutableDictionary *primer = [@{@"Dockets": [@[ ] mutableCopy], @"Entities": [@[ ] mutableCopy], @"Documents" : [@[ ] mutableCopy], @"_Documents" : [@{ } mutableCopy]} mutableCopy];
            _bookmarks = primer;
            NSData *data = [NSJSONSerialization dataWithJSONObject:_bookmarks options:NSJSONWritingPrettyPrinted error:nil];
            [data writeToFile:[self path] atomically:YES];
            return _bookmarks;
        }
        
        NSData *data = [NSData dataWithContentsOfFile:[self path]];
        _bookmarks = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    
    return _bookmarks;
}

-(NSString *) path {
    NSURL *url = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    return [url.path stringByAppendingPathComponent:BOOKMARKS_PATH];
}

@end
