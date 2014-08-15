//
//  QuizResultController.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizResultController.h"
#import "QuizSetSelectorController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NumNaoAppDelegate.h"
#import "NumNaoIAPHelper.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "appID.h"

@interface QuizResultController ()

@property (strong, nonatomic) NSDictionary *backLinkInfo;
@property (weak, nonatomic) UIView *backLinkView;
@property (weak, nonatomic) UILabel *backLinkLabel;

@end

@implementation QuizResultController
@synthesize bannerView = bannerView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0, 80.0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
  self.bannerView.adUnitID = MyAdUnitID;
  self.bannerView.delegate = self;
  [self.bannerView setRootViewController:self];
  [self.view addSubview:self.bannerView];
  [self.bannerView loadRequest:[self createRequest]];
  
  [self decorateAllButtonsAndLabel];
  [self checkQuizResult];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  NumNaoAppDelegate *delegate = (NumNaoAppDelegate *)[[UIApplication sharedApplication] delegate];
  if (delegate.refererAppLink) {
    self.backLinkInfo = delegate.refererAppLink;
    [self _showBackLink];
  }
  delegate.refererAppLink = nil;
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  NSString *quizResultString = [self.quizManager quizResultString:self.quizScore];
  [self.quizResultLabel setText:quizResultString];

}

- (GADRequest *)createRequest {
  GADRequest *request = [GADRequest request];
  request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
  return request;
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  [UIView animateWithDuration:1.0 animations:^{
    adView.frame = CGRectMake(0.0, 340.0, adView.frame.size.width, adView.frame.size.height);
  }];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad due to: %@", [error localizedFailureReason]);
}

- (void)checkQuizResult {
  NSInteger quizScoreToUnlock = 3;
  NumNaoIAPHelper *IAPInstance = [NumNaoIAPHelper sharedInstance];
  
  if (self.quizScore >= quizScoreToUnlock) {
    switch (self.quizMode) {
      case NumNaoQuizModeOnAir: {
        // Mode: On air
        if (!IAPInstance.retroCh3Purchased) {
          IAPInstance.retroCh3Purchased = YES;
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ยินดีด้วย !!"
                                                          message:@"เธอปลดล๊อดโหมดละครเก่าช่อง 3 ได้สำเร็จแล้ว !!"
                                                         delegate:nil
                                                cancelButtonTitle:@"ตกลงจ้ะ"
                                                otherButtonTitles:nil];
          [alert show];
        }
      } break;
      
      case NumNaoQuizModeRetroCh3: {
        // Mode: Retro CH 3
        if (!IAPInstance.retroCh5Purchased) {
          IAPInstance.retroCh5Purchased = YES;
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ยินดีด้วย !!"
                                                          message:@"เธอปลดล๊อดโหมดละครเก่าช่อง 5 ได้สำเร็จแล้ว !!"
                                                         delegate:nil
                                                cancelButtonTitle:@"ตกลงจ้ะ"
                                                otherButtonTitles:nil];
          [alert show];
        }
      } break;
        
      case NumNaoQuizModeRetroCh5: {
        // Mode: Retro CH 5
        if (!IAPInstance.retroCh7Purchased) {
          IAPInstance.retroCh7Purchased = YES;
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ยินดีด้วย !!"
                                                          message:@"เธอปลดล๊อดโหมดละครเก่าช่อง 7 ได้สำเร็จแล้ว !!"
                                                         delegate:nil
                                                cancelButtonTitle:@"ตกลงจ้ะ"
                                                otherButtonTitles:nil];
          [alert show];
        }
      } break;
        
      default:
        break;
    }
  }

}

