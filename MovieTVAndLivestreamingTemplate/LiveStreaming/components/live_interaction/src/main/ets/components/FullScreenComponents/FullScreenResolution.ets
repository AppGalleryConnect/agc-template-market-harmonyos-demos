import { ResolutionStorage } from '../Settings'

@ComponentV2
export struct FullScreenResolution {

  @Param @Require defaultResolution: string
  private resolution: string[] = ['1080P 原画（高帧率）', '1080P 蓝光', '720P超清', '480P高清']
  @Local nowResolution: string = '1080P 原画（高帧率）'
  @Local resolutionStorage: ResolutionStorage = ResolutionStorage.instance()
  @Event onChangeResolution: Function = () => {
  }
  @Event setHide: () => void
  @Event closeAll: () => void

  aboutToAppear(): void {
    if(this.resolutionStorage.defaultSetting !== this.defaultResolution) {
      this.resolutionStorage.defaultSetting = this.defaultResolution
      this.resolutionStorage.nowSetting = this.defaultResolution
      this.nowResolution = this.defaultResolution
    } else {
      this.nowResolution = this.resolutionStorage.nowSetting
    }
  }


  build() {
    Row() {
      Column()
        .height('100%')
        .layoutWeight(1)
        .onClick(() => {
          this.closeAll()
        })
      Column() {
        Row() {
          Image($r('app.media.back'))
            .width(40)
            .height(40)
            .borderRadius(20)
            .margin({ left: 24 })
            .onClick(() => {
              this.setHide()
            })
          Text('清晰度')
            .height(27)
            .fontSize(20)
            .fontWeight(700)
            .fontColor('#fff')
            .margin({ left: 8 })
        }
        .width('100%')
        .height(56)
        .margin({ top: 22 })

        Column() {
          ForEach(
            this.resolution,
            (item: string) => {
              Row() {
                Text(item)
                  .fontSize(16)
                  .fontWeight(500)
                  .fontColor(this.nowResolution === item ? '#EE5D1A' : '#fff')
              }
              .width(304)
              .height(48)
              .onClick(() => {
                this.nowResolution = item
                this.resolutionStorage.nowSetting = item
                this.onChangeResolution(item)
              })
              .margin({ top: 16 })

              Divider()
                .strokeWidth('1px')
                .color($r('sys.color.comp_divider'))
            },
            (item: string) => item
          )
        }
      }
      .width(368)
      .height('100%')
      .backgroundColor($r('app.color.normal_font_color'))
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    }
    .width('100%')
    .height('100%')
  }
}