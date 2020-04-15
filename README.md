## 一、编译

### 1.获取ijkplayer源码

在一个合适的位置新建一个文件夹, 假设为桌面, 文件夹名为 `ijkplayer`.

打开终端, 输入下面的指令

```sh
# 进入到刚刚新建的文件夹内
cd ~/Desktop/ijkplayer/

# 获取ijkplayer源码
git clone https://github.com/Bilibili/ijkplayer.git ijkplayer-ios

# 进入源码目录
cd ijkplayer-ios

# 切换分支 (目前为k0.8.8, 可以自行去GitHub查看最新版本号)
git checkout -B latest k0.8.8
```

### 2.配置编解码器格式支持

默认为最少支持, 如果足够你使用, 可以跳过这一步. 否则可以改为以下配置:

* `module-default` 更多的编解码器/格式
* `module-lite-hevc.sh ` 较少的编解码器/格式(包括hevc)
* `module-lite.sh` 较少的编解码器/格式(默认情况)

```sh
# 进入 config 目录
cd config

# 删除当前的 module.sh 文件
rm module.sh

# 可根据需要替换为`module-default.sh`, `module-lite-hevc.sh`, `module-lite.sh`
# 创建软链接 module.sh 指向 module-lite-hevc.sh
ln -s module-lite-hevc.sh module.sh

cd ..
cd ios
sh compile-ffmpeg.sh clean
```

### 3.获取 ffmpeg 并初始化

```sh
cd ..
./init-ios.sh
```

### 4.添加 https 支持

最后会生成支持 https 的静态文件 `libcrypto.a` 和 `libssl.a`, 如果不需要可以跳过这一步

```sh
# 获取 openssl 并初始化
./init-ios-openssl.sh

cd ios

# 在模块文件中添加一行配置 以启用 openssl 组件
echo 'export COMMON_FF_CFG_FLAGS="$COMMON_FF_CFG_FLAGS --enable-openssl"' >> ../config/module.sh

./compile-ffmpeg.sh clean
```

### 5.去掉对armv7支持

修改`compile-ffmpeg.sh` 和 `compile-openssl.sh` 两个文件，去掉对armv7的支持

原来：

```sh
FF_ALL_ARCHS_IOS8_SDK="armv7 arm64 i386 x86_64"
```

现在：

```sh
FF_ALL_ARCHS_IOS8_SDK="arm64 i386 x86_64"
```

> **注意：**这里去掉对armv7的支持主要是因为 Xcode 已经弱化了对 32 位的支持，防止后面的操作报错。

### 6.编译

```sh
# 如果下一步提示错误`xcrun: error: SDK "iphoneos" cannot be located`, 请执行`sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer/`, 再重新执行下一步

# 编译openssl，生成 `libcrypto.a` 和 `libssl.a`，如果不需要https可以跳过这一步
./compile-openssl.sh all

# 编译ffmpeg
./compile-ffmpeg.sh all
```

## 二、打包framework

### 1.打开IJKMediaPlayer项目

用命令:

```sh
open IJKMediaPlayer/IJKMediaPlayer.xcodeproj
```

或者手动用 Xcode 打开 ios 目录下的 IJKMediaPlayer 项目。

### 2.添加 openssl 相关包以支持 https

ijkplayer默认不支持https，如果需要支持则需要添加上面生成的`libcrypto.a` 和 `libssl.a` 两个静态库 ，文件路径为 `ijkplayer-ios/ios/build/universal/lib/` 

> **注意：**只有进行了上面跟 openssl 相关的操作, 才会在这个目录下有生成 `libcrypto.a` 和 `libssl.a`

### 3.打包framework

* 修改 `Build Configuration` 为 `Release`
* 分别打包真机和模拟器framework
* 使用 `lipo -create` 合并真机和模拟器framework
  * `lipo -create 真机framework路径 模拟器framework路径 -o 合并的文件路径`

## 三、使用

### 1.导入framework

直接将 `IJKMediaFramework.framework` 拖入到工程中即可

注意记得勾选 `Copy items if needed` 和 对应的 `target`

### 2.添加下列依赖到工程

* `libc++.tbd`( 编译器选 gcc 的请导入 `libstdc++.tbd`)

* `libz.tbd`

* `libbz2.tbd`

