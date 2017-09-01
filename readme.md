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

```
  [STDebugger setLogHeaderStyle:STLogHeaderStyleSimple];
  [STDebugger setFilters:@[@"nw_connection_get_connected_socket_block_invoke"]];
  [STDebugger setConfigWithFile:@"env.json"];
```

