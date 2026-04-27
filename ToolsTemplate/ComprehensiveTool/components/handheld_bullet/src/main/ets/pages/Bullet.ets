import { SliderPickerDialog } from '../components/SliderPickerDialog';
import { Constant } from '../constant/Constant';
import { ColorOption } from '../model/Index';
import { BulletVM } from '../viewmodel/BulletVM';

@Extend(Row)
function bulletSettingRow() {
  .width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 8, bottom: 8 });
}

@Builder
export function BulletBuilder() {
  Bullet();
}

@ComponentV2
export struct Bullet {
  vm: BulletVM = BulletVM.instance;

  @Builder
  ColorPickerDialog(option: ColorOption) {
    Column() {
      Column() {
        Text('基础色板').fontWeight(FontWeight.Medium).width('100%').textAlign(TextAlign.Start);

        List() {
          ForEach(Constant.COLOR_ARR, (item: string, index: number) => {
            ListItem() {
              Column() {
                Column()
                  .width('100%')
                  .height(26)
                  .borderRadius(5)
                  .backgroundColor(Color.Transparent)
                  .position({ left: 0, bottom: 0 })
                  .border({
                    width: 3,
                    color: '#ffff',
                  })
                  .visibility(option.color === item ? Visibility.Visible : Visibility.None);
              }
              .backgroundColor(item)
              .width('100%')
              .height(24)
              .onClick(() => {
                option.color = item;
              });
            };
          }, (item: string) => JSON.stringify(item));
        }
        .lanes(13)
        .height(250)
        .width('100%');

        Row() {
          Circle().size({ width: 36, height: 36 }).fill(option.color);

          Row() {
            Text('Hex: # ');
            TextInput({ text: option.color }).size({ width: 96, height: 36 }).onChange((value) => {
              option.color = value;
            });
          };
        }.width('100%').justifyContent(FlexAlign.SpaceBetween);
      };

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontColor($r('sys.color.font_emphasize'))
          .onClick(() => {
            option.closeCallBack();
          });
        Button('确定').layoutWeight(1).onClick(() => {
          option.confirmCallBack();
          option.closeCallBack();
        });
      };
    }.padding(16).height('100%').justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  BulletContent() {
    Column({ space: 8 }) {
      Text('弹幕内容').fontSize(14).width('100%').textAlign(TextAlign.Start).fontColor($r('sys.color.font_secondary'));

      TextInput({ text: this.vm.bullet.content }).onChange((value) => {
        this.vm.bullet.content = value;
      });
    }.margin({ bottom: 20 });
  }

  @Builder
  BulletSetting() {
    Text('弹幕设置')
      .fontSize(14)
      .width('100%')
      .textAlign(TextAlign.Start)
      .fontColor($r('sys.color.font_secondary'))
      .margin({ bottom: 8 });

    Column({ space: 8 }) {
      Row() {
        Text('字体大小').fontWeight(FontWeight.Medium);

        Row({ space: 4 }) {
          Text(`${this.vm.bullet.fontSize}`).fontSize(14);

          Image($r('app.media.bullet_arrow_right')).size({ width: 12, height: 24 });
        }.onClick(() => {
          this.vm.cloneFontSizeOption = this.vm.cloneFontSizeOptions();
          this.vm.isShowFontSizePicker = true;
        })
        .bindSheet($$this.vm.isShowFontSizePicker, SliderPickerDialog(this.vm.cloneFontSizeOption), {
          title: { title: '字体大小' },
          preferType: SheetType.CENTER,
          height: 320,
        });
      }.bulletSettingRow();

      Row() {
        Text('字体颜色').fontWeight(FontWeight.Medium);

        Row({ space: 4 }) {
          Text(this.vm.bullet.textColor).fontSize(14);
          Circle().size({ width: 24, height: 24 }).stroke($r('sys.color.font_primary')).fill(this.vm.bullet.textColor);
        }.onClick(() => {
          this.vm.cloneFontColorOption = this.vm.cloneFontColorOptions();
          this.vm.isShowFontColorPicker = true;
        }).bindSheet($$this.vm.isShowFontColorPicker, this.ColorPickerDialog(this.vm.cloneFontColorOption), {
          title: { title: '字体颜色' },
          preferType: SheetType.CENTER,
          height: '90%',
        });
      }.bulletSettingRow();

      Row() {
        Text('背景颜色').fontWeight(FontWeight.Medium);

        Row({ space: 4 }) {
          Text(this.vm.bullet.bgColor).fontSize(14);
          Circle().size({ width: 24, height: 24 }).stroke($r('sys.color.font_primary')).fill(this.vm.bullet.bgColor);
        }.onClick(() => {
          this.vm.cloneBgColorOption = this.vm.cloneBgColorOptions();
          this.vm.isShowBgColorPicker = true;
        }).bindSheet($$this.vm.isShowBgColorPicker, this.ColorPickerDialog(this.vm.cloneBgColorOption), {
          title: { title: '背景颜色' },
          preferType: SheetType.CENTER,
          height: '90%',
        });
      }.bulletSettingRow();

      Row() {
        Text('是否滚动').fontWeight(FontWeight.Medium);

        Toggle({ type: ToggleType.Switch, isOn: this.vm.bullet.isSupportRoll })
          .onChange((isOn: boolean) => {
            this.vm.bullet.isSupportRoll = isOn;
          });
      }.bulletSettingRow();

      Row() {
        Text('滚动速度').fontWeight(FontWeight.Medium);

        Row({ space: 4 }) {
          Text(`${this.vm.bullet.speed}`).fontSize(14);

          Image($r('app.media.bullet_arrow_right')).size({ width: 12, height: 24 });
        }.onClick(() => {
          this.vm.cloneFlowSpeedOption = this.vm.cloneFlowSpeedOptions();
          this.vm.isShowFlowSpeedPicker = true;
        }).bindSheet($$this.vm.isShowFlowSpeedPicker, SliderPickerDialog(this.vm.cloneFlowSpeedOption), {
          title: { title: '滚动速度' },
          preferType: SheetType.CENTER,
          height: 320,
        });
      }.bulletSettingRow();
    }.borderRadius(16).padding(12).backgroundColor($r('sys.color.background_primary'));

    Row() {
      Text('历史弹幕').fontWeight(FontWeight.Medium);
      Image($r('app.media.bullet_chevron_right')).size({ height: 24, width: 12 });
    }
    .padding(12)
    .backgroundColor($r('sys.color.background_primary'))
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 20 })
    .borderRadius(16)
    .onClick(() => {
      this.vm.stack.pushPathByName('History', null);
    });
  }

  @Builder
  BulletOperation() {
    Column({ space: 12 }) {
      Button('显示弹幕').borderRadius(20).fontColor($r('sys.color.font_on_primary')).width('100%').onClick(() => {
        this.vm.displayBullet(this.getUIContext());
      });

      Text('提示：显示弹幕后，长按屏幕可以退出弹幕模式').fontSize(10);
    }.width('100%').alignItems(HorizontalAlign.Center).margin({ top: 48 });
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          this.BulletContent();
          this.BulletSetting();
        };

        this.BulletOperation();
      }
      .padding(16)
      .height('100%')
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP]);
    }.hideTitleBar(true);
  }
}