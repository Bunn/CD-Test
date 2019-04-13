
#import "ViewController.h"
#import "CustomObject+CoreDataClass.h"
#import "SecondCustomObject+CoreDataClass.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (nonatomic, strong) NSManagedObjectContext *secondContext;
@property (nonatomic, strong) SecondCustomObject *secondObject;
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 250, 100)];
    [button setTitle:@"Tap here multiple times" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(triggerIssue) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.persistentContainer = appDelegate.persistentContainer;
    
    [self setupConfig];
}

- (void)setupConfig {
    NSManagedObjectContext *firstContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    firstContext.parentContext = self.persistentContainer.viewContext;
    firstContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
    self.secondContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.secondContext.parentContext = firstContext;
    self.secondContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
    self.secondObject = [[SecondCustomObject alloc] initWithContext:self.secondContext];
    self.secondObject.name = @"Name1";
}

//Needs to be triggered 2-3 times for the issue to happen
- (void)triggerIssue {
    [self.secondContext performBlock:^{
        [self.secondContext save:NULL];
        [self.persistentContainer.viewContext performBlock:^{
            [self.persistentContainer.viewContext save:NULL];
            NSLog(@"SAVED");
        }];
    }];
    
    [self.secondContext.parentContext refreshAllObjects];
    [self.secondContext.parentContext save:NULL];
    self.secondObject.name = @"Name2";
    [self print];
}

- (void)print {
    NSArray *result = [self.secondContext executeFetchRequest:SecondCustomObject.fetchRequest error:NULL];
    NSLog(@"Result Count [%lu]", (unsigned long)result.count);
    for (SecondCustomObject *obj in result) {
        NSLog(@"Obj Name [%@]", obj.name);
    }
    NSLog(@"-----");
}


/*
- (CustomObject *)getCustomObject {
    NSNumber *customID = @(222);
    NSFetchRequest *fetchRequest = CustomObject.fetchRequest;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"customID == %@", customID];
    return [[self.persistentContainer.viewContext executeFetchRequest:fetchRequest error:NULL] firstObject];
}

- (void)saveCustomObject {
    CustomObject *customObject = [[CustomObject alloc] initWithContext:self.persistentContainer.viewContext];
    customObject.name = @"TEST";
    customObject.customID = 222;
    [self.persistentContainer.viewContext save:NULL];
    
}
*/

@end
