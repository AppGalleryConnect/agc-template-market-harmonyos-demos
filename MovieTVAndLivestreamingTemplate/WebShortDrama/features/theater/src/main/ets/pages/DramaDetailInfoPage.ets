import { buttonItem, getColor, getMedia, NAV_PAGE_NAME } from '@agctemplate/resources';
import {
  AiBarHeight,
  AppStorageKeys,
  StatusBarHeight,
  UserInfoModel,
  ColorMode,
  FontModel,
  fp2pxUtil
} from '@agctemplate/widgets';
import { AppStorageV2, promptAction, window } from '@kit.ArkUI';
import { appRouter, container, NavParams, WindowManager } from '@agctemplate/utils';
import { DramaCoverVM } from '../viewmodels/DramaCoverVM';
import { ActorInfo, DramaDetailVM } from '../viewmodels/DramaDetailVM';
import { DramaRecommendInfo } from '../components/DramaRecommendInfo';
import { util } from '@kit.ArkTS';
import { RequestAPI } from '@agctemplate/server';
import {
  getDramaInfo,
  setFavorite,
  unsetFavorite
} from '@agctemplate/server/src/main/ets/api/mock/mockData/mockDramaFactory';
import { Drama } from '@agctemplate/server/src/main/ets/api/mock/mockData/bean';
import { emitter } from '@kit.BasicServicesKit';
import { ConfigurationConstant } from '@kit.AbilityKit';

@ComponentV2
export struct DramaDetailInfoPage {
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Param @Require vm: DramaDetailVM;
  @Param @Once currentIndex: number = 5
  @Event changeIndex: Function = () => {
  }
  @Local spliceNum: number = 30
  @Local currentTabIndex: number = 0
  @Local isFavorite: boolean = false
  @Local isShowSerialPickerSheet: boolean = false
  @Local recommendList: Array<DramaCoverVM> = []
  @Local pageNum: number = 1
  @Local dramaInfo: Drama | null = null
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!;
  @Local currentColorMode: ColorMode = AppStorageV2.connect(ColorMode, 'colorMode', () => new ColorMode('跟随系统'))!
  totalTabIndex: number = 0
  leftIndex: number = 0
  tabArray: Array<string> = []
  fullIndexArray: Array<number> = []
  tailIndexArray: Array<number> = []
  private controller: TabsController = new TabsController()

  @Monitor('currentColorMode.colorMode')
  onColorModeChange(monitor: IMonitor) {
    if (this.currentColorMode.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
    } else {
      WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
    }
  }

  aboutToAppear(): void {
    this.dramaInfo = getDramaInfo(this.vm.detailInfo.id)
    this.isFavorite = this.dramaInfo.isFavorite
    this.currentTabIndex = Math.floor(this.currentIndex / this.spliceNum)
    this.totalTabIndex = Math.floor(this.vm.detailInfo.totalCount / this.spliceNum) + 1
    for (let i = 0; i < this.totalTabIndex; i++) {
      if (i === this.totalTabIndex - 1) {
        this.tabArray.push(`${i * this.spliceNum + 1}-${this.vm.detailInfo.totalCount}`)
      } else {
        this.tabArray.push(`${i * this.spliceNum + 1}-${i * this.spliceNum + this.spliceNum}`)
      }
    }
    this.leftIndex = this.vm.detailInfo.totalCount % this.spliceNum
    for (let i = 0; i < this.spliceNum; i++) {
      this.fullIndexArray.push(i)
    }
    for (let i = 0; i < this.leftIndex; i++) {
      this.tailIndexArray.push(i)
    }

    this.getRecommendList(this.pageNum).then((data) => {
      this.recommendList = data;
    })
  }

  async getRecommendList(pageNum: number): Promise<Array<DramaCoverVM>> {
    let list = await container.resolve(RequestAPI).getRecommendDramaList({
      pageSize: 5,
      pageNum: pageNum
    })
    const result = list.getBody().data
      .map(cover => {
        const item = new DramaCoverVM()
        item.dramaId = cover.id
        item.imagePath = cover.coverUrl
        item.title = cover.name
        item.content = cover.description
        item.episodes = cover.totalCount
        item.latestUpdate = cover.latestUpdate
        item.rankId = parseInt(cover.id)
        item.tags = cover.category
        return item
      })
    return Promise.resolve(result)
  }

