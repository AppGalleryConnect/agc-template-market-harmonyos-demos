import { PersistenceV2 } from '@kit.ArkUI'
import { BottomMenuBar } from '../components/BottomMenuBar'
import { TitleBar } from '../components/TitleBar'
import { CommonConstants } from '../constants/CommonConstants'
import { CanvasState, DrawHistory } from '../model/Model'
import { DrawBoardVM } from '../viewmodel/DrawVM'

@Builder
export function drawBoardBuilder() {
  DrawBoard()
}

@ComponentV2
export struct DrawBoard {
  @Local drawHistory: DrawHistory = PersistenceV2.connect(DrawHistory, () => new DrawHistory())!;
  @Local drawBoardVM: DrawBoardVM = DrawBoardVM.instance
  @Param pageInfo:NavPathStack = new NavPathStack()
  @Param isHideBack:boolean = false
  getCanvasLoad() {
    this.drawBoardVM.initDrawBord()
  }

  aboutToDisappear(): void {
    this.drawBoardVM.clear()
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isHideBack:this.isHideBack,
          onDrawHistory: () => {
            this.drawBoardVM.pathStack.pushPathByName('CanvasSaveList', null, async (popInfo: PopInfo) => {
              let popInfoRes = popInfo.result as Record<string, string | CanvasState>
              if (popInfoRes.mode === 'edit' && popInfoRes?.canvasInfo) {
                this.drawBoardVM.loadFromSerializedData(popInfoRes?.canvasInfo as CanvasState);
              }
            })
          },
        })
        Stack({ alignContent: Alignment.Bottom }) {
          Canvas(this.drawBoardVM.context)
            .width(CommonConstants.ONE_HUNDRED_PERCENT)
            .height(CommonConstants.ONE_HUNDRED_PERCENT)
            .borderRadius(16)
            .clip(true)
            .backgroundImage(this.drawBoardVM.canvasBackgroundImage)
            .backgroundImageSize(ImageSize.FILL)
            .backgroundColor(this.drawBoardVM.canvasBackgroundImage === '' ? this.drawBoardVM.canvasColor :
            Color.Transparent)
            .onReady(() => {
              this.getCanvasLoad()
            })
            .onTouch((event: TouchEvent) => {
              this.drawBoardVM.handleTouch(event)
            })
        }
        .width(CommonConstants.ONE_HUNDRED_PERCENT)
        .height('82%')
        .clip(true)
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_focus'))
        .margin({
          top: 16,
          bottom: 16,
        })

        Divider()

        BottomMenuBar()
      }
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .height(CommonConstants.ONE_HUNDRED_PERCENT)
      .backgroundColor('#F1F3F5')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .padding({
        left: 16,
        right: 16,
      })
    }
    .onBackPressed(() => {
      if (this.drawBoardVM.tabCurrentIndex === 3) {
        this.drawBoardVM.tabCurrentIndex = 0;
      }
      return this.drawBoardVM.saveNotice(this.getUIContext())
    })
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onReady((context: NavDestinationContext) => {
      if(context.navDestinationId !== '0') {
        this.drawBoardVM.pathStack = context.pathStack
      }else  {
        this.drawBoardVM.pathStack = this.pageInfo
      }
    })
  }
}

