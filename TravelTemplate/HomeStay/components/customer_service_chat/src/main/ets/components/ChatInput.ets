import { common } from '@kit.AbilityKit'
import { Scale } from '@kit.ArkUI'
import { FeatureItem } from './FeatureItem'
import { Constants } from '../common/Constant'
import { GridRowColSetting } from '../common/GridRowColSetting'
import { FeatureItemConfig, FeatureSwitch } from '../models/DataModels'
import { ChatVM } from '../viewmodels/ChatVM'

@ComponentV2
export struct ChatInput {
  @Param placeHolder: ResourceStr = '请输入';
  @Param featureSwitch: FeatureSwitch = {};
  @Param additionalFeatureItems: FeatureItemConfig[] = [];
  @Local immediatelyOpacity: number = 1; // 立刻触发动画的Stack初始透明度
  @Local immediatelyScale: Scale = { x: 1, y: 1 }; // 立刻触发动画的Stack初始缩放度
  @Local vm: ChatVM = ChatVM.getInstance();

  @Computed
  get countShowValues() {
    const showCamera = this.featureSwitch.showCamera ?? true;
    const showPicture = this.featureSwitch.showPicture ?? true;
    const showLocation = this.featureSwitch.showLocation ?? true;
    return (showCamera ? 1 : 0) + (showPicture ? 1 : 0) + (showLocation ? 1 : 0);
  }

  @Computed
  get expandPadding() {
    const totalItems = this.additionalFeatureItems.length + this.countShowValues;
    const threshold = this.vm.breakpoint === 'sm' ? 4 : 8;
    return totalItems > threshold ? Constants.PADDING_EXPEND_SMALL : Constants.PADDING_EXPEND_BIG;
  }

  @Computed
  get isNeedIndicator() {
    const totalItems = this.additionalFeatureItems.length + this.countShowValues;
    const threshold = this.vm.breakpoint === 'sm' ? 8 : 16;
    return totalItems > threshold;
  }

  @Computed
  get featuresHeight() {
    const totalItems = this.additionalFeatureItems.length + this.countShowValues;
    const showThreshold = this.vm.breakpoint === 'sm' ? 4 : 8;

    // 如果项目数不超过显示阈值，用基础高度
    if (totalItems <= showThreshold) {
      return Constants.EXPAND_ITEM_HEIGHT + 2 * this.expandPadding;
    }

    // 否则使用 swiper 高度或普通高度
    return this.isNeedIndicator ? Constants.FEATURE_SWIPER_HEIGHT + 2 * this.expandPadding :
      Constants.FEATURE_HEIGHT + 2 * this.expandPadding;
  }

  @Computed
  get swiperFeatures() {
    let swiperFeatures: FeatureItemConfig[][] = [];
    const isSmBreakpoint = this.vm.breakpoint === 'sm';
    // 第一个列表
    const firstListSize = isSmBreakpoint ? (8 - this.countShowValues) : (16 - this.countShowValues);
    const firstChunk = this.additionalFeatureItems.slice(0, firstListSize);
    swiperFeatures.push(firstChunk);
    // 计算其他列表的容量
    const otherListSize = isSmBreakpoint ? 8 : 16;
    let remainingItems = this.additionalFeatureItems.slice(firstListSize);
    while (remainingItems.length > 0) {
      const chunk = remainingItems.slice(0, otherListSize);
      swiperFeatures.push(chunk);
      remainingItems = remainingItems.slice(otherListSize);
    }
    return swiperFeatures;
  }

  expandOffset(index: number, isFirst: boolean = true) {
    if (['sm', 'md'].includes(this.vm.breakpoint)) {
      return 0;
    }
    if (((this.countShowValues === 0) && (index === 0)) || (index === 0 && !isFirst)) {
      return 2;
    }
    if (isFirst) {
      return index === (8 - this.countShowValues) ? 4 : 0;
    }
    return (index % 8 === 0) && (index % 16 !== 0) ? 4 : 0;
  }

  isFixedHeight(length: number) {
    if ((this.vm.breakpoint === 'sm') && (length % 8 !== 0)) {
      return true;
    } else if (['md', 'lg', 'xl'].includes(this.vm.breakpoint) && (length % 16 !== 0)) {
      return true;
    }
    return false;
  }

  aboutToAppear(): void {
    this.vm.speechRecognizer.intiEngine();
  }

  aboutToDisappear(): void {
    this.vm.speechRecognizer.shutdown();
  }

