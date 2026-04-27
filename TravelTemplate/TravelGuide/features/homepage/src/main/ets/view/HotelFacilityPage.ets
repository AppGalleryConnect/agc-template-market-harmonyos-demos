import { SharePicker } from 'aggregated_share';
import { BarVM, TValueType } from 'common';
import { HotelModel } from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';
import { HotelPolicyGridItem } from '../components/HotelPolicyGridItem';
import { HotelPolicyItem } from '../components/HotelPolicyItem';
import { HotelFacilityPageVM } from '../viewmodel/HotelFacilityPageVM';

@Builder
export function HotelFacilityPageBuilder(params: TValueType) {
  HotelFacilityPage({
    pageParams: params as HotelModel
  })
}

@ComponentV2
export struct HotelFacilityPage {
  vm: HotelFacilityPageVM = new HotelFacilityPageVM()
  @Require @Param pageParams: HotelModel
  @Local currentClassify: number = 0;
  @Local rating: number = 0;
  private scroller: Scroller = new Scroller();
  private containerScroller: Scroller = new Scroller();
  private classifyScroller: Scroller = new Scroller();
  private classifyList: Array<string> = ['设施服务', '酒店政策'];

  classifyChangeAction(startIndex: number, isClassify: boolean) {
    if (this.currentClassify !== startIndex) {
      this.currentClassify = startIndex;
      if (isClassify) {
        this.scroller.scrollToIndex(startIndex);
      } else {
        this.classifyScroller.scrollToIndex(startIndex);
      }
    }
  }

  getRating(str: string) {
    switch (str) {
      case '二星':
        this.rating = 2
        break;
      case '三星':
        this.rating = 3
        break;
      case '四星':
        this.rating = 4
        break;
      default:
        this.rating = 5
        break;
    }
    return this.rating
  }

  aboutToAppear(): void {
    this.getRating(this.pageParams.star)
  }

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

  @Builder
  render() {
    Column() {
      if (this.vm.isShowHeadTitle) {
        // 顶部标题
        this.HeaderTitleBuilder()
      }
      Scroll(this.containerScroller) {
        Column() {
          this.tabTop()
          this.content()
        }.width('100%')
      }
      .onDidScroll(() => {
        let currentOffset = this.containerScroller.currentOffset().yOffset; // 获取垂直滑动距离
        this.vm.isShowHeadTitle = currentOffset > 250;
      })
      .edgeEffect(EdgeEffect.None)
      .backgroundColor('#DCDCDC')
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
    }
  }

