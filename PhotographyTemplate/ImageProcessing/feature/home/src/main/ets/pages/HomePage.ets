import { LengthMetrics } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { BaseTitle, CommonConstants, ICardInfo, OperateType, HOT_FILTERS, CustomFilter, RouterMap } from 'commonlib';
import { AdvertisementComponent } from 'module_advertisement';
import { HomePageVM } from '../viewmodels/HomePageVM';


@ComponentV2
export struct HomePage {
  vm: HomePageVM = new HomePageVM();

  aboutToAppear(): void {
    emitter.on('formCardPageUrl', (eventData: emitter.EventData) => {
      const data = eventData.data;
      if (data) {
        const url = data.url as string;
        switch(url) {
          case RouterMap.PICTURE_BEAUTIFICATION:
            this.vm.photoPicker(OperateType.NONE)
            break;
          case RouterMap.LUT_CAMERA_PAGE:
            this.vm.takePhoto();
            break;
          case RouterMap.COLLAGE_PAGE:
            this.vm.collage();
            break;
          default:
            break;
        }
      }
    });
  }

  build() {
    Column({ space: CommonConstants.SPACE_M }) {
      BaseTitle({
        title: '首页',
      })

      if (this.vm.breakPointModel.isMoreMD) {
        Row({ space: CommonConstants.SPACE_M }) {
          this.leftImgRightTextCard({
            label: '图片美化',
            icon: $r('app.media.ic_editing'),
            bgColor: $r('sys.color.multi_color_aux_01'),
            action: () => {
              this.vm.photoPicker(OperateType.NONE)
            }
          })
          this.leftImgRightTextCard({
            label: '相机',
            icon: $r('app.media.ic_camera_beautify'),
            bgColor: $r('sys.color.multi_color_02'),
            action: () => {
              this.vm.takePhoto();
            }
          })
          this.leftImgRightTextCard({
            label: '拼图',
            icon: $r('app.media.ic_collage'),
            bgColor: $r('sys.color.multi_color_04'),
            action: () => {
              this.vm.collage();
            }
          })
        }
        .width(CommonConstants.FULL_PERCENT)
      } else {
        Column({ space: CommonConstants.SPACE_M }) {
          this.leftImgRightTextCard({
            label: '图片美化',
            icon: $r('app.media.ic_editing'),
            bgColor: $r('sys.color.multi_color_aux_01'),
            action: () => {
              this.vm.photoPicker(OperateType.NONE)
            }
          })

          Row({ space: CommonConstants.SPACE_M }) {
            this.topImgBottomTextCard({
              label: '相机',
              icon: $r('app.media.ic_camera_beautify'),
              bgColor: $r('sys.color.multi_color_02'),
              action: () => {
                this.vm.takePhoto();
              }
            })

            this.topImgBottomTextCard({
              label: '拼图',
              icon: $r('app.media.ic_collage'),
              bgColor: $r('sys.color.multi_color_04'),
              action: () => {
                this.vm.collage();
              }
            })
          }
          .width(CommonConstants.FULL_PERCENT)
        }
        .width(CommonConstants.FULL_PERCENT)
      }

      Text('热门滤镜')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .width(CommonConstants.FULL_PERCENT)
        .textAlign(TextAlign.Start)

      Flex({ space: { main: LengthMetrics.vp(CommonConstants.SPACE_S) }}) {
        ForEach(HOT_FILTERS.filter(item => item.isHot), (item: CustomFilter) => {
          Stack({ alignContent: Alignment.Bottom }) {
            Image(item.image)
              .width(CommonConstants.FULL_PERCENT)
              .aspectRatio(this.vm.imgAspectRatio)
              .borderRadius(16)
            Text(item.name)
              .padding({ bottom: CommonConstants.PADDING_M })
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'));
          }
          .flexGrow(1)
          .onClick(() => {
            this.vm.photoPicker(OperateType.FILTER, item.name);
          })
        })
      }
      .width(CommonConstants.FULL_PERCENT)

      // 广告
      this.adViewCard()
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  leftImgRightTextCard($$: ICardInfo) {
    Row({ space: CommonConstants.SPACE_S }) {
      Image($$.icon)
        .width($r('app.float.img_card_size'))
        .height($r('app.float.img_card_size'))
      Text($$.label)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'));
    }
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.card_height'))
    .borderRadius(16)
    .backgroundColor($$.bgColor)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .flexGrow(1)
    .flexShrink(1)
    .onClick(() => {
      $$.action();
    })
  }

  @Builder
  topImgBottomTextCard($$: ICardInfo) {
    Column() {
      Image($$.icon)
        .width($r('app.float.img_card_size'))
        .height($r('app.float.img_card_size'))
      Text($$.label)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.card_height'))
    .borderRadius(16)
    .backgroundColor($$.bgColor)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .flexGrow(1)
    .flexShrink(1)
    .onClick(() => {
      $$.action();
    })
  }

  @Builder
  adViewCard() {
    Column() {
      AdvertisementComponent({
        testAd: 'testw6vs28auh3',
        adType: 8,
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(150)
    .borderRadius(8)
    .margin({ top: CommonConstants.SPACE_M })
  }
}

@Builder
export function HomePageBuilder() {
  HomePage();
}
