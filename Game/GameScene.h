//
//  GameScene.h
//  Game
//
//  Created by Rohith Raju on 2/11/17.
//  Copyright © 2017 Rohith Raju. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
@interface GameScene : SKScene<SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end
