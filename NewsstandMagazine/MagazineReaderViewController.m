//
//  MagazineReaderViewController.m
//  Magazine
//
//  Created by Gaurav on 07/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MagazineReaderViewController.h"

@interface MagazineReaderViewController ()

@end

@implementation MagazineReaderViewController

@synthesize pdfFileName;
@synthesize magazineViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSLog(@"PDF File Name is :-->%@",self.pdfFileName);
}

- (void)viewDidUnload
{
    [self setMagazineViewController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [magazineViewController release];
    [super dealloc];
}
@end