  build() {
    Column() {
      this.inputRowBuilder()

      if (this.vm.isVoiceMode) {
        this.voiceToTextBuilder()
      }

      if (this.vm.isExpand) {
        this.expandMoreBuilder()
      }
    }
    .margin({
      bottom: this.vm.isKeyboard ?
        (this.getUIContext().px2vp(this.vm.keyboardPadding) - this.vm.windowModel.windowBottomPadding) : 0
    })
    .width(Constants.FULL_PERCENT)
  }

  @Builder
  inputRowBuilder() {
    Row() {
      SymbolGlyph(!this.vm.isVoiceMode ? $r('sys.symbol.mic_filled_and_circle') : $r('sys.symbol.keyboard_circle'))
        .fontSize(Constants.ICON_SIZE)
        .fontColor([$r('sys.color.icon_primary')])
        .margin({
          left: Constants.PADDING_S,
          right: Constants.PADDING_XL,
          bottom: Constants.PADDING_S,
        })
        .onClick(() => {
          this.vm.onVoiceIconClick(this.getUIContext().getHostContext() as common.UIAbilityContext);
        })

      TextArea({
        placeholder: this.placeHolder,
        text: this.vm.textValue,
        controller: this.vm.textAreaController,
      })
        .align(Alignment.Center)
        .constraintSize({ minHeight: Constants.AVATAR_SIZE })
        .layoutWeight(1)
        .enterKeyType(EnterKeyType.Send)
        .placeholderColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .padding({
          left: Constants.PADDING_M,
          right: Constants.PADDING_M,
          top: Constants.PADDING_S,
          bottom: Constants.PADDING_S
        })
        .onChange((value) => {
          this.vm.textValue = value;
        })
        .onEditChange((data: boolean) => {
          if (data) {
            this.vm.isVoiceMode = false;
            this.vm.isExpand = false;
          }
        })
        .onSubmit((_enterKey: EnterKeyType, event: SubmitEvent) => {
          // 保持键盘不关闭
          event.keepEditableState()
          this.vm.sendTextMessage();
        })

      SymbolGlyph($r('sys.symbol.plus_circle'))
        .fontSize(Constants.ICON_SIZE)
        .fontColor([$r('sys.color.icon_primary')])
        .margin({
          left: Constants.PADDING_M,
          right: Constants.PADDING_S,
          bottom: Constants.PADDING_S,
        })
        .onClick(() => {
          this.vm.onPlusIconClick();
        })

      if (!this.vm.isVoiceMode) {
        SymbolGlyph($r('sys.symbol.arrow_up_circle_fill'))
          .fontSize(Constants.ICON_SIZE)
          .fontColor(this.vm.textValue ? [$r('sys.color.comp_background_emphasize')] :
            [$r('sys.color.comp_emphasize_secondary')])
          .margin({ bottom: Constants.PADDING_S })
          .onClick(() => {
            if (this.vm.textValue) {
              this.vm.sendTextMessage();
            }
          })
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .alignItems(VerticalAlign.Bottom)
    .constraintSize({ minHeight: Constants.BOTTOM_BAR_HEIGHT })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding({
      left: Constants.PADDING_XL,
      right: Constants.PADDING_XL,
      top: Constants.PADDING_S,
      bottom: Constants.PADDING_S,
    })
  }

  @Builder
  voiceToTextBuilder() {
    Row({ space: Constants.SPACE_VOICE_CIRCLE }) {
      if (this.vm.textValue) {
        this.buttonCircleBuilder('清除', $r('sys.color.font_secondary'), false)
      }

      Column({ space: ['lg', 'xl'].includes(this.vm.breakpoint) ? Constants.SPACE_TWENTY : Constants.SPACE_M }) {
        Stack({ alignContent: Alignment.Center }) {
          Circle({ width: Constants.MIC_CIRCLE_SIZE, height: Constants.MIC_CIRCLE_SIZE })
            .fill('#DAE7FE')
            .opacity(this.immediatelyOpacity)
            .scale(this.immediatelyScale)

          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.mic_fill'))
              .fontSize(Constants.MIC_SIZE)
              .fontColor([$r('sys.color.icon_on_primary')])
          }
          .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.8 })
          .linearGradient({
            angle: 140.27,
            colors: [['#2070f3', 0], ['#6cd1ff', 0.97]],
          })
          .width(Constants.MIC_BUTTON_SIZE)
          .height(Constants.MIC_BUTTON_SIZE)
        }
        .gesture(
          LongPressGesture({ duration: 200 })
            .onAction(() => {
              this.vm.handleSpeaking(this.getUIContext());
              this.getUIContext()?.animateTo({ duration: 1000, iterations: -1, curve: Curve.EaseInOut },
                () => {
                  this.immediatelyOpacity = 0;
                  this.immediatelyScale = { x: 2, y: 2 };
                });
            })
            .onActionEnd(() => {
              this.vm.finishSpeaking();
              this.getUIContext()?.animateTo({ duration: 0, iterations: -1, curve: Curve.EaseInOut },
                () => {
                  this.immediatelyOpacity = 1;
                  this.immediatelyScale = { x: 1, y: 1 };
                });
            })
        )

        Text('长按说话转文字')
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Medium)
          .lineHeight(Constants.FONT_HEIGHT_16)
      }
      .alignItems(HorizontalAlign.Center)

