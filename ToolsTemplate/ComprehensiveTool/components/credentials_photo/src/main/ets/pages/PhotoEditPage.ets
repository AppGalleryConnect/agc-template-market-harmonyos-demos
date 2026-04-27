import { image } from '@kit.ImageKit';
import { PhotoContainer } from '../components/PhotoContainer';
import { NavTitle } from '../components/NavTitle';
import { PhotoEditPageVM } from '../viewModels/PhotoEditPageVM';
import { SettingItem, ColorItem, DressItem } from '../model/Index';
import { getInstance } from '../util/Route';
import { DESIGN_MIN_HEIGHT } from '../constant/Index';


@Builder
export function PhotoEditPageBuilder() {
  PhotoEditPage();
}


@ComponentV2
struct PhotoEditPage {
  vm: PhotoEditPageVM = PhotoEditPageVM.instance;
  private dialogId: number = -1;

  aboutToAppear(): void {
    this.vm.getRouteParam();
  }

  aboutToDisappear(): void {
    this.vm.initData();
  }

  async openDialog() {
    this.dialogId = await this.getUIContext().getPromptAction().openCustomDialog({
      builder: () => {
        this.confirmBuilder();
      },
      autoCancel: false,
      alignment: DialogAlignment.Center,
    });
  }

  closeDialog() {
    this.getUIContext().getPromptAction().closeCustomDialog(this.dialogId);
  }

  @Builder
  confirmBuilder() {
    Column({ space: 16 }) {
      Column() {
        Text('是否确认退出编辑？')
          .tipsExtend();
        Text('退出后编辑内容将不保存').tipsExtend();
      };

      Row({ space: 20 }) {
        Button('确认退出')
          .width('calc(50% - 10vp)')
          .height(40)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontColor($r('sys.color.warning'))
          .onClick(() => {
            this.closeDialog();
            getInstance().pop();
          });
        Button('继续编辑')
          .width('calc(50% - 10vp)')
          .height(40)
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .fontColor($r('sys.color.font_on_primary'))
          .onClick(() => {
            this.closeDialog();
          });
      }.width('100%');

    }
    .height(138)
    .padding({
      top: 24,
      left: 12,
      right: 12,
      bottom: 16,
    });
  }

  build() {
    NavDestination() {
      NavTitle({
        text: this.vm.navTitle,
        isEdit: true,
        onBlock: () => {
          if (this.vm.colorIndex === 0 && this.vm.dressIndex === 0) {
            getInstance().pop();
          } else {
            this.openDialog();
          }
        },
        onSave: () => {
          this.vm.controller.snip();
        },
      });

      Column() {
        Column() {
          if (this.vm.img && this.vm.photoType) {
            PhotoContainer({
              controller: this.vm.controller,
              dressUrl: this.vm.dressList[this.vm.dressIndex].dress,
              photoUrl: this.vm.img,
              ratio: this.vm.photoType.size.height / this.vm.photoType.size.width,
              backColor: this.vm.colorList[this.vm.colorIndex].color,
              onSnapshot: (pixmap: image.PixelMap) => {
                this.vm.toSavePhoto(pixmap);
              },
            });
          }

        }.layoutWeight(1).padding({ right: 16, top: this.vm.isFitDesign ? 70 : 0 })
        .justifyContent(this.vm.isFitDesign ? FlexAlign.Start : FlexAlign.Center)
        .onSizeChange((oldSize, newSize: SizeOptions) => {
          const height = newSize.height as number;
          if (height < DESIGN_MIN_HEIGHT) {
            this.vm.isFitDesign = false;
          } else {
            this.vm.isFitDesign = true;
          }
        });


        Column({ space: 16 }) {
          if (this.vm.settingIndex === 0) {
            Row() {
              ForEach(this.vm.colorList, (item: ColorItem, index: number) => {
                Column({ space: 4 }) {
                  Stack() {
                    Image(item.icon);
                    if (this.vm.colorIndex === index) {
                      Row() {
                        Image($r('app.media.ic_color_check')).width(24);
                      }
                      .width('100%')
                      .height('100%')
                      .justifyContent(FlexAlign.Center)
                      .backgroundColor('rgba(0,0,0,0.4)');
                    }
                  }.width(40).height(40).borderRadius(8).clip(true);

                  Text(item.label)
                    .fontSize($r('sys.float.Caption_L'))
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_primary'));
                }.constraintSize({ minWidth: 65.5 }).onClick(() => {
                  this.vm.colorIndex = index;
                });
              }, (item: ColorItem, index: number) => item.label);
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 8, right: 16 });
          }

          if (this.vm.settingIndex === 1) {
            List({ space: 12 }) {
              ForEach(this.vm.dressList, (item: DressItem, index) => {
                ListItem() {
                  Stack() {
                    Image(item.icon).width('100%').height('100%');
                    if (this.vm.dressIndex === index) {
                      Column() {
                        Image($r('app.media.ic_color_check')).width(24);
                      }
                      .width('100%')
                      .height('100%')
                      .padding({ top: 13 })
                      .backgroundColor('rgba(0,0,0,0.4)');
                    }

                  }.width(68).height(68).borderRadius(8).clip(true);
                }.onClick(() => {
                  this.vm.dressIndex = index;
                });

              }, (item: DressItem, index) => item.id);

            }
            .listDirection(Axis.Horizontal)
            .height(68)
            .width('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            .scrollBar(BarState.Off);
          }


          Grid() {
            ForEach(this.vm.settingList, (item: SettingItem, index: number) => {
              GridItem() {
                Column({ space: 8 }) {
                  Image(this.vm.settingIndex === index ? item.checked : item.icon).width(48).height(48);
                  Text(item.text)
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.vm.settingIndex === index ? $r('sys.color.font_on_primary') :
                      $r('sys.color.font_primary'));
                };
              }.padding(12).borderRadius(16)
              .backgroundColor(this.vm.settingIndex === index ? $r('sys.color.comp_background_emphasize') :
                $r('sys.color.comp_background_primary'))
              .onClick(() => {
                this.vm.navTitle = item.text;
                this.vm.settingIndex = index;
              });
            }, (item: SettingItem, index) => item.text);
          }.columnsTemplate('1fr 1fr')
          .height(101)
          .columnsGap(12)
          .margin({ right: 16 });

        }.padding({ top: 8, bottom: 8 }).height(201).justifyContent(FlexAlign.End);

      }.layoutWeight(1).width('100%').padding({ left: 16 });

    }.hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      if (this.vm.colorIndex === 0 && this.vm.dressIndex === 0) {
        return false;
      } else {
        this.openDialog();
        return true;
      }
    });
  }
}

@Extend(Text)
function tipsExtend() {
  .lineHeight(21)
  .fontSize($r('sys.float.Body_L'))
  .fontWeight(FontWeight.Medium)
  .fontColor($r('sys.color.font_primary'));
}
