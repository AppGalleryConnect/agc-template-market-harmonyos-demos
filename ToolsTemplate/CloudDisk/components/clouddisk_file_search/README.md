# 网盘文件搜索组件快速入门

## 目录
- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了网盘文件搜索的相关功能，包括关键词搜索、结果列表展示与返回导航能力。支持传入页面上下文参数以优化占位提示文案，并向外暴露搜索事件以承接业务搜索逻辑。

搜索界面

<img src='screenshot/screenshot01.jpg' style='max-height:350px;object-fit:contain'> 

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.3(15) 及以上

### 权限

- 无

## 使用

1. 安装组件。  
   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。
   如果是从生态市场下载组件，请参考以下步骤安装组件。  
   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。  
   b. 在项目根目录build-profile.json5并添加clouddisk_file_search模块。
   ```typescript
   // 在项目根目录的build-profile.json5填写clouddisk_file_search路径。其中xxx为组件存在的目录名
   "modules": [
    {
      "name": "clouddisk_file_search",
      "srcPath": "./xxx/clouddisk_file_search"
    },
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```typescript
   // xxx为组件存放的目录名称
   "dependencies": {
    "clouddisk_file_search": "file:./xxx/clouddisk_file_search",
   }
   ```

2. 引入组件。

   ```typescript
   import { FileSearch } from 'clouddisk_file_search';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
   FileSearch({
     showBack: true,
     pageParam: '图片',
     searchQuery: (keyword: string) => {
       // 搜索逻辑
     }
   })
   ```

## API参考

### 接口

#### FileSearch

FileSearch(options: { showBack: boolean; pageParam?: string; searchQuery?: (x: string) => void })

文件搜索组件，提供搜索输入和结果展示功能。

**参数：**

| 参数名      | 类型                    | 是否必填 | 说明                                               |
|-------------|-------------------------|------|---------------------------------------------------|
| showBack    | boolean                 | 是    | 是否显示返回按钮                                   |
| pageParam   | string                  | 否    | 搜索提示上下文（如"图片"、"视频"），决定占位符文案 |
| searchQuery | (x: string) => void     | 否    | 搜索事件回调（回传关键字）                          |

### 事件

#### searchQuery

搜索查询事件，当用户输入搜索关键词时触发。

**回调参数：**

| 参数名  | 类型   | 说明     |
|---------|--------|----------|
| keyword | string | 搜索关键词 |

## 示例代码

```typescript
import { FileSearch } from 'clouddisk_file_search';

@Entry
@ComponentV2
export struct clouddiskTestPage {
   @Local searchResults: string[] = [];
   handleSearch = (keyword: string) => {
      console.info('搜索关键词:', keyword);
      // 模拟搜索结果
      this.searchResults = [
         `${keyword}_文档1.pdf`,
         `${keyword}_图片1.jpg`,
         `${keyword}_视频1.mp4`
      ];
   }

   build() {
      Column() {
         // 文件搜索组件
         FileSearch({
            showBack: true,
            pageParam: '全部文件',
            searchQuery: this.handleSearch
         })
            .margin({ bottom: 20 })

         // 搜索结果展示
         if (this.searchResults.length > 0) {
            Text('搜索结果:')
               .fontSize(16)
               .fontWeight(FontWeight.Bold)
               .margin({ bottom: 10 })

            ForEach(this.searchResults, (result: string, index: number) => {
               Text(result)
                  .fontSize(14)
                  .padding(10)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .margin({ bottom: 5 })
            })
         }
      }
      .height('100%')
         .width('100%')
         .margin({ top: 60 })
         .justifyContent(FlexAlign.Start)
         .padding(16)
   }
}
```