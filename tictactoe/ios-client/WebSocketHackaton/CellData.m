//
//  CellData.m
//  WebSocketHackaton
//
//  Created by Michael Seghers on 28/03/13.
//  Copyright (c) 2013 iDA MediaFoundry. All rights reserved.
//

#import "CellData.h"

@implementation CellData

- (id)init
{
    self = [super init];
    if (self) {
        self.color = [UIColor whiteColor];
    }
    return self;
}

- (id)initWithSymbol:(NSString *)symbol
{
    self = [self init];
    if (self) {
        self.symbol = symbol;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[CellData class]]) {
            return [self.symbol isEqual:[object symbol]];
    }
    return NO;
}

@end
