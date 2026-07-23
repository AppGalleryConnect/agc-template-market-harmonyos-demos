import { SignIn, SignInClass } from '../model/DaySignInModel'
import { DaySignInViewModel } from '../viewmodel/DaySignInViewModel'
import { TYCard } from '../common/TYCard'
import { FontModel } from '../model/FontModel'
import { AppStorageV2 } from '@kit.ArkUI'
import { fp2pxUtil } from '../model/FontUtils'

@ComponentV2
export struct DaySignIn {
  @Provider('balance') balance: number = 0
  @Provider('rightCount') rightCount: number = 0
  @Param title: ResourceStr = $r('app.string.daily_check_in_reward')
  @Event onSignSuccess: (day: number, balance: number) => void
  @Param coinArray: number[] = [35, 40, 45, 50, 55, 60, 65]
  @Local signInList: SignInClass[] = [
    new SignInClass(35),
    new SignInClass(40),
    new SignInClass(45),
    new SignInClass(50),
    new SignInClass(55),
    new SignInClass(60),
    new SignInClass(65)]
  @Local currentDay: number = 0
  viewModel: DaySignInViewModel = new DaySignInViewModel(this.coinArray)
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Param isLogin: boolean = true
  @Event loginFunc: () => void = () => {
  }

  async aboutToAppear() {
    await this.viewModel.initPreferences()
    this.signInList = await this.viewModel.getSignInInfo()
    this.rightCount = this.viewModel.getRightCount(this.signInList)
    this.currentDay = await this.viewModel.getCurrentDay()
  }

  aboutToDisappear(): void {
    this.viewModel.saveSignInList(this.signInList)
  }

  build() {
    TYCard({
      liftTitle: this.title,
      totalday: this.viewModel.signInList.length
    }) {
      Column() {
        GridRow({ columns: 7 }) {
          ForEach(this.signInList, (item: SignIn, index: number) => {
            GridCol() {
              Column() {
                Column() {
                  Text(item.coinNumber + '')
                    .fontSize(fp2pxUtil(12))
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_on_primary'))
                    .height(16)
                    .margin({
                      top: 22,
                      left: 10,
                      right: 9,
                      bottom: 2
                    })
                }
                .width(34)
                .height(40)
                .backgroundImage(item.isClaim ? $r('app.media.award_red_envelope_1') :
                  $r('app.media.award_red_envelope'))
                .backgroundImageSize(ImageSize.FILL)
                .opacity(item.isClaim ? 0.5 : 1)

                Text(`第${index + 1}天`)
                  .fontWeight(FontWeight.Regular)
                  .fontSize(this.fontModel.getFg(10))
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ top: 8, bottom: 12 })
              }
            }
          }, (item: SignIn) => {
            return item.coinNumber.toString() + item.isClaim
          })
        }

        Column() {
          Button(this.signInList[this.currentDay].isClaim ? $r('app.string.checked_in') :
            $r('app.string.check_in'))
            .fontSize(fp2pxUtil(16))
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.signInList[this.currentDay].isClaim ? '#D5633E' : '#EC6E45')
            .enabled(!this.signInList[this.currentDay].isClaim)
            .height(40)
            .width('100%')
            .margin({ top: 8 })
            .onClick(() => {
              if (this.isLogin) {
                this.handleSignIn()
              } else {
                this.loginFunc()
              }
            })
        }
        .padding({ left: 12, right: 12 })
        .width('100%')
      }
      .margin({ top: 16 })
      .width('100%')
    }
  }

  handleSignIn() {
    this.balance = this.signInList[this.currentDay].coinNumber
    this.signInList[this.currentDay].isClaim = true
    this.rightCount = this.signInList.filter(item => item.isClaim === true).length
    this.signInList = [...this.signInList] // 强制数组引用变化来渲染ui,否则签到红包不会改变
    this.onSignSuccess(this.rightCount, this.balance)
  }
}