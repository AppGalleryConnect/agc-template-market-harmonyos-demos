import { RouterModule } from '@agctemplate/router_module';

@ComponentV2
export struct Header {
  @Param title: string = ''
  @Param rightImageRes: Resource | undefined = undefined
  @Param fontWightParam: FontWeight | number = 700
  @Event rightOnClick: () => void = () => {
  }

  build() {
    Row() {
      Image($r('app.media.arrow_back'))
        .width(40)
        .aspectRatio(1)
        .margin({ left: 16, right: '8vp' })
        .onClick(() => {
          RouterModule.pop()
        })
      Text(this.title).size({ width: 136, height: 27 })
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(this.fontWightParam)
        .fontColor($r('sys.color.font_primary'))
      Blank()
      if (this.rightImageRes) {
        Image(this.rightImageRes).size({ width: 40, height: 40 })
          .margin({ right: 16 })
          .onClick(this.rightOnClick)
      }
    }
    .height(40)
    .width('100%')

    .margin({ top: 8, bottom: 8 })
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}