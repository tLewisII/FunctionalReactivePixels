//
//  FRPGalleryViewController.m
//  FRP
//
//  Created by Ash Furrow on 10/13/2013.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

// View Controllers
#import "FRPGalleryViewController.h"
#import "FRPFullSizePhotoViewController.h"

// Views
#import "FRPCell.h"

// Utilities
#import "FRPGalleryFlowLayout.h"
#import "FRPPhotoImporter.h"

static NSString *CellIdentifier = @"Cell";

@interface FRPGalleryViewController () <FRPFullSizePhotoViewControllerDelegate>

@property (nonatomic, strong) NSArray *photosArray;

@end

@implementation FRPGalleryViewController

- (id)init
{
    FRPGalleryFlowLayout *flowLayout = [[FRPGalleryFlowLayout alloc] init];
    
    self = [self initWithCollectionViewLayout:flowLayout];
    if (!self) return nil;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure self
    self.title = @"Popular on 500px";
    
    // Configure view
    [self.collectionView registerClass:[FRPCell class] forCellWithReuseIdentifier:CellIdentifier];
    
    // Reactive Stuff
    RACSignal *photoSignal = [FRPPhotoImporter importPhotos];
    RACSignal *noErrors = [photoSignal catch:^RACSignal *(NSError *error) {
        NSLog(@"Couldn't fetch photos from 500px: %@", error);
        return [RACSignal empty];
    }];
    RACSignal *photosLoaded = RAC(self, photosArray) = noErrors;
    @weakify(self);
    [photosLoaded subscribeCompleted:^{
        @strongify(self)
        [self.collectionView reloadData];
    }];
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FRPCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell setPhotoModel:self.photosArray[indexPath.row]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

// Note: Can't use rac_signalForSelector: here w/o implementing this method.
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FRPFullSizePhotoViewController *viewController = [[FRPFullSizePhotoViewController alloc] initWithPhotoModels:self.photosArray currentPhotoIndex:indexPath.item];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - FRPFullSizePhotoViewControllerDelegate Methods

-(void)userDidScroll:(FRPFullSizePhotoViewController *)viewController toPhotoAtIndex:(NSInteger)index {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

@end
