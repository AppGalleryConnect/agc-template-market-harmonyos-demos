import { SearchSet } from 'common';
import { getDataFromJSON } from 'common';
import { RouteEntryVM } from 'common'
import { collections } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { RandomCountdown } from '../components/RandomCountdown'
import { RouterDetailParam } from '../viewmodels/RouterParams';

@Builder
export function TravelPlanBuilder() {
  TravelPlan()
}

class LineStartEnd {
  lineName: string = '';
  startStation = '';
  endStation = '';
}

@Component
export struct TravelPlan {
  @Consume('busLineTimeList') busLineTimeList: Map<string, RandomCountdown>
  vm: RouteEntryVM = RouteEntryVM.instance;
  @State listInfoItem: Array<SearchSet> = []
  @State startText: string = '' // 起点
  @State endText: string = '' //终点
  @State searchListInfoItem: Array<SearchSet> = [] // 传入的查询总数据
  @State sameLines: Array<LineStartEnd> = []
  @State stationNameList: Array<string> = [] // 传入搜索页面进行站点查询

  aboutToAppear(): void {
    this.initDataSource()
    console.log('============' + JSON.stringify(this.listInfoItem))
  }

  initDataSource() {
    this.listInfoItem = getDataFromJSON<SearchSet>('Bus_Station.json', this);
    for (let i = 0; i < this.listInfoItem.length; i++) {
      this.stationNameList.push(this.listInfoItem[i].stationName)
    }
  }

  getSearchListInfo() {
    if (this.startText) { // 判断用户是否输入了内容
      this.searchListInfoItem = this.listInfoItem.filter((item, index) => { // filter遍历listInfoItem
        return item.stationName.indexOf(this.startText) !== -1 // 若indexOf()返回的结果不为-1即name中包含changeValue，则保留该项
      }) // 筛选完后的值会被赋值到searchListInfoItem中
    }
  }

  // 1先找到在哪些线路
  findLine(str: string) {
    let strArr: Array<SearchSet> = []
    for (let index = 0; index < this.listInfoItem.length; index++) {
      const element = this.listInfoItem[index];
      if (str === element.stationName) {
        strArr.push(this.listInfoItem[index])
      }
    }
    return strArr;
  }

  // 2再找这两个线路中有无相同线路
  // searchset包含 线路名 起点终点站 经纬度 站名 seq
  // class应该改包含线路名 起点终点站 starttext 的经纬度 endtext
  findSameLine() {
    let arr1: Array<SearchSet> = this.findLine(this.startText)
    let arr2: Array<SearchSet> = this.findLine(this.endText)
    let lines1: Array<LineStartEnd> = []
    for (let i = 0; i < arr1.length; i++) {
      for (let j = 0; j < arr2.length; j++) {
        if (arr1[i].lineName === arr2[j].lineName && arr1[i].startStation === arr2[j].startStation) { // 确定为线路名
          if (arr1[i].sequence < arr2[j].sequence) { // 确认起始站和终点站顺序
            lines1.push({
              lineName: arr1[i].lineName,
              startStation: arr1[i].startStation,
              endStation: arr1[i].endStation
            })
          }
        }
      }
    }
    // 根据线路名去重
    if (lines1 !== null) {
      const uniqueLine = Array.from(
        new Map(lines1.map(lines1 => [lines1.lineName, lines1])).values()
      );
      let lines2 = Array.from(uniqueLine)
      return lines2
    } else {
      return lines1
    }
  }

