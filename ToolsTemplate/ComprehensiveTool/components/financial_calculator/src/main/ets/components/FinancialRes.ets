import { common } from '@kit.AbilityKit'
import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { FinancialType } from '../common/Constant'
import { InvestmentDetail } from '../model/Index'
import { copyText, getCopyText } from '../utils/Index'
import { RowData } from './RowData'


@ComponentV2
export struct FinancialRes {
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
  @Param title: string = ''
  @Param investmentIncome: InvestmentDetail = new InvestmentDetail(FinancialType.BANK)

  share(text: string) {
    // 构造ShareData，需配置一条有效数据信息
    let data: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.PLAIN_TEXT,
      content: text,
    });

    // 构建ShareController
    let controller: systemShare.ShareController = new systemShare.ShareController(data);
    // 获取UIAbility上下文对象
    let uiContext: UIContext = this.getUIContext();
    let context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    // 注册分享面板关闭监听
    controller.on('dismiss', () => {
      console.info('Share panel closed');
      // 分享结束，可处理其他业务。
    });

    // 进行分享面板显示
    // 方法一：配置分享面板关联的控件ID
    controller.show(context, {
      anchor: 'shareButtonId',
    });
    // 方法二：配置分享面板显示的坐标
    controller.show(context, {
      anchor: {
        // 必选 相对锚点的窗体偏移值
        windowOffset: { x: 100, y: 100 },
        // 可选 组件的宽高 配置后会综合计算组件的大小
        size: { width: 0, height: 0 },
      },
    });
  }

  build() {
    Column() {
      Row() {
        Text(`${this.title}计算结果`)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        Row() {
          SymbolGlyph($r('sys.symbol.plus_square_on_square'))
            .fontSize(24)
            .fontColor([$r('sys.color.font_primary')])
            .margin({ right: 16 })
            .onClick(() => {
              copyText(getCopyText(this.investmentIncome))
            })
          SymbolGlyph($r('sys.symbol.share'))
            .fontSize(24)
            .fontColor([$r('sys.color.font_primary')])
            .onClick(() => {
              this.share(getCopyText(this.investmentIncome))
            })
        }
      }
      .width('100%')
      .padding({ top: 24, bottom: 16 })
      .margin({ bottom: 12 })
      .justifyContent(FlexAlign.SpaceBetween)

      RowData({ title: '投资总额', data: this.investmentIncome.money + '元' })
      RowData({ title: '总收益', data: this.investmentIncome.totalRevenue + '元' })
      RowData({ title: '利息收益', data: this.investmentIncome.rateRevenue + '元', color: '#64BB5C' })
      RowData({ title: '年化收益率', data: this.investmentIncome.rate + '%' })
      RowData({ title: '月均收益', data: this.investmentIncome.monthlyRevenue + '元' })
    }
  }
}