* `AudioToolbox.framework`

* `UIKit.framework`

* `CoreGraphics.framework`

* `AVFoundation.framework`

* `CoreMedia.framework`

* `CoreVideo.framework`

* `MediaPlayer.framework`

* `MobileCoreServices.framework`

* `OpenGLES.framework`

* `QuartzCore.framework`

* `VideoToolbox.framework`

## 四、ijkplayer常用功能

### 1.当前播放时长

```objective-c
@property (nonatomic) NSTimeInterval currentPlaybackTime;
```

### 2.总时长

```objective-c
@property(nonatomic, readonly)  NSTimeInterval duration;
```

### 3.已经缓存的时长

```objective-c
@property(nonatomic, readonly)  NSTimeInterval playableDuration;
```

### 4.倍速播放

```objective-c
@property (nonatomic) float playbackRate // 0.5 ~ 2.0
```

### 5.解决音视频不同步的问题

```objective-c
IJKFFOptions *options = [IJKFFOptions optionsByDefault];
[options setPlayerOptionIntValue:1 forKey:@"framedrop"];
```

## 五、iOS音视频开发相关

### 1.屏幕亮度

```objective-c
// 获取屏幕亮度
CGFloat brightness = [UIScreen mainScreen].brightness;
// 设置屏幕亮度
[UIScreen mainScreen].brightness = brightness;
```

### 2.系统音量

获取和设置系统音量有2种方式，一是使用`MPMusicPlayerController` ，二是使用`MPVolumeView` 。

* `MPMusicPlayerController` 的`volume` 在iOS 7之后被废弃了，所以不推荐使用；
* `MPVolumeView` 是`UIView` 的子类，它包含一个AirPlay选择界面和一个`UISlider` 类型的音量调节按钮，我们使用它的话一定要将其添加到我们自己的View上面，否则不起作用。另外，`MPVolumeView` 并没有暴露获取音量和设置音量的属性和方法，所以我们只能通过遍历子视图找到`UISlider` 类型的子视图，然后通过`UISlider` 的`value` 属性来获取和设置。

```objective-c
// 如果要自定义音量条的话，可以将MPVolumeView的frame设置在屏幕之外
MPVolumeView *mpVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-30, -30, 0, 0)];
// mpVolumeView.showsRouteButton = NO; // 是否显示AirPlay按钮
// mpVolumeView.showsVolumeSlider = NO; // 是否显示音量条，如果设置为NO，则系统的音量条会显示
[self addSubview:mpVolumeView];
// 通过遍历子View获取音量条
for (UIView *view in mpVolumeView.subviews) {
		if ([view isKindOfClass:UISlider.class]) {
    		self.volumeSlider = (UISlider *)view;
        break;
    }
}
```

### 3.后台继续播放

默认情况下，App进入后台，音频视频会暂停播放，如果想继续播放，则应该开启`Background Modes` 这个Capability，并勾选其中的`Audio, AirPlay, and Picture in Picture` 选项，如下图：

<img src="/Users/zhangyanshen/Library/Application Support/typora-user-images/image-20200415155143416.png" alt="image-20200415155143416" style="zoom:50%;" />

### 4.全屏、非全屏

* 设置 `Info.plist` 中 `Device Orientation` 为 `Portrait` ，即整个App只支持竖屏；

  <img src="/Users/zhangyanshen/Library/Application Support/typora-user-images/image-20200415162626723.png" alt="image-20200415162626723" style="zoom:100%;" />

* 在 `AppDelegate.h` 中定义一个属性 `fullScreen` ，来标识当前页面是否是全屏；

  ```objective-c
  @property (assign, nonatomic) BOOL fullScreen;
  ```

* 在 `AppDelegate.m` 中实现下面的方法，根据第二步定义的 `fullScreen` 来返回不同的值；

  ```objective-c
  - (UIInterfaceOrientationMask)application:(UIApplication *)application
    supportedInterfaceOrientationsForWindow:(UIWindow *)window
  {
      if (self.fullScreen) {
          return UIInterfaceOrientationMaskLandscape;
      }
      return UIInterfaceOrientationMaskPortrait;
  }
  ```

