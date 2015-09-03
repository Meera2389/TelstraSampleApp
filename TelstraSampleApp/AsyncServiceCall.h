//
//  AsyncServiceCall.h
//  TelstraSampleApp
//
//  Created by Meera on 9/2/15.
//  Copyright (c) 2015 Cognizant. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol asyncCallProtocol <NSObject>

@optional

-(void)receiveSuccessResponse:(NSArray*)parsedResponse;
-(void)failedStatus:(NSError *)error;
@end

@interface AsyncServiceCall : NSObject

@property(strong,nonatomic)id<asyncCallProtocol>delegate;

-(void)callRequestBlock:(NSURLRequest*)request;

@end
