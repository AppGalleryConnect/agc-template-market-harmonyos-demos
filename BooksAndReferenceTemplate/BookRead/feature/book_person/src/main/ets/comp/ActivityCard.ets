import { Constants, FontModel, TCRouter } from 'common'
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct ActivityCard {
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  build() {
    Row() {
      Row(){
        Row(){
          Column({space: 2}){
            Text($r('app.string.welfare_center'))
              .height(21)
              .fontSize(this.fontModel.getFg(16))
              .fontWeight(FontWeight.Medium)
            Text($r('app.string.welfare_description'))
              .height(14)
              .fontSize(this.fontModel.getFg(10))
              .fontWeight(FontWeight.Regular)
          }
          .alignItems(HorizontalAlign.Start)
          Image($r('app.media.welfare_center'))
            .height(48)
            .width(48)
            .objectFit(ImageFit.Contain)
            .margin({left:15})
        }
        .onClick(() => {
          TCRouter.pushByLogin(Constants.WELFARE_CENTER);
        })
        Row(){
          Column({space: 2}){
            Text($r('app.string.activity_center'))
              .height(21)
              .fontSize(this.fontModel.getFg(16))
              .fontWeight(FontWeight.Medium)
            Text($r('app.string.activity_description'))
              .height(14)
              .fontSize(this.fontModel.getFg(10))
              .fontWeight(FontWeight.Regular)
          }
          .alignItems(HorizontalAlign.Start)
          Image($r('app.media.activity_center'))
            .height(48)
            .width(48)
            .objectFit(ImageFit.Contain)
            .margin({left:15})
        }
        .onClick(() => {
          TCRouter.push(Constants.ACTIVITY_ROUTE);
        })

      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left:8,
        right:8
      })
    }
    .width(Constants.FULL_SIZE)
    .height(72)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding({
      left:12,
      right:12,
      top:8,
      bottom:8
    })

  }
}
