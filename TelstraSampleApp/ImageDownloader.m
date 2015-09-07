

#import "ImageDownloader.h"

@interface ImageDownloader ()
@property (nonatomic, strong) NSMutableData *activeDownload;

@end


@implementation ImageDownloader
@synthesize imgLoad,serviceURL,key,load,delegate,imageKey;
@synthesize imageConnection;

/*----------------------------------------------------------------------------------
 Method Name: start
 Parameters:nil
 Descriptions:
 This method start the async call for downloading the image . Once the image is downloaded
 it is set to the imageview object in imgLoad.
 
 return type: nil
 ----------------------------------------------------------------------------------*/
- (void)start
{
    async=[[AsyncServiceCall alloc]init];
    
    NSURL *url=[[NSURL alloc]initWithString:self.serviceURL];
    NSURLRequest *req=[[NSURLRequest alloc]initWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    self.imageConnection=connection;
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
    
    
}

#pragma marks -delegate methods Nsurlconnection

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
   
    
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    return nil;
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
    [self serviceLoaded:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self serviceLoaded:self.activeDownload];

}
/*----------------------------------------------------------------------------------
 Method Name: serviceLoaded
 Parameters: NSData
 Descriptions:
 This method will recieve the image nsdata and will convert to UIImage . The UIImage
 is in turn set to the UIImageView object in img.Load .
 return type: nil
 ----------------------------------------------------------------------------------*/
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

@end

