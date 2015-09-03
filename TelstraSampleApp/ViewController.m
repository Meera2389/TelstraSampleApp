//
//  ViewController.m
//  TelstraSampleApp
//
//  Created by Meera on 9/2/15.
//  Copyright (c) 2015 Cognizant. All rights reserved.
//

#import "ViewController.h"
#import "CustomCell.h"

#define titleHeight 50
#define titleWidth 200

#define syncHeight  40
#define syncWidth   40
#define ktableViewCellPadding 100
#define kDefaultCellHeight 104

@interface ViewController ()
{
    UITableView *detailTableView;
    NSMutableArray *detailArray;
    UIActivityIndicatorView *spinner;
    NSMutableDictionary *imgDict;
    UILabel *title;
    UIButton *sync;
    AsyncServiceCall *async;
}
@property(nonatomic,strong)NSMutableArray *connections;
@property(nonatomic)BOOL waitingForResponse;

@end

@implementation ViewController

@synthesize connections;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    imgDict = [NSMutableDictionary dictionary];
    async=[[AsyncServiceCall alloc]init];
    async.delegate=self;
    title=[[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-titleWidth/2, 10, titleWidth, titleHeight)];
    [self.view addSubview:title];
    sync=[[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-syncWidth, 10, syncWidth, syncHeight)];
    [self.view addSubview:sync];
    self.waitingForResponse = NO;

   
}
-(void)viewWillAppear:(BOOL)animated {
    [self syncClicked];



}
-(void)viewWillDisappear:(BOOL)animated{

    [self clearConnections];

}
-(void)clearConnections
{
    
    
    for(NSURLConnection *connection in self.connections)
        [connection cancel];
    [self.connections removeAllObjects];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self clearConnections];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initializeSpinner
{
    spinner=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    spinner.color=[UIColor blackColor];
    CGRect bounds = [UIScreen mainScreen].bounds;
    spinner.center=CGPointMake(bounds.size.width/2, bounds.size.height/2);
}
-(void)startSpinner
{
    [self.view addSubview:spinner];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [spinner bringSubviewToFront:self.view];
    [spinner startAnimating];
    
}
-(void)stopSpinner{
    [spinner stopAnimating];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [spinner removeFromSuperview];
}
/*----------------------------------------------------------------------------------
 Method Name: reloadBrandsOnScroll
 Parameters:nil
 Descriptions:
 This method reloads the visible cells once the scrolling is done
 return type: nil
 ----------------------------------------------------------------------------------*/

