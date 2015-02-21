//
//  TempReaderDocument.h
//  Regs
//
//  Created by Matthew Zorn on 11/24/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import <vfrReader/ReaderDocument.h>

@interface TempReaderDocument : ReaderDocument

@property (nonatomic) BOOL canEmail, canExport, canPrint;

@end
