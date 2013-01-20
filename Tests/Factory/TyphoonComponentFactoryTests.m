////////////////////////////////////////////////////////////////////////////////
//
//  JASPER BLUES
//  Copyright 2012 Jasper Blues
//  All Rights Reserved.
//
//  NOTICE: Jasper Blues permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import <SenTestingKit/SenTestingKit.h>
#import "Typhoon.h"

#import "Knight.h"
#import "CampaignQuest.h"
#import "CavalryMan.h"
#import "Champion.h"


static NSString* const DEFAULT_QUEST = @"quest";

@interface TyphoonComponentFactoryTests : SenTestCase
@end

@implementation TyphoonComponentFactoryTests
{
    TyphoonComponentFactory* _componentFactory;
}

- (void)setUp
{
    _componentFactory = [[TyphoonComponentFactory alloc] init];
}

/* ====================================================================================================================================== */
#pragma mark - Dependencies resolved by reference

- (void)test_objectForKey_returns_singleton_with_initializer_dependencies
{

    [_componentFactory register:[TyphoonComponentDefinition withClass:[Knight class]
            initialization:^(TyphoonComponentInitializer* initializer)
            {
                initializer.selector = @selector(initWithQuest:);
                [initializer injectParameterAtIndex:0 withReference:DEFAULT_QUEST];
            }]];

    [_componentFactory register:[TyphoonComponentDefinition withClass:[CampaignQuest class] key:DEFAULT_QUEST]];

    Knight* knight = [_componentFactory componentForType:[Knight class]];

    assertThat(knight, notNilValue());
    assertThat(knight, instanceOf([Knight class]));
    assertThat(knight.quest, notNilValue());

    NSLog(@"Here's the knight: %@", knight);
}

- (void)test_objectForKey_raises_exception_if_reference_does_not_exist
{
    [_componentFactory register:[TyphoonComponentDefinition withClass:[Knight class] key:@"knight"
            initialization:^(TyphoonComponentInitializer* initializer)
            {
                initializer.selector = @selector(initWithQuest:);
                [initializer injectParameterAtIndex:0 withReference:DEFAULT_QUEST];
            }]];

    @try
    {
        Knight* knight = [_componentFactory componentForKey:@"knight"];
        NSLog(@"Knight: %@", knight);
        STFail(@"Should have thrown exception");
    }
    @catch (NSException* e)
    {
        assertThat([e description], equalTo(@"No component matching id 'quest'."));
    }
}

/* ====================================================================================================================================== */
#pragma mark - Dependencies resolved by type

- (void)test_allObjectsForType
{

    [_componentFactory register:[TyphoonComponentDefinition withClass:[Knight class] key:@"knight"
            initialization:^(TyphoonComponentInitializer* initializer)
            {
                [initializer setSelector:@selector(initWithQuest:)];
                [initializer injectParameterNamed:@"quest" withReference:@"quest"];
            }]];

    [_componentFactory register:[TyphoonComponentDefinition withClass:[CavalryMan class] key:@"cavalryMan"]];
    [_componentFactory register:[TyphoonComponentDefinition withClass:[CampaignQuest class] key:@"quest"]];

    assertThat([_componentFactory allComponentsForType:[Knight class]], hasCountOf(2));
    assertThat([_componentFactory allComponentsForType:[CampaignQuest class]], hasCountOf(1));
    assertThat([_componentFactory allComponentsForType:@protocol(NSObject)], hasCountOf(3));
}

- (void)test_objectForType
{

    [_componentFactory register:[TyphoonComponentDefinition withClass:[Knight class] key:@"knight"
            initialization:^(TyphoonComponentInitializer* initializer)
            {
                [initializer setSelector:@selector(initWithQuest:)];
                [initializer injectParameterNamed:@"quest" withReference:@"quest"];
            }]];

    [_componentFactory register:[TyphoonComponentDefinition withClass:[CavalryMan class] key:@"cavalryMan"]];
    [_componentFactory register:[TyphoonComponentDefinition withClass:[CampaignQuest class] key:@"quest"]];

    assertThat([_componentFactory componentForType:[CavalryMan class]], notNilValue());

    @try
    {
        Knight* knight = [_componentFactory componentForType:[Knight class]];
        NSLog(@"Here's the knight: %@", knight);
        STFail(@"Should have thrown exception");
    }
    @catch (NSException* e)
    {
        assertThat([e description], equalTo(@"More than one component is defined satisfying type: 'Knight'"));
    }

    @try
    {
        Knight* knight = [_componentFactory componentForType:[Champion class]];
        NSLog(@"Here's the knight: %@", knight);
        STFail(@"Should have thrown exception");
    }
    @catch (NSException* e)
    {
        assertThat([e description], equalTo(@"No components defined which satisify type: 'Champion'"));
    }
}

- (void)test_objectForKey_returns_singleton_with_property_dependencies_resolved_by_type
{

    [_componentFactory register:[TyphoonComponentDefinition withClass:[Knight class] key:@"knight"
            properties:^(TyphoonComponentDefinition* definition)
            {
                [definition injectProperty:@"quest"];
                [definition setLifecycle:TyphoonComponentLifeCyclePrototype];
            }]];

    [_componentFactory register:[TyphoonComponentDefinition withClass:[CampaignQuest class] key:@"quest"]];

    Knight* knight = [_componentFactory componentForKey:@"knight"];

    assertThat(knight, notNilValue());
    assertThat(knight, instanceOf([Knight class]));
    assertThat(knight.quest, notNilValue());

    NSLog(@"Here's the knight: %@", knight);
}

@end