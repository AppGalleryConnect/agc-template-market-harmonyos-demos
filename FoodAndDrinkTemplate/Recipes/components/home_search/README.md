# 搜索组件快速入门

## 目录
- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了搜索菜谱，并展示搜索结果的相关功能。

| 搜索                                                   | 结果展示                                                 |
|------------------------------------------------------|------------------------------------------------------|
| <img src="./screenshot/HomeSearch1.PNG" width="300"> | <img src="./screenshot/HomeSearch2.PNG" width="300"> |

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
   b. 在项目根目录build-profile.json5并添加base_ui和home_search模块。
   ```typescript
   // 在项目根目录的build-profile.json5填写base_ui和home_search路径。其中xxx为组件存在的目录名
   "modules": [
     {
       "name": "base_ui",
       "srcPath": "./xxx/base_ui",
     },
     {
       "name": "home_search",
       "srcPath": "./xxx/home_search",
     }
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```typescript
   // xxx为组件存放的目录名称
   "dependencies": {
     "home_search": "file:./xxx/home_search"
   }
   ```

2. 引入组件。

   ```typescript
   import { HomeSearch } from 'home_search';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
   HomeSearch({
       hotInfo: this.vm.hotInfo,
       resultList: this.vm.resultList,
       historyInfo: this.vm.historyInfo,
       paramsKeyword: this.vm.paramsKeyword,
       isShowResult: this.vm.isShowResult,
       isShowSearch: this.vm.formPage === CommonConstants.CLASSIFICATION_PAGE,
       searchDishes: (keyword: string) => {
         // 调用搜索查询事件
       },
       changeIndex: (index: number, keyword: string) => {
         // 切换搜索排序的事件
       },
       changeShowResult: (flag: boolean) => {
         // 切换展示搜索结果的事件
       },
       goRecipeDetail: (id: number) => {
         // 跳转菜谱详情事件
       },
     })
   ```

## API参考

### 接口

HomeSearch(options?: HomeSearchOptions)

搜索菜谱组件。

**参数：**

| 参数名     | 类型                                          | 必填 | 说明       |
|---------|---------------------------------------------|----|----------|
| options | [HomeSearchOptions](#HomeSearchOptions对象说明) | 否  | 搜索菜谱的参数。 |

### HomeSearchOptions对象说明

| 名称            | 类型                                        | 必填 | 说明       |
|---------------|-------------------------------------------|----|----------|
| hotInfo       | [RecipeBriefInfo](#RecipeBriefInfo对象说明)[] | 否  | 热门搜索     |
| resultList    | [RecipeBriefInfo](#RecipeBriefInfo对象说明)[] | 否  | 搜索结果     |
| historyInfo   | string[]                                  | 否  | 历史搜索     |
| paramsKeyword | string                                    | 否  | 默认搜索词    |
| isShowResult  | boolean                                   | 否  | 是否展示搜索结果 |
| isShowSearch  | boolean                                   | 否  | 是否展示搜索框  |

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

#### searchDishes

searchDishes(callback: (keyword: string) => void)

调用搜索查询事件

#### changeIndex

changeIndex(callback: (index: number, keyword: string) => void)

切换搜索排序的事件

#### changeShowResult

changeShowResult(callback: (flag: boolean) => void)

切换展示搜索结果的事件

#### goRecipeDetail

goRecipeDetail(callback: (id: number) => void)

跳转菜谱详情事件

## 示例代码

```typescript
import { promptAction } from '@kit.ArkUI';
import { HomeSearch, RecipeBriefInfo } from 'home_search';

@Entry
@ComponentV2
struct Index {
   @Local historyInfo: string[] = ['西红柿炒鸡蛋', '可乐鸡翅']
   @Local hotInfo: RecipeBriefInfo[] = [{
      id: 1,
      title: '西红柿炒鸡蛋',
      description: '西红柿炒鸡蛋',
      category: '',
      cookingTime: 0,
      difficulty: '',
      author: '美食博主',
      authorAvatar: 'startIcon',
      thumbnail: 'startIcon',
      views: 100,
      likes: 100,
   } as RecipeBriefInfo, {
      id: 2,
      title: '可乐鸡翅',
      description: '西红柿炒鸡蛋',
      category: '',
      cookingTime: 0,
      difficulty: '',
      author: '美食博主',
      authorAvatar: 'startIcon',
      thumbnail: 'startIcon',
      views: 100,
      likes: 100,
   } as RecipeBriefInfo];
   @Local resultList: RecipeBriefInfo[] = [{
      id: 1,
      title: '西红柿炒鸡蛋',
      description: '西红柿炒鸡蛋',
      category: '',
      cookingTime: 0,
      difficulty: '',
      author: '美食博主',
      authorAvatar: 'startIcon',
      thumbnail: 'startIcon',
      views: 100,
      likes: 100,
   } as RecipeBriefInfo, {
      id: 2,
      title: '可乐鸡翅',
      description: '西红柿炒鸡蛋',
      category: '',
      cookingTime: 0,
      difficulty: '',
      author: '美食博主',
      authorAvatar: 'startIcon',
      thumbnail: 'startIcon',
      views: 100,
      likes: 100,
   } as RecipeBriefInfo];

   build() {
      RelativeContainer() {
         HomeSearch({
            hotInfo: this.hotInfo,
            resultList: this.resultList,
            historyInfo: this.historyInfo,
            paramsKeyword: '',
            isShowResult: true,
            isShowSearch: true,
            searchDishes: (keyword: string) => {
               // 调用搜索查询事件
               promptAction.showToast({ message: '调用搜索查询' })
            },
            changeIndex: (index: number, keyword: string) => {
               // 切换搜索排序的事件
               promptAction.showToast({ message: '切换搜索排序' })
            },
            changeShowResult: (flag: boolean) => {
               // 切换展示搜索结果的事件
               promptAction.showToast({ message: '切换展示搜索结果' })
            },
            goRecipeDetail: (id: number) => {
               // 跳转菜谱详情事件
               promptAction.showToast({ message: '跳转菜谱详情' })
            },
         })
      }
      .height('100%')
      .width('100%')
      .padding({ top: 45 })
   }
}
```