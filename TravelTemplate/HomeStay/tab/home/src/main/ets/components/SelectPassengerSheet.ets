import { Constants } from 'constant';
import { Passenger as PassengerType } from 'type';

@ComponentV2
export struct SelectPassengerSheet {
  @Param passengerList: PassengerType[] = [];
  @Param selectedPassengerIds: number[] = [];
  @Param isShowAddSheet: boolean = false;
  @Event onClose: () => void = () => {};
  @Event onTogglePassenger: (item: PassengerType) => void = () => {};
  @Event onConfirm: () => void = () => {};
  @Event onAddClick: () => void = () => {};
  @Event onEditClick: (item: PassengerType) => void = () => {};

  build() {
    Column() {
      Row() {
        Text('选择游客')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        Blank()
        Image($r('app.media.ic_right_close'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.onClose();
          })
      }
      .width(Constants.FULL_SCREEN)
      .padding({ top: 16, bottom: 8 })

      Row({ space: 8 }) {
        Image($r('app.media.add_guest'))
          .width(24)
          .height(24)
        Text('添加常用游客')
          .fontSize(16)
          .fontColor('#F0353A')
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Center)
      .width(Constants.FULL_SCREEN)
      .height(72)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .borderRadius(16)
      .padding({ top: 12, bottom: 12 })
      .onClick(() => {
        this.onAddClick();
      })

      List({ space: 12 }) {
        ForEach(this.passengerList, (item: PassengerType) => {
          ListItem() {
            Row({ space: 12 }) {
              Checkbox()
                .select(this.selectedPassengerIds.includes(item.passengerId))
                .shape(CheckBoxShape.CIRCLE)
                .onChange((checked: boolean) => {
                  this.onTogglePassenger(item);
                })

              Column({ space: 4 }) {
                Text(item.passengerName)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))

                Row({ space: 4 }) {
                  Text('证件号')
                    .fontSize(14)
                    .fontColor($r('sys.color.font_secondary'))
                  Text(item.passengerCardId)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                }

                Row({ space: 4 }) {
                  Text('手机号')
                    .fontSize(14)
                    .fontColor($r('sys.color.font_secondary'))
                  Text(item.passengerPhone)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Image($r('app.media.edit_guest'))
                .width(24)
                .height(24)
                .onClick(() => {
                  this.onEditClick(item);
                })
            }
            .width(Constants.FULL_SCREEN)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .padding(12)
            .borderRadius(16)
            .alignItems(VerticalAlign.Center)
          }
        }, (item: PassengerType) => item.passengerId.toString())
      }
      .width(Constants.FULL_SCREEN)
      .layoutWeight(1)
      .margin({ top: 12 })
      .scrollBar(BarState.Off)

      Button('确定')
        .borderRadius($r('sys.float.corner_radius_level11'))
        .height(44)
        .width(Constants.FULL_SCREEN)
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .fontColor($r('sys.color.font_on_primary'))
        .margin({ left: 16, right: 16, top: 12, bottom: 44 })
        .onClick(() => {
          this.onConfirm();
        })
    }
    .width(Constants.FULL_SCREEN)
    .padding({ left: 16, right: 16 })
    .borderRadius({
      topLeft: $r('sys.float.corner_radius_level8'),
      topRight: $r('sys.float.corner_radius_level8'),
    })
  }
}
