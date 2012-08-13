

#import "AQGridView.h"
#import "MagazineGridViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "MagazineReaderViewController.h"
#import "UIDownloadBar.h"

@interface MagazineGridViewCellViewController : UIViewController <AQGridViewDataSource,AQGridViewDelegate,UIDownloadBarDelegate> {
    MBProgressHUD *_hud;
    UIDownloadBar *bar;
}

@property (nonatomic, retain) IBOutlet AQGridView *gridView;
@property (nonatomic, retain) IBOutlet MagazineGridViewCell *gridViewCellContent;
@property (retain, nonatomic) IBOutlet UIView *bView;
@property (retain) MBProgressHUD *hud;
@property (retain, nonatomic) NSDictionary* json;
@property (retain, nonatomic) IBOutlet UIButton *downloadBtn;

- (IBAction)downloadFileFromServer:(id)sender;

@end

