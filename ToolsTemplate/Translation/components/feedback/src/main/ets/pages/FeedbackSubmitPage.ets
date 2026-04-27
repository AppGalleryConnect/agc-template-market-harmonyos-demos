import { UIContext, KeyboardAvoidMode } from '@kit.ArkUI';
import { BreakpointType, PageName } from '../common/CustomTypes';
import { Config } from '../common/Config';
import { pickImage } from '../utils/PickImageUtils';
import { FeedbackFormVM } from '../viewmodels/FeedbackFormVM';
import { Api } from '../http/Api';

@ComponentV2
struct FeedbackSubmitPage {
  private navPathStack: NavPathStack = new NavPathStack();
  private uiContext: UIContext = this.getUIContext();
  private cacheKeyboardAvoidMode: KeyboardAvoidMode = KeyboardAvoidMode.OFFSET;
  @Local private templateForGrid: string = '1fr '.repeat(4);
  @Local private imagesGap: number = 8;
  @Local private submitButtonAreaWidth: string = '100%';
  @Local private isSubmitting: boolean = false;
  @Local private form: FeedbackFormVM = new FeedbackFormVM(this.uiContext);
  @Local private statusBarHeight: number = 0;

  public aboutToAppear(): void {
    this.cacheKeyboardAvoidMode = this.uiContext.getKeyboardAvoidMode();
    // 使用固定状态栏高度
    this.statusBarHeight = 39;
  }

