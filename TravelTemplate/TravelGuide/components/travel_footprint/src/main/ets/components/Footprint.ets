import { FootPrintItem, FootPrintList } from '../viewmodel/FootprintModel'
import { FootprintVm } from '../viewmodel/FootprintVm'
import { LightMap } from './LightMap'
import { SelectWithWhiteArrow } from './SelectWithWhiteArrow'

/**
 * @usage: 旅行足迹主组件，展示用户的旅行足迹地图、总里程和按年份分组的足迹列表
 * @layout: 层叠布局，顶部导航栏+点亮地图+里程统计+年份筛选+足迹列表
 * @isGen: true
 * @fileType: component
 * @zhName: 旅行足迹组件
 * @domain: 旅游
 * @component: LightMap, SelectWithWhiteArrow
 */
@ComponentV2
export struct Footprint {
  @Param footPrints: FootPrintItem[] = []
  @Event returnClick?: () => void | undefined = undefined
  @Event addPostClick?: () => void | undefined = undefined
  @Event jumpPostClick?: (id: string) => void | undefined = undefined
  vm: FootprintVm = new FootprintVm()

  @Monitor('footPrints')
  onDataChange() {
    this.vm.initData(this.footPrints)
  }

  aboutToAppear() {
    this.vm.initData(this.footPrints)
  }

  @Builder
  pageHeader() {
    Row() {
      Row({ space: 8 }) {
        if (this.returnClick !== undefined) {
          Image($r('app.media.white_back'))
            .width(40)
            .height(40)
            .onClick(() => {
              if (this.returnClick) {
                this.returnClick()
              }
            })
        }

        Text('旅行足迹')
          .fontSize(20)
          .fontColor('#fff')
      }

      if (this.addPostClick !== undefined) {
        Row({ space: 4 }) {
          Image($r('app.media.ic_add_circle'))
            .width(16)
            .height(16)
          Text('添加足迹')
            .fontSize(16)
            .fontColor('#fff')
        }
        .onClick(() => {
          if (this.addPostClick) {
            this.addPostClick()
          }
        })
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .padding({ left: 16, right: 16 })
    .position({ top: 36, left: 0 })
    .backgroundColor(Color.Transparent)
  }

  @Builder
  mileageRow() {
    Row() {
      Column({ space: 10 }) {
        Text('总里程')
          .fontColor('rgba(255, 255, 255, 0.50)')
          .fontSize(14)
        Text() {
          Span(this.vm.getMiles())
            .fontSize(32)
            .fontWeight(700)
          Span(' 公里')
            .fontSize(13)
        }
        .fontColor('#fff')
      }
      .alignItems(HorizontalAlign.Start)

      Text('中国')
        .padding({
          left: 10,
          right: 10,
          top: 6,
          bottom: 6
        })
        .fontSize(14)
        .fontWeight(500)
        .fontColor('#fff')
        .borderRadius(14)
        .linearGradient({
          angle: 132,
          colors: [['#39D8F6', 0.0], ['#1175FF', 1]]
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .margin({ bottom: 10 })
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Bottom)
  }

  @Builder
  selectRow() {
    Row() {
      Blank()
      Row({ space: 28 }) {
        Text('全部')
          .fontSize(14)
          .fontColor(this.vm.showAll ? '#fff' : 'rgba(255, 255, 255, 0.50)')
          .fontWeight(500)
          .onClick(() => {
            this.vm.showAll = true
            this.vm.changeSelect()
          })

        SelectWithWhiteArrow({
          options: this.vm.selectList,
          selectedIndex: this.vm.selectIndex,
          value: this.vm.selectYear,
          onSelect: (index: number, value: ResourceStr) => {
            this.vm.showAll = false
            this.vm.selectIndex = index;
            if (value) {
              this.vm.selectYear = value;
            }
            this.vm.changeSelect()
          },
          selectWidth: 64,
          selectHeight: 28,
          fontSizeRes: 16,
          textColor: this.vm.showAll ? 'rgba(255, 255, 255, 0.50)' : '#fff',
          cornerRes: 32,
          selectedTextColor: '#157FFE',
          itemWidth: 131,
          itemHeight: 51,
        })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .margin({ bottom: 8 })
  }

  @Builder
  footPrintListBuilder() {
    Column({ space: 24 }) {
      ForEach(this.vm.footPrintList, (item: FootPrintList) => {
        this.footPrintRowBuilder(item)
      },(item: FootPrintList) => JSON.stringify(item))
    }
    .padding({ left: 16, right: 16 })
  }

  @Builder
  footPrintRowBuilder(item: FootPrintList) {
    Column({ space: 8 }) {
      Text(item.year)
        .fontColor('rgba(255, 255, 255, 0.50)')
        .fontSize(16)
        .fontWeight(500)

      Scroll() {
        Row({ space: 8 }) {
          ForEach(item.list, (footPrintItem: FootPrintItem) => {
            Column({ space: 6 }) {
              Image(footPrintItem.img)
                .width(104)
                .height(78)
                .borderRadius(12)
              Text(footPrintItem.city)
                .fontColor('#fff')
                .fontWeight(500)
                .fontSize(12)
            }
            .onClick(() => {
              if (this.jumpPostClick) {
                this.jumpPostClick(footPrintItem.id)
              }
            })
          },(item: FootPrintItem) => JSON.stringify(item))
        }
      }
      .width('100%')
      .align(Alignment.Start)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .scrollable(ScrollDirection.Horizontal)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  build() {
    Stack() {
      Scroll() {
        Column() {
          LightMap({ lightItems: this.vm.lightItems })
          this.mileageRow()
          if (this.vm.selectList.length) {
            this.selectRow()
          }
          this.footPrintListBuilder()
        }
      }
      .padding({ bottom: 24 })
      .layoutWeight(1)
      .width('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      this.pageHeader()
    }
    .align(Alignment.TopStart)
    .width('100%')
    .height('100%')
  }
}
