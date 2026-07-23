import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources'
import { DramaInfo } from '@agctemplate/server'
import { appRouter, WindowManager } from '@agctemplate/utils'
import { PlayController } from 'video_swiper'
import { util } from '@kit.ArkTS'
import { ShortDramaDetailListVM } from '../viewmodels/ShortDramaDetailListVM'
import { DetailVideoData } from '../models/DetailVideoData'
import { FontModel, fp2pxUtil, UserInfoModel } from '@agctemplate/widgets'
import { AppStorageV2 } from '@kit.ArkUI'

export class ActorInfo {
  id: string = ''
  avatar: ResourceStr = ''
  name: string = ''

  constructor(name: string, avatar: ResourceStr) {
    this.name = name
    this.avatar = avatar
  }
}

@ComponentV2
export struct DramaDesc {
  @Param @Require @Once dramaInfo: DramaInfo
  @Param @Require playController: PlayController
  @Event closeSheet: () => void
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Column() {
      Row() {
        Image(this.dramaInfo.coverUrl)
          .width(48)
          .height(64)

        Column() {
          Flex({ alignItems: ItemAlign.Center }) {
            Text(this.dramaInfo.name)
              .fontSize(this.fontModel.getFg(16))
              .fontWeight(FontWeight.Medium)
              .flexBasis('auto')
              .height(this.fontModel.getDesFg(21))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Row() {
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(this.fontModel.getFg(16))
                .fontColor([$r('sys.color.icon_primary')])
            }.height(this.fontModel.getDesFg(21))
            .width(this.fontModel.getDesFg(16))
            .margin({ left: 2 })
            .onClick(() => {
              this.closeSheet()
              WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
              this.playController.pause()
              appRouter.push({
                builderName: NAV_PAGE_NAME.DramaDetailInfoPage.name, params: {
                  dramaInfo: this.dramaInfo,
                  currentIndex: this.playController.curentIndex,
                  changeIndex: (index: number) => {
                    this.playController.changeIndex(index)
                  }
                }
              })
            })
          }
          .align(Alignment.Start)

          Text(this.dramaInfo.description)
            .fontSize(this.fontModel.getFg(12))
            .fontWeight(FontWeight.Regular)
            .opacity(0.6)
            .height(this.fontModel.getDesFg(16))
            .maxLines(1)
            .textAlign(TextAlign.Start)
            .margin({ top: 2, bottom: 8 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          List({ space: 16 }) {
            ForEach(this.dramaInfo.actorInfo, (item: ActorInfo, index: number) => {
              ListItem() {
                Row() {
                  Image(item.avatar)
                    .width(16)
                    .height(16)
                  Text(item.name)
                    .fontSize(fp2pxUtil(12))
                    .fontWeight(FontWeight.Regular)
                    .opacity(0.6)
                    .height(16)
                    .margin({ left: 8 })
                }
              }
            }, (item: ActorInfo) => item.toString())
          }.height(16)
          .listDirection(Axis.Horizontal)
        }.width('calc(100% - 64vp)')
        .alignItems(HorizontalAlign.Start)
      }.justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
    }
  }
}

@ComponentV2
export struct SerialPicker {
  @Param @Require dramaInfo: DramaInfo
  @Param @Require playController: PlayController
  @Param @Once spliceNum: number = 30
  @Param @Once currentIndex: number = 5
  @Local currentTabIndex: number = 0
  @Local shortDramaDetailListVM: ShortDramaDetailListVM = ShortDramaDetailListVM.instance
  @Event closeSheet: () => void
  @Event onIndexSelect: (index: number) => void = (index: number) => {
  };
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  pageStack: NavPathStack = new NavPathStack();
  totalTabIndex: number = 0
  leftIndex: number = 0
  tabArray: Array<string> = [];
  fullIndexArray: Array<number> = [];
  tailIndexArray: Array<number> = []
  private controller: TabsController = new TabsController()
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  aboutToAppear(): void {
    this.currentTabIndex = Math.floor(this.currentIndex / this.spliceNum)
    this.totalTabIndex = Math.floor(this.dramaInfo.totalCount / this.spliceNum) + 1
    for (let i = 0; i < this.totalTabIndex; i++) {
      if (i === this.totalTabIndex - 1) {
        this.tabArray.push(`${i * this.spliceNum + 1}-${this.dramaInfo.totalCount}`)
      } else {
        this.tabArray.push(`${i * this.spliceNum + 1}-${i * this.spliceNum + this.spliceNum}`)
      }
    }
    this.leftIndex = this.dramaInfo.totalCount % this.spliceNum
    for (let i = 0; i < this.spliceNum; i++) {
      this.fullIndexArray.push(i)
    }
    for (let i = 0; i < this.leftIndex; i++) {
      this.tailIndexArray.push(i)
    }
  }

