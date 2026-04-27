import { CompressedFile } from '../model/ZipModel'

@ComponentV2
export struct MoveBuilder {
  @Param folderList: CompressedFile[] = []
  @Param directory: string[] = []
  @Param directoryStructure: string = ''
  @Event onCancel: () => void = () => {
  }
  @Event onConfirm: () => void = () => {
  }
  @Event toDirectory: (name: string) => void = () => {
  }
  @Event goBack: () => void = () => {
  }

  build() {
    Column() {
      Text('选择目录')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })
      Row() {
        Image($r('app.media.file'))
          .width(43)
          .height(35)
          .margin({ right: 12 })
        Text(this.directoryStructure)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .padding({
        top: 8,
        bottom: 8,
        left: 12,
        right: 12,
      })
      .margin({ bottom: 12 })
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        if (this.directory.length > 0) {
          this.goBack()
        }
      })

      List() {
        ForEach(this.folderList, (data: CompressedFile, index: number) => {
          ListItem() {
            Row() {
              Image($r('app.media.file'))
                .width(43)
                .height(35)
                .margin({ right: 12 })

              Column({ space: 2 }) {
                Text(data.name)
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)

                Text(`Last edited:${data.updatedTime}`)
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor($r('sys.color.font_secondary'))
                  .fontWeight(FontWeight.Regular)
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .onClick(() => {
              this.toDirectory(data.name)
            })
          }
          .padding({
            left: 12,
            right: 12,
          })
          .margin({ bottom: 12 })
        }, (item: CompressedFile) => JSON.stringify(item))
      }
      .height(200)
      .scrollBar(BarState.Off)

      Row() {
        Row() {
          Text('取消')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .width(120)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 16 })
        .onClick(() => {
          this.onCancel()
        })

        Row() {
          Text('确定')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
            .fontWeight(FontWeight.Medium)
        }
        .width(120)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.onConfirm()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
  }
}