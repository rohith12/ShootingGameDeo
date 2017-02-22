//
//  GameScene.m
//  Game
//
//  Created by Rohith Raju on 2/11/17.
//  Copyright © 2017 Rohith Raju. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene {
//    SKShapeNode *_spinnyNode;
//    SKLabelNode *_label;

}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // 2
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // 3
        self.backgroundColor = [SKColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7];
        
        // 4
//        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"home"];
//        SKCropNode *cropNode = [[SKCropNode alloc] init];
//        cropNode.maskNode = [[SKSpriteNode alloc] initWithImageNamed:@"cockpitMask"];
//        [cropNode addChild: sceneContentNode];
//        [self addChild:cropNode];
//        self.player.position = CGPointMake(100, 100);
//        [self addChild:self.player];
        
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"home"];

        SKSpriteNode *mask = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size: CGSizeMake(100, 100)]; //100 by 100 is the size of the mask
        SKCropNode *cropNode = [SKCropNode node];
        [cropNode setMaskNode: mask];
        [self addChild: cropNode];
        cropNode.position = CGPointMake( CGRectGetMidX (self.frame), CGRectGetMidY (self.frame));
//        self.player.position = CGPointMake( CGRectGetMidX (self.frame), CGRectGetMidY (self.frame));

        [cropNode addChild:  self.player ];

        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}
-(void)setMask{
    
    SKCropNode *cropNode = [[SKCropNode alloc] init];
    
    SKShapeNode *circleMask = [[SKShapeNode alloc ]init];
    CGMutablePathRef circle = CGPathCreateMutable();
    CGPathAddArc(circle, NULL, CGRectGetMidX(self.frame), CGRectGetMidY(self.frame), 50, 0, M_PI*2, YES); // replace 50 with HALF the desired radius of the circle
    circleMask.path = circle;
    circleMask.lineWidth = 100; // replace 100 with DOUBLE the desired radius of the circle
    circleMask.strokeColor = [SKColor whiteColor];
    circleMask.name=@"circleMask";
    
    [cropNode setMaskNode:circleMask];
    
}


- (void)addMonster {
    
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size]; // 1
    monster.physicsBody.dynamic = YES; // 2
    monster.physicsBody.categoryBitMask = monsterCategory; // 3
    monster.physicsBody.contactTestBitMask = projectileCategory; // 4
    monster.physicsBody.collisionBitMask = 0; // 5
    // Determine where to spawn the monster along the Y axis
    int minY = monster.size.height / 2;
    int maxY = self.frame.size.height - monster.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}



- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}



- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // 1 - Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // 2 - Set up initial location of projectile
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"bullet"];
    projectile.position = CGPointMake( CGRectGetMidX (self.frame), CGRectGetMidY (self.frame));
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    // 3- Determine offset of location to projectile
    CGPoint offset = rwSub(location, projectile.position);
    
    // 4 - Bail out if you are shooting down or backwards
    if (offset.x <= 0) return;
    
    // 5 - OK to add now - we've double checked position
    [self addChild:projectile];
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = rwNormalize(offset);
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // 8 - Add the shoot amount to the current position
    CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    // 9 - Create the actions
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}



- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0)
    {

//        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
        
        [firstBody.node removeFromParent];
        SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"]];
        emitter.position = CGPointMake(secondBody.node.position.x,secondBody.node.position.y);
        [self addChild:emitter];
        [secondBody.node removeFromParent];
        [self performSelector:@selector(removeParticle:) withObject:emitter afterDelay:0.5];
    }
}

-(void)removeParticle:(SKEmitterNode*)node{
    
    [node removeFromParent];

}


//- (SKEmitterNode *) newExplosion: (float)posX : (float) posy
//{
//    SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"particle" ofType:@"sks"]];
//   // NSLog(@"Hit:%f,%f",monster.position.x,monster.position.y);
//
//    emitter.position = CGPointMake(posX,posy);
//    emitter.name = @"explosion";
//    emitter.targetNode = self.scene;
//    emitter.numParticlesToEmit = 1000;
//    emitter.zPosition=2.0;
//    return emitter;
//}








@end
