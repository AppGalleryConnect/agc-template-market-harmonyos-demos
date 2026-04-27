import { AppStorageV2 } from '@kit.ArkUI';
import { Constant, LazyDataSource } from 'common';
import { LoginConfirmDialogComponent } from 'module_base';
import { UserInfo } from 'types';
import { TitleBar } from 'uicomponents';
import { CommodityInfo } from '../model/CommodityInfo';
import { COMMODITY_TABS_INFO, CommodityTabBarData } from '../model/CommodityTabInfo';
import { CommodityVM } from '../viewmodel/CommodityVM';

@Builder
export function MallBuilder() {
  MallView();
}

@ComponentV2
export struct MallView {
  vm: CommodityVM = CommodityVM.instance;
  @Local userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local currentCommodityId: number = 0
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: LoginConfirmDialogComponent({
      confirm: () => {
        this.userInfo.mockLink()
        this.getUIContext().getPromptAction().showToast({ message: '成功关联账号' });
        this.mainPathStack.pushPathByName('CommodityDetail', this.currentCommodityId);
      },
    }),
    customStyle: false,
    autoCancel: true,
  });

  aboutToAppear(): void {
    this.vm.getCommodityList();
  }

  @Builder
  CommodityTabBar(title: ResourceStr, targetIndex: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontColor(this.vm.type === targetIndex ? '#64BB5C' :
          Color.Black)
        .opacity(this.vm.type === targetIndex ? 1 :
          0.6);

      if (this.vm.type === targetIndex) {
        Divider().color('#64BB5C').strokeWidth(3).width(64);
      }
    }
    .onClick(() => {
      // 切换tab触发数据请求
      this.vm.type = targetIndex;
      this.vm.getCommodityList();
    })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  CommodityWaterFlowBuilder(commodityList: LazyDataSource<CommodityInfo>) {
    Grid() {
      LazyForEach(commodityList, (item: CommodityInfo) => {
        GridItem() {
          this.CommodityCardBuilder(item);
        }
        .width(Constant.FULL_PERCENT);
      }, (item: CommodityInfo) => item.commodityId.toString());
    }
    .cachedCount(10)
    .columnsTemplate('repeat(auto-stretch, 150)')
    .columnsGap(8)
    .rowsGap(8)
    .width(Constant.FULL_PERCENT)
    .padding(16)
    .backgroundColor('#F1F3F5');
  }

  @Builder
  CommodityCardBuilder(item: CommodityInfo) {
    Column() {
      Image(item.banner)
        .width('100%')
        .height(90)
        .borderRadius(8)

      Column() {
        Text(item.name)
          .fontSize(12)
          .fontWeight(500)
          .margin({ top: 8, bottom: 12 })
          .maxLines(2)
          .width(Constant.FULL_PERCENT)
          .textAlign(TextAlign.Start);

        Row() {
          Row() {
            Text() {
              Span('￥').fontSize(12).fontColor('#E84026');
              Span(`${item.spuInfo[item.basicSpu]?.spuDiscountPrice}`)
                .fontSize(16)
                .fontWeight(500)
                .fontColor('#E84026');
            };

            Text(`￥${item.spuInfo[item.basicSpu]?.spuOriginalPrice}`)
              .fontSize(10)
              .decoration({ type: TextDecorationType.LineThrough })
              .opacity(0.4);
          }.alignItems(VerticalAlign.Bottom);

          Button('预订')
            .backgroundColor('#64BB5C')
            .fontSize($r('sys.float.Body_S'))
            .height(28)
            .borderRadius(24)
            .fontColor($r('sys.color.font_on_primary'));
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
      }.padding(12);
    }
    .width(150)
    .height(180)
    .backgroundColor($r('sys.color.font_on_primary'))
    .borderRadius(8)
    .onClick(() => {
      if (this.userInfo.isLink) {
        this.mainPathStack.pushPathByName('CommodityDetail', item.commodityId);
      } else {
        this.currentCommodityId = item.commodityId
        this.dialogController?.open()
      }
    })
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '特色文创', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Tabs({ index: this.vm.type }) {
          ForEach(COMMODITY_TABS_INFO, (item: CommodityTabBarData) => {
            TabContent() {
              this.CommodityWaterFlowBuilder(this.vm.commodityList);
            }.tabBar(this.CommodityTabBar(item.title, item.type));
          }, (item: CommodityTabBarData) => item.title.toString());
        }.barWidth(160).animationMode(AnimationMode.NO_ANIMATION).height('90%').onChange((value: number) => {
          this.vm.type = value;
          this.vm.getCommodityList();
        });
      };
    }.hideTitleBar(true);
  }
}