import { ColorShow } from 'painting_color_selector'
import { Constants, GlobalContext, RouterMap, TValueType } from 'common'
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router'
import { BottomMenuBar } from '../comp/BottomMenuBar'
import { CommonConstants } from '../constants/Constant'
import { DrawingBoardVM } from '../viewmodel/DrawingBoardVM'
import { DrawingHistoryItem } from '../viewmodel/DrawingHistoryVM'
import { baseToast } from '../comp/ConfirmDialog'
import { DrawBoardListPageBuilder } from './DrawBoardListPage'


@Builder
export function DrawingBoardBuilder(params: TValueType) {
  DrawingBoardPage({ pageParams: params })
}

/**
 * @usage: 画板绘画页面，提供完整的绘画功能，包含顶部工具栏（返回、清空、撤销、重做、保存）、
 * 中间画布区域（支持触摸绘画、橡皮擦、颜色取样，背景支持纯色、渐变、相册图片）、
 * 底部工具菜单栏（画笔、颜色、橡皮擦、形状、背景）。支持新建和编辑两种模式。
 * @layout: 页面采用垂直布局(Column)，顶部为工具栏(Row，左侧返回按钮，右侧操作按钮组横向排列),中间为画布区域(Stack布局，
 * Canvas作为底层，颜色取样预览和画笔预览圆圈叠加在上层)，底部为工具菜单栏(BottomMenuBar组件)。
 * @constraints:保存逻辑中的防抖机制(isSaving)不可删除，防止重复保存。pageParams 参数类型不可修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 画板绘画页面
 * @domain: 绘画
 * @image: screenshots/home/drawingboard.jpg
 * @component: BottomMenuBar, ColorShow
 */
@ComponentV2
export struct DrawingBoardPage {
  @Local drawingBoardVM: DrawingBoardVM = DrawingBoardVM.instance
  @Param pageParams: TValueType = null;
  @Local titleInput: string = ''
  private isSaving: boolean = false // 防抖标志
  private pageInfo: OHPageConfig = new OHPageConfig({
    onBackPress: () => {
      this.backPress();
      return true
    },
  })

  aboutToAppear(): void {
    setTimeout(() => {
      const param = this.pageParams as DrawingHistoryItem
      if (param) {
        this.drawingBoardVM.loadDrawing(param)
      } else {
        this.drawingBoardVM.init()
      }
    }, 300)
  }

  aboutToDisappear(): void {
    this.drawingBoardVM.resetAllState()
  }

  @Builder
  render() {
    Column() {
      this.topTool()

      Stack({ alignContent: Alignment.Bottom }) {
        Canvas(this.drawingBoardVM.context)
          .width(Constants.FULL_SIZE)
          .height(Constants.FULL_SIZE)
          .clip(true)
          .backgroundImage(this.drawingBoardVM.backgroundSelectType === 'Album' ?
          this.drawingBoardVM.canvasBackgroundImage : '')
          .backgroundImageSize(ImageSize.Cover)
          .backgroundColor(this.drawingBoardVM.backgroundSelectType === 'SolidColor' ? this.drawingBoardVM.canvasColor :
          Color.Transparent)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: this.drawingBoardVM.backgroundSelectType === 'Gradient' ? this.drawingBoardVM.gradientColor : []
          })
          .onReady(() => {
            // Canvas 重新加载时(折叠屏展开/折叠、小窗、分屏等场景)
            if (this.drawingBoardVM.needsRedraw()) {
              this.drawingBoardVM.redrawCanvas()
            }
          })
          .onTouch((event: TouchEvent) => {
            this.drawingBoardVM.onTouch(event)
          })
          .id(CommonConstants.DRAW_BOARD_ID)
        if (this.drawingBoardVM.isPreview && !this.drawingBoardVM.shapeMode) {
          Circle()
            .width(this.getSize())
            .height(this.getSize())
            .fill(Color.Transparent)
            .strokeWidth(1)
            .stroke('#4D000000')
            .position({
              x: this.drawingBoardVM.positionX - this.getSize(true),
              y: this.drawingBoardVM.positionY - this.getSize(true)
            })
        }
        if (this.drawingBoardVM.isColorSampling) {
          ColorShow({
            color: this.drawingBoardVM.selectColor,
            r: this.drawingBoardVM.rgb[0],
            g: this.drawingBoardVM.rgb[1],
            b: this.drawingBoardVM.rgb[2],
            touchX: this.drawingBoardVM.touchX,
            touchY: this.drawingBoardVM.touchY,
            maxWidth: this.drawingBoardVM.context.width
          })
        }
      }
      .layoutWeight(1)
      .width(Constants.FULL_SIZE)
      .clip(true)
      .backgroundColor(Color.White)

