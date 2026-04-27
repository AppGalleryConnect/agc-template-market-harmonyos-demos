import { CommonMap } from 'travel_map';
import { phoneRouterControl } from 'oh_router';
import { BarVM, TValueType, RouterMap, GlobalContext } from 'common';
import { MapPageVM } from '../viewmodel/MapPageVM';
import { AttractionDetail } from '../common/mock/AttractionDetailMockData';
import { AttractionDetailPageBuilder } from './AttractionDetailPage';
import { ReputationItem } from '../common/mock/ReputationMockData';

@Builder
export function AttractionMapPageBuilder(params: TValueType) {
  AttractionMapPage({
    pageParams: params
  })
}

@ComponentV2
export struct AttractionMapPage {
  vm: MapPageVM = new MapPageVM()
  @Param pageParams: TValueType = Object()
  @Local attractionDetail: AttractionDetail | undefined = undefined
  @Local reputationItem: ReputationItem | undefined = undefined
  @Local attractionName: string = ''

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  aboutToAppear(): void {
    // 判断传入的参数类型
    const params = this.pageParams as Record<string, TValueType>
    if (params && typeof params === 'object') {
      // 检查是否是 AttractionDetail 类型（有 location 和 name 属性）
      if (params.location !== undefined && params.name !== undefined && params.headerImage !== undefined) {
        this.attractionDetail = this.pageParams as AttractionDetail
        this.attractionName = this.attractionDetail.name
      }
      // 检查是否是 ReputationItem 类型（有 rank 属性）
      else if (params.rank !== undefined) {
        this.reputationItem = this.pageParams as ReputationItem
        this.attractionName = this.reputationItem.name
      }
      // 如果都没有，尝试直接从 params 获取 name
      else if (params.name) {
        this.attractionName = params.name as string
      }
    }
    // 默认不显示底部卡片，点击地图上的点后才显示
    this.vm.showTips = false
  }

  // 获取景点名称
  getAttractionName(): string {
    if (this.attractionDetail) {
      return this.attractionDetail.name
    }
    if (this.reputationItem) {
      return this.reputationItem.name
    }
    // 如果还没有初始化，尝试从 pageParams 中获取
    const params = this.pageParams as Record<string, TValueType>
    if (params && params.name) {
      return params.name as string
    }
    return ''
  }

  // 获取位置信息
  getLocation(): string {
    if (this.attractionDetail) {
      return `${this.attractionDetail.location}·${this.attractionDetail.locationDetail}`
    }
    if (this.reputationItem) {
      return this.reputationItem.location
    }
    return ''
  }

  // 获取景点图片
  getAttractionImage(): Resource | string {
    if (this.attractionDetail) {
      return this.attractionDetail.headerImage
    }
    if (this.reputationItem) {
      return this.reputationItem.image
    }
    // 如果还没有初始化，尝试从 pageParams 中获取
    const params = this.pageParams as Record<string, TValueType>
    if (params && params.headerImage) {
      return params.headerImage as Resource
    }
    if (params && params.image) {
      return params.image as Resource | string
    }
    return $r('app.media.ic_reputation_header')
  }

  @Builder
  render() {
    Stack({ alignContent: Alignment.TopStart }) {
      Stack({ alignContent: Alignment.BottomEnd }) {
        CommonMap(
          {
            travelMapOptions: {
              location: {
                latitude: 31.968,
                longitude: 118.799,
              },
              icon: $r('app.media.point'),
              titleOptions: {
                name: this.attractionName || this.getAttractionName() || '景点',
                strokeColor: 0xFFFFFFFF,
              },
              cameraSpeed: 1000,
              zoom: 10,
              height: '100%',
              pointClickCallBack: () => {
                // 点击地图上的标记点时，显示底部卡片
                this.vm.showTips = true
              },
            },
          });
        if (this.vm.showTips) {
          Column() {
            this.BottomBuilder()
          }.padding({ left: 16, right: 16 }).width('100%').margin({ bottom: 16 })
        }
      }

      Row() {
        Image($r('app.media.ic_back_black')).width(40).height(40)
          .onClick(() => {
            phoneRouterControl.popPage()
          })
        Text('旅游地图')
          .fontSize(20)
          .fontColor('#000000')
          .fontWeight(500)
          .margin({ left: 8 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }.width('100%').margin({ top: BarVM.instance.staBarH, left: 16 })
    }

  }

  // 景点详情底部卡片
  @Builder
  BottomBuilder() {
    Row({ space: 12 }) {
      // 左侧景点图片
      Image(this.getAttractionImage())
        .width(77)
        .height(103)
        .borderRadius(10)
        .objectFit(ImageFit.Cover)

      // 右侧文字信息
      Column() {
        Row() {
          // 景点名称
          Text(this.getAttractionName())
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Blank()
          Image($r('app.media.icon_right_btn'))
            .width(20)
        }
        .onClick(() => {
          // 跳转到景点详情页
          if (this.reputationItem) {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.ATTRACTION_DETAIL_PAGE,
              builder: wrapBuilder(AttractionDetailPageBuilder),
              param: this.reputationItem
            })
          } else if (this.attractionDetail) {
            // 如果有 AttractionDetail，需要转换为 ReputationItem
            const item: ReputationItem = {
              id: this.attractionDetail.id,
              rank: 0,
              image: this.attractionDetail.headerImage,
              name: this.attractionDetail.name,
              reviewCount: '',
              travelHotspot: '',
              date: '',
              annualList: '',
              location: this.attractionDetail.location
            }
            phoneRouterControl.jumpPage({
              pageName: RouterMap.ATTRACTION_DETAIL_PAGE,
              builder: wrapBuilder(AttractionDetailPageBuilder),
              param: item
            })
          }
        })

        // 用户数据行
        Row({ space: 16 }) {
          Text('29%的用户选择')
            .fontSize(12)
            .fontColor('#666666')
        }
        .width('100%')
        .margin({ top: 10, bottom: 4 })

        Row() {
          Text('3810人收藏')
            .fontSize(12)
            .fontColor('#666666')
          Text('712人好评')
            .fontSize(12)
            .fontColor('#666666')
        }
        .width('100%')

        // 口碑榜标签
        Row({ space: 4 }) {
          Image($r('app.media.ic_top_badge'))
            .height(16)
            .objectFit(ImageFit.Contain)
          Text('口碑榜')
            .fontSize(12)
            .fontColor('#C77634')
        }
        .width('100%')
        .margin({ top: 4, bottom: 8 })

        Row() {
          Image($r('app.media.icon_location'))
            .width(16)
          // 位置信息
          Text(this.getLocation())
            .fontSize(12)
            .fontColor('#666666')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .height(103)

    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .padding(16)
  }
}

