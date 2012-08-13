
#import "MagazineGridViewCell.h"


@implementation MagazineGridViewCell
@synthesize downloadButton;

@synthesize imageView, textLabel;

- (void)dealloc
{
	[imageView release];
	[textLabel release];
    [downloadButton release];
    [super dealloc];
}

@end
