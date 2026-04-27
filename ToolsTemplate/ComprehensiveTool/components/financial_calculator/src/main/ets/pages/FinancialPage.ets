import { setPathStack } from '../common/CommonRoute';
import { DepositType } from '../common/Constant';
import { CapsuleTab } from '../components/CapsuleTab'
import { FinancialRes } from '../components/FinancialRes';
import { InputRow, titleBuilder } from '../components/InputRow';
import { TitleBar } from '../components/TitleBar';
import { calculateCompoundInterest, calculateCurrentDepositInterest, calculateFixedInvestmentProfit } from '../utils/Index';
import { FinancialPageVM } from '../viewmodel/FinancialPageVM';

@ComponentV2
export struct FinancialPage {
  vm: FinancialPageVM = FinancialPageVM.instance
  private swiperController: SwiperController = new SwiperController();

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      TitleBar({
        name: `理财计算`,
        onClear: () => {
          this.vm.clear()
        },
      })
      Column() {
        // 顶部胶囊tab
        CapsuleTab({
          index: this.vm.currentIndex,
          onChange: (index) => {
            this.vm.currentIndex = index
            this.swiperController.changeIndex(index, true)
          },
        })
        Swiper(this.swiperController) {
          this.bankBuilder()
          this.compoundRateBuilder()
          this.regularInvestmentBuilder()
        }
        .width('100%')
        .height('100%')
        .margin({ top: 20 })
        .indicator(false)
        .onChange((index: number) => {
          this.vm.currentIndex = index
        })
      }
      .padding({ left: 16, right: 16 })
      .height('calc(100% - 56vp)')
    }
    .backgroundColor(Color.White)
    .hideTitleBar(true)
    .onReady((ctx) => {
      setPathStack(ctx.pathStack);
    });
  }

  @Builder
  bankBuilder() {
    Scroll() {
      Column() {
        Row() {
          titleBuilder('存款类型')
          Select([{ value: '活期' }, { value: '定期' }])
            .value(this.vm.type)
            .layoutWeight(1)
            .optionWidth(224)
            .borderRadius($r('sys.float.corner_radius_level4'))
            .backgroundColor('#F1F3F5')
            .onSelect((index, text) => {
              this.vm.type = text
              if (this.vm.type === '活期') {
                this.vm.bank.type = DepositType.CURRENT
              } else {
                this.vm.bank.type = DepositType.REGULAR
              }
            })
        }
        .width('100%')
        .height(40)
        .margin({ bottom: 16 })

        InputRow({
          title: '存款金额',
          text: this.vm.bank.money,
          placeholder: '请输入存款金额',
          func: (value: string) => {
            this.vm.bank.money = value
            this.vm.checkBank()
          },
        })
        InputRow({
          title: '存款年限',
          text: this.vm.bank.time,
          placeholder: '请输入存款年限',
          type: '年',
          func: (value: string) => {
            this.vm.bank.time = value
            this.vm.checkBank()
          },
        })
        InputRow({
          title: '年利率',
          text: this.vm.bank.rate,
          placeholder: '请输入年利率',
          type: '%',
          func: (value: string) => {
            this.vm.bank.rate = value
            this.vm.checkBank()
          },
        })

        promptMessage()

        Button('计算银行理财')
          .width('100%')
          .backgroundColor(this.vm.bank.isShowButton ? '#0A59F7' : 'rgba(0, 0, 0, 0.05)')
          .fontColor(this.vm.bank.isShowButton ? '#FFFFFF' : 'rgba(0, 0, 0, 0.4)')
          .margin({ bottom: 16 })
          .onClick(() => {
            if (!this.vm.bank.isShowButton) {
              return
            }
            const res = calculateCurrentDepositInterest(Number(this.vm.bank.money), Number(this.vm.bank.time),
              Number(this.vm.bank.rate) * 0.01)
            this.vm.bank.isShowRes = true
            this.vm.bank.totalRevenue = res.totalRevenue
            this.vm.bank.rateRevenue = res.rateRevenue
            this.vm.bank.monthlyRevenue = res.monthlyRevenue
            this.vm.closeKeyboard()
          })

        if (this.vm.bank.isShowRes) {
          FinancialRes({ title: '银行理财', investmentIncome: this.vm.bank })
        }
      }
      .margin({ bottom: 40 })
    }
    .layoutWeight(1)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  compoundRateBuilder() {
    Scroll() {
      Column() {
        InputRow({
          title: '存款金额',
          titleWidth: 80,
          text: this.vm.compoundRate.money,
          placeholder: '请输入存款金额',
          func: (value: string) => {
            this.vm.compoundRate.money = value
            this.vm.checkCompoundRate()
          },
        })
        InputRow({
          title: '存款年限',
          titleWidth: 80,
          text: this.vm.compoundRate.time,
          placeholder: '请输入存款年限',
          type: '年',
          func: (value: string) => {
            this.vm.compoundRate.time = value
            this.vm.checkCompoundRate()
          },
        })
        InputRow({
          title: '年利率',
          titleWidth: 80,
          text: this.vm.compoundRate.rate,
          placeholder: '请输入年利率',
          type: '%',
          func: (value: string) => {
            this.vm.compoundRate.rate = value
            this.vm.checkCompoundRate()
          },
        })
        InputRow({
          title: '年复利次数',
          titleWidth: 80,
          text: this.vm.compoundRate.compoundRateCount,
          placeholder: '请输入年复利次数',
          type: '次/年',
          func: (value: string) => {
            this.vm.compoundRate.compoundRateCount = value
            this.vm.checkCompoundRate()
          },
        })

        promptMessage()

        Button('计算复利理财')
          .width('100%')
          .backgroundColor(this.vm.compoundRate.isShowButton ? '#0A59F7' : 'rgba(0, 0, 0, 0.05)')
          .fontColor(this.vm.compoundRate.isShowButton ? '#FFFFFF' : 'rgba(0, 0, 0, 0.4)')
          .margin({ bottom: 16 })
          .onClick(() => {
            if (!this.vm.compoundRate.isShowButton) {
              return
            }
            const res = calculateCompoundInterest(Number(this.vm.compoundRate.money), Number(this.vm.compoundRate.time),
              Number(this.vm.compoundRate.rate) * 0.01, Number(this.vm.compoundRate.compoundRateCount))
            this.vm.compoundRate.isShowRes = true
            this.vm.compoundRate.totalRevenue = res.totalRevenue
            this.vm.compoundRate.rateRevenue = res.rateRevenue
            this.vm.compoundRate.monthlyRevenue = res.monthlyRevenue
            this.vm.closeKeyboard()
          })

        if (this.vm.compoundRate.isShowRes) {
          FinancialRes({ title: '复利理财', investmentIncome: this.vm.compoundRate })
        }
      }
      .margin({ bottom: 40 })
    }
    .layoutWeight(1)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  regularInvestmentBuilder() {
    Scroll() {
      Column() {
        InputRow({
          title: '每月定投',
          titleWidth: 80,
          text: this.vm.regularInvestment.monthlyMoney,
          placeholder: '请输入每月定投金额',
          func: (value: string) => {
            this.vm.regularInvestment.monthlyMoney = value
            this.vm.checkRegularInvestment()
          },
        })
        InputRow({
          title: '定投年限',
          titleWidth: 80,
          text: this.vm.regularInvestment.time,
          placeholder: '请输入定投年限',
          type: '年',
          func: (value: string) => {
            this.vm.regularInvestment.time = value
            this.vm.checkRegularInvestment()
          },
        })
        InputRow({
          title: '年化收益率',
          titleWidth: 80,
          text: this.vm.regularInvestment.rate,
          placeholder: '请输入年化收益率',
          type: '%',
          func: (value: string) => {
            this.vm.regularInvestment.rate = value
            this.vm.checkRegularInvestment()
          },
        })

        promptMessage()

        Button('计算定投理财')
          .width('100%')
          .backgroundColor(this.vm.regularInvestment.isShowButton ? '#0A59F7' : 'rgba(0, 0, 0, 0.05)')
          .fontColor(this.vm.regularInvestment.isShowButton ? '#FFFFFF' : 'rgba(0, 0, 0, 0.4)')
          .margin({ bottom: 16 })
          .onClick(() => {
            if (!this.vm.regularInvestment.isShowButton) {
              return
            }
            const res = calculateFixedInvestmentProfit(Number(this.vm.regularInvestment.monthlyMoney),
              Number(this.vm.regularInvestment.time),
              Number(this.vm.regularInvestment.rate) * 0.01)
            this.vm.regularInvestment.isShowRes = true
            this.vm.regularInvestment.money =
              Number(this.vm.regularInvestment.time) * Number(this.vm.regularInvestment.monthlyMoney) * 12 + ''
            this.vm.regularInvestment.totalRevenue = res.totalRevenue
            this.vm.regularInvestment.rateRevenue = res.rateRevenue
            this.vm.regularInvestment.monthlyRevenue = res.monthlyRevenue
            this.vm.closeKeyboard()
          })

        if (this.vm.regularInvestment.isShowRes) {
          FinancialRes({ title: '定投理财', investmentIncome: this.vm.regularInvestment })
        }
      }
      .margin({ bottom: 40 })
    }
    .layoutWeight(1)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  inputRowBuilder(title: string, text: string, placeholder: string, type: string, width: number, func: Function) {
    Row() {
      titleBuilder(title, width)
      TextInput({ text: text, placeholder: placeholder })
        .layoutWeight(1)
        .backgroundColor('#F1F3F5')
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .margin({ right: 12 })
        .type(InputType.NUMBER_DECIMAL)
        .enabled(title === '合计本金' ? false : true)
        .onChange((value) => {
          func(value)
        })
      Text(type)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
    }
    .width('100%')
    .height(40)
    .margin({ bottom: 16 })
  }
}

@Builder
function promptMessage() {
  Row() {
    Text('请输入准确的数值以获得精确的计算结果')
      .fontSize($r('sys.float.Caption_L'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_tertiary'))
      .margin({ bottom: 24 })
  }
  .width('100%')
}

@Builder
export function FinancialPageBuilder() {
  FinancialPage()
}