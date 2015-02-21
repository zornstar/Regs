//
//  DocumentManager.h
//  Regs
//
//  Created by Matthew Zorn on 11/28/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DocumentSortType) {
    DocumentSortTypeDocket,
    DocumentSortTypeAlpha,
    DocumentSortTypeDate
};


@interface DocumentManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *documents;
@property (nonatomic) BOOL needsUpdate;

+ (instancetype) sharedManager;
- (NSArray *) documentsSortedBy:(DocumentSortType)type;
- (void) save:(id)info;
- (void) delete:(id)info;
- (NSMutableDictionary *)getDocumentById:(NSString *)_id;
@end
