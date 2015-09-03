//
//  AsyncServiceCall.m
//  TelstraSampleApp
//
//  Created by Meera on 9/2/15.
//  Copyright (c) 2015 Cognizant. All rights reserved.
//

#import "AsyncServiceCall.h"

@implementation AsyncServiceCall

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
-(void)callRequestBlock:(NSURLRequest*)request
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[[NSOperationQueue alloc] init]
                               completionHandler:^(NSURLResponse *resp, NSData *data, NSError *err) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       
                                       if(err)
                                       {
                                           [delegate failedStatus:err];
                                           
                                       }
                                       else
                                           [self checkService:data];
                                       
                                   });
                               }];
    });
    
}

-(void)checkService:(NSData*)receiveResponse
{
    NSString *responseString= [[NSString alloc] initWithData:receiveResponse encoding:NSISOLatin1StringEncoding];
    NSData *responseData=[responseString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error;
   NSArray *responseKeyValue= [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    if([responseKeyValue count]==0)
    {
        [delegate failedStatus:nil];
        
        
    }
    else
        [delegate receiveSuccessResponse:responseKeyValue];
    
}
@end
