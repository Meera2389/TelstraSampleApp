//
//  CustomCell.m
//  TelstraSampleApp
//
//  Created by Meera on 9/2/15.
//  Copyright (c) 2015 Cognizant. All rights reserved.
//

#import "CustomCell.h"

#define DescriptionTitleHeight 20
#define DescriptionImageHeight 50
#define DescriptionIndicatorHeight 40
#define ImagePadding 80

@implementation CustomCell
@synthesize descriptionTitle;
@synthesize descriptionImage;
@synthesize descriptionText;
@synthesize indicatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier :(NSString *) content
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //configure view
        [self setBackgroundColor:[UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0]];
        [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44.0)];
        
        // configure control(s)
        self.descriptionTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, 300, DescriptionTitleHeight)];
        self.descriptionTitle.textColor = [UIColor colorWithRed:66.0/255.0 green:41.0/255.0 blue:161.0/255.0 alpha:1.0];
        self.descriptionTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
        
        CGSize size = [self findMessgeStringHeight:content];

        self.descriptionImage=[[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-ImagePadding,  self.descriptionTitle.frame.size.height+40, DescriptionImageHeight, DescriptionImageHeight)];
        [self addSubview:self.descriptionImage];
        
        self.descriptionText=[[UILabel alloc]initWithFrame:CGRectMake(self.descriptionTitle.frame.origin.x, ImagePadding/2, [UIScreen mainScreen].bounds.size.width-(self.descriptionImage.frame.size.width+ImagePadding/2), size.height)];
        self.descriptionText.textColor = [UIColor blackColor];
        self.descriptionText.font = [UIFont fontWithName:@"Helvetica" size:12.0f];

        self.indicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-ImagePadding, self.descriptionText.frame.origin.y, DescriptionIndicatorHeight, DescriptionIndicatorHeight)];
        [self.indicatorView setHidden:YES];
        [self.indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        
        [self addSubview:self.descriptionTitle];
        [self addSubview:self.descriptionText];
        [self addSubview:self.indicatorView];

    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (CGSize)findMessgeStringHeight :(NSString *)message
{
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:message attributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:12.0f] }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){225, MAXFLOAT}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize requiredSize = rect.size;
    
    return requiredSize; //finally u return your height
}

@end
