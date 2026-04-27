import { setPathStack } from '../common/CommonRoute';
import { InputRow } from '../components/InputRow';
import { PensionRes } from '../components/PensionRes';
import { TitleBar } from '../components/TitleBar'
import { calculatePension } from '../utils/Index';
import { PensionPageVM } from '../viewmodel/PensionPageVM';

@ComponentV2
export struct PensionPage {
  vm: PensionPageVM = PensionPageVM.instance
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.vm.clear()
  }

  build() {
    NavDestination() {
      TitleBar({
        name: '养老金计算',
        onClear: () => {
          this.vm.clear()
          this.vm.check()
        },
      })

      Column() {
        Scroll(this.scroller) {
          Column() {
            Row() {
              subTitleBuilder('基础信息')
            }
            .width('100%')
            .margin({ top: 16 })

            InputRow({
              title: '当前年龄',
              text: this.vm.pensionInfo.currentAge,
              placeholder: '请输入当前年龄',
              type: '岁',
              func: (value: string) => {
                this.vm.pensionInfo.currentAge = value
                this.vm.check()
              },
            })
            InputRow({
              title: '计划退休年龄',
              text: this.vm.pensionInfo.plannedRetirementAge,
              placeholder: '请输入计划退休年龄',
              type: '岁',
              func: (value: string) => {
                this.vm.pensionInfo.plannedRetirementAge = value
                this.vm.check()
              },
            })
            InputRow({
              title: '已缴费年限',
              text: this.vm.pensionInfo.costYear,
              placeholder: '请输入已缴费年限',
              type: '年',
              func: (value: string) => {
                this.vm.pensionInfo.costYear = value
                this.vm.check()
              },
            })

            subTitleBuilder('缴费信息')
            InputRow({
              title: '月缴费工资',
              text: this.vm.pensionInfo.monthlyContributionWage,
              placeholder: '请输入月缴费工资',
              type: '元',
              func: (value: string) => {
                this.vm.pensionInfo.monthlyContributionWage = value
                this.vm.check()
              },
            })
            InputRow({
              title: '当地上半年在岗职工月平均工资',
              text: this.vm.pensionInfo.averageLocalWage,
              placeholder: '请输入当地上半年在岗职工月平均工资',
              type: '元',
              func: (value: string) => {
                this.vm.pensionInfo.averageLocalWage = value
                this.vm.check()
              },
            })

            subTitleBuilder('缴费比例')
            InputRow({
              title: '个人缴费比例',
              text: this.vm.pensionInfo.employeePercentage,
              placeholder: '请输入个人缴费比例',
              func: (value: string) => {
                this.vm.pensionInfo.employeePercentage = value
                this.vm.check()
              },
            })
            InputRow({
              title: '单位缴费比例',
              text: this.vm.pensionInfo.unitPercentage,
              placeholder: '请输入单位缴费比例',
              func: (value: string) => {
                this.vm.pensionInfo.unitPercentage = value
                this.vm.check()
              },
            })
            InputRow({
              title: '预期年均工资增长率',
              text: this.vm.pensionInfo.wageGrowthRate,
              placeholder: '请输入预期年均工资增长率',
              func: (value: string) => {
                this.vm.pensionInfo.wageGrowthRate = value
                this.vm.check()
              },
            })

            Button('计算养老金')
              .id('pensionButton')
              .width('100%')
              .backgroundColor(this.vm.pensionInfo.showButton ? '#0A59F7' : 'rgba(0, 0, 0, 0.05)')
              .fontColor(this.vm.pensionInfo.showButton ? '#FFFFFF' : 'rgba(0, 0, 0, 0.4)')
              .margin({ bottom: 16 })
              .onClick(() => {
                if (!this.vm.pensionInfo.showButton || !this.vm.checkCompliance()) {
                  return
                }
                const res = calculatePension(this.vm.pensionInfo)
                this.vm.pensionCalcRes.showRes = true
                this.vm.pensionCalcRes.estimatedPaymentYears = res.totalPaymentYears.toString()
                this.vm.pensionCalcRes.personalAccount = res.personalAccountBalance.toString()
                this.vm.pensionCalcRes.basicPension = res.basicPension.toString()
                this.vm.pensionCalcRes.personalAccountPension = res.personalAccountPension.toString()
                this.vm.pensionCalcRes.estimatedPayment = res.monthlyBenefit.toString()
                this.vm.closeKeyboard()
                const instance = this.vm.getBarInfo(this.getUIContext()) - 20
                this.scroller.scrollTo({ xOffset: 0, yOffset: instance, animation: true })
              })
            if (this.vm.pensionCalcRes.showRes) {
              PensionRes({ pensionCalcRes: this.vm.pensionCalcRes })
            }
          }
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .padding({ left: 16, right: 16 })
      .height('calc(100% - 56vp)')
    }
    .backgroundColor(Color.White)
    .hideTitleBar(true)
    .onReady((ctx) => {
      setPathStack(ctx.pathStack);
    })
  }
}

@Builder
function subTitleBuilder(title: string) {
  Row() {
    Text(title)
      .fontSize($r('sys.float.Subtitle_L'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
  }
  .width('100%')
  .margin({ top: 8, bottom: 12 })
}

@Builder
export function PensionPageBuilder() {
  PensionPage()
}