      if (this.vm.textValue) {
        this.buttonCircleBuilder('发送', $r('sys.color.font_emphasize'), true)
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .justifyContent(FlexAlign.Center)
    .width(Constants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .height(Constants.EXPEND_HEIGHT)
    .padding({ top: Constants.PADDING_VOICE_TOP, bottom: Constants.PADDING_VOICE_BOTTOM })
  }

  @Builder
  buttonCircleBuilder(text: string, color: Resource, operation: boolean) {
    Button(text, { type: ButtonType.Circle })
      .fontColor(color)
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Medium)
      .width(['lg', 'xl'].includes(this.vm.breakpoint) ? Constants.CIRCLE_BUTTON_SIZE_LG : Constants.CIRCLE_BUTTON_SIZE)
      .height(['lg', 'xl'].includes(this.vm.breakpoint) ? Constants.CIRCLE_BUTTON_SIZE_LG :
        Constants.CIRCLE_BUTTON_SIZE)
      .padding({ left: Constants.PADDING_TEN, right: Constants.PADDING_TEN })
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .onClick(() => {
        if (!operation) {
          this.vm.textValue = '';
        } else {
          this.vm.sendTextMessage();
        }
      })
  }

  @Builder
  expandMoreBuilder() {

    Swiper() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        if (this.featureSwitch.showCamera ?? true) {
          GridCol({ span: 1, offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET }) {
            FeatureItem({
              icon: $r('sys.symbol.camera_fill'),
              label: '拍照',
              onItemClick: this.vm.onCameraIconClick,
            })
          }
        }

        if (this.featureSwitch.showPicture ?? true) {
          GridCol({
            span: 1,
            offset: this.featureSwitch.showCamera === false ? GridRowColSetting.DEFAULT_CENTER_COL_OFFSET : 0
          }) {
            FeatureItem({
              icon: $r('sys.symbol.picture_fill'),
              label: '图片',
              onItemClick: this.vm.onPictureIconClick,
            })
          }
        }

        if (this.featureSwitch.showLocation ?? true) {
          GridCol({
            span: 1,
            offset: this.countShowValues <= 1 ? GridRowColSetting.DEFAULT_CENTER_COL_OFFSET : 0
          }) {
            FeatureItem({
              icon: $r('sys.symbol.local_fill'),
              label: '位置',
              onItemClick: this.vm.onLocationIconClick,
            })
          }
        }

        ForEach(this.swiperFeatures[0], (item: FeatureItemConfig, index: number) => {
          GridCol({ span: 1, offset: this.expandOffset(index) }) {
            FeatureItem({
              icon: item.icon,
              label: item.label,
              isSymbolGraph: item.isSymbolGraph,
              onItemClick: item.onClick,
            })
          }
        }, (listItem: FeatureItemConfig) => JSON.stringify(listItem.label))
      }

      ForEach(this.swiperFeatures.slice(1), (perSwiperItem: FeatureItemConfig[]) => {
        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          ForEach(perSwiperItem, (item: FeatureItemConfig, index: number) => {
            GridCol({ span: 1, offset: this.expandOffset(index, false) }) {
              FeatureItem({
                icon: item.icon,
                label: item.label,
                isSymbolGraph: item.isSymbolGraph,
                onItemClick: item.onClick,
              })
            }
          }, (listItem: FeatureItemConfig) => JSON.stringify(listItem.label))
        }
        .padding({
          bottom: this.isFixedHeight(perSwiperItem.length) ? Constants.EXPAND_ITEM_HEIGHT + Constants.SPACE_XL :
            undefined,
        })
      }, (perSwiperItem: FeatureItemConfig[]) => JSON.stringify(perSwiperItem[0].label))
    }
    .loop(false)
    .indicator(this.isNeedIndicator)
    .width(Constants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .height(this.featuresHeight)
    .padding({
      top: this.expandPadding,
      bottom: this.expandPadding,
      left: GridRowColSetting.getPageMargin(this.vm.breakpoint),
      right: GridRowColSetting.getPageMargin(this.vm.breakpoint),
    })
  }
}