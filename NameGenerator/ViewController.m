//
//  ViewController.m
//  NameGenerator
//
//  Created by Mike Roebuck on 2/12/14.
//  Copyright (c) 2014 Mike Roebuck. All rights reserved.
//

#import "ViewController.h"
#import "NameGeneratorApi.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, strong) NameGeneratorApi * nameGenerator;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.nameGenerator = [NameGeneratorApi new];
    self.dispatchQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.nameGenerator loadNamesFromCensus];
    });
}
- (IBAction)onGenerateMaleName:(id)sender {
    NSString * firstName = [self.nameGenerator generateMaleFirstName];
    NSString * lastName = [self.nameGenerator generateLastName];
    
    self.firstNameLabel.text = firstName;
    self.lastNameLabel.text = lastName;
    
}
- (IBAction)onGenerateFemaleName:(id)sender {
    NSString * firstName = [self.nameGenerator generateFemalFirstName];
    NSString * lastName = [self.nameGenerator generateLastName];
    
    self.firstNameLabel.text = firstName;
    self.lastNameLabel.text = lastName;
}

@end
