/*
 File: IconDownloader.m
 Abstract: Helper object for managing the downloading of a particular app's icon.
 As a delegate "NSURLConnectionDelegate" is downloads the app icon in the background if it does not
 yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 
 Version: 1.4
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "ImageDownloader.h"

@interface ImageDownloader ()
@property (nonatomic, strong) NSMutableData *activeDownload;

@end


@implementation ImageDownloader
@synthesize imgLoad,serviceURL,key,load,delegate,imageKey;
@synthesize imageConnection;
- (void)start
{
    async=[[AsyncServiceCall alloc]init];
//    NSString *urlString=[self.serviceURL stringByAppendingString:[NSString stringWithFormat:@"%@",self.imageKey]];

    NSLog(@"the image url :%@",self.serviceURL);

                NSURL *url=[[NSURL alloc]initWithString:self.serviceURL];
                NSURLRequest *req=[[NSURLRequest alloc]initWithURL:url];
                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
                self.imageConnection=connection;
        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [connection start];
    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[[NSOperationQueue alloc] init]
//                           completionHandler:^(NSURLResponse *resp, NSData *data, NSError *err) {
//                               dispatch_async(dispatch_get_main_queue(), ^{
//                                   
//                                   [self serviceLoaded:data];
//                                   
//                               });
//                           }];
    }


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
   
    
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    return nil;
}


-(void)serviceLoaded:(NSData*)data
{
    if(data){
    
        // Set appIcon and clear temporary data/image
    
    if( [self.imgLoad isKindOfClass:[UIImageView class]])
        {
        
            UIImage *image = [[UIImage alloc] initWithData:data];

            if( [self.imgLoad isKindOfClass:[UIImageView class]])
                {
                UIImageView *imgView=(UIImageView*)self.imgLoad;
                [imgView setImage:image];
                
                }   
            else
                {
                UIButton *btnView=(UIButton*)self.imgLoad;
                [btnView setBackgroundImage:image forState:UIControlStateNormal];
                }

        
        }

    }
    [delegate returnImages:self.imgLoad :self.key andActivityLoad:self.load];

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.activeDownload = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error in image accessing is %@",error.description);
    [self serviceLoaded:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self serviceLoaded:self.activeDownload];

}
#pragma mark NSOperation Specific Methods

-(NSData*)returnImageData:(NSDictionary *)resultData
{
    NSDictionary *tempDic = [resultData valueForKey:@""];
    
    NSArray *base64Image = [tempDic valueForKey:imageKey];
    
    return [ImageDownloader bytearraytoimage:base64Image];
}
+(NSData*)bytearraytoimage:(NSArray*)byteArray
{
    
    unsigned c = byteArray.count;
    uint8_t *bytes = malloc(sizeof(*bytes) * c);
    
    unsigned i;
    for (i = 0; i < c; i++)
    {
        NSString *str = [byteArray objectAtIndex:i];
        int byte = [str intValue];
        bytes[i] = byte;
    }
    
    NSData *imageData = [NSData dataWithBytesNoCopy:bytes length:c freeWhenDone:YES];
    return imageData;
}
-(BOOL)dataIsValidJPEG:(NSData *)data
{
    
    //Due to less connectivity, some image data not received fully and they are corrupted. This functions checks for it .
    if (!data || data.length < 2) return NO;
    
    NSInteger totalBytes = data.length;
    const char *bytes = (const char*)[data bytes];
    
    return (bytes[0] == (char)0xff &&
            bytes[1] == (char)0xd8 &&
            bytes[totalBytes-2] == (char)0xff &&
            bytes[totalBytes-1] == (char)0xd9);
}
@end

