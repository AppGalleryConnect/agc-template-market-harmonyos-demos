import { CanvasTextItem } from '../model/BeautificationParam';
import { Constants } from '../constant/Constants';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';

@ComponentV2
export struct AddTextToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  @Local textTabIndex: number = 0;
  private textTabController: TabsController = new TabsController();
  tabTitle: string[] = ['样式', '文案'];

  build() {
    Column() {
      Row() {
        Tabs({ barPosition: BarPosition.Start, controller: this.textTabController }) {
          TabContent() {
            this.fontStyleBuilder();
          };

          TabContent() {
            this.textRecommendBuilder();
          };
        }
        .barHeight(0)
        .onChange((index: number) => {
          this.textTabIndex = index;
        });
      };

      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.barIndex = -1;
            this.cleanText();
          });

        Row({ space: 32 }) {
          ForEach(this.tabTitle, (item: string, index: number) => {
            Text(item)
              .fontColor(this.textTabIndex === index ? '#ED6F21' : Color.Black)
              .fontSize(16)
              .fontWeight(this.textTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
              .onClick(() => {
                this.textTabIndex = index;
                this.textTabController.changeIndex(this.textTabIndex);
              });
          }, (item: string) => item);
        };

        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.barIndex = -1;
            this.vm.saveImageWithText();
          });
      }
      .height(24)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .padding(16)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius({ topLeft: 16, topRight: 16 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
  }

  @Builder
  fontStyleBuilder() {
    Column() {
      Row() {
        ForEach(Constants.fontColorList, (item: string) => {
          Stack() {
            Circle({ width: 24, height: 24 })
              .fill(item)
              .stroke(item === '#FFFFFF' ? '#000000' : Color.Transparent);

            Circle({ width: 12, height: 12 })
              .fill(item === '#FFFFFF' ? '#000000' : '#FFFFFF')
              .visibility(this.vm.canvasItemStack.currentColor === item ? Visibility.Visible : Visibility.None);
          }
          .onClick(() => {
            this.vm.canvasItemStack.currentColor = item;
          });
        }, (item: string) => item);
      }
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height(40)
      .margin({ bottom: 12 });

      Row() {
        Text('字号')
          .fontSize(16)
          .margin({ right: 16 });
        Row() {
          Image($r('app.media.minus'))
            .borderRadius(700)
            .backgroundColor('#F1F3F5')
            .height(28)
            .width(28)
            .padding(4)
            .onClick(() => {
              this.vm.canvasItemStack.fontSize--;
            });
          Text(this.vm.canvasItemStack.fontSize.toString())
            .fontSize(16)
            .fontWeight(FontWeight.Medium);
          Image($r('app.media.plus'))
            .borderRadius(700)
            .height(28)
            .width(28)
            .padding(4)
            .backgroundColor('#F1F3F5')
            .onClick(() => {
              this.vm.canvasItemStack.fontSize++;
            });
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(120)
        .height(32)
        .border({
          radius: 16,
          color: '#F1F3F5',
          width: 1,
          style: BorderStyle.Solid,
        });
      }.width('100%')
      .justifyContent(FlexAlign.Start);

      Row() {
        Text('透明')
          .fontSize(16)
          .margin({ right: 16 });
        Slider({
          value: this.vm.canvasItemStack.opacity,
          min: 0,
          max: 1,
          step: 0.1,
          style: SliderStyle.OutSet,
        })
          .layoutWeight(1)
          .showTips(true)
          .onChange((value: number) => {
            this.vm.canvasItemStack.opacity = value;
          });
      }
      .margin({ bottom: 12 });

      Row() {
        Image($r('app.media.bold'))
          .width(24)
          .height(24)
          .margin({ left: 8 })
          .onClick(() => {
            this.vm.canvasItemStack.isBold = !this.vm.canvasItemStack.isBold;
          })
          .backgroundColor(this.vm.canvasItemStack.isBold ? '#F1F3F5' : Color.White);
        Image($r('app.media.italic'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.vm.canvasItemStack.isItalics = !this.vm.canvasItemStack.isItalics;
          })
          .backgroundColor(this.vm.canvasItemStack.isItalics ? '#F1F3F5' : Color.White);
        Image($r('app.media.decoration'))
          .width(24)
          .height(24)
          .margin({ right: 8 })
          .onClick(() => {
            this.vm.canvasItemStack.isUnderline = !this.vm.canvasItemStack.isUnderline;
          })
          .backgroundColor(this.vm.canvasItemStack.isUnderline ? '#F1F3F5' : Color.White);
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
              this.vm.canvasItemStack.text = item;
            });
        };
      }, (item: string) => item);
    }.margin({ top: 12 }).width('100%')
    .height('calc(100% - 12vp)')
    .scrollBar(BarState.Off);
  }

  cleanText() {
    this.textTabIndex = 0;
    this.vm.canvasItemStack = new CanvasTextItem('#000000', 16, 100, false, false, false, '鸿蒙黑体', '', 25, 25);
  }
}