//
//  CustomCell.h
//  TelstraSampleApp
//
//  Created by Meera on 9/2/15.
//  Copyright (c) 2015 Cognizant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property (nonatomic, strong) UILabel *descriptionTitle;
@property(nonatomic,strong) UIImageView *descriptionImage;
@property(nonatomic,strong) UILabel *descriptionText;
@property(nonatomic,strong) UIActivityIndicatorView *indicatorView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier :(NSString *) content;

@end
