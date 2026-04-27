# 日历组件快速入门

## 目录

- [简介](#简介)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供上门取件日期选择的功能。

<img src="screenshots/screenShot_20251230_163033.jpeg" width="300">

## 使用

1. 安装组件。

   需要将模板根目录的components下[calendar_select]()目录拷贝至您工程根目录components/，并添加依赖和module声明。

```
// main/oh-package.json5
"dependencies": {
  "calendar_select": "file:../components/calendar_select"
}

// build-profile.json5
"modules": [
  {
    "name": "calendar_select",
    "srcPath": "./components/calendar_select",
  }
]
```

2. 引入组件。

```
import { DateInfo } from 'calendar_select';
```

## API参考

### DateInfo()

#### 参数说明

| 参数名         | 类型        | 必填 | 说明       |
|:------------|:----------|:---|:---------|
| startDate   |[DateModel](#DateModel对象说明) | 是  | 初始开始日期   |
| endDate     | [DateModel](#DateModel对象说明) | 是  | 初始结束日期   |
| night       | number    | 是  | 晚数       |
| isShowPrice | boolean | 是  | 是否展示价格日历 |
| priceList   | Price | 是  | 价格日历     |

#### DateModel对象说明

| 参数名       | 类型     | 必填 | 说明   |
|:----------|:-------|:---|:-----|
| day      | number | 是  | 天数   |
| week | number | 是  | 起始时间 |
| month   | number | 是  | 结束时间 |
| year   | number | 是  | 结束时间 |

#### Price对象说明

| 参数名                | 类型            | 必填 | 说明 |
|:-------------------|:--------------|:---|:---|
| date              | string    | 是  | 日期 |
| price      | ResourceColor | 是  | 价格 |

## 示例代码

```
import { CalendarUtil, DateInfo, DateModel, getLastDayOfMonth, getRealTimeDate } from 'calendar_select';

@Entry
@Component
export struct Home {
  @StorageLink('night') night: number = CalendarUtil.getNight() ?? 1;
  @StorageLink('startDate') startDate: DateModel | undefined = CalendarUtil.getStartDate();
  @StorageLink('endDate') endDate: DateModel | undefined = CalendarUtil.getEndDate();
  @State currentMonth: number | undefined = CalendarUtil.getCurrentDate()?.month;
  @State currentDay: number | undefined = CalendarUtil.getCurrentDate()?.day;
  @State currentYear: number | undefined = CalendarUtil.getCurrentDate()?.year;
  
  aboutToAppear(): void {
    // 首次初始化
    let dates: Promise<undefined> = new Promise(() => {
      if (!AppStorage.get('startDate') && !AppStorage.get('endDate')) {
        this.startDate = getRealTimeDate();
        let date = new Date();
        let days = getLastDayOfMonth(this.currentYear ?? date.getFullYear(),
          this.currentMonth ?? date.getMonth());
        if (this.startDate.day >= days) {
          this.endDate =
            new DateModel(this.startDate.day - days + 1, this.startDate.week, this.startDate.month + 1,
              this.startDate.year);
        } else {
          this.endDate =
            new DateModel(this.startDate.day + 1, this.startDate.week, this.startDate.month, this.startDate.year);
        }

        AppStorage.setOrCreate('currentDate', this.startDate);
        AppStorage.setOrCreate('startDate', this.startDate);
        AppStorage.setOrCreate('endDate', this.endDate);
      }
    });

    dates.then(() => {
      promptAction.showToast({ message: '初始化日期成功' });
    });
  }

  build() {
    Column() {
      DateInfo(
        {
          startDate: this.startDate,
          endDate: this.endDate,
          night: this.night,
          isShowPrice: false,
          priceList: [],
        },
      )
        .backgroundColor('#f5f6fa')
        .borderRadius(8);
    };
  }
}
```
