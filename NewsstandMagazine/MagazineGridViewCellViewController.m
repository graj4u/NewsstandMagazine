

#import "MagazineGridViewCellViewController.h"
#import "Reachability.h"


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kDOCSFOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
-(NSData*)toJSON;
@end

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}
@end




@interface MagazineGridViewCellViewController ()
@property (nonatomic, retain) NSArray *names;
@end


@implementation MagazineGridViewCellViewController

@synthesize downloadBtn;
@synthesize bView,json;
@synthesize hud = _hud;

@synthesize gridView, gridViewCellContent, names;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = @"Loading...";
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:20.0];
    
    if(![[self navigationController] isNavigationBarHidden])
	{
		[self.navigationController setNavigationBarHidden:YES animated:NO];
	}
    
    NSString *completeURLStr = [NSString stringWithFormat:@"http://api.nxtsys.com/magazine.php"];
    
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString:completeURLStr]];
        if (data !=nil) {
            [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
        }
        else {
            [self dismissHUD:nil];
        }
        
    });
    
	gridView.dataSource = self;
    gridView.delegate = self;
	[gridView reloadData];
    
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath    = [rootPath stringByAppendingPathComponent:@"channelList.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
		NSLog(@"File alreay exist.....");
	}
    else{
        NSLog (@"File not found...");
    }
    
}

- (void)fetchedData:(NSData *)responseData
{
    //parse out the json data
    NSError* error;
    json = [NSJSONSerialization JSONObjectWithData:responseData //1
                                           options:kNilOptions
                                             error:&error];
    //NSLog(@"JSON :->%@",json);
    NSLog(@"JSON Value :->%@",[json valueForKey:@"magazines"]);
    
    self.names = [json valueForKey:@"magazines"];
    
    [self.gridView reloadData];
    [self dismissHUD:nil];
}


- (NSUInteger)numberOfItemsInGridView:(AQGridView *)aGridView
{
    return [names count];
}

- (AQGridViewCell *)gridView:(AQGridView *)aGridView cellForItemAtIndex:(NSUInteger)index
{
	static NSString *CellIdentifier = @"MagazineGridViewCell";
	
	AQGridViewCell *cell = (AQGridViewCell *)[gridView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		[[NSBundle mainBundle] loadNibNamed:@"MagazineGridViewCell" owner:self options:nil];
        
		cell = [[[AQGridViewCell alloc] initWithFrame:gridViewCellContent.frame
									  reuseIdentifier:CellIdentifier] autorelease];
		[cell.contentView addSubview:gridViewCellContent];
		
		cell.selectionStyle = AQGridViewCellSelectionStyleNone;
        self.bView.layer.cornerRadius = 5;
        self.bView.layer.masksToBounds = YES;
	}
	
	MagazineGridViewCell *content = (MagazineGridViewCell *)[cell.contentView viewWithTag:1];
	NSString *name = [[names objectAtIndex:index] valueForKey:@"title"];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[names objectAtIndex:index] valueForKey:@"coverURL"]]]];
    
    NSString *fileName = [[[names objectAtIndex:index] valueForKey:@"downloadURL"] lastPathComponent];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",kDOCSFOLDER,fileName];
    NSLog(@"File Name is:--->%@",filePath);
    NSFileManager *filemgr;
    filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:filePath] == YES) {
        NSLog (@"File exists at specific path...");
        [self.downloadBtn setTitle:@"Open" forState:UIControlStateNormal];
        [self.downloadBtn addTarget:self
                             action:@selector(openBook:)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        NSLog (@"File not found Display title to button in grid view");
        NSString *magStatus = [[names objectAtIndex:index] valueForKey:@"free"];
        if ([magStatus isEqualToString:@"YES"]) {
            [self.downloadBtn setTitle:@"Free" forState:UIControlStateNormal];
            [self.downloadBtn addTarget:self
                                 action:@selector(downloadBookFromServer:)
                       forControlEvents:UIControlEventTouchUpInside];
            
        }
        else {
            [self.downloadBtn setTitle:@"Purchase" forState:UIControlStateNormal];
            [self.downloadBtn addTarget:self
                                 action:@selector(purchaseBookFromStore:)
                       forControlEvents:UIControlEventTouchUpInside];
        }
    }
    self.downloadBtn.tag = index;
    
    //NSString *imageName = [[name lowercaseString] stringByAppendingString:@".png"];
    if (image != nil) {
        content.imageView.image = image;
    }
    else {
        content.imageView.image = [UIImage imageNamed:@"no-image.png"];
    }
    content.textLabel.text = name;
    
    return cell;
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)aGridView
{
    [[NSBundle mainBundle] loadNibNamed:@"MagazineGridViewCell" owner:self options:nil];
    return gridViewCellContent.frame.size;
}