- (void)decorateAllButtonsAndLabel {
  
  // Set the button Text Color
  [self.backToMenuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [self.backToMenuButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
  
  // Draw a custom gradient
  CAGradientLayer *backToMenuBtnGradient = [CAGradientLayer layer];
  backToMenuBtnGradient.frame = self.backToMenuButton.bounds;
  backToMenuBtnGradient.colors = [NSArray arrayWithObjects:
                                  (id)[[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f] CGColor],
                                  (id)[[UIColor colorWithRed:251.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f] CGColor],
                                  nil];
  [self.backToMenuButton.layer insertSublayer:backToMenuBtnGradient atIndex:0];
  
  // Round button corners
  CALayer *backToMenuBtnLayer = [self.backToMenuButton layer];
  [backToMenuBtnLayer setMasksToBounds:YES];
  [backToMenuBtnLayer setCornerRadius:5.0f];
  
  // Apply a 1 pixel, black border around Buy Button
  [backToMenuBtnLayer setBorderWidth:1.0f];
  [backToMenuBtnLayer setBorderColor:[[UIColor blackColor] CGColor]];
  
  
  // Draw a custom gradient for quizLabel
  CAGradientLayer *quizResultGradient = [CAGradientLayer layer];
  quizResultGradient.frame = self.quizResultLabel.bounds;
  quizResultGradient.colors = [NSArray arrayWithObjects:
                               (id)[[UIColor colorWithRed:150.0f / 255.0f green:150.0f / 255.0f blue:150.0f / 255.0f alpha:0.3f] CGColor],
                               (id)[[UIColor colorWithRed:1.0f / 255.0f green:1.0f / 255.0f blue:1.0f / 255.0f alpha:0.3f] CGColor],
                               nil];
  [self.quizResultLabel.layer insertSublayer:quizResultGradient atIndex:0];
  [[self.quizResultLabel layer] setCornerRadius:5.0];
  [[self.shareFacebookButton layer] setCornerRadius:5.0];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToMainMenu:(id)sender {
  [self performSegueWithIdentifier:@"MainMenuSegue" sender:self];
}

- (IBAction)shareOnFacebook:(id)sender {
  
//  [self postStatusUpdateWithShareDialog];
  [self shareLinkWithShareDialog];
//  [self StatusUpdateWithAPICalls];
}

- (void)postStatusUpdateWithShareDialog
{
  
  // Check if the Facebook app is installed and we can present the share dialog
  
  FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
  params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
  
  // If the Facebook app is installed and we can present the share dialog
  if ([FBDialogs canPresentShareDialogWithParams:params]) {
    
    // Present share dialog
    [FBDialogs presentShareDialogWithLink:nil
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                    if(error) {
                                      // An error occurred, we need to handle the error
                                      // See: https://developers.facebook.com/docs/ios/errors
                                      NSLog(@"Error publishing story: %@", error.description);
                                    } else {
                                      // Success
                                      NSLog(@"result %@", results);
                                    }
                                  }];
    
    // If the Facebook app is NOT installed and we can't present the share dialog
  } else {
    // FALLBACK: publish just a link using the Feed dialog
    // Show the feed dialog
    NSMutableDictionary *optionDict = [[NSMutableDictionary alloc] init];
    [optionDict setObject:@"my text zzz" forKey:@"description"];
    [optionDict setObject:@"my text zzz" forKey:@"name"];
    
    
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:optionDict
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                if (error) {
                                                  // An error occurred, we need to handle the error
                                                  // See: https://developers.facebook.com/docs/ios/errors
                                                  NSLog(@"Error publishing story: %@", error.description);
                                                } else {
                                                  if (result == FBWebDialogResultDialogNotCompleted) {
                                                    // User cancelled.
                                                    NSLog(@"User cancelled.");
                                                  } else {
                                                    // Handle the publish feed callback
                                                    NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                    
                                                    if (![urlParams valueForKey:@"post_id"]) {
                                                      // User cancelled.
                                                      NSLog(@"User cancelled.");
                                                      
                                                    } else {
                                                      // User clicked the Share button
                                                      NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                      NSLog(@"result %@", result);
                                                    }
                                                  }
                                                }
                                              }];
  }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
  NSArray *pairs = [query componentsSeparatedByString:@"&"];
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  for (NSString *pair in pairs) {
    NSArray *kv = [pair componentsSeparatedByString:@"="];
    NSString *val =
    [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    params[kv[0]] = val;
  }
  return params;
}

- (IBAction)shareLinkWithShareDialog
{
  
  // Check if the Facebook app is installed and we can present the share dialog
  FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
  params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
  
  // If the Facebook app is installed and we can present the share dialog
 /* if ([FBDialogs canPresentShareDialogWithParams:params]) {
    
    // Present share dialog
    [FBDialogs presentShareDialogWithLink:params.link
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                    if(error) {
                                      // An error occurred, we need to handle the error
                                      // See: https://developers.facebook.com/docs/ios/errors
                                      NSLog(@"Error publishing story: %@", error.description);
                                    } else {
                                      // Success
                                      NSLog(@"result %@", results);
                                    }
                                  }];
    
  }*/
  
    NSMutableDictionary *optionDict = [[NSMutableDictionary alloc] init];
    NSString *scoreStr = [NSString stringWithFormat:@"คุณได้ %ld คะแนน", self.quizScore];
    [optionDict setObject:scoreStr forKey:@"name"];
    [optionDict setObject:@" " forKey:@"caption"];
    [optionDict setObject:@"ท่าทางคุณจะติดละครงอมแงมเลยทีเดียว เอาเวลาไปอ่านหนังสือสอบบ้างนะจ๊ะ" forKey:@"description"];
    [optionDict setObject:@"https://developersx.facebook.com/docs/ios/share/" forKey:@"link"];
    [optionDict setObject:@"http://i.imgur.com/g3Qc1HN.png" forKey:@"picture"];
    
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:optionDict
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                if (error) {
                                                  // An error occurred, we need to handle the error
                                                  // See: https://developers.facebook.com/docs/ios/errors
                                                  NSLog(@"Error publishing story: %@", error.description);
                                                } else {
                                                  if (result == FBWebDialogResultDialogNotCompleted) {
                                                    // User canceled.
                                                    NSLog(@"User cancelled.");
                                                  } else {
                                                    // Handle the publish feed callback
                                                    NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                    
                                                    if (![urlParams valueForKey:@"post_id"]) {
                                                      // User canceled.
                                                      NSLog(@"User cancelled.");
                                                      
                                                    } else {
                                                      // User clicked the Share button
                                                      NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                      NSLog(@"result %@", result);
                                                    }
                                                  }
                                                }
                                              }];
  
}

