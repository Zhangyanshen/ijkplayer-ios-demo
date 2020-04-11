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

