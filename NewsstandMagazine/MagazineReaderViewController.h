//
//  MagazineReaderViewController.h
//  Magazine
//
//  Created by Gaurav on 07/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MagazineReaderViewController : UIViewController

@property (nonatomic, retain) NSString *pdfFileName;
@property (retain, nonatomic) IBOutlet UIWebView *magazineViewController;

@end
