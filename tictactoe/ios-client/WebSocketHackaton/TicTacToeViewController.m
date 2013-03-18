//
//  TicTacToeViewController.m
//  WebSocketHackaton
//
//  Created by Michael Seghers on 6/03/13.
//  Copyright (c) 2013 iDA MediaFoundry. All rights reserved.
//

#import "TicTacToeViewController.h"
#import "SocketRocket/SRWebSocket.h"
#import "TicTacToeCollectionViewCell.h"

#define IAM_P1_WAITING @"p1"
#define P2_JOINED @"p2"
#define IAM_P2 @"p3"

@interface TicTacToeViewController () {
    SRWebSocket *_socket;
    NSString *_symbol;
    NSString *_otherSymbol;
    BOOL _myTurn;
}

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

#define MR_CHALK_BIG ([UIFont fontWithName:@"MrChalk" size:50.0])
#define MR_CHALK_NORMAL ([UIFont fontWithName:@"MrChalk" size:17.0])

@implementation TicTacToeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:@"ws://ec2-54-242-90-129.compute-1.amazonaws.com:80/tictactoeserver/endpoint"];
    //NSURL *url = [NSURL URLWithString:@"ws://localhost:8080/tictactoeserver/endpoint"];
    
    _socket = [[SRWebSocket alloc] initWithURL:url];
    _socket.delegate = self;
    [_socket open];
    
    self.titleLabel.font = MR_CHALK_BIG;
    self.statusLabel.font = MR_CHALK_NORMAL;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SocketRocket WebSocket delegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Received message via WebSocket: %@", message);
    if ([IAM_P1_WAITING isEqualToString:message]) {
        //I am player one and have to wait for P2 to arive
        self.statusLabel.text = @"Waiting for player 2...";
    } else if ([message hasPrefix:P2_JOINED]) {
        //I am player one and P2 Joined
        self.statusLabel.text = @"Player 2 joined! You play O";
        _symbol = @"o";
        _otherSymbol = @"x";
        _myTurn = YES;
    } else if ([IAM_P2 isEqualToString:message]) {
        self.statusLabel.text = @"You joined a game! You play X";
        _symbol = @"x";
        _otherSymbol = @"o";
        _myTurn = NO;
    } else if ([message hasPrefix:@"om"]) {
        //o is played by other player (well should), put this on board
        int position = [[message substringFromIndex:2] intValue];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:position inSection:0];
        TicTacToeCollectionViewCell *cell = (TicTacToeCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
        [self setSymbol:_otherSymbol forCell:cell];
        _myTurn = YES;
    } else {
        NSLog(@"Receive message %@, but did nothing with it", message);
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"The WebSocket has been opened!");
    //Unblock user interaction
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"WebSocket failed: %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"WebSocket was closed with code %d and reason %@ (%@)", code, reason, wasClean ? @"CLEAN" : @"UNCLEAN") ;
}

#pragma mark - Collection view datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TicTacToeCollectionViewCell *cell = (TicTacToeCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ButtonCell" forIndexPath:indexPath];
    
    cell.textLabel.font = MR_CHALK_BIG;
    
    return cell;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_myTurn) {
    TicTacToeCollectionViewCell *cell = (TicTacToeCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
    if ([self setSymbol:_symbol forCell:cell]) {
        _myTurn = NO;
        NSString *message = [NSString stringWithFormat:@"pm %d", indexPath.row];
        [_socket send:message];        
    }
    } else {
        self.statusLabel.text = @"Wait for the other player to make a move...";
    }
}

- (BOOL) setSymbol:(NSString *) symbol forCell:(TicTacToeCollectionViewCell *) cell {
    BOOL result;
    if (!cell.filledIn) {
        cell.textLabel.text = [symbol uppercaseString];
        cell.filledIn = YES;
        result = YES;
    } else {
        NSLog(@"You don't fool me!");
        result = NO;
    }
    return result;
}

@end