  @Builder
  buildSearchItem() {
    Row() {
      Image($r('app.media.greenline'))
        .height(20)
        .width(2)
        .margin({ left: '5%', right: 9 })
      Text('推荐路线')
        .fontSize(16)
        .fontWeight(400)
    }
    .width('100%')
    .margin({ top: 16, bottom: 8 })

    List({ space: '8lpx' }) {
      ForEach(this.sameLines, (item: LineStartEnd) => {
        ListItem() {
          Row() {
            Row() {
              Image($r('app.media.ic_buslogo'))
                .height('25vp')
                .width('25vp')
                .margin({ left: '12vp', right: '11vp' })
              Flex({ direction: FlexDirection.Column }) {
                Text() {
                  Span(item.lineName)
                  Span('下行')
                    .margin({ right: '10vp' })
                  Span('(')
                  Span(item.startStation)
                  Span('-')
                  Span(item.endStation)
                  Span(')')
                }
                .fontSize(13)
                .margin({ top: '19vp', bottom: '12vp' })
                .textAlign(TextAlign.Start)

                Text() {
                  Span('距你') //以下全为随机数
                  Span(this.busLineTimeList.get(item.lineName)?.nearestFirstDis.toString()).fontColor('#62B42E')
                  Span('千米').fontColor('#62B42E')
                  Span('|').fontColor('#62B42E')
                  Span('预计')
                  Span(this.busLineTimeList.get(item.lineName)?.nearestFirstMin.toString()).fontColor('#62B42E')
                  Span('分钟').fontColor('#62B42E')
                }
                .fontSize(13)
                .textAlign(TextAlign.Start)
              }
            }

            Image($r('app.media.ic_public_right_arrow'))
              .height('16vp')
              .width('16vp')
              .margin({ right: '6vp' })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .height('74vp')
          .width('90%')
          .backgroundColor($r('app.color.background_color_white'))
          .margin({ left: '5%', right: '12lpx' })
          .borderRadius(12)
          .onClick(() => {
            this.vm.pushByParams('RouteDetail',
              { lineName: item.lineName, busTimer: this.busLineTimeList.get(item.lineName) } as RouterDetailParam)
          })
        }
      },(item:LineStartEnd)=>new Date().toString())
    }
  }

  build() {
    Column() {
      Row() {
        Column() {
          Row() {
            Image($r('app.media.circle_start'))
              .height(12)
              .width(12)
            TextInput({ text: $$this.startText, placeholder: '我的位置' })
              .caretColor($r('app.color.system_color_green'))
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .margin({ left: '8vp' })
              .onClick(() => {
                this.vm.toSearchDetail(this.stationNameList, (popInfo: PopInfo) => { // 跳转SpecificContentSearch
                  this.startText = `${popInfo.result}`
                  this.getSearchListInfo()
                })
              })
              .onChange(() => {
                this.sameLines = this.findSameLine()
                if (this.sameLines.length === 0 && this.startText.length && this.endText.length) {
                  promptAction.showToast({
                    message: '暂未查询到线路',
                    duration: 1500,
                    bottom: 80,
                  });
                }
              })
          }

          Image($r('app.media.dashedline'))
            .height('12vp')
            .width('1vp')
            .margin({ left: '6vp' })

          Row() {
            Image($r('app.media.circle_end'))
              .height(12)
              .width(12)
            TextInput({ text: $$this.endText, placeholder: '输入终点' })
              .caretColor($r('app.color.system_color_green'))
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .margin({ left: '8vp' })
              .onClick(() => {
                this.vm.toSearchDetail(this.stationNameList, (popInfo: PopInfo) => { // 跳转SpecificContentSearch
                  this.endText = `${popInfo.result}`
                  this.getSearchListInfo()
                })
              })
              .onChange(() => {
                this.sameLines = this.findSameLine()
                if (this.sameLines.length === 0 && this.startText.length && this.endText.length) {
                  promptAction.showToast({
                    message: '暂未查询到线路',
                    duration: 1500,
                    bottom: '80vp',
                  });
                }
              })
          }
        }
        .width('240vp')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)

        Image($r('app.media.change_dir'))// 点击 我的位置和输入终点文字互换
          .height('32vp')
          .width('32vp')
          .margin({ left: '22vp', right: '25vp' })
          .onClick(() => {
            let temp = this.startText
            this.startText = this.endText
            this.endText = temp
          })
      }
      .height('116vp')
      .width('90%')
      .borderRadius(16)
      // .margin({bottom: "12lpx"})
      .padding({ top: '14vp', left: '20vp', bottom: '14vp' })
      .backgroundColor($r('sys.color.comp_background_list_card'))


      if (this.sameLines.length) {
        this.buildSearchItem()
      }
      if (this.sameLines.length === 0 && this.startText.length && this.endText.length) {

      }
    }
    .width('100%')
    .height('100%')

  }
}