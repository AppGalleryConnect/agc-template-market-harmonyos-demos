import { getDaysDiff } from 'base_apis'

@ComponentV2
export struct DistanceToday {
  @Param endDate: Date = new Date()

  build() {
    Row() {
      if (getDaysDiff(new Date(), new Date(this.endDate)) < 0) {
        Text('已过期')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
      } else {
        Text(getDaysDiff(new Date(), new Date(this.endDate)) ?
          Math.abs(getDaysDiff(new Date(), new Date(this.endDate))).toString() :
          '今天')
          .fontColor('#C4272B')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Text('天')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .visibility(getDaysDiff(new Date(), new Date(this.endDate)) ? Visibility.Visible :
            Visibility.None)
      }

    }
  }
}