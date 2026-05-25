# 滑动卡片组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了展示滑动卡片的相关功能。

<img src="./screenshot/swiper_card.PNG" width="300">

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.4 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.4 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）、平板
- HarmonyOS版本：HarmonyOS 5.0.4(16)及以上

### 权限

- 无

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。
   
   如果是从生态市场下载组件，请参考以下步骤安装组件。 
   
   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。 
   
   b. 在项目根目录build-profile.json5中添加swiper_card。
   ```typescript
   // 在项目根目录的build-profile.json5填写swiper_card路径。其中xxx为组件存在的目录名
      "modules": [
     {
       "name": "swiper_card",
       "srcPath": "./xxx/swiper_card"
     },
     {
        "name": "base_common",
        "srcPath": "./xxx/base_common",
     }
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```typescript
   // xxx为组件存放的目录名称
     "dependencies": {
     "swiper_card": "file:./xxx/swiper_card",
     "base_common": "file:./xxx/base_common"
   }
   ```

2. 引入组件。

   ```typescript
   import { swiper_card } from 'swiper_card';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

   ```typescript
    TUISwiper({
     imgWidth: , // 中心图片宽度
     imgHeight: , // 中心图片高度
     interval: , // 间隔时间
     isLoop: , // 是否循环
     builderList: , // 图书卡片布局
     bookList: , // 图书数据
     onImageClick: (index: number) => {
       // 图片被点击时执行的操作
     }
   })
   ```

## API参考

### 接口

TUISwiper({
   imgWidth: number,
   imgHeight: number,
   interval: number,
   builderList: LazyDataVM<BookInfo>,
   bookList: WrappedBuilder<BookInfo>,
   isLoop: boolean,
   onImageClick: (index: number) => {
   }
})

展示滑动卡片页面组件。

**参数：**

| 参数名          | 类型                                                       | 是否必填 | 说明       |
|-------------|----------------------------------------------------------|----|----------|
| imgWidth    | number                                                   | 否  | 中心图片宽度   |
| imgHeight   | number                                                   | 否  | 中心图片高度   |
| interval    | number                                                   | 否  | 间隔时间     |
| isLoop      | boolean                                                  | 否  | 是否循环     |
| builderList | WrappedBuilder<[BookInfo](#BookInfo对象说明)>                | 是  | 封装全局的图书数据 |
| bookList    | [LazyDataVM](#LazyDataVM对象说明)<[BookInfo](#BookInfo对象说明)> | 是  | 图书数据     |

### LazyDataVM对象说明

| 名称         | 类型                          | 是否必填 | 说明   |
|------------|-----------------------------|---|------|
| dataArray  | [BookInfo](#BookInfo对象说明)[] | 是 | 图书列表 |

### BookInfo对象说明

| 名称        | 类型                                    | 是否必填 | 说明         |
| ----------- | --------------------------------------- | -------- | ------------ |
| id          | string                                  | 是       | 图书id       |
| name        | string                                  | 是       | 图书名称     |
| coverUrl    | PixelMap\ResourceStr\DrawableDescriptor | 否       | 封面         |
| rankUrl     | PixelMap\ResourceStr\DrawableDescriptor | 否       | 等级图标     |
| rate        | string                                  | 是       | 等级数       |
| description | string                                  | 是       | 描述         |
| author      | string                                  | 是       | 作者         |
| localPath   | string                                  | 否       | 图书本地路径 |
| epubUrl     | string                                  | 是       | 图书的epub   |
| category    | string                                  | 是       | 类别         |
| isFree      | string                                  | 是       | 付费类型     |
| count       | string                                  | 否       | 字数         |
| popular     | string                                  | 否       | 热度         |
| gender      | string                                  | 否       | 性别         |

### 事件

支持以下事件：

#### onImageClick

onImageClick(callback: (id: number) => void)

图片被点击时执行的操作

## 示例代码

```typescript
import { BookInfo, LazyDataVM, TUISwiper, bookSingleSwiper } from 'swiper_card';

const bookSingleSwiperBuilder: WrappedBuilder<[BookInfo]> = wrapBuilder(bookSingleSwiper);
@Entry
@ComponentV2
struct Index {
   @Local books: LazyDataVM<BookInfo> = new LazyDataVM();
   @Local imgHeight: number = 250;
   @Local imgWidth: number = 150;
   @Local builderList: WrappedBuilder<[BookInfo]>[] = []

   aboutToAppear(): void {
      this.books.pushArrayData([{
         "id": "1",
         "author": "作者",
         "name": "设计理论实践应用",
         "coverUrl": "app.media.book_image_1",
         "category": "艺术",
         "rate": "8",
         "count": "102万字",
         "popular": "10.5",
         "isFree": "0",
         "gender": "2"
      } as BookInfo, {
         "id": "2",
         "author": "作者",
         "name": "小羊肖恩",
         "coverUrl": "app.media.book_image_2",
         "category": "文学",
         "rate": "7",
         "count": "102万字",
         "popular": "10.5",
         "isFree": "1",
         "gender": "2"
      } as BookInfo,{
         "id": "2",
         "author": "作者",
         "name": "小羊肖恩",
         "coverUrl": "app.media.book_image_2",
         "category": "文学",
         "rate": "7", 
         "count": "102万字",
         "popular": "10.5",
         "isFree": "1",
         "gender": "2"
      } as BookInfo])
      this.builderList.push(bookSingleSwiperBuilder);
      this.builderList.push(bookSingleSwiperBuilder);
      this.builderList.push(bookSingleSwiperBuilder);
   }

   build() {
      Column() {
         TUISwiper({
            imgWidth: this.imgWidth,
            imgHeight: this.imgHeight,
            builderList: this.builderList,
            bookList: this.books,
            isLoop: true,
            onImageClick: (index: number) => {
            }
         })
      }
   }
}
```

<img src="./screenshot/swiper_card.PNG" width="300">