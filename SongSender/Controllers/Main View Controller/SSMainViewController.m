//
//  SSMainViewController.m
//  SongSender
//
//  Created by Aaron Wojnowski on 2014-05-07.
//  Copyright (c) 2014 Aaron. All rights reserved.
//

#import "SSMainViewController.h"

#import "SSFileManager.h"

@import AVFoundation;
@import MediaPlayer;
@import MessageUI;

@interface SSMainViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *songs;

@end

@implementation SSMainViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    [SSFileManager wipeTemporarySaveDirectory];
    
    [self setTitle:@"SongSender"];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    MPMediaQuery *musicLibrary = [[MPMediaQuery alloc] init];
    [self setSongs:[musicLibrary items]];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [[self view] addSubview:tableView];
    [self setTableView:tableView];
    
}

-(void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    [[self tableView] setFrame:[[self view] bounds]];
    
}

#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self songs] count];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        
    }
    
    MPMediaItem *song = [self songAtIndexPath:indexPath];
    NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
    NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
    
    [[cell textLabel] setText:title];
    [[cell detailTextLabel] setText:artist];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MPMediaItem *song = [self songAtIndexPath:indexPath];
    [self exportMediaItem:song];
    
}

#pragma mark - Helper Methods

-(MPMediaItem *)songAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self songs][[indexPath row]];
    
}

#pragma mark - Song Exporting

-(void)exportMediaItem:(MPMediaItem *)item {
    
    [[self tableView] setUserInteractionEnabled:NO];
    [[self tableView] setAlpha:0.5];
    
    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    NSString *songName = [NSString stringWithFormat:@"%@.m4a",title];
    
    NSURL *url = [item valueForProperty: MPMediaItemPropertyAssetURL];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:songAsset presetName:AVAssetExportPresetAppleM4A];
    [exporter setOutputFileType:@"com.apple.m4a-audio"];
    [exporter setOutputURL:[SSFileManager temporaryFileURLWithName:songName]];
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            [[self tableView] setUserInteractionEnabled:YES];
            [[self tableView] setAlpha:1.0];
            
            AVAssetExportSessionStatus exportStatus = [exporter status];
            switch (exportStatus)
            {
                case AVAssetExportSessionStatusCompleted:
                {
                    NSData *data = [NSData dataWithContentsOfFile:[SSFileManager temporaryFilePathWithName:songName]];
                    
                    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
                    [mailComposeViewController setMailComposeDelegate:self];
                    [mailComposeViewController setSubject:title];
                    [mailComposeViewController addAttachmentData:data mimeType:@"audio/mp4" fileName:songName];
                    [self presentViewController:mailComposeViewController animated:YES completion:nil];
                    
                    [SSFileManager wipeTemporarySaveDirectory];
                    
                    break;
                }
                case AVAssetExportSessionStatusFailed:
                {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:[[exporter error] localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                    
                    break;
                }
                default:
                {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An unknown error occurred." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                    
                    break;
                }
            }
            
        });
        
    }];
    
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
