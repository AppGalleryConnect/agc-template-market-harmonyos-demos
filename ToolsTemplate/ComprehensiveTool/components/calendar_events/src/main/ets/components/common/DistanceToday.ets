import { getDaysDiff } from '../../utils/Utils'

@ComponentV2
export struct DistanceToday {
  @Param endDate: Date = new Date()

  build() {
    Row() {
      Text(getDaysDiff(new Date(), new Date(this.endDate)) ?
      Math.abs(getDaysDiff(new Date(), new Date(this.endDate))).toString() :
        '今天')
        .fontColor('#C4272B')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      Text(getDaysDiff(new Date(), new Date(this.endDate)) < 0 ? '天前' : '天')
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .visibility(getDaysDiff(new Date(), new Date(this.endDate)) ? Visibility.Visible :
        Visibility.None)
    }
  }
}