  @Builder
  serialPickerBuilder() {
    Column() {
      Column() {
        Row() {
          Text('剧集观看')
            .height(this.fontModel.getDesFg(27))
            .fontSize(this.fontModel.getFg(20))
            .fontWeight(700)
            .fontColor($r('sys.color.font_primary'))
          buttonItem($r('sys.symbol.xmark'), () => {
            this.isShowSerialPickerSheet = !this.isShowSerialPickerSheet
          })
        }
        .width('100%')
        .height(this.fontModel.getDesFg(56))
        .margin({ top: 8 })
        .justifyContent(FlexAlign.SpaceBetween)

        Column() {
          List({ space: 24 }) {
            ForEach(this.tabArray, (item: string, index: number) => {
              ListItem() {
                Text(item)
                  .fontColor(this.currentTabIndex === index ? $r('sys.color.font_primary') :
                    $r('sys.color.font_tertiary'))
                  .fontSize(this.fontModel.getFg(14))
                  .height(this.fontModel.getDesFg(19))
              }.onClick(() => {
                this.currentTabIndex = index
              })
            }, (item: string, index: number) => item + index)
          }.width('100%')
          .listDirection(Axis.Horizontal)
          .height(this.fontModel.getDesFg(19))
          .margin({ bottom: 16 })

          Tabs({ index: this.currentTabIndex, controller: this.controller }) {
            ForEach(this.tabArray, (item: string, index: number) => {
              TabContent() {
                Grid() {
                  if (index === this.totalTabIndex - 1) {
                    ForEach(this.tailIndexArray, (item: number, indexIndex: number) => {
                      GridItem() {
                        Stack({ alignContent: Alignment.TopEnd }) {
                          Stack({ alignContent: Alignment.BottomEnd }) {
                            Text(`${(index) * this.spliceNum + indexIndex + 1}`)
                              .textAlign(TextAlign.Center)
                              .width(this.fontModel.getDesFg(48))
                              .height(this.fontModel.getDesFg(48))
                              .fontColor(this.currentIndex === (index * this.spliceNum + indexIndex) ? '#EC6E45' :
                                $r('sys.color.font_primary'))
                              .fontSize(this.fontModel.getFg(14))
                              .backgroundColor(this.currentIndex === (index * this.spliceNum + indexIndex) ?
                                'rgba(236, 110, 69, 0.05)' : $r('sys.color.comp_background_tertiary'))
                            if (this.currentIndex === (index * this.spliceNum + indexIndex)) {
                              Image(getMedia('app.media.playing'))
                                .width(this.fontModel.getDesFg(12))
                                .height(this.fontModel.getDesFg(10))
                                .margin({ bottom: 3, right: 3 })
                            }
                          }

                          if (indexIndex > 10 && index === 0 || index > 0) {
                            Text('VIP')
                              .textAlign(TextAlign.Center)
                              .fontSize(fp2pxUtil(8))
                              .width(13)
                              .height(11)
                              .fontColor($r('sys.color.font_primary'))
                              .backgroundColor('rgba(255,215,0,0.36)')
                          }
                        }
                      }
                      .onClick(() => {
                        this.isShowSerialPickerSheet = false
                        WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
                        appRouter.back(true)
                        this.changeIndex(index * this.spliceNum + indexIndex)
                      })
                    }, (item: number) => item.toString())
                  } else {
                    ForEach(this.fullIndexArray, (item: number, indexIndex: number) => {
                      GridItem() {
                        Stack({ alignContent: Alignment.TopEnd }) {
                          Stack({ alignContent: Alignment.BottomEnd }) {
                            Text(`${(index) * this.spliceNum + indexIndex + 1}`)
                              .textAlign(TextAlign.Center)
                              .width(this.fontModel.getDesFg(48))
                              .height(this.fontModel.getDesFg(48))
                              .fontColor(this.currentIndex === (index * this.spliceNum + indexIndex) ? '#EC6E45' :
                                $r('sys.color.font_primary'))
                              .fontSize(this.fontModel.getFg(14))
                              .backgroundColor(this.currentIndex === (index * this.spliceNum + indexIndex) ?
                                'rgba(236, 110, 69, 0.05)' : $r('sys.color.comp_background_tertiary'))
                            if (this.currentIndex === (index * this.spliceNum + indexIndex)) {
                              Image(getMedia('app.media.playing'))
                                .width(this.fontModel.getDesFg(12))
                                .height(this.fontModel.getDesFg(10))
                                .margin({ bottom: 3, right: 3 })
                            }

                          }

                          if (indexIndex > 10 && index === 0 || index > 0) {
                            Text('VIP')
                              .textAlign(TextAlign.Center)
                              .fontSize(fp2pxUtil(8))
                              .width(13)
                              .height(11)
                              .fontColor($r('sys.color.font_primary'))
                              .backgroundColor('rgba(255,215,0,0.36)')
                          }

                        }
                      }
                      .onClick(() => {
                        this.isShowSerialPickerSheet = false
                        WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
                        appRouter.back(true)
                        this.changeIndex(index * this.spliceNum + indexIndex)
                      })
                    }, (item: number) => item.toString())
                  }

                }
                .maxCount(6)
                .columnsGap(8)
                .rowsGap(8)
              }
              .align(Alignment.Top)

            }, (item: string) => item + util.generateRandomUUID())
          }
          .onChange((index: number) => {
            this.currentTabIndex = index
          })
          .barHeight(0)
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')
    }
    .height('100%')
    .padding({ left: 16, right: 16 })
  }

  detailInfoSendFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 5
    };
    let eventData: emitter.EventData = {
      data: {
        id: 5
      }
    };
    try {
      emitter.emit(event, eventData);
    } catch (e) {
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Scroll() {
          Column() {
            Column() {
              Row({ space: 16 }) {
                Image(this.vm.detailInfo.coverUrl)
                  .width(48)
                  .height(64)
                  .borderRadius(4)
                Column() {
                  Text(this.vm.detailInfo.name)
                    .fontSize(this.fontModel.getFg(16))
                    .fontWeight(500)
                    .fontColor($r('sys.color.font_primary'))
                    .maxLines(1)
                    .width('100%')
                    .height(this.fontModel.getDesFg(21))
                    .textAlign(TextAlign.Start)
                    .textOverflow({
                      overflow: TextOverflow.Ellipsis
                    })

                  Text(`${this.vm.detailInfo.category} · 热度${this.vm.detailInfo.popular}`)
                    .height(this.fontModel.getDesFg(16))
                    .fontSize(this.fontModel.getFg(12))
                    .fontColor($r('sys.color.font_secondary'))
                    .fontWeight(400)
                    .margin({ top: 2 })
                    .width('100%')

                  List({ space: 16 }) {
                    ForEach(this.vm.detailInfo.actorInfo, (item: ActorInfo) => {
                      ListItem() {
                        Row() {
                          Image(item.avatar)
                            .width(16)
                            .height(16)
                            .borderRadius(8)
                          Text(item.name)
                            .fontSize(fp2pxUtil(12))
                            .fontWeight(FontWeight.Regular)
                            .opacity(0.6)
                            .height(16)
                            .margin({ left: 8 })
                        }
                        .height(24)
                        .alignItems(VerticalAlign.Bottom)
                      }
                      .height(24)
                    }, (item: ActorInfo, index: number) => item.name + '_' + index.toString())
                  }
                  .width('100%')
                  .height(24)
                  .listDirection(Axis.Horizontal)
                }
              }
              .width('100%')
              .height(80)

              Column() {
                Row() {
                  Text('剧情简介')
                    .height(this.fontModel.getDesFg(24))
                    .fontSize(this.fontModel.getFg(18))
                    .fontWeight(700)
                    .fontColor($r('sys.color.font_primary'))
                  ForEach(
                    this.vm.detailInfo.category,
                    (item: string) => {
                      Text(item)
                        .height(this.fontModel.getDesFg(16))
                        .fontSize(this.fontModel.getFg(10))
                        .lineHeight(this.fontModel.getDesFg(13))
                        .fontWeight(400)
                        .fontColor($r('sys.color.font_primary'))
                        .padding({ left: 4, right: 4 })
                        .backgroundColor($r('sys.color.comp_background_tertiary'))
                        .margin({ left: 12 })
                    }, (item: string) => item
                  )
                }
                .height(this.fontModel.getDesFg(24))

                Text(this.vm.detailInfo.description)
                  .width('100%')
                  .margin({ top: 12 })
                  .fontSize(this.fontModel.getFg(14))
                  .fontWeight(400)
                  .lineHeight(this.fontModel.getDesFg(19))
                  .fontColor($r('sys.color.font_primary'))
                  .align(Alignment.TopStart)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ top: 24 })

              Row() {
                Text('剧集')
                  .height(this.fontModel.getDesFg(24))
                  .fontSize(this.fontModel.getFg(18))
                  .fontWeight(700)
                  .fontColor($r('sys.color.font_primary'))
                Row() {
                  Text(this.vm.detailInfo.latestUpdate === this.vm.detailInfo.totalCount ? '已完结' : '连载中')
                    .lineHeight(this.fontModel.getDesFg(16))
                    .fontSize(this.fontModel.getFg(12))
                    .fontColor($r('sys.color.font_secondary'))
                  Text('·')
                    .lineHeight(this.fontModel.getDesFg(16))
                    .fontSize(this.fontModel.getFg(12))
                    .fontColor($r('sys.color.font_secondary'))
                  Text(`共${this.vm.detailInfo.totalCount}集`)
                    .lineHeight(this.fontModel.getDesFg(16))
                    .fontSize(this.fontModel.getFg(12))
                    .fontColor($r('sys.color.font_secondary'))
                  Column() {
                    SymbolGlyph($r('sys.symbol.chevron_forward'))
                      .fontSize(this.fontModel.getFg(9))
                      .fontColor([$r('sys.color.icon_secondary')])
                  }
                  .width(this.fontModel.getDesFg(16))
                  .height(this.fontModel.getDesFg(16))
                  .justifyContent(FlexAlign.Center)
                  .margin({ left: 2 })
                }
                .height(this.fontModel.getDesFg(16))
                .onClick(() => {
                  this.isShowSerialPickerSheet = !this.isShowSerialPickerSheet
                })
                .bindSheet($$this.isShowSerialPickerSheet, this.serialPickerBuilder(), {
                  height: 736,
                  detents: [SheetSize.LARGE],
                  showClose: false,
                  preferType: SheetType.CENTER
                })
              }
              .width('100%')
              .height(this.fontModel.getDesFg(56))
              .margin({ top: 24 })
              .justifyContent(FlexAlign.SpaceBetween)

              Column() {
                List({ space: 24 }) {
                  ForEach(this.tabArray, (item: string, index: number) => {
                    ListItem() {
                      Text(item)
                        .fontColor(this.currentTabIndex === index ? $r('sys.color.font_primary') :
                          $r('sys.color.font_tertiary'))
                        .fontSize(this.fontModel.getFg(14))
                        .height(this.fontModel.getDesFg(19))
                    }.onClick(() => {
                      this.currentTabIndex = index
                    })
                  }, (item: string, index: number) => item + index)
                }.width('100%')
                .listDirection(Axis.Horizontal)
                .height(this.fontModel.getDesFg(19))
                .margin({ bottom: 16 })

                Tabs({ index: this.currentTabIndex, controller: this.controller }) {
                  ForEach(this.tabArray, (item: string, index: number) => {
                    TabContent() {
                      Grid() {
                        if (index === this.totalTabIndex - 1) {
                          ForEach(this.tailIndexArray, (item: number, indexIndex: number) => {
                            GridItem() {
                              Stack({ alignContent: Alignment.TopEnd }) {
                                Stack({ alignContent: Alignment.BottomEnd }) {
                                  Text(`${(index) * this.spliceNum + indexIndex + 1}`)
                                    .textAlign(TextAlign.Center)
                                    .width(48)
                                    .height(48)
                                    .fontColor(this.currentIndex === (index * this.spliceNum + indexIndex) ? '#EC6E45' :
                                      $r('sys.color.font_primary'))
                                    .fontSize(this.fontModel.getFg(14))
                                    .backgroundColor(this.currentIndex === (index * this.spliceNum + indexIndex) ?
                                      'rgba(236, 110, 69, 0.05)' : $r('sys.color.comp_background_tertiary'))
                                  if (this.currentIndex === (index * this.spliceNum + indexIndex)) {
                                    Image(getMedia('app.media.playing'))
                                      .width(12)
                                      .height(10)
                                      .margin({ bottom: 3, right: 3 })
                                  }
                                }

                                if (indexIndex > 10 && index === 0 || index > 0) {
                                  Text('VIP')
                                    .textAlign(TextAlign.Center)
                                    .fontSize(fp2pxUtil(8))
                                    .width(13)
                                    .height(11)
                                    .fontColor($r('sys.color.font_primary'))
                                    .backgroundColor('rgba(255,215,0,0.36)')
                                }
                              }
                              .onClick(() => {
                                this.isShowSerialPickerSheet = false
                                WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
                                appRouter.back(true)
                                this.changeIndex(index * this.spliceNum + indexIndex)
                              })
                            }
                          }, (item: number) => item.toString())
                        } else {
                          ForEach(this.fullIndexArray, (item: number, indexIndex: number) => {
                            GridItem() {
                              Stack({ alignContent: Alignment.TopEnd }) {
                                Stack({ alignContent: Alignment.BottomEnd }) {
                                  Text(`${(index) * this.spliceNum + indexIndex + 1}`)
                                    .textAlign(TextAlign.Center)
                                    .width(48)
                                    .height(48)
                                    .fontColor(this.currentIndex === (index * this.spliceNum + indexIndex) ? '#EC6E45' :
                                      $r('sys.color.font_primary'))
                                    .fontSize(this.fontModel.getFg(14))
                                    .backgroundColor(this.currentIndex === (index * this.spliceNum + indexIndex) ?
                                      'rgba(236, 110, 69, 0.05)' : $r('sys.color.comp_background_tertiary'))
                                  if (this.currentIndex === (index * this.spliceNum + indexIndex)) {
                                    Image(getMedia('app.media.playing'))
                                      .width(12)
                                      .height(10)
                                      .margin({ bottom: 3, right: 3 })
                                  }
                                }

                                if (indexIndex > 10 && index === 0 || index > 0) {
                                  Text('VIP')
                                    .textAlign(TextAlign.Center)
                                    .fontSize(fp2pxUtil(8))
                                    .width(13)
                                    .height(11)
                                    .fontColor($r('sys.color.font_primary'))
                                    .backgroundColor('rgba(255,215,0,0.36)')
                                }
                              }
                              .onClick(() => {
                                this.isShowSerialPickerSheet = false
                                WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
                                appRouter.back(true)
                                this.changeIndex(index * this.spliceNum + indexIndex)
                              })
                            }
                          }, (item: number) => item.toString())
                        }
                      }
                      .nestedScroll({
                        scrollForward: NestedScrollMode.SELF_FIRST,
                        scrollBackward: NestedScrollMode.SELF_FIRST
                      })
                      .scrollBar(BarState.Off)
                      .rowsTemplate('1fr')
                      .columnsGap(8)
                      .width('100%')
                      .height(48)
                    }
                    .align(Alignment.Top)
                  }, (item: string) => item + util.generateRandomUUID())
                }
                .onChange((index: number) => {
                  this.currentTabIndex = index
                })
                .barHeight(0)
              }
              .height(85)

              RecommendView({
                recommendList: this.recommendList,
                gutter: 21,
                onItemClick: (options: DramaCoverVM) => {
                  this.vm.jumpDetailPage(options)
                },
                changeRecommendList: () => {
                  if (this.pageNum < 10) {
                    this.pageNum++
                  } else {
                    this.pageNum = 1
                  }
                  this.getRecommendList(this.pageNum).then((data) => {
                    this.recommendList = data;
                  })
                }
              })
                .margin({ top: 24 })

              Column()
                .width('100%')
                .height(this.fontModel.getDesFg(156))
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)

        Row() {
          Row() {
            Column() {
              Image(this.isFavorite ? getMedia('app.media.favorite_select') :
                getMedia('app.media.favorite_black'))
                .width(21)
                .height(21)
              Text('收藏')
                .fontSize(fp2pxUtil(10))
                .lineHeight(13)
                .margin({ top: 4 })
            }
            .width(this.fontModel.getDesFg(48))
            .margin({ right: 12 })
            .onClick(() => {
              if (this.userInfo.isPhoneAssociated) {
                if (this.isFavorite) {
                  unsetFavorite(this.dramaInfo!.id)
                  this.getUIContext().getPromptAction().showToast({ message: '取消收藏成功' })
                } else {
                  setFavorite(this.dramaInfo!.id)
                  this.getUIContext().getPromptAction().showToast({ message: '收藏成功' })
                }
                this.isFavorite = this.dramaInfo!.isFavorite
                this.detailInfoSendFavoriteEmitter()
              } else {
                appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name })
              }
            })

            Row() {
              Row({ space: 16 }) {
                SymbolGlyph($r('sys.symbol.play_fill'))
                  .fontSize(fp2pxUtil(14))
                  .fontColor([$r('sys.color.icon_primary')])
                Text('继续播放')
                  .lineHeight(21)
                  .fontSize(fp2pxUtil(16))
                  .fontWeight(500)
              }
            }
            .borderRadius(20)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .justifyContent(FlexAlign.Center)
            .layoutWeight(1)
            .height(40)
            .onClick(() => {
              WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
              appRouter.back(true)
            })
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .backgroundColor($r('sys.color.background_primary'))
      }
    }
    .onBackPressed(() => {
      WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
      appRouter.back(true)
      return true
    })
    .padding({
      top: `${this.getUIContext().px2vp(this.statusBarHeight.value)}vp`,
      bottom: `${this.getUIContext().px2vp(this.aiBarHeight.value)}vp`
    })
  }
}


