//
//  CellData.h
//  WebSocketHackaton
//
//  Created by Michael Seghers on 28/03/13.
//  Copyright (c) 2013 iDA MediaFoundry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellData : NSObject

@property(nonatomic, strong) UIColor *color;
@property(nonatomic, strong) NSString *symbol;

- (id) initWithSymbol:(NSString *) symbol;

@end
