//
//  HeroEntity+CoreDataProperties.m
//  
//
//  Created by Newcastle on 02.03.17.
//
//  This file was automatically generated and should not be edited.
//

#import "HeroEntity+CoreDataProperties.h"

@implementation HeroEntity (CoreDataProperties)

+ (NSFetchRequest<HeroEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"HeroEntity"];
}

@dynamic desc;
@dynamic imagePath;
@dynamic name;

@end
