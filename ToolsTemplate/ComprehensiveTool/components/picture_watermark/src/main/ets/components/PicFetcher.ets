import { StyleConstants } from '../constants/Styles';
import { WaterMarksVM } from '../viewmodel/WaterMarksVM';

@ComponentV2
export struct PicFetcher {
  vm: WaterMarksVM = WaterMarksVM.instance;

  build() {
    Column({ space: 16 }) {
      Text('图片上传')
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)

      Column() {
        Image($r('app.media.ic_upload'))
          .fillColor($r('sys.color.font_primary'))
          .width(StyleConstants.IMAGE_24)
          .aspectRatio(1)

        Text('点击或拖拽上传图片')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .margin({ top: StyleConstants.SPACE_16, bottom: StyleConstants.SPACE_8 })

        Text('支持JPG、PNG、WEBP等格式图片文件')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Caption_L'))
          .fontWeight(FontWeight.Regular)
      }
      .border({
        radius: StyleConstants.RADIUS_12,
        width: 1,
        style: BorderStyle.Dashed,
        color: $r('sys.color.comp_divider'),
      })
      .width(StyleConstants.FULL_PERCENT)
      .padding({ top: StyleConstants.SPACE_24, bottom: StyleConstants.SPACE_24 })
      .backgroundColor($r('sys.color.comp_background_gray'))
      .onDrop((event) => {
        this.vm.dragPic(event);
      })
    }
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.vm.choosePic();
    })
  }
}