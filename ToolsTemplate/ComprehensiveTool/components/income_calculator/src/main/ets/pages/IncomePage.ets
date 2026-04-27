import { setPathStack } from '../common/CommonRoute';
import { IncomeCalculator } from '../components/IncomeCalculator';

// 跳转页面入口函数
@Builder
export function IncomePageBuilder() {
  IncomePage()
}

@ComponentV2
export struct IncomePage {
  build() {
    NavDestination() {
      IncomeCalculator()
    }
    .height('100%')
    .backgroundColor('#F1F3F5')
    .title('个税计算器').onReady((ctx) => {
      setPathStack(ctx.pathStack);
    });
  }
}