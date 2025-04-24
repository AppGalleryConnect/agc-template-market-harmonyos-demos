import { Banner } from '../view/Banner';
import { NearbyStores } from '../view/NearbyStores';
import { ServiceGrids } from '../view/SeviceGrids';
import { MainEntryVM, StoreModel, TitleTop } from '@ohos_agcit/postpartum_care_center_uicomponents';

const STORE_LIST : StoreModel[] = [
  new StoreModel(1, '南京涵江楼', '南京市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic1'), '南京', 31.98, 118.76),
  new StoreModel(2, '南京卓美悦', '南京市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic2'), '南京', 31.99, 118.71),
  new StoreModel(5, '苏州华轩苑', '苏州市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic1'), '苏州', 31.29, 120.64),
  new StoreModel(3, '南京华轩府', '南京市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic2'), '南京', 32.03, 118.80),
  new StoreModel(4, '无锡雅辉阁', '无锡市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic1'), '无锡', 31.58, 120.30),
  new StoreModel(6, '杭州科技城', '杭州市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic2'), '杭州', 30.22, 120.12),
  new StoreModel(7, '北京卓美悦', '北京市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic1'), '北京', 39.91, 116.47),
  new StoreModel(8, '深圳海月楼', '深圳市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic2'), '深圳', 22.54, 114.06),
  new StoreModel(9, '东莞华轩苑', '东莞市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic1'), '东莞', 23.02, 113.75),
  new StoreModel(10, '广州银月楼', '广州市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic2'), '广州', 23.13, 113.26),
  new StoreModel(11, '汕头卓美悦', '汕头市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic1'), '汕头', 23.35, 116.68),
  new StoreModel(12, '常州银月楼', '常州市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic2'), '常州', 31.81, 119.94),
  new StoreModel(13, '上海银月楼', '上海市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic1'), '上海', 31.23, 121.47),
  new StoreModel(14, '上海云顶轩', '上海市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic2'), '上海', 31.20, 121.36),
  new StoreModel(15, '北京云顶轩', '北京市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic1'), '北京', 39.90, 116.41),
  new StoreModel(16, '常州星辉阁', '常州市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic2'), '常州', 31.78, 119.89),
  new StoreModel(17, '深圳华轩苑', '深圳市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic1'), '深圳', 22.57, 113.94),
  new StoreModel(18, '广州卓美拉', '广州市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic2'), '广州', 23.17, 113.39),
  new StoreModel(19, '上海雅阁楼', '上海市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic1'), '上海', 31.18, 121.38),
  new StoreModel(20, '上海华轩府', '上海市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic2'), '上海', 31.22, 121.35),
  new StoreModel(21, '杭州涵江楼', '杭州市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic1'), '杭州', 30.25, 120.16),
  new StoreModel(22, '杭州卓美悦', '杭州市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic2'), '杭州', 30.20, 119.99),
  new StoreModel(23, '无锡卓美悦', '无锡市高新技术产业园区软件大道101号酒店16F', '12345678910',
    $r('app.media.store_pic1'), '无锡', 31.52, 120.45),
];

@Entry
@Preview
@ComponentV2
export struct Home {
  vm: MainEntryVM = MainEntryVM.instance;

  aboutToAppear(): void {
    this.vm.storeList.storeList = STORE_LIST;
    this.vm.storeListNearby.storeList = STORE_LIST;
    this.vm.requestLocationPermission();
  }

  build() {
    Column() {
      TitleTop({ title: $r('app.string.title_home')})
      Scroll() {
        Column() {
          Banner();
          Column() {
            Text($r('app.string.title_sub_service'))
              .fontColor('rgba(0,0,0,0.90)')
              .fontSize($r('app.string.font_size_18'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .height(56)
              .padding({ top: $r('app.string.padding_24'), bottom: $r('app.string.padding_8') });
            ServiceGrids()
              .margin({ top: $r('app.string.margin_xs') });
          }
          .backgroundColor('#F1F3F5')
          .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') });

          Column() {
            Row() {
              Text($r('app.string.title_sub_booking'))
                .fontColor('rgba(0,0,0,0.90)')
                .fontSize($r('app.string.font_size_18'))
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Bold)
                .width('50%')
                .height(56)
                .padding({ top: $r('app.string.padding_24'), bottom: $r('app.string.padding_8') })
                .textAlign(TextAlign.Start);
              Row() {
                Text($r('app.string.title_sub_all_store'))
                  .fontColor('rgba(0,0,0,0.60)')
                  .fontSize($r('app.string.font_size_14'))
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Regular)
                  .height(56)
                  .padding({ top: $r('app.string.padding_29'), bottom: $r('app.string.padding_8') })
                Image($r('app.media.chevron_right'))
                  .width(12)
                  .height(56)
                  .padding({
                    top: $r('app.string.padding_26'),
                    bottom: $r('app.string.padding_6'),
                    left: $r('app.string.padding_5'),
                  });
              }
              .justifyContent(FlexAlign.End) // 设置子组件右对齐
              .width('50%')
              .height(56)
              .onClick(() => {
                this.vm.curIndex = 1;
              });
            }
            .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') })
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .height(56);

            NearbyStores()
              .margin({ top: $r('app.string.margin_xs') });
          };
        }
        .padding({ top: $r('app.string.padding_8'), bottom: $r('app.string.padding_10') })
      }
      .scrollBar(BarState.Off) // 关闭滚动时的滚动条显示
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .align(Alignment.TopStart)
    .backgroundColor('#F1F3F5')
    .clip(false)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}