      BottomMenuBar()
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
  }

  private getSize(half?: boolean): number {
    const size = this.drawingBoardVM.eraserMode ? this.drawingBoardVM.eraserSize : this.drawingBoardVM.strokeWidth
    if (half) {
      return size / 2
    }
    return size
  }

  @Builder
  drawTitle() {
    Column() {
      TextInput({
        text: this.titleInput,
        placeholder: '请输入绘画保存的名称',
      })
        .fontSize($r('sys.float.Body_M'))
        .onChange((value) => {
          this.titleInput = value;
        })
        .width(Constants.FULL_SIZE)
        .height($r('app.float.vp_40'))
        .borderRadius($r('sys.float.corner_radius_level10'))
    }
    .width(Constants.FULL_SIZE)
  }

  // 处理保存画作
  private async handleSaveDrawing() {
    // 防抖：如果正在保存，直接返回
    if (this.isSaving) {
      return
    }
    this.isSaving = true
    if (this.drawingBoardVM.isNewDrawing()) {
      // 新建画作：显示对话框输入名称(不使用 try-finally，由对话框回调控制)
      this.showSaveNewDrawingDialog()
    } else {
      // 编辑已有画作：直接保存
      try {
        const success = await this.drawingBoardVM.saveExistingDrawing()
        if (success) {
          phoneRouterControl.popPage()
        }
      } finally {
        // 延迟重置防抖标志
        setTimeout(() => {
          this.isSaving = false
        }, 500)
      }
    }
  }

  // 显示保存新画作对话框
  private showSaveNewDrawingDialog() {
    this.titleInput = this.drawingBoardVM.title
    let isConfirming = false // 对话框确认按钮防抖标志
    
    baseToast.show({
      type: 'dialog',
      hasTitle: $r('app.string.dialog_title_tip'),
      cancelColor: $r('sys.color.icon_secondary'),
      confirmColor: $r('app.color.theme_color'),
      confirmText: $r('app.string.save'),
      messageBuilder: () => {
        this.drawTitle()
      },
      confirmAction: async () => {
        // 防止对话框确认按钮被重复点击
        if (isConfirming) {
          return
        }
        isConfirming = true
        try {
          const success = await this.drawingBoardVM.saveNewDrawing(this.titleInput)
          if (success) {
            baseToast.hide()
            // 跳转到画本列表
            phoneRouterControl.replacePage({
              pageName: RouterMap.DRAWING_BOARD_LIST,
              builder: wrapBuilder(DrawBoardListPageBuilder)
            })
          } else {
            // 保存失败，重置标志允许重试
            isConfirming = false
            this.isSaving = false
          }
        } catch (err) {
          // 发生错误，重置标志允许重试
          isConfirming = false
          this.isSaving = false
        }
      },
      cancelAction: () => {
        // 取消时重置防抖标志
        this.isSaving = false
        baseToast.hide()
      },
    })
  }

  @Builder
  topTool() {
    Row() {
      Image($r('app.media.ic_back'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .onClick(() => {
          this.backPress();
        })
      Blank()

      // 操作按钮组
      Row({ space: 8 }) {
        Image($r('app.media.ic_clear'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .onClick(() => {
            baseToast.show({
              type: 'dialog',
              message: $r('app.string.dialog_message_clear_canvas'),
              cancelColor: $r('sys.color.icon_secondary'),
              confirmColor: $r('app.color.theme_color'),
              confirmAction: () => {
                this.drawingBoardVM.clearCanvas();
                baseToast.hide();
                GlobalContext.getUIContext().getPromptAction().showToast({ message: '清除成功' })
              },
              cancelAction: () => {
                baseToast.hide();
              },
            });
          });
        Image(this.drawingBoardVM.unDoDraw ? $r('app.media.ic_undo_enabled') : $r('app.media.ic_undo_disabled'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .enabled(this.drawingBoardVM.unDoDraw)
          .onClick(() => {
            this.drawingBoardVM.drawOperateUndo();
          });

        Image(this.drawingBoardVM.redoDraw ? $r('app.media.ic_redo_enabled') : $r('app.media.ic_redo_disabled'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .margin({ left: $r('app.float.vp_8') })
          .enabled(this.drawingBoardVM.redoDraw)
          .onClick(() => {
            this.drawingBoardVM.drawOperateRedo();
          });
        Image($r('app.media.ic_save'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .margin({ left: $r('app.float.vp_8') })
          .onClick(() => {
            this.handleSaveDrawing()
          });
      }
    }
    .width(Constants.FULL_SIZE)
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_8'),
      bottom: $r('app.float.vp_8')
    })
  }

  private backPress() {
    if (!this.drawingBoardVM.isSave) {
      baseToast.show({
        type: 'dialog',
        hasTitle: $r('app.string.dialog_title_warm_tip'),
        cancelColor: $r('sys.color.icon_secondary'),
        confirmColor: $r('app.color.theme_color'),
        confirmText: $r('app.string.save'),
        message: $r('app.string.dialog_message_unsaved_drawing'),
        confirmAction: async () => {
          baseToast.hide();
          await this.handleSaveDrawing();
        },
        cancelAction: () => {
          phoneRouterControl.popPage();
        }
      });
    } else {
      phoneRouterControl.popPage();
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      pageConfig: this.pageInfo,
      useSafePadding: false
    })
  }
}