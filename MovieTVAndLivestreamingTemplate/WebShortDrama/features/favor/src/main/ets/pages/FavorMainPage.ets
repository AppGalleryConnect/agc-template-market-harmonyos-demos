import { jumpDetailPage, ParamsModel } from '@agctemplate/detail'
import { VideoSeries } from '@agctemplate/mine'
import { getString } from '@agctemplate/resources'
import { MyFollowDramaData, MyFollowDramaRes, RequestAPI } from '@agctemplate/server'
import {
  getDramaInfo, unsetFavorite
} from '@agctemplate/server/src/main/ets/api/mock/mockData/mockDramaFactory'
import { container, WindowManager } from '@agctemplate/utils'
import {
  AiBarHeight,
  AppStorageKeys,
  BreakPoint,
  BreakPointType,
  BreakPointValue,
  FontModel,
  fp2pxUtil,
  MainTitleModifier,
  StatusBarHeight
} from '@agctemplate/widgets'
import { AlertDialog, AppStorageV2, display } from '@kit.ArkUI'
import { emitter } from '@kit.BasicServicesKit'

@ComponentV2
export struct FavorMainPage {
  @Local isDeleting: boolean = false
  @Local selectCount: number = 0
  @Local selectedIds: string[] = []
  @Local deletePromptMsg: string | Resource = '此条'
  @Local myFollowDramaRes: MyFollowDramaRes = new MyFollowDramaRes();
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight(0))!;
  @Consumer('tabState') tabState: boolean = true;
  @Consumer('curTabIndex') currentIndex: number = 0;
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
  @Local trackSize: string | number =
    new BreakPointType<string | number>({
      sm: this.fontModel.getDesFg(99),
      md: this.fontModel.getDesFg(159),
      lg: this.fontModel.getDesFg(189)
    }).getValue(this.currentBreakpoint.value)!
  @Local isLandScape: boolean = display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
    display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED
  callback: Callback<number> = (data: number) => {
    if (display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
      display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED) {
      this.isLandScape = true
    } else {
      this.isLandScape = false
    }
  }
  modifier: MainTitleModifier = new MainTitleModifier();
  deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: getString('app.string.delete_favor_prompt', this.deletePromptMsg.toString()),
      primaryButton: {
        value: '取消',
        action: () => {
          this.deleteDialogController.close()
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: $r('sys.color.ohos_id_color_warning'),
        action: () => {
          if (this.selectCount > 0) {
            // 删除选中
            this.selectedIds.map(item => unsetFavorite(item))
            this.updateFavorites()
            this.deleteDialogController.close()
            this.isDeleting = !this.isDeleting
            this.tabState = true
            this.selectedIds = []
            this.selectCount = 0
            this.sendDeleteFavoriteEmitter()
          }
        },
      },
    }),
  })

  @Monitor('currentIndex')
  onChange() {
    if (this.currentIndex === 3) {
      this.updateFavorites()
    }
  }

  @Monitor('currentBreakpoint.value')
  onBreakChange(monitor: IMonitor) {
    this.trackSize = new BreakPointType<number>({ sm: 99, md: 159, lg: 189 }).getValue(this.currentBreakpoint.value)!
  }

  aboutToAppear(): void {
    this.sendDeleteFavoriteEmitter()
    this.updateFavorites()
    try {
      display.on('change', this.callback)
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    try {
      display.off('change', this.callback)
    } catch (e) {
    }
  }

  sendDeleteFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 6
    };
    let eventData: emitter.EventData = {
      data: {
        id: 6
      }
    };
    try {
      emitter.emit(event, eventData);
    } catch (e) {
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部
        this.topBuilder()
        Column() {
          if (this.myFollowDramaRes.myFollowDramas.length > 0) {
            this.favorBuilder()
          } else {
            Text('暂无追剧')
              .height('100%')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.icon_secondary'))
          }
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
      })
      .backgroundColor($r('sys.color.background_secondary'))

      if (this.isDeleting) {
        this.footItemBuilder()
      }
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      top: `${this.getUIContext().px2vp(this.statusBarHeight.value)}vp`
    })
    .hideTitleBar(true)
  }

  @Builder
  topBuilder() {
    Row() {
      Text('追剧')
        .attributeModifier(this.modifier)

      Button(this.isDeleting ? '取消' : '编辑')
        .fontSize(fp2pxUtil(16))
        .margin({ left: 8 })
        .height(40)
        .borderRadius(20)
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          if (this.myFollowDramaRes.myFollowDramas.length > 0) {
            this.isDeleting = !this.isDeleting
            this.tabState = !this.isDeleting
            this.selectedIds = []
            this.selectCount = 0
            this.myFollowDramaRes.myFollowDramas.forEach(item => {
              item.isSelect = false;
            })
          }
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height(56)
    .width('100%')
  }

  @Builder
  favorBuilder() {
    Grid() {
      Repeat<MyFollowDramaData>(this.myFollowDramaRes.myFollowDramas)
        .each((ri: RepeatItem<MyFollowDramaData>) => {
          GridItem() {
            VideoSeries({
              title: ri.item.name,
              currentEpisode: ri.item.currentWatch + 1,
              totalCount: ri.item.totalCount,
              cover: ri.item.coverUrl,
              isDeleting: this.isDeleting,
              likeCount: ri.item.likeCount,
              isLike: false,
              isSelectBack: (isSelect) => {
                ri.item.isSelect = isSelect
                this.getSelectedIds()
              },
              isVip: ri.item.isVip,
              onContinueWatch: () => {
                jumpDetailPage(ri.item, ri.item.currentWatch, 0, (params) => {
                  WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                  const paramsInfo = params.result as ParamsModel
                  const drama = getDramaInfo(paramsInfo.id)
                  drama.curIndex = paramsInfo.curIndex
                  this.updateFavorites()
                })
              }
            })
          }
          .padding({ bottom: ri.index === this.myFollowDramaRes.myFollowDramas.length - 1 ? 160 : 0})
        })
        .key((item: MyFollowDramaData, index: number): string => item.id)// 键值生成函数
        .virtualScroll({
          totalCount: this.myFollowDramaRes.myFollowDramas.length
        }) // 打开virtualScroll模式，totalCount为期望加载的数据长度
    }
    .edgeEffect(EdgeEffect.Spring)
    .columnsTemplate(`repeat(auto-stretch, ${this.trackSize})`)
    .columnsGap(new BreakPointType<string | number>({
      sm: 8,
      md: 12,
      lg: 16
    }).getValue(this.currentBreakpoint.value))
    .scrollBar(BarState.Off)
    .cachedCount(4) // 容器组件的预加载区域大小
  }

  @Builder
  footItemBuilder() {
    Row() {
      Column() {
        SymbolGlyph($r('sys.symbol.eraser_line'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
        Text('一键清空')
          .fontSize(this.fontModel.getFg(10))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Center)
          .margin({ top: 2 })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)
      .height('100%')
      .onClick(() => {
        this.getAllIds()
        this.deleteDialogController.open()
      })

      Column() {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize(24)
          .fontColor([this.selectCount > 0 ? $r('sys.color.icon_primary') : $r('sys.color.icon_secondary')])
        Text('删除')
          .fontSize(this.fontModel.getFg(10))
          .fontWeight(FontWeight.Medium)
          .fontColor(this.selectCount > 0 ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
          .textAlign(TextAlign.Center)
          .margin({ top: 2 })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)
      .height('100%')
      .opacity(this.selectCount > 0 ? 1 : 0.4)
      .enabled(this.selectCount > 0)
      .onClick(() => {
        this.getSelectedIds()
        this.deleteDialogController.open()
      })
    }
    .width(this.currentBreakpoint.value === 'sm' ? 168 : 184)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR,
      { colorMode: ThemeColorMode.LIGHT, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
    .height(56)
    .borderRadius(28)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
    .position({ left: '50%', bottom: 28 })
    .translate({ x: '-50%' })
  }

  // 更新观看记录数据
  updateFavorites(): void {
    container.resolve(RequestAPI).getMyFollowDrama({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.myFollowDramaRes = new MyFollowDramaRes(res.getBody());
    })
  }

  // 获取列表id
  getSelectedIds() {
    this.selectedIds = this.myFollowDramaRes.myFollowDramas
      .filter(item => item.isSelect)
      .map(item => item.id)
    this.selectCount = this.selectedIds.length
    this.getSelectCount()
  }

  // 获取所有id
  getAllIds() {
    this.selectedIds = this.myFollowDramaRes.myFollowDramas
      .map(item => item.id);
    this.selectCount = this.selectedIds.length
    this.getSelectCount()
  }

  // 获取所有id
  getSelectCount() {
    if (this.selectCount < 1) {
      return
    }
    if (this.selectCount === 1) {
      this.deletePromptMsg = '此条'
    } else if (this.selectCount === this.myFollowDramaRes.myFollowDramas.length) {
      this.deletePromptMsg = '全部'
    } else {
      this.deletePromptMsg = this.selectCount + '条'
    }
  }
}


@Builder
export function FavorMainPageBuilder(index: number) {
  FavorMainPage();
}