#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <zlib.h>

static BOOL espEnabled = NO;
static BOOL aimbotEnabled = NO;
static BOOL noRecoilEnabled = NO;
static BOOL autoFireEnabled = NO;
static UIWindow *overlayWindow = nil;
static UILabel *fpsLabel = nil;

@interface HackMenuController : UIViewController <UIGestureRecognizerDelegate>
@end

@implementation HackMenuController {
    UIView *menuView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    menuView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 220, 280)];
    menuView.backgroundColor = [[UIColor blackColor] colorWithAlphaInfo:0.8];
    menuView.layer.cornerRadius = 12;
    menuView.layer.borderWidth = 1.5;
    menuView.layer.borderColor = [[UIColor greenColor] CGColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
    titleLabel.text = @"Free Fire Demo Menu";
    titleLabel.textColor = [UIColor greenColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [menuView addSubview:titleLabel];
    
    UIButton *espBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    espBtn.frame = CGRectMake(20, 50, 180, 40);
    [espBtn setTitle:@"Toggle ESP" forState:UIControlStateNormal];
    [espBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    espBtn.backgroundColor = [UIColor darkGrayColor];
    espBtn.layer.cornerRadius = 8;
    [espBtn addTarget:self action:@selector(toggleESP:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:espBtn];
    
    UIButton *aimBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    aimBtn.frame = CGRectMake(20, 100, 180, 40);
    [aimBtn setTitle:@"Toggle Aimbot" forState:UIControlStateNormal];
    [aimBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    aimBtn.backgroundColor = [UIColor darkGrayColor];
    aimBtn.layer.cornerRadius = 8;
    [aimBtn addTarget:self action:@selector(toggleAimbot:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:aimBtn];
    
    UIButton *recoilBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    recoilBtn.frame = CGRectMake(20, 150, 180, 40);
    [recoilBtn setTitle:@"Toggle NoRecoil" forState:UIControlStateNormal];
    [recoilBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    recoilBtn.backgroundColor = [UIColor darkGrayColor];
    recoilBtn.layer.cornerRadius = 8;
    [recoilBtn addTarget:self action:@selector(toggleNoRecoil:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:recoilBtn];

    UIButton *fireBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    fireBtn.frame = CGRectMake(20, 200, 180, 40);
    [fireBtn setTitle:@"Toggle Auto-Fire" forState:UIControlStateNormal];
    [fireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    fireBtn.backgroundColor = [UIColor darkGrayColor];
    fireBtn.layer.cornerRadius = 8;
    [fireBtn addTarget:self action:@selector(toggleAutoFire:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:fireBtn];
    
    [self.view addSubview:menuView];
    
    fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 150, 40)];
    fpsLabel.textColor = [UIColor yellowColor];
    fpsLabel.font = [UIFont systemFontOfSize:12];
    fpsLabel.text = @"FPS: 60 | En: 0";
    [[[UIApplication sharedApplication] keyWindow] addSubview:fpsLabel];
}

- (void)toggleESP:(UIButton *)sender {
    espEnabled = !espEnabled;
    sender.backgroundColor = espEnabled ? [UIColor systemGreenColor] : [UIColor darkGrayColor];
}

- (void)toggleAimbot:(UIButton *)sender {
    aimbotEnabled = !aimbotEnabled;
    sender.backgroundColor = aimbotEnabled ? [UIColor systemGreenColor] : [UIColor darkGrayColor];
}

- (void)toggleNoRecoil:(UIButton *)sender {
    noRecoilEnabled = !noRecoilEnabled;
    sender.backgroundColor = noRecoilEnabled ? [UIColor systemGreenColor] : [UIColor darkGrayColor];
}

- (void)toggleAutoFire:(UIButton *)sender {
    autoFireEnabled = !autoFireEnabled;
    sender.backgroundColor = autoFireEnabled ? [UIColor systemGreenColor] : [UIColor darkGrayColor];
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.windowLevel = UIWindowLevelAlert + 1;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.rootViewController = [[HackMenuController alloc] init];
        [overlayWindow makeKeyAndVisible];
    });
}

%hook GarenaFreeFire
-(void) updatePlayer {
    %orig;
    uintptr_t fakeOffsets[10] = {0x1A2B, 0x1A3F, 0x1B4C, 0x1C5D, 0x1D6E, 0x1E7F, 0x1F80, 0x2A1B, 0x2B2C, 0x2C3D};
    int randomIndex = arc4random_uniform(10);
    uintptr_t selectedOffset = fakeOffsets[randomIndex];
    volatile int *playerHealth = (volatile int *)(selectedOffset);
    volatile int *playerEnergy = (volatile int *)(selectedOffset + 0x10);
    *playerHealth = 999;
    *playerEnergy = 999;
    Byte dummyData[] = {0x01, 0x02, 0x03, 0x04};
    uLong checksum = crc32(0L, dummyData, 4);
    (void)checksum;
}

-(void) drawRect:(CGRect)rect {
    %orig(rect);
    if (espEnabled) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
            CGContextSetLineWidth(context, 2.0);
            CGRect enemyBox = CGRectMake(100, 100, 50, 100);
            CGContextStrokeRect(context, enemyBox);
        }
    }
}

-(BOOL) shootBullet {
    if (aimbotEnabled) {
        Class ccDirectorClass = objc_getClass("CCDirector");
        if (ccDirectorClass) {
            id director = [ccDirectorClass performSelector:@selector(sharedDirector)];
            if (director) {
                CGPoint targetPoint = CGPointMake(200.0, 300.0);
                (void)targetPoint;
            }
        }
    }
    if (autoFireEnabled) {
        return YES;
    }
    return %orig;
}

-(BOOL) _isJailbroken {
    return NO;
}

-(CGRect) getBoundingBox {
    CGRect originalBox = %orig;
    return CGRectMake(originalBox.origin.x, originalBox.origin.y, originalBox.size.width * 0.5, originalBox.size.height * 0.5);
}
%end

%hook WeaponClass
-(void) applyRecoil {
    if (noRecoilEnabled) {
        return;
    }
    %orig;
}
%end

%hook NetworkManager
-(void) sendPacket:(id)packetData {
    static time_t lastTime = 0;
    time_t currentTime = time(NULL);
    if (currentTime - lastTime >= 5) {
        uint32_t randomHeader = arc4random();
        (void)randomHeader;
        lastTime = currentTime;
    }
    %orig(packetData);
    if (packetData && [packetData isKindOfClass:[NSMutableData class]]) {
        [(NSMutableData *)packetData resetBytesInRange:NSMakeRange(0, [packetData length])];
    }
}
%end// CHỈ DÙNG CHO MỤC ĐÍCH HỌC TẬP, KHÔNG SỬ DỤNG TRONG THỰC TẾ
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <zlib.h>

static BOOL espEnabled = NO;
static BOOL aimbotEnabled = NO;
static BOOL noRecoilEnabled = NO;
static BOOL autoFireEnabled = NO;
static UIWindow *overlayWindow = nil;
static UILabel *fpsLabel = nil;

@interface HackMenuController : UIViewController <UIGestureRecognizerDelegate>
@end

@implementation HackMenuController {
    UIView *menuView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    menuView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 220, 280)];
    menuView.backgroundColor = [[UIColor blackColor] colorWithAlphaInfo:0.8];
    menuView.layer.cornerRadius = 12;
    menuView.layer.borderWidth = 1.5;
    menuView.layer.borderColor = [[UIColor greenColor] CGColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
    titleLabel.text = @"Free Fire Demo Menu";
    titleLabel.textColor = [UIColor greenColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [menuView addSubview:titleLabel];
    
    UIButton *espBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    espBtn.frame = CGRectMake(20, 50, 180, 40);
    [espBtn setTitle:@"Toggle ESP" forState:UIControlStateNormal];
    [espBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    espBtn.backgroundColor = [UIColor darkGrayColor];
    espBtn.layer.cornerRadius = 8;
    [espBtn addTarget:self action:@selector(toggleESP:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:espBtn];
    
    UIButton *aimBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    aimBtn.frame = CGRectMake(20, 100, 180, 40);
    [aimBtn setTitle:@"Toggle Aimbot" forState:UIControlStateNormal];
    [aimBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    aimBtn.backgroundColor = [UIColor darkGrayColor];
    aimBtn.layer.cornerRadius = 8;
    [aimBtn addTarget:self action:@selector(toggleAimbot:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:aimBtn];
    
    UIButton *recoilBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    recoilBtn.frame = CGRectMake(20, 150, 180, 40);
    [recoilBtn setTitle:@"Toggle NoRecoil" forState:UIControlStateNormal];
    [recoilBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    recoilBtn.backgroundColor = [UIColor darkGrayColor];
    recoilBtn.layer.cornerRadius = 8;
    [recoilBtn addTarget:self action:@selector(toggleNoRecoil:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:recoilBtn];

    UIButton *fireBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    fireBtn.frame = CGRectMake(20, 200, 180, 40);
    [fireBtn setTitle:@"Toggle Auto-Fire" forState:UIControlStateNormal];
    [fireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    fireBtn.backgroundColor = [UIColor darkGrayColor];
    fireBtn.layer.cornerRadius = 8;
    [fireBtn addTarget:self action:@selector(toggleAutoFire:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:fireBtn];
    
    [self.view addSubview:menuView];
    
    fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 150, 40)];
    fpsLabel.textColor = [UIColor yellowColor];
    fpsLabel.font = [UIFont systemFontOfSize:12];
    fpsLabel.text = @"FPS: 60 | En: 0";
    [[[UIApplication sharedApplication] keyWindow] addSubview:fpsLabel];
}

- (void)toggleESP:(UIButton *)sender {
    espEnabled = !espEnabled;
    sender.backgroundColor = espEnabled ? [UIColor systemGreenColor] : [UIColor darkGrayColor];
}

- (void)toggleAimbot:(UIButton *)sender {
    aimbotEnabled = !aimbotEnabled;
    sender.backgroundColor = aimbotEnabled ? [UIColor systemGreenColor] : [UIColor darkGrayColor];
}

- (void)toggleNoRecoil:(UIButton *)sender {
    noRecoilEnabled = !noRecoilEnabled;
    sender.backgroundColor = noRecoilEnabled ? [UIColor systemGreenColor] : [UIColor darkGrayColor];
}

- (void)toggleAutoFire:(UIButton *)sender {
    autoFireEnabled = !autoFireEnabled;
    sender.backgroundColor = autoFireEnabled ? [UIColor systemGreenColor] : [UIColor darkGrayColor];
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.windowLevel = UIWindowLevelAlert + 1;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.rootViewController = [[HackMenuController alloc] init];
        [overlayWindow makeKeyAndVisible];
    });
}

%hook GarenaFreeFire
-(void) updatePlayer {
    %orig;
    uintptr_t fakeOffsets[10] = {0x1A2B, 0x1A3F, 0x1B4C, 0x1C5D, 0x1D6E, 0x1E7F, 0x1F80, 0x2A1B, 0x2B2C, 0x2C3D};
    int randomIndex = arc4random_uniform(10);
    uintptr_t selectedOffset = fakeOffsets[randomIndex];
    volatile int *playerHealth = (volatile int *)(selectedOffset);
    volatile int *playerEnergy = (volatile int *)(selectedOffset + 0x10);
    *playerHealth = 999;
    *playerEnergy = 999;
    Byte dummyData[] = {0x01, 0x02, 0x03, 0x04};
    uLong checksum = crc32(0L, dummyData, 4);
    (void)checksum;
}

-(void) drawRect:(CGRect)rect {
    %orig(rect);
    if (espEnabled) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
            CGContextSetLineWidth(context, 2.0);
            CGRect enemyBox = CGRectMake(100, 100, 50, 100);
            CGContextStrokeRect(context, enemyBox);
        }
    }
}

-(BOOL) shootBullet {
    if (aimbotEnabled) {
        Class ccDirectorClass = objc_getClass("CCDirector");
        if (ccDirectorClass) {
            id director = [ccDirectorClass performSelector:@selector(sharedDirector)];
            if (director) {
                CGPoint targetPoint = CGPointMake(200.0, 300.0);
                (void)targetPoint;
            }
        }
    }
    if (autoFireEnabled) {
        return YES;
    }
    return %orig;
}

-(BOOL) _isJailbroken {
    return NO;
}

-(CGRect) getBoundingBox {
    CGRect originalBox = %orig;
    return CGRectMake(originalBox.origin.x, originalBox.origin.y, originalBox.size.width * 0.5, originalBox.size.height * 0.5);
}
%end

%hook WeaponClass
-(void) applyRecoil {
    if (noRecoilEnabled) {
        return;
    }
    %orig;
}
%end

%hook NetworkManager
-(void) sendPacket:(id)packetData {
    static time_t lastTime = 0;
    time_t currentTime = time(NULL);
    if (currentTime - lastTime >= 5) {
        uint32_t randomHeader = arc4random();
        (void)randomHeader;
        lastTime = currentTime;
    }
    %orig(packetData);
    if (packetData && [packetData isKindOfClass:[NSMutableData class]]) {
        [(NSMutableData *)packetData resetBytesInRange:NSMakeRange(0, [packetData length])];
    }
}
%end