  // 顶部标题
  @Builder
  HeaderTitleBuilder() {
    Row() {
      Row() {
        Image($r('app.media.ic_back_black')).width(40).height(40)
          .onClick(() => {
            phoneRouterControl.popPage()
          })
        Text('亮点设施').fontSize(20).fontColor('#000000').margin({ left: 8 })
      }.justifyContent(FlexAlign.Start)

      Image($r('app.media.ic_share_black')).width(28).height(28)
        .onClick(() => {
          const picker: SharePicker = new SharePicker({
            title: 'HarmonyOS官方模板集成创新活动',
          });
          picker.show();
        })
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: BarVM.instance.staBarH, left: 16, right: 16 })
  }

  @Builder
  attractionHeader() {
    Row() {
      Row() {
        Image($r('app.media.ic_back_white')).width(40).height(40)
          .onClick(() => {
            phoneRouterControl.popPage()
          })
        Text('亮点设施').fontSize(20).fontColor('#FFFFFF').margin({ left: 8 })
      }.justifyContent(FlexAlign.Start)

      Image($r('app.media.ic_share')).width(28).height(28)
        .onClick(() => {
          const picker: SharePicker = new SharePicker({
            title: 'HarmonyOS官方模板集成创新活动',
          });
          picker.show();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: BarVM.instance.staBarH })
  }

  @Builder
  tabTop() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.icon_hotel_bg')).width('100%').objectFit(ImageFit.Contain)
      Column() {
        this.attractionHeader()
        Column() {
          Text(this.pageParams.name)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .fontWeight(500)
        }.width('100%').alignItems(HorizontalAlign.Start).margin({ top: 26, bottom: 10 })


        Column({ space: 12 }) {
          Row() {
            Text() {
              Span('开业时间  ').fontColor('rgba(255, 255, 255, 0.80)').fontWeight(400)
              Span(this.pageParams.openingTime).fontColor('#FFFFFF').fontWeight(500)
            }
            .width('50%')
            .fontSize(12)

            Text() {
              Span('房间数量  ').fontColor('rgba(255, 255, 255, 0.80)').fontWeight(400)
              Span(this.pageParams.quantity.toString()).fontColor('#FFFFFF').fontWeight(500)
            }
            .width('50%')
            .fontSize(12)
          }.justifyContent(FlexAlign.Start)

          Row() {
            Text() {
              Span('装修时间  ').fontColor('rgba(255, 255, 255, 0.80)').fontWeight(400)
              Span(this.pageParams.decorationTime).fontColor('#FFFFFF').fontWeight(500)
            }
            .width('50%')
            .fontSize(12)

            Row() {
              Text() {
                Span('酒店等级  ').fontColor('rgba(255, 255, 255, 0.80)').fontWeight(400)
              }.fontSize(12)

              Rating({ rating: this.rating, indicator: false })
                .stars(5)
                .stepSize(1)
                .starStyle({
                  backgroundUri: 'resource://base/media/ic_star_unchoosen.png',
                  foregroundUri: 'resource://base/media/ic_star_choosen.png'
                })
                .height('12vp')
                .width(70)
            }.justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
            .width('50%')

          }.justifyContent(FlexAlign.Start)

          Divider()
            .height(0.5)
            .color($r('sys.color.comp_divider'))
            .width('100%')

          Text() {
            Span('酒店电话  ').fontColor('rgba(255, 255, 255, 0.80)').fontWeight(400)
            Span(this.pageParams.telephone).fontColor('#FFFFFF').fontWeight(500)
          }
          .fontSize(12)

        }
        .backgroundColor('rgba(0, 0, 0, 0.30)')
        .width('100%')
        .padding(12)
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)
      }
      .height('100%')
      .padding({ left: 16, right: 16 })
      .linearGradient({

        colors:
        this.vm.isShowHeadTitle ?
          [
            ['#FFFFFF', 0], // 起始颜色及位置
            ['#FFFFFF', 1]// 结束颜色及位置
          ]
          :
          [
            ['rgba(0, 0, 0, 0.60)', 0], // 起始颜色及位置
            ['rgba(0, 0, 0, 0.30)', 0.5],
            ['rgba(0, 0, 0, 0.60)', 1]// 结束颜色及位置
          ]
      })
    }.width('100%').height('35%').margin({ bottom: -24 })
  }

  @Builder
  content() {
    Column() {
      List({ space: 10 }) {
        ForEach(this.classifyList, (item: string, index: number) => {
          ListItem() {
            Column() {
              Text(item)
                .fontSize(14)
                .fontColor(index === this.currentClassify ?
                  '#000000' : 'rgba(0, 0, 0, 0.50)')
                .fontWeight(500)
                .textAlign(TextAlign.Center)
              Divider()
                .width(36)
                .color($r('sys.color.comp_divider'))
                .strokeWidth(2)
                .visibility(index === this.currentClassify ? Visibility.Visible : Visibility.Hidden)
                .margin({
                  top: 8
                })
            }
            .justifyContent(FlexAlign.Center)
            .width('50%')
            .height('100%')
          }
          .onClick(() => {
            this.classifyChangeAction(index, true);
          })
        }, (item: string, _index: number) => JSON.stringify(item))
      }
      .height(46)
      .padding({ left: 16, right: 16 })
      .borderRadius({ topLeft: 24, topRight: 24 })
      .backgroundColor('#FFFFFF')
      .width('100%')
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

      List({ scroller: this.scroller }) {
        ForEach(this.classifyList, (item: string, index: number) => {
          if (index !== this.classifyList.length - 1) {
            ListItem() {
              Column() {
                // 标题
                Text('设施服务')
                  .fontSize(18).fontColor('#000000').fontWeight(500).margin({ top: 16 })

                Column() {
                  Row() {
                    Image($r('app.media.ic_parking')).width(14).height(14)
                    Text('交通服务').textTitle()
                  }.justifyContent(FlexAlign.Start).width('100%').alignItems(VerticalAlign.Top)

                  Column({ space: 6 }) {
                    Text('公共停车场').textStyleTitle()
                    Text('所处位置：酒店附近停车场').textStyleTitle()
                    Text('预约信息：无法提前预定').textStyleTitle()
                    Text('供应情况：车位紧张').textStyleTitle()
                    Text('收费信息：每小时¥4').textStyleTitle()
                  }.width('100%').alignItems(HorizontalAlign.Start).margin({ left: 21 })
                }.margin({ top: 20 }).justifyContent(FlexAlign.Start).width('100%')

                HotelPolicyGridItem({
                  img: 'app.media.ic_catering',
                  title: '餐饮服务',
                  items: [
                    '无餐厅',
                  ]
                })


                HotelPolicyGridItem({
                  img: 'app.media.ic_reception',
                  title: '前台服务',
                  items: [
                    '行李寄存',
                    '快速入住退房',
                    '24小时前台',
                    '叫醒服务',
                    '电子身份证入住'
                  ]
                })

                HotelPolicyGridItem({
                  img: 'app.media.ic_public_area',
                  title: '公共区',
                  items: [
                    '公用区wifi',
                    '公共区域禁烟',
                    '电梯'
                  ]
                })

                HotelPolicyGridItem({
                  img: 'app.media.ic_clean',
                  title: '清洁服务',
                  items: [
                    '洗衣服务',
                    '洗衣房'
                  ]
                })
                HotelPolicyGridItem({
                  img: 'app.media.ic_security',
                  title: '安全与安保',
                  items: [
                    '灭火报警器'
                  ]
                })
                HotelPolicyGridItem({
                  img: 'app.media.ic_barrier_free',
                  title: '无障碍设施服务',
                  items: [
                    '无障碍通道'
                  ]
                })
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .alignItems(HorizontalAlign.Start)
            }
          } else {
            ListItem() {
              Column() {
                // 标题
                Text('酒店政策')
                  .fontSize(18).fontColor('#000000').fontWeight(500).margin({ top: 16 })

                // 入离时间
                HotelPolicyItem({
                  img: 'app.media.ic_exit_time',
                  title: '入离时间',
                  items: [
                    '入住时间：14:00后',
                    '退房时间：12:00前'
                  ]
                })

                // 入住方式
                HotelPolicyItem({
                  img: 'app.media.ic_method',
                  title: '入住方式',
                  items: [
                    '可到店使用自助入住机办理入住'
                  ]
                })

                // 可接待人群
                HotelPolicyItem({
                  img: 'app.media.ic_acceptable',
                  title: '可接待人群',
                  items: [
                    '接待来自任何国家/地区的客人'
                  ]
                })

                // 年龄限制
                HotelPolicyItem({
                  img: 'app.media.ic_restriction',
                  title: '年龄限制',
                  items: [
                    '入住办理需年满18岁'
                  ]
                })
              }
              .height('100%')
              .width('100%')
              .backgroundColor('#FFFFFF')
              .alignItems(HorizontalAlign.Start)
            }
          }
        }, (item: string, _index: number) => JSON.stringify(item))
      }
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .height('calc(100% - 50vp)')
      .edgeEffect(EdgeEffect.Spring)
      .onScrollIndex((start: number) => this.classifyChangeAction(start, false))
      .scrollBar(BarState.Off)
      .padding({
        left: 16,
        right: 16,
      })
      .backgroundColor('#FFFFFF')
      .edgeEffect(EdgeEffect.None)
    }

  }

  @Builder
  CardItemComponent() {
    Column() {

    }
  }
}

@Extend(Text)
function textTitle() {
  .fontSize(14)
  .fontColor('#000000')
  .fontWeight(500)
  .margin({ left: 7, bottom: 10 })
}

@Extend(Text)
function textStyleTitle() {
  .fontSize(12)
  .fontColor('rgba(0, 0, 0, 0.50)')
  .fontWeight(500)
}