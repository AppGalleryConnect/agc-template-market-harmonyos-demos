import { StoreModel } from '../model/StoreModel';
import { MainEntryVM } from '../viewmodel/MainEntryVM';
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { PromptActionClass } from '@ohos_agcit/postpartum_care_center_utils';
import { callDialog } from './StoreCard';
import { ComponentContent } from '@kit.ArkUI';

@Builder
export function StoreDetailBuilder() {
  StoreDetail();
} // 全局自定义构建函数

@Entry
@ComponentV2
struct StoreDetail {
  vm: MainEntryVM = MainEntryVM.instance;
  private ctx: UIContext = this.getUIContext();
  @Local store: StoreModel =
    new StoreModel(1, '南京涵江楼', '软件大道101号', '11100001111', $r('app.media.store_pic1'), '南京', 31.98, 118.76);
  @Local isImageDetailVisible: boolean = false; // 控制图片详情的显示状态
  private contentNode: ComponentContent<object> = new ComponentContent(this.ctx,wrapBuilder(callDialog), callPhone);

  @Builder
  imageDetailBuilder() {
    Column() {
      Image($r('app.media.store_price_table'))
        .objectFit(ImageFit.Contain)
        .width('100%')
        .height('100%')
        .onClick(() => {
          this.isImageDetailVisible = false; // 点击图片关闭模态框
        });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .justifyContent(FlexAlign.Center);
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Column() {
            Column() {
              Image(this.store.image)
                .width('100%')
                .borderRadius($r('app.string.border_radius_16'))
                .height(180)
                .objectFit(ImageFit.Cover);
            }
            .padding({ left: $r('app.string.margin_ms'), right: $r('app.string.margin_ms') });

            Column() {
              Text('门店理念')
                .fontSize($r('app.string.font_size_24'))
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Medium)
                .fontColor('#000000');
              Text('以科学护理重塑产后美好时光')
                .fontSize($r('app.string.font_size_12'))
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Regular)
                .fontColor('rgba(0,0,0,0.60)')
                .margin({ bottom: $r('app.string.margin_32') });
              Text('核心优势')
                .fontSize($r('app.string.font_size_16'))
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Medium)
                .fontColor('#000000');
              Text('三甲医院妇产专家每周巡诊\n' +
                '国家营养师定制三餐三点\n' +
                '德国进口仪器+中医手法护理\n' +
                '每日生长发育监测、早早教启蒙\n' +
                '全套房设计，空气净化系统+静音建材，家属陪住区\n' +
                '宝宝24小时视频探视')
                .textAlign(TextAlign.Center)
                .fontSize($r('app.string.font_size_12'))
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Regular)
                .fontColor('rgba(0,0,0,0.60)')
                .lineHeight(28)
                .margin({ bottom: 34});

              Row() {
                Image($r('app.media.ic_public_telephone'))
                  .width(56)
                  .height(56);
              }
              .width('100%')
              .justifyContent(FlexAlign.End)
              .margin({ bottom: 34})
              .onClick(() => {
                // 电话号码和回调函数
                PromptActionClass.openDialog(this.getUIContext(), this.contentNode);
              });
            }
            .margin({ top: $r('app.string.margin_32') })
            .padding({ left: $r('app.string.margin_ms'), right: $r('app.string.margin_ms') });
          };

          Row() {
            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Text($r('app.string.package_price_list'))
                .fontSize($r('app.string.font_size_16'))// 设置字号为16
                .fontFamily('HarmonyHeiTi')// 设置字体为鸿蒙黑体
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333');
            }
            .backgroundColor('#FFFFFF')
            .padding({
              top: 10,
              bottom: 9,
            }) // 设置文字内边距
            .borderRadius($r('app.string.border_radius_20'))
            .backgroundColor('rgba(0,0,0,0.05)') // 设置按钮背景颜色为白色
            .width('47%')
            .onClick(() => {
              this.isImageDetailVisible = true; // 显示图片详情
            });

            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Text($r('app.string.visit_booking'))
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
            .width('47%')
            .onClick(() => {
              this.vm.navStack.pushPathByName('Booking', this.store.name);
            });
          }
          .width('100%') // 设置Row的宽度为100%
          .height(60) // 设置Row的高度
          .justifyContent(FlexAlign.SpaceBetween) // 设置子组件两端对齐
          .padding({
            top: $r('app.string.padding_10'),
            right: $r('app.string.padding_16'),
            bottom: $r('app.string.padding_8'),
            left: $r('app.string.padding_16'),
          });
        }
        .justifyContent(FlexAlign.SpaceBetween) // 设置子组件两端对齐，按钮在页面底部
        .width('100%')
        .height('100%')
        .bindContentCover(this.isImageDetailVisible, this.imageDetailBuilder(), {
          modalTransition: ModalTransition.ALPHA, // 设置透明度渐变转场效果
          backgroundColor: Color.Gray, // 设置模态框背景颜色
        });
      }
      .margin({ top: $r('app.string.margin_xs') });
    }
    .title('门店详情')
    .onReady((context: NavDestinationContext) => {
      this.vm.navStack = context.pathStack;
      let params = context.pathInfo.param as Record<string, Object>;

      this.store = params.store as StoreModel;
      this.contentNode = params.contentNode as ComponentContent<object>;
    });
  }
}

export function callPhone() {
  // 如果设备支持呼叫能力，则继续跳转到拨号界面，并显示拨号的号码
  call.makeCall('12345678910', (err: BusinessError) => {
    if (!err) {
      console.log('make call success.');
    } else {
      console.log('make call fail, err is:' + JSON.stringify(err));
    }
  });
}