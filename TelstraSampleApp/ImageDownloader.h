

#import <Foundation/Foundation.h>
#import "AsyncServiceCall.h"
#import <UIKit/UIKit.h>


@protocol ImageDownloaderDelegate <NSObject>

@optional

-(void)returnImages:(id)imgLoad :(NSString*)key andActivityLoad:(id)activityLoad;

@end
@interface ImageDownloader : NSObject

{
    AsyncServiceCall *async;
}
@property(strong,nonatomic)id imgLoad;
@property(strong,nonatomic) UIActivityIndicatorView *load;
@property(strong,nonatomic)NSString *serviceURL;
@property(strong,nonatomic)NSString *key;
@property(strong,nonatomic)NSString *imageKey;

@property(weak,nonatomic)id<ImageDownloaderDelegate> delegate;
@property (nonatomic, strong)   NSURLConnection *imageConnection;

- (void)start;
@end
