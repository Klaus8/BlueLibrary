
#import "ViewController.h"
#import "LibraryAPI.h"
#import "Album+TableRepresentation.h"

#import "HorizontalScroller.h"
#import "AlbumView.h"


@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, HorizontalScrollerDelegate>
{
    UITableView *dataTable;
    NSArray *allAlbums;
    NSDictionary *currentAlbumData;
    int currentAlbumIndex;
    
    HorizontalScroller *scroller;
    
    UIToolbar *toolbar;
    NSMutableArray *undoStack;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.76f green:0.81f blue:0.87f alpha:1.f];
    currentAlbumIndex = 0;
    
    toolbar = [[UIToolbar alloc]init];
    
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemUndo
                                                                             target:self
                                                                             action:@selector(undoAction)];
    undoItem.enabled = NO;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
    
    UIBarButtonItem *delete = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                           target:self
                                                                           action:@selector(deleteAlbum)];
    
    toolbar.items = @[undoItem, space, delete];
    [self.view addSubview:toolbar];
    
    undoStack = [NSMutableArray array];
    
    
    allAlbums = [[LibraryAPI sharedInstance] getAlbums];
    
    //UITableView (dataTable) который отображает данные альбома
    CGRect frame = CGRectMake(0.f, 120.f, self.view.frame.size.width, self.view.frame.size.height-120.f);
    dataTable = [[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
    dataTable.delegate = self;
    dataTable.dataSource = self;
    dataTable.backgroundView = nil;
    [self.view addSubview:dataTable];
    
    [self loadPreviousState];
    
    //HorizontalScroller (scroller)
    scroller = [[HorizontalScroller alloc]initWithFrame:CGRectMake(0.f, 20.f, self.view.frame.size.width, 120.f)];
    scroller.backgroundColor = [UIColor colorWithRed:0.24f green:0.35f blue:0.49f alpha:1];
    scroller.delegate = self;
    [self.view addSubview:scroller];
    
    [self reloadScroller];
    
    [self showDataForAlbumAtIndex:currentAlbumIndex];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveCurrentState)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}


-(void)viewWillLayoutSubviews
{
    toolbar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    dataTable.frame = CGRectMake(0, 130, self.view.frame.size.width, self.view.frame.size.height - 200);
}


-(void)reloadScroller
{
    allAlbums = [[LibraryAPI sharedInstance]getAlbums];
    if (currentAlbumIndex < 0)
        currentAlbumIndex = 0;
    else if (currentAlbumIndex >= [allAlbums count])
        currentAlbumIndex = [allAlbums count] - 1;
    [scroller reload];
    
    [self showDataForAlbumAtIndex:currentAlbumIndex];
}


-(void)showDataForAlbumAtIndex:(NSUInteger)albumIndex
{
    if (albumIndex < [allAlbums count]) {
        Album *album = allAlbums[albumIndex];
        currentAlbumData = [album tr_tableRepresentation];
    } else {
        currentAlbumData = nil;
    }
    
    [dataTable reloadData];
}


#pragma mark - UITableViewDelegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [currentAlbumData[@"titles"] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1
                                     reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = currentAlbumData[@"titles"][indexPath.row];
    cell.detailTextLabel.text = currentAlbumData[@"values"][indexPath.row];
    return cell;
}

#pragma mark - HorizontalScrollerDelegate methods

-(void)horizontalScroller:(HorizontalScroller *)scroller clickedViewAtIndex:(int)index
{
    currentAlbumIndex = index;
    [self showDataForAlbumAtIndex:index];
}

-(NSUInteger)numberOfViewsForHorizontalScroller:(HorizontalScroller *)scroller
{
    return [allAlbums count];
}

-(UIView *)horizontalScroller:(HorizontalScroller *)scroller viewAtIndex:(int)index
{
    Album *album = allAlbums[index];
    return [[AlbumView alloc]initWithFrame:CGRectMake(0.f, 0.f, 100.f, 100.f) albumCover:album.coverUrl];
}

-(NSInteger)initialViewIndexForHorizontalScroller:(HorizontalScroller *)scroller
{
    return currentAlbumIndex;
}


//Memento pattern

-(void)saveCurrentState
{
    [[NSUserDefaults standardUserDefaults] setInteger:currentAlbumIndex forKey:@"currentAlbumIndex"];
    [[LibraryAPI sharedInstance] saveAlbums];
}

-(void)loadPreviousState
{
    currentAlbumIndex = [[NSUserDefaults standardUserDefaults]integerForKey:@"currentAlbumIndex"];
    [self showDataForAlbumAtIndex:currentAlbumIndex];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addAlbum:(Album *)album atIndex:(int)index
{
    [[LibraryAPI sharedInstance]addAlbum:album atIndex:index];
    currentAlbumIndex = index;
    [self reloadScroller];
}

-(void)deleteAlbum
{
    Album *deleteAlbum = allAlbums[currentAlbumIndex];
    
    NSMethodSignature *sig = [self methodSignatureForSelector:@selector(addAlbum:atIndex:)];
    NSInvocation *undoDeleteAction = [NSInvocation invocationWithMethodSignature:sig];
    [undoDeleteAction setTarget:self];
    [undoDeleteAction setSelector:@selector(addAlbum:atIndex:)];
    [undoDeleteAction setArgument:&deleteAlbum atIndex:2];
    [undoDeleteAction setArgument:&currentAlbumIndex atIndex:3];
    [undoDeleteAction retainArguments];
    
    [undoStack addObject:undoDeleteAction];
    
    [[LibraryAPI sharedInstance]deleteAlbumAtIndex:currentAlbumIndex];
    [self reloadScroller];
    
    [toolbar.items[0] setEnabled:YES];
}

-(void)undoAction
{
    if (undoStack.count > 0) {
        NSInvocation *undoAction = [undoStack lastObject];
        [undoStack removeLastObject];
        [undoAction invoke];
        
        if (undoStack.count == 0) {
            [toolbar.items[0] setEnabled:NO];
        }
    }
}


@end