- (IBAction)StatusUpdateWithAPICalls {
  // We will post on behalf of the user, these are the permissions we need:
  NSArray *permissionsNeeded = @[@"publish_actions"];
  
  // Request the permissions the user currently has
  [FBRequestConnection startWithGraphPath:@"/me/permissions"
                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                          if (!error){
                            NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                            NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                            
                            // Check if all the permissions we need are present in the user's current permissions
                            // If they are not present add them to the permissions to be requested
                            for (NSString *permission in permissionsNeeded){
                              if (![currentPermissions objectForKey:permission]){
                                [requestPermissions addObject:permission];
                              }
                            }
                            
                            // If we have permissions to request
                            if ([requestPermissions count] > 0){
                              // Ask for the missing permissions
                              [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                                                                    defaultAudience:FBSessionDefaultAudienceFriends
                                                                  completionHandler:^(FBSession *session, NSError *error) {
                                                                    if (!error) {
                                                                      // Permission granted, we can request the user information
                                                                      [self makeRequestToUpdateStatus];
                                                                    } else {
                                                                      // An error occurred, handle the error
                                                                      // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                                                      NSLog(@"%@", error.description);
                                                                    }
                                                                  }];
                            } else {
                              // Permissions are present, we can request the user information
                              [self makeRequestToUpdateStatus];
                            }
                            
                          } else {
                            // There was an error requesting the permission information
                            // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                            NSLog(@"%@", error.description);
                          }
                        }];
}

- (void)makeRequestToUpdateStatus {
  
  // NOTE: pre-filling fields associated with Facebook posts,
  // unless the user manually generated the content earlier in the workflow of your app,
  // can be against the Platform policies: https://developers.facebook.com/policy
  
  [FBRequestConnection startForPostStatusUpdate:@"User-generated status update."
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                if (!error) {
                                  // Status update posted successfully to Facebook
                                  NSLog(@"result: %@", result);
                                } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSLog(@"%@", error.description);
                                }
                              }];
}

