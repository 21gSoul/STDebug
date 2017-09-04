# STDebug


## 描述
**STDebug**是iOS平台上的实用测试工具，主要功能是环境切换，重定向日志到App等功能，方便测试人员报告bug，环境切换。主要优点：

* 支持大量日志
* 支持日志查找
* 支持环境切换
* 支持模拟器日志
* 手机App、XCode控制台日志同时显示

## 接入步骤
* 在podfile中加入：

```
pod STDebug
pod Masonry
```

* 执行pod update

## 使用
启动时设置：

```
[STDebugger setLogHeaderStyle:STLogHeaderStyleSimple];
[STDebugger setFilters:@[@"nw_connection_get_connected_socket_block_invoke"]];
[STDebugger setConfigWithFile:@"env.json"];
```

打开操作界面：

```
[STDebugger show];
```
说明：

+ (void) showOnConsole:(BOOL)show;  设置是否同时在控制台显示日志，默认显示
+ (void) setLogHeaderStyle:(STLogHeaderStyle)style;  设置日志头信息
+ (void) setConfig:(NSDictionary *)config;  设置环境配置信息，配置信息demo参见env.json
+ (void) setConfigWithFile:(NSString *)fileName;   设置环境配置文件，文件格式参照env.json
+ (NSDictionary *) envirment;  通过此方法返回用户当前的环境配置信息
+ (void) setFilters:(NSArray *)filters;  设置日志过滤，包含的日志将被丢弃
+ (void) setExtendDelegate:(id<STDebugExtendDelegate>) delegate;   设置快捷功能的代理，用以实现额外的业务功能
+ (void) show;   打开用户操作界面
