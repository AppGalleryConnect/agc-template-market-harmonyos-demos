import { Logger, ActivityModel } from '@ohos_agcit/postpartum_care_center_utils';
import { ActivityEntryVM } from '../viewmodel/ActivityEntryVM';

@Builder
export function ActivityDetailBuilder() {
  ActivityDetail();
} // 全局自定义构建函数

@ComponentV2
@Preview
struct ActivityDetail{
  vm: ActivityEntryVM = ActivityEntryVM.instance;

  @Local activity: ActivityModel | null = null;

  aboutToAppear(): void {
    this.activity = this.vm.navStack.getParamByName('ActivityDetail')[0] as ActivityModel;
    Logger.debug(JSON.stringify(this.activity));
  }

  build() {
    NavDestination() {
      Column() {
        Text(this.activity?.name)
          .fontSize($r('app.string.font_size_16'))
          .fontFamily($r('app.string.font_family_default'))
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .textAlign(TextAlign.Start)
          .width('100%')
          .margin({top:$r('app.string.margin_xs')})

        Text(this.activity?.type)
          .fontSize($r('app.string.font_size_12'))
          .fontFamily($r('app.string.font_family_default'))
          .fontWeight(FontWeight.Regular)
          .fontColor('#000000')
          .textAlign(TextAlign.Start)
          .width('100%')
          .margin({top:$r('app.string.margin_xs'), bottom: $r('app.string.margin_ms')})

        Column() {
          Image(this.activity?.picDescUrl)
            .width('100%')
            .borderRadius($r('app.string.border_radius_8'))
            .height(180)
            .objectFit(ImageFit.Cover)
            .margin({bottom: $r('app.string.margin_l')})

          Text($r('app.string.activity_desc_title'))
            .fontSize($r('app.string.font_size_18'))
            .fontFamily($r('app.string.font_family_default'))
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({bottom: $r('app.string.margin_ms')})

        }

        Column(){
          // 当前统一为公共文案，后续可用this.activity?.desc替换活动各自的文案
          Text('\t\t【活动主题】：儿科专家健康讲座\n' +
            '\t\t【活动日期】：1月31日 周六下午15:00\n' +
            '\t\t【活动地点】：' + this.activity?.supportStoreName +'\n' +
            '1、三甲医院儿科主任亲授，解读0-1岁宝宝喂养难题、睡眠规律与常见疾病预防，助您避开育儿误区。\n' +
            '2、课后专属咨询时段，专家一对一解答过敏、湿疹、疫苗接种等实际问题，提供针对性护理建议。\n' +
            '3、到场家庭可领取体温安抚礼盒（含婴儿生理海盐水、安全镊子），享持续育儿指导。')
            .fontSize($r('app.string.font_size_12'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontColor('#000000')
            .lineHeight($r('app.string.font_size_20'))
            .width('100%')
        }
        .width('100%')
        .height(336)

        Row(){
          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Text($r('app.string.desc_activity_booking_submit'))
              .fontSize($r('app.string.font_size_16'))// 设置字号为16
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF');
          }
          .backgroundColor('#333333')
          .padding({
            top: 10,
            bottom: 9,
          }) // 设置文字内边距
          .borderRadius($r('app.string.border_radius_20'))
          .width('100%')
          .onClick(() => {
            this.vm.navStack.pushPathByName('ActivityBooking', this.activity);
          });
        }
        .justifyContent(FlexAlign.Center) // 设置子组件两端对齐，按钮在页面底部
        .width('100%')
        .height('40')
        .margin({bottom: 13})

      }
      .width('100%')
      .height('100%')
      .padding({ bottom: $r('app.string.margin_xs'), left: $r('app.string.margin_ms'), right: $r('app.string.margin_ms') })
    }
    .title('活动详情');
  }
}