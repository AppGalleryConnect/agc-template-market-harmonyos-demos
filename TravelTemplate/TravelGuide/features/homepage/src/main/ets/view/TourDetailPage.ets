import { BarVM, TValueType } from 'common'
import {
  Activity, DetailsFeatures, ItineraryDay, LineSchedule, TourModel
} from 'common_travel_guide'
import { phoneRouterControl } from 'oh_router'
import { TourDetailPageVM } from '../viewmodel/TourDetailPageVM'
import { detailsFeaturesList, purchaseNoteList } from '../common/mock/TourDetailMockData'

@Builder
export function TourDetailPageBuilder(params?: TValueType) {
  TourDetailPage({ pageParam: params as TourModel })
}

phoneRouterControl.registerPageBuilder('TourDetailPage', wrapBuilder(TourDetailPageBuilder))

@ComponentV2
export struct TourDetailPage {
  vm: TourDetailPageVM = new TourDetailPageVM()
  @Param pageParam: TValueType = null
  private containerScroller: Scroller = new Scroller();
  // 详情、须知、行程tabs，Scroller控制器
  private classifyTitleScroller: Scroller = new Scroller();
  // 详情、须知、行程tabContent，Scroller控制器
  private classifyListScroller: Scroller = new Scroller();
  // 行程:左列表分类标题
  private itineraryTitleScroller: Scroller = new Scroller();
  // 行程:右列表内容区域
  private itineraryListScroller: Scroller = new Scroller();
  // 新路班期
  private scheduleListScroller: ListScroller = new ListScroller()

  aboutToAppear(): void {
    // 根据路由传参获取详情数据
    const model: TourModel | null = this.pageParam as TourModel
    this.vm.detailInfo = model;
    // 默认选择第一个班期
    let schedule = model.lineSchedule[0]
    this.vm.price = schedule.price
    this.vm.scheduleCreateDate = schedule.createDate
    this.vm.scheduleDateCode = schedule.dateCode
    if (this.vm.tourCollectList.tourCollectList && this.vm.tourCollectList.tourCollectList?.length) {
      this.vm.isCollect = this.vm.tourCollectList.tourCollectList.some(item => item.id === model.id);
    }
  }

  // 详情、须知、行程:下标索引处理
  classifyChangeAction(startIndex: number, isClassify: boolean) {
    if (this.vm.classifyCurrentIndex !== startIndex) {
      this.vm.classifyCurrentIndex = startIndex;
      if (isClassify) {
        this.classifyListScroller.scrollToIndex(startIndex);
      } else {
        this.classifyTitleScroller.scrollToIndex(startIndex);
      }
    }
  }

  // 行程安排:下标索引处理
  itineraryChangeAction(index: number, isClassify: boolean): void {
    if (this.vm.itineraryCurrentIndex !== index) {
      this.vm.itineraryCurrentIndex = index;
      if (isClassify) {
        this.itineraryListScroller.scrollToIndex(index);
      } else {
        this.itineraryTitleScroller.scrollToIndex(index);
      }
    }
  }

