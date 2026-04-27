import { common } from '@kit.AbilityKit'
import { RowData } from './RowData'
import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { copyText, getCopyText } from '../utils/Index'
import { PensionCalcRes } from '../model/Index'

@ComponentV2
export struct PensionRes {
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
  @Require @Param pensionCalcRes: PensionCalcRes

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
        Text(`养老金估算结果`)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
        Row() {
          SymbolGlyph($r('sys.symbol.plus_square_on_square'))
            .fontSize(24)
            .fontColor([$r('sys.color.font_primary')])
            .margin({ right: 16 })
            .onClick(() => {
              copyText(getCopyText(this.pensionCalcRes))
            })
          SymbolGlyph($r('sys.symbol.share'))
            .fontSize(24)
            .fontColor([$r('sys.color.font_primary')])
            .onClick(() => {
              this.share(getCopyText(this.pensionCalcRes))
            })
        }
      }
      .width('100%')
      .padding({ top: 24, bottom: 16 })
      .margin({ bottom: 12 })
      .justifyContent(FlexAlign.SpaceBetween)

      RowData({ title: '预计总缴费年限', data: `${this.pensionCalcRes.estimatedPaymentYears}年` })
      RowData({ title: '个人账户累计存储额', data: `${this.pensionCalcRes.personalAccount}元` })
      RowData({ title: '基础养老金', data: `${this.pensionCalcRes.basicPension}元` })
      RowData({ title: '个人账户养老金', data: `${this.pensionCalcRes.personalAccountPension}元` })
      RowData({ title: '每月预计领取养老金总额', data: `${this.pensionCalcRes.estimatedPayment}元` })

      Column() {
        Row() {
          Text('养老金构成与缴费分析')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 16 })

        Row() {
          Text('养老金计算说明：')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .margin({ bottom: 12 })


        Row() {
          Text('1. 基础养老金计算公式：\n' +
            '基础养老金 = (退休时当地上年度在岗职工月平均工资 + 本人指数化月平均缴费工资) ÷ 2 × 缴费年限 × 1%\n' +
            '\n' +
            '2. 个人账户养老金计算公式：\n' +
            '个人账户养老金 = 个人账户储存额 ÷ 计发月数（60岁退休为139，55岁为170，50岁为195）\n' +
            '\n' +
            '3. 本人指数化月平均缴费工资：\n' +
            '本人指数化月平均缴费工资 = 当地上年度在岗职工月平均工资 × 本人平均缴费指数')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
        .margin({ bottom: 12 })

        Row() {
          Text('养老金缴费建议：')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .margin({ bottom: 12 })

        Row() {
          Text('提高养老金的方法：\n' +
            '- 延长缴费年限，缴费年限越长，基础养老金越多\n' +
            '\n' +
            '- 提高缴费基数，缴费基数越高，个人账户积累越多\n' +
            '\n' +
            '- 选择较晚的退休年龄，可获得更高的月养老金\n' +
            '\n' +
            '- 考虑购买商业养老保险作为补充')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
        .margin({ bottom: 12 })

        Row() {
          Text('注意事项：')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .margin({ bottom: 12 })

        Row() {
          Text('提高养老金的方法：\n' +
            '- 本计算器仅为估算，实际养老金以社保部门核算为准\n' +
            '\n' +
            '- 养老金政策可能调整，建议定期关闭最新政策\n' +
            '\n' +
            ' - 最低缴费年限为15年，不足15年可能无法领取基础养老金\n' +
            '\n' +
            '- 计发月数根据退休年龄确定，60岁为139个月，55岁为170个月，50岁为195个月')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
      }
      .backgroundColor('#F1F3F5')
      .padding({
        top: 16,
        bottom: 16,
        left: 12,
        right: 12,
      })
      .borderRadius(20)
    }
  }
}