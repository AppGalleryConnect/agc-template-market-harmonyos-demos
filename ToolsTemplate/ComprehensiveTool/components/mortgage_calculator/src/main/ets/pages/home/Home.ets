import { PersistenceV2 } from '@kit.ArkUI';
import { LoanType } from '../../types/Index';
import CommercialLoan from './components/CommercialLoan';
import ProvidentFundLoan from './components/ProvidentFundLoan';
import CombinationLoan from './components/CombinationLoan';
import { CalculationViewModel } from '../../viewmodel/CalculationViewModel';
import { setPathStack } from '../../common/Route';
import { TitleBar } from '../../components/TitleBar';

@ComponentV2
export struct Home {
  @Local currentIndex: LoanType = LoanType.Commercial;
  controller: TabsController = new TabsController();
  @Local vm: CalculationViewModel = PersistenceV2.connect(CalculationViewModel, () => new CalculationViewModel())!;

  @Builder
  TabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? $r('app.string.theme_color') : '#182431')
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 8, bottom: 8 });
      Divider()
        .strokeWidth(2)
        .color($r('app.string.theme_color'))
        .opacity(this.currentIndex === index ? 1 : 0)
        .width('50%');
    }.width('100%');
  }

  aboutToAppear() {
    this.vm.queryLPRList();
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({ title: '房贷计算器' });
        Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
          TabContent() {
            CommercialLoan();
          }.tabBar(this.TabBuilder(LoanType.Commercial, '商业贷款'));

          TabContent() {
            ProvidentFundLoan();
          }.tabBar(this.TabBuilder(LoanType.ProvidentFund, '公积金贷款'));

          TabContent() {
            CombinationLoan();
          }.tabBar(this.TabBuilder(LoanType.Combination, '组合贷款'));
        }
        .animationDuration(400)
        .edgeEffect(EdgeEffect.Spring)
        .onChange((type: LoanType) => {
          this.currentIndex = type;
        }).padding(16);
      }.width('100%')
      .height('100%')
    }.hideTitleBar(true)
    .onReady((ctx) => {
      setPathStack(ctx.pathStack);
    })
    .onSizeChange((oldSize:SizeOptions,newSize:SizeOptions)=>{
      const height:number = newSize.height as  number
      if (height<=this.vm.DEFAULT_HEIGHT){
        this.vm.isSmallHeight = true
      }else {
        this.vm.isSmallHeight = false
      }
    })
  }
}

@Builder
export function MortgageCalculationHomeBuilder() {
  Home();
}