@ComponentV2
struct RecommendView {
  windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  // 获取主窗口的方式
  mainWin: window.Window = this.windowStage.getMainWindowSync();
  @Param @Require recommendList: Array<DramaCoverVM>
  @Param @Require gutter: number
  @Event onItemClick: Function
  @Local rotating: number = 0
  @Event changeRecommendList: () => void
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Column() {
      Row() {
        Text('猜你喜欢')
          .height(this.fontModel.getDesFg(24))
          .fontSize(this.fontModel.getFg(18))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .margin({ bottom: 12 })
        Row() {
          SymbolGlyph($r('sys.symbol.arrow_clockwise'))
            .fontSize(this.fontModel.getFg(14))
            .fontColor([$r('sys.color.icon_secondary')])
            .margin({ right: 4 })
            .rotate({ angle: this.rotating })
            .animation({ duration: 300, curve: Curve.Linear })
          Text('换一批')
            .fontSize(this.fontModel.getFg(12))
            .lineHeight(this.fontModel.getDesFg(16))
            .fontColor($r('sys.color.font_secondary'))
        }
        .height(this.fontModel.getDesFg(16))
        .onClick(() => {
          this.rotating += 360
          setTimeout(() => {
            this.changeRecommendList()
          }, 300)
        })
      }
      .width('100%')
      .height(this.fontModel.getDesFg(56))
      .justifyContent(FlexAlign.SpaceBetween)

      List() {
        ForEach(this.recommendList, (recommend: DramaCoverVM) => {
          ListItem() {
            DramaRecommendInfo({ drama: recommend, onItemClick: this.onItemClick })
          }
          .margin({ right: 9.5 })
        }, (item: DramaCoverVM) => item.dramaId + item.title)
      }
      .width('100%')
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
  }
}

@Builder
export function dramaInfoPageBuilder() {
  DramaDetailInfoPage({
    vm: new DramaDetailVM(NavParams.getParams()?.dramaInfo),
    currentIndex: NavParams.getParams()?.currentIndex,
    changeIndex: NavParams.getParams()?.changeIndex
  });
}