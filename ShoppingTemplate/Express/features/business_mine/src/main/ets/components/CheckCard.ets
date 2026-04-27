import { CheckIn, RouterModule } from 'lib_foundation'
import { RouterMap } from 'module_base'
import { VipPageVM } from '../viewModels/VipPageVM'

@ComponentV2
export struct CheckCard {
  vm: VipPageVM = VipPageVM.instance

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text('签到7天 赚积分')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))

        Text() {
          Span('已打卡')
          Span(this.vm.signInCount.toString())
            .fontColor('#EC6E45')
          Span('/7天')
        }
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
      }
      .margin({ bottom: 16 })

      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.vm.checkInList, (checkIn: CheckIn, index: number) => {
          Column() {
            Stack() {
              Image(checkIn.isChecked ? $r('app.media.ic_checked') : $r('app.media.ic_no_checked'))
                .width(34)
                .height(40)
                .opacity(checkIn.isChecked ? 0.4 : 1)
              Row() {
                Text(checkIn.value + '')
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor(Color.White)
                  .margin({ bottom: 2 })
              }
              .width(34)
              .height(40)
              .alignItems(VerticalAlign.Bottom)
              .justifyContent(FlexAlign.Center)
            }
            .margin({ bottom: 8 })

            Text(`第${index + 1}天`)
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
          }
        }, (item: CheckIn[]) => JSON.stringify(item))
      }
      .margin({ bottom: 16 })

      Row() {
        Button(this.vm.isSign ? '已签到' : '签到')
          .width('100%')
          .backgroundColor(this.vm.isSign ? 'rgba(153,153,153,0.4)' : '#0A59F7')
          .onClick(() => {
            if (!this.vm.userInfoModel.isLogin) {
              RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
              return
            }
            if (!this.vm.isSign) {
              this.vm.isSign = true
              this.vm.checkInList[this.vm.currentIndex].isChecked = true
              if (this.vm.userInfoModel.isVip) {
                this.vm.userInfoModel.points =
                  this.vm.userInfoModel.points + this.vm.checkInList[this.vm.currentIndex].value * 2
              } else {
                this.vm.userInfoModel.points =
                  this.vm.userInfoModel.points + this.vm.checkInList[this.vm.currentIndex].value
              }
              this.vm.signInCount = this.vm.signInCount + 1
            }
          })
      }
      .padding({ left: 12, right: 12 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({
      top: 19,
      bottom: 12,
      left: 12,
      right: 12,
    })
    .margin({ bottom: 12 })
  }
}