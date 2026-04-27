import { common } from '@kit.AbilityKit';
import { RealNameAuthPageVM } from '../viewmodel/RealNameAuthPageVM';
import { IdCardInfo } from '../types';


@ComponentV2
export struct RealNameAuthView {
  @Param pathStack: NavPathStack = new NavPathStack();
  @Event confirm: () => void;
  vm: RealNameAuthPageVM = new RealNameAuthPageVM();
  @Local context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext

  build() {
    Column() {
      Column() {
        Scroll() {
          Column({ space: 12 }) {
            this.buildTipInfo()

            ForEach(this.vm.idCardList, (item: IdCardInfo) => {
              this.buildIdCardPic(item);
            }, (item: IdCardInfo) => JSON.stringify(item))

            Blank().height(4)
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 12, bottom: 16 })
          .backgroundColor(Color.White)
          .borderRadius(16)
          .bindSheet($$this.vm.showIdCardSheet, this.builderIdCardMenus(), {
            height: 160,
            backgroundColor: Color.White,
            showClose: false,
            preferType: SheetType.BOTTOM,
          })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8 })

      this.buildButtonRow()
    }
    .width('100%')
  }

  @Builder
  buildTipInfo() {
    Column({ space: 12 }) {
      Text('请拍照或上传身份证正反面')
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .lineHeight(21)
        .textAlign(TextAlign.Start)
      Text('正面为头像面，反面为国徽面')
        .fontSize(12)
        .fontColor($r('sys.color.font_emphasize'))
        .fontWeight(FontWeight.Regular)
        .lineHeight(16)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildIdCardPic($$: IdCardInfo) {
    Row({ space: 12 }) {
      Column() {
        Text($$.title)
          .width(48)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
      }
      .justifyContent(FlexAlign.Start)
      .alignSelf(ItemAlign.Stretch)

      Stack({ alignContent: Alignment.Top }) {
        Image($$.cardImg || $$.icon)
          .width('100%')
          .aspectRatio(220/136)
          .enabled(!$$.cardImg)
          .constraintSize({ maxWidth: 320 })
          .onError(() => {
            $$.cardImg = $r('app.media.id_card_pic_1')
          })
          .onClick(() => {
            this.vm.currentIdx = $$.id;
            if ($$.id === 2) {
              this.vm.showIdCardSheet = true;
            } else {
              // 使用身份证识别
              this.pathStack.pushPathByName('CardRecognitionPage', this.vm.currentIdx, (popInfo: PopInfo) => {
                if (popInfo.result) {
                  const imageUrl = popInfo.result as string;
                  this.vm.setResult(imageUrl);
                }
              })
            }
          })

        if ($$.cardImg) {
          Row() {
            SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
              .fontSize(20)
              .fontColor([$r('sys.color.icon_secondary')])
              .margin({ top: 6, right: 6 })
              .onClick(() => {
                $$.cardImg = '';
                this.vm.currentIdx = -1;
              })
          }
          .width('100%')
          .constraintSize({ maxWidth: 320 })
          .justifyContent(FlexAlign.End)
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius(8)
  }

  @Builder
  sheetMenuItem(label: string, action?: () => void) {
    Text(label)
      .width('100%')
      .textAlign(TextAlign.Center)
      .fontSize(16)
      .fontColor($r('sys.color.font_primary'))
      .padding(4)
      .onClick(() => {
        action?.();
        this.vm.showIdCardSheet = false;
      })
  }

  @Builder
  builderIdCardMenus() {
    Column({ space: 12 }) {
      this.sheetMenuItem('拍照', () => {
        if (this.vm.currentIdx === -1) {
          return;
        }
        // 手持身份证照片
        this.vm.takePhoto(this.context);
      })

      this.sheetMenuItem('从相册中选择', () => {
        this.vm.pickerImage();
      })

      Row().width('100%').height(6).backgroundColor($r('sys.color.comp_background_tertiary'))

      this.sheetMenuItem('取消')
    }
    .width('100%')
    .padding({ top: 12, bottom: 24 })
  }

  @Builder
  buildButtonRow() {
    Row() {
      Button('确认')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .width('100%')
        .constraintSize({ maxWidth: 448 })
        .enabled(this.allPicChosen())
        .onClick(() => {
          this.confirm?.();
        })
    }
    .width('100%')
    .margin({ top: 12 })
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
  }

  allPicChosen(): boolean {
    const enabled = this.vm.idCardList.every((item) => item.cardImg)
    return enabled;
  }
}