  build() {
    Stack() {
      Column() {
        DramaDesc({
          dramaInfo: this.dramaInfo,
          playController: this.playController,
          closeSheet: () => this.closeSheet()
        })

        List({ space: 24 }) {
          ForEach(this.tabArray, (item: string, index: number) => {
            ListItem() {
              Text(item)
                .fontColor(this.currentTabIndex === index ? $r('sys.color.font_primary') :
                $r('sys.color.font_secondary'))
                .fontSize(this.fontModel.getFg(14))
                .height(19)
            }.onClick(() => {
              this.currentTabIndex = index
            })
          }, (item: string, index: number) => item + index)
        }.width('100%')
        .listDirection(Axis.Horizontal)
        .height(19)
        .margin({ top: 32, bottom: 16 })

        Tabs({ index: this.currentTabIndex, controller: this.controller }) {
          ForEach(this.tabArray, (item: string, index: number) => {
            TabContent() {
              Grid() {
                if (index === this.totalTabIndex - 1) {
                  ForEach(this.tailIndexArray, (item: number, indexIndex: number) => {
                    GridItem() {
                      Stack({ alignContent: Alignment.BottomEnd }) {
                        Text(`${(index) * this.spliceNum + indexIndex + 1}`)
                          .textAlign(TextAlign.Center)
                          .width(48)
                          .height(48)
                          .onClick(() => {
                            this.onIndexSelect(index * this.spliceNum + indexIndex)
                          })
                          .fontColor(this.currentIndex === (index * this.spliceNum + indexIndex) ? '#EC6E45' :
                          $r('sys.color.font_primary'))
                          .fontSize(this.fontModel.getFg(14))
                          .backgroundColor(this.currentIndex === (index * this.spliceNum + indexIndex) ?
                            'rgba(236, 110, 69, 0.05)' : $r('sys.color.comp_background_tertiary'))
                        if (this.currentIndex === (index * this.spliceNum + indexIndex)) {
                          Image(getMedia('app.media.playing'))
                            .width(10)
                            .height(8)
                            .margin({ bottom: 3, right: 3 })
                        }
                        if ((index * this.spliceNum + indexIndex) > 10 &&
                        this.isLocked(index * this.spliceNum + indexIndex)) {
                          SymbolGlyph($r('sys.symbol.lock_fill'))
                            .fontSize(fp2pxUtil(16))
                            .fontColor([$r('sys.color.icon_tertiary')])
                        }
                      }
                    }
                  }, (item: number) => item.toString())
                } else {
                  ForEach(this.fullIndexArray, (item: number, indexIndex: number) => {
                    GridItem() {
                      Stack({ alignContent: Alignment.BottomEnd }) {
                        Text(`${(index) * this.spliceNum + indexIndex + 1}`)
                          .textAlign(TextAlign.Center)
                          .width(48)
                          .height(48)
                          .onClick(() => {
                            this.currentIndex = (index * this.spliceNum + indexIndex)
                            this.onIndexSelect(index * this.spliceNum + indexIndex)
                          })
                          .fontColor(this.currentIndex === (index * this.spliceNum + indexIndex) ? '#EC6E45' :
                          $r('sys.color.font_primary'))
                          .fontSize(this.fontModel.getFg(14))
                          .backgroundColor(this.currentIndex === (index * this.spliceNum + indexIndex) ?
                            'rgba(236, 110, 69, 0.05)' : $r('sys.color.comp_background_tertiary'))
                        if (this.currentIndex === (index * this.spliceNum + indexIndex)) {
                          Image(getMedia('app.media.playing'))
                            .width(10)
                            .height(8)
                            .margin({ bottom: 3, right: 3 })
                        }
                        if ((index * this.spliceNum + indexIndex) > 10 &&
                        this.isLocked(index * this.spliceNum + indexIndex)) {
                          SymbolGlyph($r('sys.symbol.lock_fill'))
                            .fontSize(fp2pxUtil(16))
                            .fontColor([$r('sys.color.icon_tertiary')])
                        }
                      }
                    }
                  }, (item: number) => item.toString())
                }

              }
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
      }.width('100%')
      .padding({ top: 34, left: 16, right: 16 })
    }
    .alignContent(Alignment.BottomEnd)
    .height(487)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  isLocked(index: number): boolean {
    try {
      if (this.userInfo.isVip) {
        return false
      }
      if (!(this.shortDramaDetailListVM.data.getData(index) as DetailVideoData).videoMask.isLocked) {
        return false
      }
      return true
    }catch (err){
      console.info('can not read video isLocked!')
      return false
    }
  }
}