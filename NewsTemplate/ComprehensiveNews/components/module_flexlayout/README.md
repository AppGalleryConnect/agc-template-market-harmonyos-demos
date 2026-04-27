# 动态布局组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件支持布局描述文件进行页面布局。

<img src="./screenshots/flexLayout.png">

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.3 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.3 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）、平板
- 系统版本：HarmonyOS 5.0.1(13)及以上

### 权限

- 网络权限：ohos.permission.INTERNET

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_flexlayout模块。

   ```
   // 项目根目录下build-profile.json5填写module_flexlayout路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_flexlayout",
       "srcPath": "./XXX/module_flexlayout"
     }
   ]
   ```

   c. 在项目根目录oh-package.json5添加依赖。

   ```
   // XXX为组件存放的目录名称
   "dependencies": {
     "module_flexlayout": "file:./XXX/module_flexlayout"
   }
   ```

2. 引入组件。

   ```
   import { FlexLayout } from 'module_flexlayout';
   ```

3. 调用组件，详细组件调用参见[示例代码](#示例代码)。

   ```ts
   import { FlexLayout } from 'module_flexlayout'
   
   @Entry
   @ComponentV2
   struct Index {
     build() {
       FlexLayout({
          ...
       })
     }
   }
   ```

## API参考

### 接口

ArticlePost(option: [FlexLayoutOptions](#FlexLayoutOptions对象说明))

动态布局组件的参数

**参数：**

| 参数名     | 类型                                                    | 是否必填 | 说明         |
|:--------|:------------------------------------------------------|:-----|:-----------|
| options | [FlexLayoutOptions](#FlexLayoutOptions对象说明) | 否    | 动态布局组件的参数。 |

#### FlexLayoutOptions对象说明

| 参数名        | 类型 | 是否必填 | 说明   |
|:-----------|:---|:-----|:-----|
| flexLayoutEngine  | [FlexLayoutEngine](#FlexLayoutEngineOptions对象说明) | 是    | 初始化类 |

#### FlexLayoutEngineOptions对象说明

| 参数名        | 类型 | 是否必填 | 说明   |
|:-----------|:---|:-----|:-----|
| setting  | LayoutSetting | 是    | 布局描述 |
| articles  | JSONObject | 是    | 文章数据 |
| breakpointModel  | BreakpointModel | 是    | 断点类  |
| extraInfo  | Record | 是    | 额外字段 |

## 示例代码

```ts
// index
import { FlexLayoutPage } from './FlexLayout'

export class NavInfo {
  setting: string = ''
}

@ObservedV2
export class RequestListData {
  navInfo: NavInfo = new NavInfo()
  @Trace articles: ESObject[] = []
  extraInfo: Record<string, string | boolean | Record<string, string | boolean>[]> = {}
}



@Entry
@ComponentV2
struct Index {
 @Local flexList:RequestListData[] = [
   {
     navInfo: {
       setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomImageCard","name":"上文下图"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
     },
     articles: [
       {
         id: 'article_6',
         type: 1,
         title: '住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？',
         authorId: 'author_1',
         markCount: 0,
         createTime: 1751089800000,
         commentCount: 25,
         likeCount: 6000,
         shareCount: 12000,
         isLiked: false,
         isMarked: false,
         postImgList: [
           'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_1.jpg'
         ],
       },
     ],
     extraInfo: {
       'flexId':'flexId_2',
     },
   },
 ]

  build() {
    Column(){
      ForEach(this.flexList, (item: RequestListData) => {
        ListItem() {
          FlexLayoutPage({
            setting: JSON.parse(item.navInfo.setting),
            articles: item.articles,
          })
        }
      }, (item: RequestListData) => JSON.stringify(item))
    }
  }
}
```
```ts
// FlexLayout.ets
import { CardRegister, FlexLayout, FlexLayoutEngine, LayoutSetting } from 'module_flexlayout';
import { TopTextBottomImageCard } from './TopTextBottomImageCard';

export class CardRegisterEngine {
  public static CardRegister() {
    let nodeBuilderConfigVm = CardRegister.instance
    nodeBuilderConfigVm.registerCard('TopTextBottomImageCard', wrapBuilder(TopTextBottomImageCard))
  }
}

/*
 * 动态布局组件
 * 核心逻辑参考FrameNodeFactory.ets/NativeNodeFactory.ets
 * */
@ComponentV2
export struct FlexLayoutPage {
  @Param setting: LayoutSetting = new LayoutSetting()
  @Param articles: ESObject[] = []
  @Param flowIndex: number = 0
  @Param extraInfo: Record<string, number | string | boolean | Record<string, string | boolean>[]> = {}
  @Local flexLayoutEngine: FlexLayoutEngine = new FlexLayoutEngine()

  @Monitor('settingInfo.darkSwitch')
  darkSwitch() {
    /*
     * 调用rebuild接口通知NodeContainer组件重新回调makeNode方法，更新子节点。
     * */
    this.flexLayoutEngine.frameController.rebuild();
  }

  aboutToAppear(): void {
    this.extraInfo.flowIndex = this.flowIndex
    // 注册本地卡片
    CardRegisterEngine.CardRegister()
    // 初始化本地数据
    this.flexLayoutEngine.createJsonLoader(this.setting, this.articles, this.extraInfo)
  }

  build() {
    FlexLayout({
      flexLayoutEngine: this.flexLayoutEngine,
    })
  }
}
```

```ts
// TopTextBottomImageCard.ets
import { LayoutParams } from 'module_flexlayout'
import { UIUtils } from '@kit.ArkUI'


@Builder
export function TopTextBottomImageCard(cardData: LayoutParams) {
  NativeComponent({
    cardData: cardData,
  })
}

@ComponentV2
struct NativeComponent {
  @Param @Require cardData: LayoutParams
  @Local currentIndex: number = 0

  aboutToAppear(): void {
    this.cardData.nativeCardData = UIUtils.makeObserved(this.cardData.nativeCardData)
  }

  build() {
    Column({ space:5 }) {
      Text(this.cardData.nativeCardData?.title)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Grid() {
        ForEach(this.cardData.nativeCardData?.postImgList, (item: string) => {
          GridItem() {
            Image(item)
              .aspectRatio(1).clip(true)
              .width('100%')
          }
        }, (item: string, index: number) => index + JSON.stringify(item))
      }
      .columnsTemplate('1fr '.repeat(this.cardData.nativeCardData?.postImgList?.length ?? 0))
      .columnsGap(8)
    }

    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
```