* 在点击全屏按钮时设置设备的方向，然后在布局方法中设置相关View的frame；

  ```objective-c
  // 1.改变设备方法
  - (void)changeOritention {
    	/*
       根据当前是否是全屏来给设备设置不同的方向
       1.全屏：UIInterfaceOrientationLandscapeRight
       2.非全屏：UIInterfaceOrientationPortrait
       */
      UIInterfaceOrientation orientation = self.playerController.fullScreen ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
    	// 通过KVO设置
      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
  }
  
  // 2.设置相关View的frame
  - (void)viewWillLayoutSubviews {
      [super viewWillLayoutSubviews];
      if (self.playerController.isFullScreen) {
          self.playerController.view.frame = self.view.bounds;
      } else {
          self.playerController.view.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16.0);
      }
  }
  ```

### 5.手势控制播放进度、系统音量及屏幕亮度



### 6.获取运营商信息

* 添加 `CoreTelephony.framework` ；

  <img src="/Users/zhangyanshen/Library/Application Support/typora-user-images/image-20200415211713861.png" alt="image-20200415211713861" style="zoom:50%;" />

* 导入头文件；

  ```objective-c
  #import <CoreTelephony/CTTelephonyNetworkInfo.h>
  #import <CoreTelephony/CTCarrier.h>
  ```

* 获取并监听运营商信息；

  ```objective-c
  ...
  @property (strong, nonatomic) CTTelephonyNetworkInfo *networkInfo;  
  ...
  
  // 加载运营商信息
  - (void)loadCarrier {
      NSDictionary *carrierDic = [self.networkInfo serviceSubscriberCellularProviders];
    	// 首次加载并不会走监听，所以这里要手动获取一下
      [self updateCarrierInfo:carrierDic[self.networkInfo.dataServiceIdentifier]];
      __weak typeof(self) weakSelf = self;
      // 监听运营商变化
      self.networkInfo.serviceSubscriberCellularProvidersDidUpdateNotifier = ^(NSString * _Nonnull dataServiceIdentifier) {
          CTCarrier *carrier = carrierDic[dataServiceIdentifier];
          [weakSelf updateCarrierInfo:carrier];
      };
  }
  
  // 更新运营商信息
  - (void)updateCarrierInfo:(CTCarrier *)carrier {
      NSString *carrierName;
      if (!carrier.isoCountryCode) {
          carrierName = @"无SIM卡";
      } else {
          carrierName = carrier.carrierName;
      }
      self.carrierLbl.text = carrierName;
  }
  ```

### 7.获取电池状态和电量

* 要获取电池电量和电池状态，首先必须开启电池监测，即需要添加下面一行代码；

  ```objective-c
  // 开启电池监测
  [UIDevice currentDevice].batteryMonitoringEnabled = YES;
  ```

* 电池状态

  * 添加通知 `UIDeviceBatteryStateDidChangeNotification` ；

    ```objective-c
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBatteryStateDidChangeNotification:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    ```

  * 通过 `UIDevice` 的 `batteryState` 属性获取电池状态；

    ```objective-c
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    switch (batteryState) {
        case UIDeviceBatteryStateCharging: // 正在充电(<100%)
        {
            self.batteryStateLbl.text = @"充电中";
        }
            break;
        case UIDeviceBatteryStateFull: // 正在充电(100%)
        {
            self.batteryStateLbl.text = @"已充满";
        }
            break;
        case UIDeviceBatteryStateUnplugged:
        {
            self.batteryStateLbl.text = @"未充电";
        }
            break;
        case UIDeviceBatteryStateUnknown:
        {
            self.batteryStateLbl.text = @"未知";
        }
            break;
        default:
            break;
    }
    ```

* 电池电量

  * 添加通知 `UIDeviceBatteryLevelDidChangeNotification` ；

    ```objective-c
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBatteryLevelDidChangeNotification:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    ```

  * 通过 `UIDevice` 的 `batteryLevel` 属性获取电池电量；

    ```objective-c
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel < 0.0) {
        self.batteryLevelLbl.text = @"0%";
    } else {
        self.batteryLevelLbl.text = [NSString stringWithFormat:@"%.0f%%", batteryLevel * 100];
    }
    ```

  > **注意：**获取电池状态和电量在首次加载时并不会走监听方法，所以在刚启动时，需要先手动获取一下。

### 8.获取网络信息