  // 景点图片和名称信息
  @Builder
  attractionHeader() {
    Stack({ alignContent: Alignment.Bottom }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($r(this.vm.detailInfo?.image))
          .width('100%')
          .objectFit(ImageFit.Contain)
      }

      Column() {
        Text(this.vm.detailInfo?.title)
          .width('100%')
          .fontColor('#333333')
          .fontSize(17)
          .margin({ bottom: 6 })
        Text(this.vm.detailInfo?.subTitle)
          .width('100%')
          .fontColor('#717376')
          .fontSize(10)
      }
      .width('100%')
      .padding({
        top: 12,
        bottom: 12,
        left: 16,
        right: 16
      })
      .borderRadius({ topLeft: 24, topRight: 24 })
      .backgroundColor($r('sys.color.background_primary'))
    }
    .margin({ bottom: 8 })
  }

  // 线路班期水平列表（从当天起30天）
  @Builder
  scheduleListBuilder() {
    Column() {
      Text('线路班期')
        .fontSize(10)
        .fontColor('#496792')
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 4 })

      List({ space: 8, scroller: this.scheduleListScroller }) {
        ForEach(this.vm.detailInfo?.lineSchedule, (item: LineSchedule, index: number) => {
          ListItem() {
            Column() {
              Text(item.date)
                .fontSize(12)
                .fontColor('#000000')
              Text(item.dateCode)
                .fontSize(14)
                .fontColor('#000000')
                .lineHeight(18)
              Text('¥' + item.price)
                .fontSize(14)
                .fontColor('#FF4A26')
            }
            .padding({
              top: 12,
              bottom: 12,
              left: 10,
              right: 10
            })
            .backgroundColor(this.vm.selectedScheduleIndex === index ? '#FEE231' : '#F8FAFD')
            .border({ width: 0.5, color: '#EBEFF5', radius: 8 })
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              this.vm.price = item.price
              this.vm.scheduleCreateDate = item.createDate
              this.vm.scheduleDateCode = item.dateCode
              this.vm.selectedScheduleIndex = index
              if (index > 2) {
                this.scheduleListScroller.scrollToIndex(index - 2)
              }
            })
          }
        }, (item: LineSchedule) => item.toString())
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .listDirection(Axis.Horizontal)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
    }
    .margin({ bottom: 8 })
    .padding({
      left: 16,
      right: 16,
      top: 6,
      bottom: 10
    })
    .backgroundColor($r('sys.color.background_primary'))
  }

  // 详情、须知、行程
  @Builder
  classifyTitleBuilder(item: string, index: number) {
    Column() {
      Text(item)
        .fontSize(14)
        .fontColor(index === this.vm.classifyCurrentIndex ?
          '#000000' : 'rgba(0,0,0,0.5)')
        .fontWeight(index === this.vm.classifyCurrentIndex ? 500 :
        FontWeight.Normal)
        .width(70)
        .textAlign(TextAlign.Center)
        .lineHeight(22)
      Divider()
        .width(36)
        .color($r('sys.color.comp_divider'))
        .strokeWidth(2)
        .visibility(index === this.vm.classifyCurrentIndex ? Visibility.Visible : Visibility.Hidden)
        .margin({
          top: 6
        })
    }
    .width('33%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.background_primary'))
  }

  // 详情特色
  @Builder
  detailsFeaturesBuilder() {
    Column({ space: 18 }) {
      Text('详情特色')
        .width('100%')
        .fontSize(18)
        .fontWeight(500)
        .fontColor('#000000')
      Column({ space: 16 }) {
        ForEach(detailsFeaturesList, (item: DetailsFeatures) => {
          Column({ space: 10 }) {
            Row({ space: 8 }) {
              Image($r(item.icon)).width(20).height(20)
              Text(item.title)
                .fontSize(14)
                .fontWeight(500)
                .fontColor('#000000')
            }

            Column({ space: 8 }) {
              if (Array.isArray(item.describe)) {
                ForEach(item.describe as string[], (desc: string) => {
                  Text(desc).fontSize(10).fontColor('#808080')
                }, (desc: string) => desc)
              } else {
                Text(item.describe as string).fontSize(12).fontColor('#808080')
              }
            }
            .padding({ left: 28 })
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }, (item: DetailsFeatures, index) => `${item.id}_${index}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('sys.color.background_primary'))
  }

  // 购买须知
  @Builder
  purchaseNotesBuilder() {
    Column({ space: 18 }) {
      Text('购买须知')
        .width('100%')
        .fontSize(18)
        .fontWeight(500)
        .fontColor('#000000')

      Column({ space: 16 }) {
        ForEach(purchaseNoteList, (item: DetailsFeatures) => {
          Row() {
            Row({ space: 22 }) {
              Image($r(item.icon)).width(32).height(32)
              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(14)
                  .fontColor('#000000')
                  .fontWeight(500)
                if (Array.isArray(item.describe)) {
                  ForEach(item.describe as string[], (desc: string) => {
                    Text(desc).fontSize(12).fontColor('#808080')
                  }, (desc: string) => desc)
                } else {
                  Text(item.describe as string).fontSize(12).fontColor('#808080')
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              this.vm.jumpPurchaseNotesPage()
            })

            Image($r('app.media.icon_right_arrow')).width(20).height(20)
          }
          .justifyContent(FlexAlign.SpaceBetween)
        }, (item: DetailsFeatures, index) => `${item.id}_${index}`)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('sys.color.background_primary'))
  }

  // 行程安排
  @Builder
  itineraryPlanBuilder() {
    Column({ space: 10 }) {
      Text('行程安排')
        .width('100%')
        .fontSize(18)
        .fontWeight(500)
        .fontColor('#000000')
        .padding({ left: 16, right: 16 })
      // 列表页
      Row() {
        List({ scroller: this.itineraryTitleScroller }) {
          ForEach(this.vm.detailInfo?.itinerary, (item: ItineraryDay, index: number) => {
            ListItem() {
              this.itineraryTitleBuilder(`${item.day.toString()}`, index)
            }
          }, (item: ItineraryDay, index: number) => item.day.toString() + index)
        }
        .width(64)
        .height('100%')
        .backgroundColor('#FAFAFA')
        .listDirection(Axis.Vertical)
        .scrollBar(BarState.Off)
        .contentEndOffset(12)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

        List({ space: 16, scroller: this.itineraryListScroller }) {
          ForEach(this.vm.detailInfo?.itinerary, (item: ItineraryDay) => {
            ListItemGroup({
              header: this.itineraryListHeaderBuilder(item.title),
              space: 12,
            }) {
              ListItem() {
                Grid() {
                  ForEach(item.activities, (listItem: Activity) => {
                    GridItem() {
                      Column({ space: 6 }) {
                        Row({ space: 6 }) {
                          Image($r(listItem.icon))
                            .width(14)
                            .height(14)
                          Text(listItem.activity)
                            .fontColor('rgba(0,0,0,0.7)')
                            .fontSize(12)
                        }.width('100%')
                      }.width('100%')
                    }
                  }, (listItem: Activity) => `${item.day}${listItem.activity}`)
                }
              }
            }
          }, (item: ItineraryDay) => item.day.toString())
        }
        .layoutWeight(1)
        .height('100%')
        .margin({ left: 8, right: 16 })
        .scrollBar(BarState.Off)
        .sticky(StickyStyle.None)
        .contentStartOffset(12)
        .contentEndOffset(12)
        .onScrollIndex((start: number) => this.itineraryChangeAction(start, false))
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .height(400)
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ bottom: 50 })
  }

  // 行程标题分类
  @Builder
  itineraryTitleBuilder(typeName: string, index: number) {
    Row() {
      Text(`第${typeName}天`)
        .fontSize(12)
        .fontWeight(this.vm.itineraryCurrentIndex === index ? 500 : FontWeight.Normal)
        .fontColor(this.vm.itineraryCurrentIndex === index ? 'rgba(0,0,0,1)' : 'rgba(0,0,0,0.7)')
        .textAlign(TextAlign.Center)
    }
    .border({ width: { right: this.vm.itineraryCurrentIndex === index ? 2 : 0 }, color: '#000000' })
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .margin({ top: 14, bottom: 14 })
    .constraintSize({ maxWidth: '100%' })
    .onClick(() => {
      this.itineraryChangeAction(index, true);
    })
  }

  // 行程内容头部标题
  @Builder
  itineraryListHeaderBuilder(title: string) {
    Row() {
      Text(title).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#000000')
    }.width('100%').margin({ bottom: 12 })
  }

  // 顶部标题
  @Builder
  HeaderTitleBuilder() {
    Row({ space: 8 }) {
      // 返回按钮
      Image(this.vm.isShowHeadTitle ? $r('app.media.icon_back') : $r('app.media.ic_back_white'))
        .height(40)
        .width(40)
        .onClick(() => {
          this.vm.backPage();
        })
      if (this.vm.isShowHeadTitle) {
        Text(this.vm.detailInfo?.title)
          .fontColor('#000000')
          .fontSize(20)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .padding({
      top: 8 + BarVM.instance.staBarH,
      left: 16,
      bottom: 8,
      right: 16
    })
    .backgroundColor(this.vm.isShowHeadTitle ? $r('sys.color.background_primary') : Color.Transparent)
  }

  //   底部按钮
  @Builder
  BottomOperationBuilder() {
    Row({ space: 12 }) {
      Column() {
        Image(this.vm.isCollect ? $r('app.media.ic_collect') : $r('app.media.ic_uncollect'))
          .width(24)
          .height(24)
        Text(this.vm.isCollect ? '已收藏' : '收藏').fontSize(12).fontColor('#333333')
      }
      .onClick(() => {
        this.vm.handleCollect()
      })

      // 搜索按钮
      Text('下一步')
        .fontSize(16)
        .fontColor('#FF333333')
        .fontWeight(500)
        .layoutWeight(1)
        .height(43)
        .textAlign(TextAlign.Center)
        .backgroundColor('#FFFEE231')
        .borderRadius(24)
        .onClick(() => {
          this.vm.jumpTourOrderPage()
        })
    }.width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: BarVM.instance.aiBarH + 12
    })
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  render() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // 顶部标题
        if (this.vm.isShowHeadTitle) {
          this.HeaderTitleBuilder()
        }
        Stack({ alignContent: Alignment.TopStart }) {
          // 滚动区域
          Scroll(this.containerScroller) {
            Column() {
              // 背景图和景点介绍
              this.attractionHeader()
              // 线路班期
              this.scheduleListBuilder()
              // 吸顶区域
              Column() {
                // tabs:详情、须知、行程
                List({ scroller: this.classifyTitleScroller }) {
                  ForEach(this.vm.classifyTitleList, (item: string, index: number) => {
                    ListItem() {
                      this.classifyTitleBuilder(item, index)
                    }
                    .margin({ bottom: 8 })
                    .onClick(() => {
                      this.classifyChangeAction(index, true);
                    })
                  }, (item: string, _index: number) => JSON.stringify(item))
                }
                .height(50)
                .listDirection(Axis.Horizontal)
                .scrollBar(BarState.Off)
                .edgeEffect(EdgeEffect.Spring)

                // tabContent:详情特色、购买须知、行程安排
                List({ scroller: this.classifyListScroller }) {
                  // 详情特色
                  ListItem() {
                    this.detailsFeaturesBuilder()
                  }
                  .margin({ bottom: 8 })

                  // 购买须知
                  ListItem() {
                    this.purchaseNotesBuilder()
                  }.margin({ bottom: 8 })

                  // 行程计划
                  ListItem() {
                    Column() {
                      this.itineraryPlanBuilder()
                    }
                    .height('100%')
                  }
                }
                .nestedScroll({
                  scrollForward: NestedScrollMode.PARENT_FIRST,
                  scrollBackward: NestedScrollMode.SELF_FIRST
                })
                .height('calc(100% - 50vp)')
                .edgeEffect(EdgeEffect.Spring)
                .onScrollIndex((start: number) => this.classifyChangeAction(start, false))
                .scrollBar(BarState.Off)
                .edgeEffect(EdgeEffect.None)
              }.height('100%')
            }
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .onDidScroll(() => {
            let currentOffset = this.containerScroller.currentOffset().yOffset; // 获取垂直滑动距离
            this.vm.isShowHeadTitle = currentOffset > 250;
          })

          // 顶部返回按钮
          if (!this.vm.isShowHeadTitle) {
            this.HeaderTitleBuilder()
          }
        }
      }
      .backgroundColor($r('sys.color.background_secondary'))

      // 底部操作栏
      this.BottomOperationBuilder()
    }
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
  }
}
