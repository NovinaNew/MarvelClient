//
//  HeroEntity+CoreDataProperties.h
//  
//
//  Created by Newcastle on 01.03.17.
//
//  This file was automatically generated and should not be edited.
//

#import "HeroEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface HeroEntity (CoreDataProperties)

+ (NSFetchRequest<HeroEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *desc;
@property (nullable, nonatomic, copy) NSString *imagePath;
@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
