//
//  ViewController.h
//  TelstraSampleApp
//
//  Created by Meera on 9/2/15.
//  Copyright (c) 2015 Cognizant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncServiceCall.h"
#import "ImageDownloader.h"

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,asyncCallProtocol,ImageDownloaderDelegate>


@end