//------------------Login implementation starts here------------------

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
  // If the user is logged in, they can post to Facebook using API calls, so we show the buttons
 // [_ShareLinkWithAPICallsButton setHidden:NO];
 // [_StatusUpdateWithAPICallsButton setHidden:NO];
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
  // If the user is NOT logged in, they can't post to Facebook using API calls, so we show the buttons
 // [_ShareLinkWithAPICallsButton setHidden:YES];
  //[_StatusUpdateWithAPICallsButton setHidden:YES];
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
  NSString *alertMessage, *alertTitle;
  
  // If the user should perform an action outside of you app to recover,
  // the SDK will provide a message for the user, you just need to surface it.
  // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
  if ([FBErrorUtility shouldNotifyUserForError:error]) {
    alertTitle = @"Facebook error";
    alertMessage = [FBErrorUtility userMessageForError:error];
    
    // This code will handle session closures since that happen outside of the app.
    // You can take a look at our error handling guide to know more about it
    // https://developers.facebook.com/docs/ios/errors
  } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
    alertTitle = @"Session Error";
    alertMessage = @"Your current session is no longer valid. Please log in again.";
    
    // If the user has cancelled a login, we will do nothing.
    // You can also choose to show the user a message if cancelling login will result in
    // the user not being able to complete a task they had initiated in your app
    // (like accessing FB-stored information or posting to Facebook)
  } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
    NSLog(@"user cancelled login");
    
    // For simplicity, this sample handles other errors with a generic message
    // You can checkout our error handling guide for more detailed information
    // https://developers.facebook.com/docs/ios/errors
  } else {
    alertTitle  = @"Something went wrong";
    alertMessage = @"Please try again later.";
    NSLog(@"Unexpected error:%@", error);
  }
  
  if (alertMessage) {
    [[[UIAlertView alloc] initWithTitle:alertTitle
                                message:alertMessage
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
  }
}


//------------------Handling links back to app link launching app------------------

- (void) _showBackLink {
  if (nil == self.backLinkView) {
    // Set up the view
    UIView *backLinkView = [[UIView alloc] initWithFrame:
                            CGRectMake(0, 30, 320, 40)];
    backLinkView.backgroundColor = [UIColor darkGrayColor];
    UILabel *backLinkLabel = [[UILabel alloc] initWithFrame:
                              CGRectMake(2, 2, 316, 36)];
    backLinkLabel.textColor = [UIColor whiteColor];
    backLinkLabel.textAlignment = NSTextAlignmentCenter;
    backLinkLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    [backLinkView addSubview:backLinkLabel];
    self.backLinkLabel = backLinkLabel;
    [self.view addSubview:backLinkView];
    self.backLinkView = backLinkView;
  }
  // Show the view
  self.backLinkView.hidden = NO;
  // Set up the back link label display
  self.backLinkLabel.text = [NSString
                             stringWithFormat:@"Touch to return to %@", self.backLinkInfo[@"app_name"]];
  // Set up so the view can be clicked
  UITapGestureRecognizer *tapGestureRecognizer =
  [[UITapGestureRecognizer alloc] initWithTarget:self
                                          action:@selector(_returnToLaunchingApp:)];
  tapGestureRecognizer.numberOfTapsRequired = 1;
  [self.backLinkView addGestureRecognizer:tapGestureRecognizer];
  tapGestureRecognizer.delegate = self;
}

- (void)_returnToLaunchingApp:(id)sender {
  // Open the app corresponding to the back link
  NSURL *backLinkURL = [NSURL URLWithString:self.backLinkInfo[@"url"]];
  if ([[UIApplication sharedApplication] canOpenURL:backLinkURL]) {
    [[UIApplication sharedApplication] openURL:backLinkURL];
  }
  self.backLinkView.hidden = YES;
}

@end
