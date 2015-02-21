//
//  BookmarkManager.h
//  Regs
//
//  Created by Matthew Zorn on 11/25/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BookmarkType) {
    BookmarkTypeDocket = 0,
    BookmarkTypeDocument,
    BookmarkTypeEntity
};

@interface BookmarkManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *bookmarks;
@property (nonatomic) BOOL needsUpdate;

+ (instancetype) sharedManager;
- (void) write;
- (void) add:(id)info as:(BookmarkType)type;
- (BOOL) delete:(id)info as:(BookmarkType)type;

@end
