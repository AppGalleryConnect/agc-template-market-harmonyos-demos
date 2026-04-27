@ComponentV2
export struct NoMusicData{
  build() {
    Column(){
      Image($r('app.media.ic_no_data')).width(100).height(83)
        .margin({bottom:32})
      Text('暂无作品').fontSize(15).fontColor('#99FFFFFF')
    }.width('100%').height('100%')
    .justifyContent(FlexAlign.Center)
  }
}