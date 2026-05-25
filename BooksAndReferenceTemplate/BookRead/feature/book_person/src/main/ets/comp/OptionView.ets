import { Constants, FontModel, TCRouter } from 'common'
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct OptionView {
  @Param text:string=''
  @Param url?:string=''
  @Param additionalText?:string=''
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
      Row(){
        Text(this.text)
          .fontSize(this.fontModel.getFg(16))
          .height(21)
          .width(100)
        Image($r('app.media.ic_arrow_right'))
          .width(7)
          .height(14)
          .objectFit(ImageFit.Contain)
      }

      .width(Constants.FULL_SIZE)
      .height(61)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left:18,
        top:20,
        bottom:20,
        right:18
      })
      .onClick(() => {
        if(this.url){
          TCRouter.push(this.url);
        }
      })
  }
}