- (void) gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index {
    
    //Get the cell at the selected index
    
}


#pragma mark -
#pragma mark - HUD

- (void)dismissHUD:(id)arg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.hud = nil;
    
}

- (void)timeout:(id)arg
{
    //Disclaimer!\nActual position of stations may vary on map. We're improving map for better result
    _hud.labelText = @"Warning!";
    _hud.detailsLabelText = @"Request Timeout ";
    _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"golf.png"]];
    _hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:1.0];
    
}

- (void)dealloc
{
    [gridView release];
    [gridViewCellContent release];
    [names release];
    [bView release];
    [downloadBtn release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setBView:nil];
    [self setDownloadBtn:nil];
    [super viewDidUnload];
}

-(void)purchaseBookFromStore:(id)sender {
    NSLog(@"Purchase Book From Store.......");
    UIButton *button = (UIButton *)sender;
    int row = button.tag;
    NSLog(@"Index of button:%d",row);
}

-(void)openBook:(id)sender {
    NSLog(@"Open Book........");
    UIButton *button = (UIButton *)sender;
    int row = button.tag;
    NSLog(@"Index of button:%d",row);
    NSString *fileName = [[[names objectAtIndex:row] valueForKey:@"downloadURL"] lastPathComponent];
    [self loadPDFFile:fileName];
}

-(void)downloadBookFromServer:(NSInteger)sender {
    NSLog(@"Download Book From Server.........");
    UIButton *button = (UIButton *)sender;
    int row = button.tag;
    NSLog(@"Index of button:%d",row);
    CGPoint position = button.frame.origin;
    NSString *downloadURlStr= [[names objectAtIndex:row] valueForKey:@"downloadURL"];
    
    bar = [[UIDownloadBar alloc] initWithURL:[NSURL URLWithString:downloadURlStr]
                            progressBarFrame:CGRectMake(position.x+12, position.y-5, 120, 20)
                                     timeout:15
                                    delegate:self];
    [self.view addSubview:bar];
    
}

#pragma mark -
#pragma mark - PDF REDER

- (void)loadPDFFile:(NSString *)pdfFile
{
    NSString *pdfFilePath = [kDOCSFOLDER stringByAppendingPathComponent:pdfFile];
    NSLog(@"%s", __FUNCTION__);
    PDFViewerViewController *loadPdfController =[[PDFViewerViewController alloc] init];
    //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loadPdfController];
    loadPdfController.fNamePath = pdfFilePath;
    [self.navigationController pushViewController:loadPdfController animated:YES];
    [loadPdfController release];
    
}


#pragma mark -
#pragma mark Downloaded

- (void)downloadBar:(UIDownloadBar *)downloadBar didFinishWithData:(NSData *)fileData suggestedFilename:(NSString *)filename {
    NSLog(@"Did Finis hWith Data %@", filename);
    //[self loadPDFFile:filename];
    [self.gridView reloadData];
}

- (void)downloadBar:(UIDownloadBar *)downloadBar didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)downloadBarUpdated:(UIDownloadBar *)downloadBar {
}




@end
