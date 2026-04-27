import { Constants } from '../common/Constants';
import { FormItemModel } from '../common/Types';

const storageWidget = new LocalStorage();

@Entry(storageWidget)
@Component
struct WidgetCard {
  @LocalStorageProp('data') @Watch('onDataUpdated') data: string = '[]';
  @LocalStorageProp('imgName') imgName: string = '';
  @State list: FormItemModel = new FormItemModel();
  readonly actionType: string = 'router';
  readonly abilityName: string = 'EntryAbility';

  onDataUpdated() {
    try {
      this.list = JSON.parse(this.data) as FormItemModel;
    } catch (e) {
      this.list = new FormItemModel();
    }
  }

  build() {
    Column() {
      Column({ space: Constants.SPACE_M }) {
        Column() {
          Stack({ alignContent: Alignment.End }) {
            Image('memory://' + this.imgName).objectFit(ImageFit.Cover).width(Constants.FULL_PERCENT)
              .height(Constants.FULL_PERCENT)
            Column() {
              Image($r('app.media.form_icon')).width(20).height(20)
                .margin({ top: 8 })
              Row() {
                Text(this.list.isFollow ? '已订阅' : '为您推荐')
                  .fontSize(10)
                  .fontColor($r('sys.color.font_on_primary'))
                  .fontWeight(FontWeight.Medium)
              }
              .padding(6)
              .borderRadius(6)
              .margin({ right: 8, bottom: 8 })
              .backgroundColor($r('sys.color.mask_tertiary'))
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .height(Constants.FULL_PERCENT)
          }
          .width('100%').height('60%')

          Column({ space: 6 }) {
            Text(this.list.title)
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text('更新至20260312期')
              .fontSize(10)
              .fontColor($r('sys.color.font_secondary'))
          }
          .width(Constants.FULL_PERCENT)
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 8 })
          .padding({ left: 8, top: 6 })
        }
      }
      .width(Constants.FULL_PERCENT)
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .onClick(() => {
      // 拉起应用
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
        params: {
          source: Constants.SOURCE,
          avId: this.list.id,
        },
      });
    })
  }
}