  public build(): void {
    NavDestination() {
      Column() {
        this.buildTitleBar()
        GridRow({
          columns: 12,
          breakpoints: { value: ['320vp', '600vp', '840vp', '1440vp'] }
        }) {
          GridCol({
            span: {
              xs: 12,
              sm: 12,
              md: 10,
              lg: 8
            },
            offset: {
              xs: 0,
              sm: 0,
              md: 1,
              lg: 2
            }
          }) {
            Column() {
              Scroll() {
                Column() {
                  Text() {
                    Span('问题描述')
                      .fontColor($r('sys.color.font_secondary'))
                    Span(' *')
                      .fontColor($r('sys.color.warning'))
                  }
                  .fontSize($r('sys.float.Body_M'))
                  .margin({ top: 24, bottom: 8 })

                  this.textAreaBuilder()

                  if (this.form.descriptionErrorMessage) {
                    Text(this.form.descriptionErrorMessage)
                      .margin({ top: 8 })
                      .padding({ left: 8 })
                      .fontColor($r('sys.color.warning'))
                      .fontSize($r('sys.float.Caption_M'))
                      .fontWeight(FontWeight.Regular)
                  }

                  Text('上传图片')
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 24, bottom: 8 })

                  this.girdBuilder()

                  Text('您的联系方式')
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 24, bottom: 8 })

                  this.textInputBuilder()

                  if (this.form.contactErrorMessage) {
                    Text(this.form.contactErrorMessage)
                      .margin({ top: 8 })
                      .padding({ left: 8 })
                      .fontColor($r('sys.color.warning'))
                      .fontSize($r('sys.float.Caption_M'))
                      .fontWeight(FontWeight.Regular)
                  }
                }
                .width('100%')
                .constraintSize({ minHeight: '100%' })
                .alignItems(HorizontalAlign.Start)
                .padding({ bottom: 12 })
              }
              .layoutWeight(1)
              /**
               * 将 Padding 单独设置在 Scroll 而非父组件，保证空白区域在 Scroll 之内以支持触摸滚动
               *
               * 当页面处于极端高度场景时，如分屏模式下的最小窗口，一旦文本描述框自身可滚动，且刚好处于
               * 中间位置并大于窗口，则必须通过划动其两侧的空白区域来滚动页面。
               */
              .padding({ left: 16, right: 16 })
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)

              this.bottomButtonsSpace()
            }
          }
        }
        .layoutWeight(1)
        .onBreakpointChange((breakpoints: string) => {
          if (breakpoints === BreakpointType.XS || breakpoints === BreakpointType.SM) {
            this.imagesGap = 8;
            this.templateForGrid = '1fr '.repeat(4);
            this.submitButtonAreaWidth = '100%';
          } else if (breakpoints === BreakpointType.MD) {
            this.imagesGap = 12;
            this.templateForGrid = '1fr '.repeat(6);
            this.submitButtonAreaWidth = '60%';
          } else {
            this.imagesGap = 16;
            this.templateForGrid = '1fr '.repeat(6);
            this.submitButtonAreaWidth = '60%';
          }
        })
      }
      .width('100%')
      .height('100%')
      .padding({ top: this.statusBarHeight })
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .padding({ top: 40, bottom: 28 })
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onShown(() => this.uiContext.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE))
    .onWillDisappear(() => this.uiContext.setKeyboardAvoidMode(this.cacheKeyboardAvoidMode))
    .onReady((ctx: NavDestinationContext) => this.navPathStack = ctx.pathStack)
    .onBackPressed(() => {
      this.navPathStack.pop()
      return true
    })
  }

  @Builder
  textAreaBuilder() {
    //
    TextArea({
      placeholder: '请详细描述您的问题（必填）',
      text: this.form.description
    })
      .width('100%')
      .height(150)
      .borderRadius(16)
      .padding(12)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .placeholderColor($r('sys.color.font_secondary'))
      .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Regular)
      .borderWidth($r('sys.float.border_medium'))
      .borderColor(this.form.descriptionErrorMessage ?
      $r('sys.color.warning') :
      $r('sys.color.comp_background_primary')
      )
      .maxLength(Config.DESC_TEXT_MAX_LENGTH)
      .showCounter(true)
      .focusable(!this.isSubmitting)
      .onChange((value: string) => this.form.description = value)
      .onEditChange((isEditing: boolean) => {
        if (isEditing) {
          this.form.descriptionErrorMessage = '';
        } else {
          this.form.validateDescription(false);
        }
      })
  }

  @Builder
  textInputBuilder() {
    TextInput({
      placeholder: '手机号或邮箱（选填）',
      text: this.form.contact
    })
      .width('100%')
      .height(40)
      .borderRadius(16)
      .padding({
        left: 12,
        right: 12,
        top: 0,
        bottom: 0
      })
      .backgroundColor($r('sys.color.comp_background_primary'))
      .placeholderColor($r('sys.color.font_secondary'))
      .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Regular)
      .borderWidth($r('sys.float.border_medium'))
      .borderColor(this.form.contactErrorMessage ?
      $r('sys.color.warning') :
      $r('sys.color.comp_background_primary')
      )
      .focusable(!this.isSubmitting)
      .onChange((value: string) => this.form.contact = value)
      .onEditChange((isEditing: boolean) => {
        if (isEditing) {
          this.form.contactErrorMessage = '';
        } else {
          this.form.validateContact(false);
        }
      })
  }

  @Builder
  girdBuilder() {
    Grid() {
      ForEach(this.form.selectedUris, (uri: string, index: number) => {
        GridItem() {
          Stack({ alignContent: Alignment.TopEnd }) {
            Image(uri)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Contain)
              .draggable(false)
            SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
              .fontSize(24)
              .fontColor(['#FF999999', $r('sys.color.comp_background_primary')])
              .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
              .fontWeight(FontWeight.Normal)
              .onClick(() => this.form.selectedUris.splice(index, 1))
          }
          .width('100%')
          .aspectRatio(1)
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .clip(true)
        }
      }, (uri: string, index: number) => index + '_' + uri)
      /**
       * 图片上传按钮
       */
      if ((Config.MAX_IMAGE_COUNT - this.form.selectedUris.length) > 0) {
        GridItem() {
          Button() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(24)
              .fontColor([$r('sys.color.icon_secondary')])
              .fontWeight(FontWeight.Normal)
          }
          .width('100%')
          .aspectRatio(1)
          .type(ButtonType.ROUNDED_RECTANGLE)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .onClick(async () => {
            const maxSelectNumber: number = Config.MAX_IMAGE_COUNT - this.form.selectedUris.length;
            const uris: string[] = await pickImage(maxSelectNumber);
            this.form.selectedUris.push(...uris);
          })
        }
      }
    }
    .width('100%')
    .height('auto')
    .columnsTemplate(this.templateForGrid)
    .rowsGap(this.imagesGap)
    .columnsGap(this.imagesGap)
    .hitTestBehavior(this.isSubmitting ? HitTestMode.Block : HitTestMode.Default)
  }

  /**
   * 底部按钮区
   */
  @Builder
  bottomButtonsSpace() {
    Row() {
      Button() {
        Row() {
          if (this.isSubmitting) {
            LoadingProgress()
              .width(24)
              .height(24)
              .color($r('sys.color.icon_on_primary'))
              .margin({ right: 5 })
            Text('提交中...')
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
          } else {
            Text('提交')
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
          }
        }
      }
      .width('100%')
      .height(40)
      .type(ButtonType.ROUNDED_RECTANGLE)
      .stateEffect(!this.isSubmitting)
      .opacity(this.isSubmitting ? 0.4 : 1)
      .onClick(async () => {
        if (this.isSubmitting) {
          return;
        }
        this.uiContext.getFocusController().clearFocus();
        if (!this.form.validateAll()) {
          return;
        }
        this.isSubmitting = true;
        const isSuccess: boolean = await Api.submitFeedback(this.form.toSubmitDTO());
        if (isSuccess) {
          this.uiContext.getPromptAction().showToast({ message: '提交成功' });
          this.navPathStack.replacePathByName(PageName.FeedbackHistory, null);
        } else {
          this.uiContext.getPromptAction().showToast({ message: '提交失败，请稍后重试' });
        }
        this.isSubmitting = false;
      })
    }
    .width(this.submitButtonAreaWidth)
    .padding({ left: 16, right: 16, bottom: 12 })
  }

  /**
   * todo: 如果需要自定义标题栏样式，可以从以下代码着手修改
   */
  @Builder
  private buildTitleBar(): void {
    Row() {
      /**
       * 页面返回按钮
       */
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .margin({ right: 8 })
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => this.navPathStack.pop())

      /**
       * 标题文本
       */
      Text('问题反馈')
        .layoutWeight(1)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
      /**
       * 反馈记录页跳转按钮
       */
      Button() {
        SymbolGlyph($r('sys.symbol.doc_plaintext'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .margin({ left: 8 })
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => this.navPathStack.pushPathByName(PageName.FeedbackHistory, null))
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }
}

@Builder
export function BuildFeedbackSubmitPage(): void {
  FeedbackSubmitPage()
}
