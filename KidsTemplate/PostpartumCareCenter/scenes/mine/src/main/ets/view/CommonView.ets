@Builder
export  function noRecordView(){
  Column() {
    Image($r('app.media.ic_no_records'))
      .width(120)
      .height(120)
      .margin({ top: 97 });
    Text('暂无预约记录')
      .fontSize($r('app.string.font_size_14'))
      .fontColor('rgba(0,0,0,0.40)')
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Regular)
      .textAlign(TextAlign.Center)
      .margin({ top: $r('app.string.margin_3') });
  }
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Center);
}

@Builder
export  function cancelledImage(size: string){
  Image($r('app.media.booking_canceled'))
    .width(size === 'big' ? '58%': '13%')
    .height(size === 'big' ? '28%': '8%')
    .objectFit(ImageFit.Cover)
}