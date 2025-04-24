import { TouristInfo } from 'types';

@Extend(Text)
function touristKeyText() {
  .fontSize(14).opacity(0.4);
}

@Extend(Text)
function touristValueText() {
  .fontSize(14).opacity(0.9);
}

@Extend(Image)
function operationImage() {
  .size({ width: 24, height: 24 }).opacity(0.2);
}

@ComponentV2
export struct TouristCardComponent {
  @Param @Require isInReserve: boolean = false;
  @Param @Require tourist: TouristInfo;
  @Event editTourist: () => void;
  @Event deleteTourist: () => void;
  @Event updateCheckStatus: (value: boolean) => void;

  build() {
    Row() {
      Row({ space: 12 }) {
        if (this.isInReserve) {
          Checkbox()
            .select($$this.tourist.isChecked)
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .onChange((value: boolean) => {
              // 更新勾选状态
              this.updateCheckStatus(value);
            });
        }

        Column({ space: 2 }) {
          Text(this.tourist.name).fontWeight(500).opacity(0.9);
          Row({ space: 8 }) {
            Text('证件号').touristKeyText();
            Text(this.tourist.cardNo).touristValueText();
          };

          Row({ space: 8 }) {
            Text('手机号').touristKeyText();
            Text(this.tourist.phone).touristValueText();
          };
        }.alignItems(HorizontalAlign.Start);
      };

      Row({ space: 24 }) {
        Image($r('app.media.edit')).operationImage().onClick(() => {
          this.editTourist();
        });

        if (!this.isInReserve) {
          Image($r('app.media.delete')).operationImage().onClick(() => {
            this.deleteTourist();
          });
        }
      };
    }
    .padding(16)
    .width('100%')
    .borderRadius(8)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White);
  }
}