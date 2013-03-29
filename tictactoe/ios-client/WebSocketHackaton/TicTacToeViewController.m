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
#import "CellData.h"

#define IAM_P1_WAITING @"p1"
#define P2_JOINED @"p2"
#define IAM_P2 @"p3"

@interface TicTacToeViewController () {
    SRWebSocket *_socket;
    NSString *_symbol;
    NSString *_otherSymbol;
    BOOL _myTurn;
    NSMutableArray *board;
}

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIButton *startGameButton;
- (IBAction)startGameTouched:(id)sender;

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
    //NSURL *url = [NSURL URLWithString:@"ws://ec2-54-242-90-129.compute-1.amazonaws.com:80/tictactoeserver/endpoint"];
    
    
    self.titleLabel.font = MR_CHALK_BIG;
    self.statusLabel.font = MR_CHALK_NORMAL;
    self.startGameButton.titleLabel.font = MR_CHALK_NORMAL;
    self.statusLabel.hidden = YES;
}

- (void) startGame {
    NSURL *url = [NSURL URLWithString:@"ws://localhost:8080/tictactoeserver/endpoint"];
    
    _socket = [[SRWebSocket alloc] initWithURL:url];
    _socket.delegate = self;
    [_socket open];
    
    self.statusLabel.hidden = NO;
    self.startGameButton.hidden = YES;
    [self resetCells];
}

- (UIColor *) cellColorWithData:(id) data {
    if (data == [NSNull null]) {
        return [UIColor whiteColor];
    } else if ([[data symbol] isEqualToString:_symbol]) {
        return [UIColor greenColor];
    } else {
        return [UIColor redColor];
    }
}

- (void) detectWinner {
    CellData *data;
    UIColor *color;
    
    for (int i = 0; i < 3; i++) {
        if ([board[i][0] isEqual:board[i][1]] && [board[i][1] isEqual:board[i][2]]) {
            color = [self cellColorWithData:board[i][0] ];
            for (int j = 0; j < 3; j++) {
                data = board[i][j];
                data.color = color;
            }
            [self.collectionView reloadData];
            return;
        }
    }
    
    //Check columns
    for (int i = 0; i < 3; i++) {
        if ([board[0][i] isEqual:board[1][i]] && [board[1][i]  isEqual:board[2][i]]) {
            color = [self cellColorWithData:board[0][i] ];
            for (int j = 0; j < 3; j++) {
                data = board[j][i];
                data.color = color;
            }
            [self.collectionView reloadData];
            return;
        }
    }
    
    
    
    if ([board[0][0] isEqual:board[1][1]] && [board[1][1] isEqual:board[2][2]]) {
        color = [self cellColorWithData:board[0][0] ];
        for (int i = 0; i < 3; i++) {
            data = board[i][i];
            data.color = color;
        }
        [self.collectionView reloadData];
        return;
    }
    
    
    if ([board[0][2] isEqual:board[1][1]] && [board[1][1] isEqual:board[2][0]]) {
        color = [self cellColorWithData:board[0][2] ];
        for (int i = 0; i < 3; i++) {
            data = board[i][2 - i];
            data.color = color;
        }
        [self.collectionView reloadData];
        return;
    }
    
    
    
}

- (BOOL) isFull {
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            if (board[i][j] == [NSNull null]) {
                return NO;
            }
        }
    }
    return YES;
}

- (void) resetCells {
    if (!board) {
        board = [NSMutableArray arrayWithCapacity:3];
    }
    
    for (int i = 0; i < 3; i++) {
        NSMutableArray *cols;
        if (board.count <= i) {
            cols = [NSMutableArray arrayWithCapacity:3];
            board[i] = cols;
        } else {
            cols = board[i];
        }
        
        for (int j = 0; j < 3; j++) {
            cols[j] = [NSNull null];
        }
    }
    [self.collectionView reloadData];
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
        int row = position / 3;
        int col = fmod(position, 3);
        board[row][col] = [[CellData alloc] initWithSymbol:_otherSymbol];
        [self.collectionView reloadData];
        _myTurn = YES;
        self.statusLabel.text = @"Your oppenent made his move.";
    } else if ([message hasPrefix:@"p4"]) {
        [self detectWinner];
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
    self.statusLabel.text = @"Game closed";
    self.statusLabel.hidden = YES;
    self.startGameButton.hidden = NO;
    
    if ([self isFull]) {
        UIColor *color = [UIColor redColor];
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                [board[i][j] setColor:color];
            }
            
        }
        [self.collectionView reloadData];
    }
}

#pragma mark - Collection view datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TicTacToeCollectionViewCell *cell = (TicTacToeCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ButtonCell" forIndexPath:indexPath];
    
    cell.textLabel.font = MR_CHALK_BIG;
    cell.textLabel.textColor = [UIColor whiteColor];
    int row = indexPath.row / 3;
    int col = fmod(indexPath.row, 3);
    if (board[row][col] == [NSNull null]) {
        cell.textLabel.text = nil;
    } else {
        CellData *cellData = board[row][col];
        
        cell.textLabel.text = cellData.symbol;
        cell.textLabel.textColor = cellData.color;
    }
    
    return cell;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_myTurn) {
        int row = indexPath.row / 3;
        int col = fmod(indexPath.row, 3);
        if (board[row][col] == [NSNull null]) {
            board[row][col] = [[CellData alloc] initWithSymbol:_symbol];
            [self.collectionView reloadData];
            NSString *message = [NSString stringWithFormat:@"pm %d", indexPath.row];
            [_socket send:message];
            _myTurn = NO;
        }
    } else {
        self.statusLabel.text = @"Wait for the other player to make a move...";
    }
}


- (IBAction)startGameTouched:(id)sender {
    [self startGame];
}
@end
