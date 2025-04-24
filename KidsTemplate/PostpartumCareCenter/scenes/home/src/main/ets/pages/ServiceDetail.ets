import { MainEntryVM } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { display } from '@kit.ArkUI';

@Builder
export function ServiceDetailBuilder() {
  ServiceDetail();
} // 全局自定义构建函数

@ComponentV2
struct ServiceDetail {
  vm: MainEntryVM = MainEntryVM.instance;
  @Local message: string = '';
  @Local screenWidth: number = 0;

  build() {
    NavDestination() {
      Column(){
        Stack({ alignContent: Alignment.Bottom }){
          Image($r('app.media.service_detail_background'))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover);

          Row() {
            // 左侧线段
            Line()
              .startPoint([0,0])
              .endPoint([50,0]) // 线段长度50vp
              .stroke(Color.Black)
              .strokeWidth(1)
              .margin({ right: 10 }) // 与Text的间距

            // 居中文字
            Text('新科研护理模式')
              .fontSize($r('app.string.font_size_16'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Medium)
              .fontColor('#000000')
              .layoutWeight(1) // 占据剩余空间以实现居中
              .textAlign(TextAlign.Center)

            // 右侧线段
            Line()
              .startPoint([0,0])
              .endPoint([50,0]) // 线段长度50vp
              .stroke(Color.Black)
              .strokeWidth(1)
              .margin({ left: 10 }) // 与Text的间距
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding(27) // 整体边距

        }
        .width('100%')
        .margin({bottom: 12})

        Column(){
          Text('专业呵护')
            .fontSize($r('app.string.font_size_18'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({bottom: 2})


          Text('专业的护理团队，\n' +
            '全天候贴心照护每一位妈妈和宝宝。\n' +
            '精心调配的月子膳食，\n' +
            '确保营养均衡，助力快速恢复体力。\n' +
            '详尽的孕期指南，\n' +
            '帮助准妈妈们从容应对每一个重要时刻。')
            .fontSize($r('app.string.font_size_12'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0,0,0,0.60)')
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({bottom: 24})

          Image($r('app.media.service_detail_desc'))
            .width('100%')
            .height(154)
            .borderRadius($r('app.string.border_radius_8'))
            .objectFit(ImageFit.Cover)
            .margin({bottom: 24});

          Text('温馨家园')
            .fontSize($r('app.string.font_size_18'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({bottom: 2})


          Text('引入先进的育婴黑科技，\n' +'让育儿体验更加智能便捷。\n' +
            '全面的产后恢复计划，\n' +'结合传统与现代技术，帮助新妈妈焕发新生。\n' +
            '安全舒适的居住环境，\n'+
            '采用环保材料装修，24小时监控保障，让您享受安心无忧的月子时光。')
            .fontSize($r('app.string.font_size_12'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0,0,0,0.60)')
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({bottom: 24})


        }
        .margin({left: '10%', right: '10%'})
      }


    }
    .onReady((context: NavDestinationContext) => {
      this.message = context.pathInfo.param as string;
      const displayClass = display.getDefaultDisplaySync();
      this.screenWidth = px2vp(displayClass.width);
    });
  }
}
