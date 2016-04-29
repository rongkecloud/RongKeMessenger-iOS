# RongKeMessenger-iOS
RongKeMessenger for iOS（融科通iOS端源码）

![云视互动](http://www.rongkecloud.com/skin/simple/img/logo-small.png)

[Home Page(官方主页)](http://www.rongkecloud.com) | [Doc(文档手册)](http://www.rongkecloud.com/download/rongketong/doc.zip) |  [CHANGELOG(更新历史)](https://github.com/rongkecloud/RongKeMessenger-iOS/blob/master/CHANGELOG.md)

## 功能介绍
融科通是基于云视互动打造的前、后完全开源APP，除完善的APP框架和后台设计外，还涵盖了注册、登录、通讯录管理、单聊、群聊、音视频通话、多人语音聊天室等即时通讯互动功能，陆续融科通还会逐步推出朋友圈、附近的人、多媒体客服等高级功能，旨在帮助广大开发者能够基于融科通开源代码上最低成本快速实现自身的产品。

注意：如果用户想以融科通为基础构建自己的应用APP并上线时，需要您修改包名为自己的包名。 

## 基于开源框架融科通开发App说明：

下载iOS端融科通开源代码，使用Xcode开发工具打开。

#### 1、修改工程名称 <br>
需要将融科通工程名修改为自己App相关的名称（具体步骤请在网络中查找，此处不在详细叙说）。

#### 2、修改融科通客户端秘钥 <br>
在Definition类中修改RKCLOUD_SDK_APPKEY宏定义为您应用的客户端秘钥。

#### 3、修改Bundle identifier <br>
将工程中Info.plist文件中Bundle identifier修改为自己App的标识符，以及对
应的Code Signing Identity签名，确保能在真机正常运行。

#### 4、修改HttpApi <br>
参考文档配置服务器部分配置好您的服务器端，并且保证服务器端正常运行。客户端需要在Definition中修改如下宏定义地址：
修改DEFAULT_HTTP_API_SERVER_ADDRESS为您应用服务器端域名；
修改DEFAULT_RKCLOUD_ROOT_SERVER_PORT为您应用服务器端端口号

#### 5、修改关于页面 <br>
在AboutSoftWareViewController.xib为融科通App的内容介绍，需要将内容修改为自己的App或者其他相关内容介绍即可。

[Service Agreement(云视互动开发者平台服务协议)](http://www.rongkecloud.com/tecinfo/28.html)

[![联系我们][contactImage]](http://kefu.rongkecloud.com/RKServiceClientWeb/index.html?ek=6f2683bb7f9b98aa09283fd8b47f4086aec37b56&ct=1&bg=3&gd=143)
[Contact us(联系我们)][serviceLink]

[contactImage]: http://www.rongkecloud.com/skin/simple/img/right/online.png "在线客服"
[serviceLink]: http://kefu.rongkecloud.com/RKServiceClientWeb/index.html?ek=6f2683bb7f9b98aa09283fd8b47f4086aec37b56&ct=1&bg=3&gd=143 "在线客服"