-(void)reloadBrandsOnScroll
{
    NSArray *visiblePaths = [detailTableView indexPathsForVisibleRows];
    
    [detailTableView reloadRowsAtIndexPaths:visiblePaths withRowAnimation:UITableViewRowAnimationNone];
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self reloadBrandsOnScroll];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self reloadBrandsOnScroll];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return [detailArray count];
}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HistoryCell";
    
    // Similar to UITableViewCell, but
    CustomCell *cell = (CustomCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSString *content=[self checkNull:[[detailArray objectAtIndex:indexPath.row] valueForKey:@"description"]];
    cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier :content];
    [detailTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    
    cell.descriptionTitle.text =[self checkNull: [[detailArray objectAtIndex:indexPath.row] valueForKey:@"title"]];
    cell.descriptionText.text=[self checkNull:[[detailArray objectAtIndex:indexPath.row] valueForKey:@"description"]];
    cell.descriptionText.lineBreakMode = NSLineBreakByWordWrapping;
    cell.descriptionText.numberOfLines = 0;
   
    
    NSString *cellId=cell.descriptionTitle.text;
    if([imgDict valueForKey:cellId] == nil){
        
        [cell.indicatorView startAnimating];
        [cell.indicatorView setHidden:NO];

        NSString *imageUrl=[self checkNull:[[detailArray objectAtIndex:indexPath.row] valueForKey:@"imageHref"]];
        
        if (detailTableView.dragging == NO && detailTableView.decelerating == NO && ![imageUrl isEqualToString:@""])
        {
            ImageDownloader *newcall=[[ImageDownloader alloc]init];
            newcall.serviceURL=imageUrl;
            newcall.imgLoad=cell.descriptionImage;
            newcall.delegate=self;
            newcall.imageKey=@"_big.jpg";
            newcall.load=cell.indicatorView;
            newcall.key=cellId;
            [newcall start];
            [self.connections addObject:newcall.imageConnection];
        }
    }
    
    else{
        [cell.indicatorView setHidden:YES];
        [cell.indicatorView stopAnimating];
        UIImage *img = [imgDict valueForKey:cellId];
        [cell.descriptionImage setImage:img];
        
    }
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *content = [self checkNull:[[detailArray objectAtIndex:indexPath.row] valueForKey:@"description"]];
    
    CGSize sizeForHeight = [ViewController findSizeOfString:content andView:tableView andWidth:tableView.frame.size.width];
    
    
    if(sizeForHeight.height+ktableViewCellPadding>kDefaultCellHeight)
        return sizeForHeight.height+ktableViewCellPadding;
    else
        return ktableViewCellPadding;
    
}
-(NSString*)checkNull:(NSString*)value
{
    if([value isEqual:[NSNull null]]){
        value=@"";
    }
    return value;
}
#pragma mark - async delegate method
-(void)receiveSuccessResponse:(NSArray*)parsedResponse
{
    
    [self stopSpinner];
    self.waitingForResponse = false;
    CGRect frame = [UIScreen mainScreen].bounds;

    detailTableView = [[UITableView alloc] initWithFrame:CGRectMake(frame.origin.x, title.frame.size.height+title.frame.origin.y, frame.size.width, frame.size.height-titleHeight) style:UITableViewStylePlain];

    [sync setBackgroundImage:[UIImage imageNamed:@"Download"] forState:UIControlStateNormal];
    [sync addTarget:self action:@selector(syncClicked) forControlEvents:UIControlEventTouchUpInside];
    [sync setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:detailTableView];
    detailTableView.delegate = self;
    detailTableView.dataSource = self;
    

    title.text=[parsedResponse valueForKey:@"title"];
    title.textAlignment = NSTextAlignmentCenter;

    NSArray *arr=[[NSArray alloc]initWithArray:[parsedResponse valueForKey:@"rows"]];
    detailArray=[[NSMutableArray alloc]init];
    for(NSDictionary *dict in arr){
        if(![[self checkNull:[dict objectForKey:@"title"]]isEqualToString:@""]){
           [detailArray addObject:dict];
        }
    }
    [detailTableView reloadData];
}

- (BOOL)shouldAutorotate {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait) {
        CGRect frame = [UIScreen mainScreen].bounds;

        CGRect tableViewFrame = CGRectMake(frame.origin.x, title.frame.size.height+title.frame.origin.y, frame.size.width, frame.size.height-titleHeight);
        detailTableView.frame = tableViewFrame;
        [detailTableView reloadData];
        title.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-100, 10, 200, 50) ;
        sync.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-40, 10, 40, 40);

    }
    else{
        CGRect frame = [UIScreen mainScreen].bounds;

        CGRect tableViewFrame = CGRectMake(frame.origin.x, title.frame.size.height+title.frame.origin.y, 703, self.view.frame.size.height-titleHeight);
        detailTableView.frame = tableViewFrame;
        [detailTableView reloadData];
        title.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-100, 10, 200, 50) ;
        sync.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-40, 10, 40, 40);


    }
    
    return YES;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    if(self.waitingForResponse) {
        NSLog(@"%f",bounds.size.width);
        [spinner removeFromSuperview];
        [self initializeSpinner];
        [self startSpinner];
    }
   
}

-(void)returnImages:(id)imgLoad :(NSString*)key andActivityLoad:(id)activityLoad
{
    if( [imgLoad isKindOfClass:[UIImageView class]])
    {
        UIImageView *imgView=(UIImageView*)imgLoad;
        
        if(imgView.image)
        {
            [imgDict setObject:imgView.image forKey:key];
            [activityLoad stopAnimating];
            [activityLoad setHidden:YES];
        }
        else{
            [activityLoad stopAnimating];
            [activityLoad setHidden:YES];

        }
    }
    
    


}
-(void)syncClicked{
    [self initializeSpinner];
    [self startSpinner];
    self.waitingForResponse = YES;
    NSURL *url= [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/746330/facts.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    [async callRequestBlock:request];
   
    connections=[[NSMutableArray alloc]init];
    

}


+ (CGSize)findSizeOfString:(NSString *)string andView:(UIView *)viewItem andWidth:(CGFloat)width {
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];
    CGSize labelSize = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName :font } context:nil].size;
    return labelSize;
}
@end
