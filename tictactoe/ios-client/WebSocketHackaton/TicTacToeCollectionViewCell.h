//
//  TicTacToeCollectionViewCell.h
//  WebSocketHackaton
//
//  Created by Michael Seghers on 18/03/13.
//  Copyright (c) 2013 iDA MediaFoundry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TicTacToeCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (assign, nonatomic) BOOL filledIn;

@end
