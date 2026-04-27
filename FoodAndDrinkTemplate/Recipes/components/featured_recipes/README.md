# 菜谱瀑布流组件快速入门

## 目录
- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了展示菜谱列表搜瀑布流的相关功能。

<img src="./screenshot/FeaturedRecipes1.PNG" width="300">

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.4 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.4 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）、华为平板
- 系统版本：HarmonyOS 5.0.4(16)及以上

### 权限

- 无

## 使用

1. 安装组件。  
   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。
   如果是从生态市场下载组件，请参考以下步骤安装组件。  
   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。  
   b. 在项目根目录build-profile.json5并添加base_ui和featured_recipes模块。
   ```typescript
   // 在项目根目录的build-profile.json5填写base_ui和featured_recipes路径。其中xxx为组件存在的目录名
   "modules": [
    {
       "name": "base_ui",
       "srcPath": "./xxx/base_ui",
     },
     {
       "name": "featured_recipes",
       "srcPath": "./xxx/featured_recipes",
     }
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```typescript
   // xxx为组件存放的目录名称
   "dependencies": {
     "featured_recipes": "file:./xxx/featured_recipes"
   }
   ```

2. 引入组件。

   ```typescript
   import { FeaturedRecipes } from 'featured_recipes';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
   FeaturedRecipes({
      dishesList: this.vm.dishesList,
      showTitle: true,
      onClickCb: (id: number) => {
        // 点击跳转菜谱详情
      },
      jumpBloggerInfo: (id: number) => {
        // 点击跳转菜谱作者主页
      },
    })
   ```

## API参考

### 接口

FeaturedRecipes(options?: FeaturedRecipesOptions)

展示菜谱列表搜瀑布流组件。

**参数：**

| 参数名     | 类型                                                    | 必填 | 说明             |
|---------|-------------------------------------------------------|----|----------------|
| options | [FeaturedRecipesOptions](#FeaturedRecipesOptions对象说明) | 否  | 展示菜谱列表搜瀑布流的参数。 |

### FeaturedRecipesOptions对象说明

| 名称         | 类型                                                                             | 必填 | 说明      |
|------------|--------------------------------------------------------------------------------|----|---------|
| dishesList | [LazyDataSource](#LazyDataSource对象说明)<[RecipeBriefInfo](#RecipeBriefInfo对象说明)> | 否  | 菜谱懒加载列表 |
| showTitle  | boolean                                                                        | 否  | 是否展示标题  |
| canDelete  | boolean                                                                        | 否  | 是否可以删除  |
| isToDelete | boolean                                                                        | 否  | 是否是删除状态 |

### LazyDataSource对象说明

| 名称        | 类型                                        | 必填 | 说明   |
|-----------|-------------------------------------------|----|------|
| dataArray | [RecipeBriefInfo](#RecipeBriefInfo对象说明)[] | 是  | 菜谱列表 |

### RecipeBriefInfo对象说明

| 名称           | 类型     | 必填 | 说明     |
|--------------|--------|----|--------|
| id           | number | 是  | 菜谱序号   |
| title        | string | 是  | 菜谱名称   |
| description  | string | 否  | 菜谱描述   |
| category     | string | 否  | 菜谱分类   |
| cookingTime  | number | 否  | 菜谱制作时间 |
| difficulty   | string | 否  | 菜谱难度   |
| authorId     | number | 是  | 作者id序号 |
| author       | string | 是  | 作者名称   |
| authorAvatar | string | 是  | 作者头像   |
| thumbnail    | string | 是  | 菜谱缩略图  |
| views        | number | 否  | 浏览数    |
| likes        | number | 是  | 收藏数    |

### 事件

支持以下事件：

#### onClickCb

onClickCb(callback: (id: number) => void)

点击跳转菜谱详情

#### jumpBloggerInfo

jumpBloggerInfo(callback: (id: number) => void)

点击跳转菜谱作者主页

#### deleteRecipes

deleteRecipes(callback: (ids: number[]) => void)

点击删除菜谱事件

#### changeSelect

changeSelect(callback: (id: number,flag:boolean) => void)

删除时点击修改选中菜谱事件

#### changeDeleteState

changeDeleteState(callback: (isToDelete:boolean) => void)

长按菜谱时触发删除状态变更

## 示例代码

```typescript
import { promptAction } from '@kit.ArkUI';
import { FeaturedRecipes, LazyDataSource, RecipeBriefInfo } from 'featured_recipes';

@Entry
@ComponentV2
struct Index {
   @Local dishesList: LazyDataSource<RecipeBriefInfo> = new LazyDataSource();

   aboutToAppear(): void {
      this.dishesList.pushArrayData([{
         id: 1,
         title: '西红柿炒鸡蛋',
         authorId: 1,
         author: '美食博主',
         authorAvatar: 'startIcon',
         thumbnail: 'startIcon',
         likes: 100,
      } as RecipeBriefInfo,
         {
            id: 2,
            title: '可乐鸡翅',
            authorId: 1,
            author: '美食博主',
            authorAvatar: 'startIcon',
            thumbnail: 'startIcon',
            likes: 100,
         } as RecipeBriefInfo])
   }

   build() {
      RelativeContainer() {
         FeaturedRecipes({
            dishesList: this.dishesList,
            showTitle: true,
            onClickCb: (id: number) => {
               // 点击跳转菜谱详情
               promptAction.showToast({ message: '跳转菜谱详情' })
            },
            jumpBloggerInfo: (id: number) => {
               // 点击跳转菜谱作者主页
               promptAction.showToast({ message: '跳转菜谱作者主页' })
            },
         })
      }
      .height('100%')
      .width('100%')
      .padding({ top: 45 })
   }
}
```

<img src="./screenshot/Screenshot_1.jpeg" width="300">
