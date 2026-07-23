import { CanvasTextItem } from '../model/BeautificationParam';
import { Constants } from '../constant/Constants';
import { BreakpointNameEnum, CommonColorPicker, CommonConstants, OperateType, WindowUtil } from 'commonlib';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { ToolBarHeader } from './ToolBarHeader';
import { TextFontUtil } from '../util/TextFontUtil';
import { TextFontModel } from '../model/ImageModel';
import { NumberStepper } from './NumberStepper';
import { LayerType } from '../constant/Enum';

@ComponentV2
export struct AddTextToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  @Local textTabIndex: number = 0;
  @Local hasUseVipText: boolean = false;
  tabTitle: string[] = ['文案库', '字体', '样式'];
  private textTabController: TabsController = new TabsController();

  aboutToAppear(): void {
    WindowUtil.setGestureBackEnabled(false);
  }

  aboutToDisappear(): void {
    WindowUtil.setGestureBackEnabled(true);
  }

  @Computed
  get listLines() {
    return this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 4 : 8
  }

  textFontVisibility(item: TextFontModel) {
    return this.vm.canvasText.font === item.font.familyName ? Visibility.Visible : Visibility.None;
  }

  exitText() {
    this.vm.showRemind = false;
    this.vm.showCanvasText = false;
    // 切换操作时，图片需要复原位置和大小
    this.vm.matrix4TransitVM.resetImageTransform(() => {
      this.vm.operateType = OperateType.NONE;
    });
    this.textTabIndex = 0;
    this.vm.saveText = false;
    this.hasUseVipText = false;
    this.vm.canvasText = new CanvasTextItem();
  }

  saveText() {
    if (this.vm.canvasText.text) {
      if (this.hasUseVipText && !this.vm.userInfo.isVip) {
        this.vm.showRemind = true;
        this.getUIContext().getPromptAction().showToast({ message: '成为vip享受很多精彩资源！' });
        return
      }
      this.vm.saveText = true;
      setTimeout(() => {
        this.vm.saveImage(LayerType.TEXT);
        this.exitText()
      }, 20)
    } else {
      this.exitText()
    }
  }

  build() {
    Column() {
      // 头部
      ToolBarHeader({
        close: () => {
          this.exitText();
        },
        confirm: () => {
          this.saveText();
        },
        centerBuilder: () => {
          this.textTitle()
        }
      })
      Row() {
        Tabs({ barPosition: BarPosition.Start, controller: this.textTabController, index: this.textTabIndex }) {
          TabContent() {
            this.textRecommendBuilder();
          };

          TabContent() {
            this.fontListBuilder();
          }
          .align(Alignment.Top)

          TabContent() {
            this.fontStyleBuilder();
          };
        }
        .barHeight(0)
        .scrollable(false)
        .animationDuration(0)
        .onChange((index: number) => {
          this.textTabIndex = index;
        });
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(172)
      .padding({
        left: this.vm.breakPointModel.pagePadding,
        right: this.vm.breakPointModel.pagePadding
      })
    }
    .padding({ bottom: CommonConstants.PADDING_M })
    .borderRadius({ topLeft: 16, topRight: 16 })
    .backgroundColor($r('sys.color.background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  textTitle() {
    Row({ space: 32 }) {
      ForEach(this.tabTitle, (item: string, index: number) => {
        Text(item)
          .fontColor(this.textTabIndex === index ? $r('sys.color.multi_color_aux_01') : Color.Black)
          .fontSize(16)
          .fontWeight(this.textTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
          .onClick(() => {
            this.textTabIndex = index;
            this.textTabController.changeIndex(this.textTabIndex);
          });
      }, (item: string) => item);
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder
  fontListBuilder() {
    List({ space: 12 }) {
      ForEach(TextFontUtil.fontList, (item: TextFontModel) => {
        ListItem() {
          Column({ space: 4 }) {
            Stack() {
              Column() {
                Text('拍摄美化')
                  .fontSize(14)
                  .fontFamily(item.font.familyName)
              }
              .width('100%')
              .height(46)
              .borderRadius(8)
              .justifyContent(FlexAlign.Center)
              .backgroundColor($r('sys.color.background_secondary'))

              // 选中时的蒙层
              Column() {
                Image($r('app.media.checkmark_circle')).width(24);
              }
              .width('100%')
              .height(46)
              .borderRadius(8)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('rgba(0, 0, 0, 0.4)')
              .visibility(this.textFontVisibility(item))
            }

            if (item.isVip) {
              Image($r('app.media.ic_beauty_vip'))
                .width(16)
                .height(16)
                .position({left: 0, top: 0})
            }

            Text(item.font.familyName || '默认字体')
              .fontSize(12)
              .fontWeight(400)
              .lineHeight(16)
          }
          .onClick(() => {
            this.vm.showRemind = item.isVip;
            this.hasUseVipText = item.isVip;
            this.vm.canvasText.font = item.font.familyName;
          });
        };
      }, (item: TextFontModel) => JSON.stringify(item));
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignListItem(ListItemAlign.Start)
    .scrollBar(BarState.Off)
    .lanes(this.listLines, 12)
    .contentStartOffset(12)
  }

  @Builder
  fontStyleBuilder() {
    Column({ space: 12 }) {
      // 颜色选择
      CommonColorPicker({
        onSelectColor: (color: string) => {
          this.vm.canvasText.currentColor = color;
        }
      })

      Row({ space: 16 }) {
        Text('字号').fontSize(16)
        Row() {
          NumberStepper({
            value: this.vm.canvasText.fontSize,
            min: 10,
            max: 80,
            buttonType: ButtonType.Circle,
            onChange: (value) => {
              if (value <= 10) {
                return;
              }
              if (value > 80) {
                return;
              }
              this.vm.canvasText.fontSize = value;
            },
          })
        }
      }.width('100%')
      .justifyContent(FlexAlign.Start);

      Row({ space: 16 }) {
        Text('透明').fontSize(16)
        Slider({
          value: this.vm.canvasText.opacity,
          min: 0,
          max: 1,
          step: 0.1,
          style: SliderStyle.OutSet,
        })
          .layoutWeight(1)
          .showTips(true)
          .onChange((value: number) => {
            this.vm.canvasText.opacity = value;
          });
      }

      Row() {
        Image($r('app.media.bold'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.canvasText.isBold = !this.vm.canvasText.isBold;
          })
          .backgroundColor(this.vm.canvasText.isBold ? $r('sys.color.comp_background_tertiary') : Color.White);

        Image($r('app.media.italic'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.canvasText.isItalics = !this.vm.canvasText.isItalics;
          })
          .backgroundColor(this.vm.canvasText.isItalics ? $r('sys.color.comp_background_tertiary') : Color.White);

        Image($r('app.media.decoration'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.canvasText.isUnderline = !this.vm.canvasText.isUnderline;
          })
          .backgroundColor(this.vm.canvasText.isUnderline ? $r('sys.color.comp_background_tertiary') : Color.White);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);
    }.width('100%');
  }

  @Builder
  textRecommendBuilder() {
    List({ space: 12 }) {
      ForEach(Constants.recommendTextList, (item: string) => {
        ListItem() {
          Text(item)
            .fontSize(16)
            .onClick(() => {
              this.vm.showCanvasText = true;
              this.vm.canvasText.text = item;
            });
        };
      }, (item: string) => item);
    }.margin({ top: 12 }).width('100%')
    .height('calc(100% - 12vp)')
    .scrollBar(BarState.Off);
  }
}