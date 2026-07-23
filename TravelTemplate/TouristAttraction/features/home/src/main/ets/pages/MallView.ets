import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, BreakpointNameEnum, BreakpointType, Constant,
  GridRowColSetting,
  LazyDataSource } from 'common';
import { LoginConfirmDialogComponent } from 'module_base';
import { UserInfo } from 'types';
import { TitleBar } from 'uicomponents';
import { CommodityInfo } from '../model/CommodityInfo';
import { CommodityTabBarType } from '../model/CommodityTabInfo';
import { CommodityVM } from '../viewmodel/CommodityVM';

@Builder
export function MallBuilder() {
  MallView();
}

@ComponentV2
export struct MallView {
  vm: CommodityVM = CommodityVM.instance;
  @Local userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local currentCommodityId: number = 0
  @Local currentTabIndex: number = 0;
  tabsController: TabsController = new TabsController();
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
    this.vm.getCommodityList(CommodityTabBarType.SPECIAL);
    this.vm.getCommodityList(CommodityTabBarType.CULTURE);
  }

  @Builder
  CommodityTabBar() {
    Row() {
      Text('特色特产')
        .fontColor(
          this.currentTabIndex === 0 ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_M'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .height(36)
        .padding({ top: 6, bottom: 6, left: 12, right: 12 })
        .backgroundColor(
          this.currentTabIndex === 0 ? $r('sys.color.comp_background_primary_contrary_secondary') : '#00000000')
        .borderRadius(18)
        .shadow(this.currentTabIndex === 0 ? {
          radius: 3, offsetX: 0, offsetY: 0, color: '#33000000', fill: false,
        } : { radius: 0 })
        .onClick(() => {
          this.tabsController.changeIndex(0);
        })
      Text('文创产品')
        .fontColor(
          this.currentTabIndex === 1 ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_M'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .height(36)
        .padding({ top: 6, bottom: 6, left: 12, right: 12 })
        .backgroundColor(
          this.currentTabIndex === 1 ? $r('sys.color.comp_background_primary_contrary_secondary') : '#00000000')
        .borderRadius(18)
        .shadow(this.currentTabIndex === 1 ? {
          radius: 3, offsetX: 0, offsetY: 0, color: '#33000000', fill: false,
        } : { radius: 0 })
        .onClick(() => {
          this.tabsController.changeIndex(1);
        })
    }
    .width(Constant.FULL_PERCENT)
    .constraintSize({ maxWidth: Constant.MAX_WIDTH })
    .padding(2)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius(20)
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
    .columnsTemplate(new BreakpointType({
      [BreakpointNameEnum.SM]: '1fr '.repeat(2),
      [BreakpointNameEnum.MD]: '1fr '.repeat(3),
      [BreakpointNameEnum.LG]: '1fr '.repeat(5),
      [BreakpointNameEnum.XL]: '1fr '.repeat(5),
    }).getValue(this.breakPointModel.currentBreakpoint))
    .columnsGap(GridRowColSetting.getGutter(this.breakPointModel.currentBreakpoint))
    .rowsGap(12)
    .margin({ top: 16 })
    .width(Constant.FULL_PERCENT)
    .backgroundColor($r('sys.color.background_secondary'));
  }

  @Builder
  CommodityCardBuilder(item: CommodityInfo) {
    Column() {
      Image(item.banner)
        .width(Constant.FULL_PERCENT)
        .height(160)
        .borderRadius(8)

      Column() {
        Text(item.name)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .margin({ top: 8, bottom: 4 })
          .width(Constant.FULL_PERCENT)
          .maxLines(2)
          .textAlign(TextAlign.Start);

        Row({ space: 2 }) {
          Text() {
            Span('￥').fontSize($r('sys.float.Body_S'));
            Span(`${item.spuInfo[item.basicSpu]?.spuDiscountPrice}`)
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium);
          }.fontColor($r('sys.color.multi_color_08'));

          Text(`￥${item.spuInfo[item.basicSpu]?.spuOriginalPrice}`)
            .fontSize(12)
            .decoration({ type: TextDecorationType.LineThrough })
            .fontColor($r('sys.color.font_tertiary'));
        }.width(Constant.FULL_PERCENT);
      }.padding({ left: 8, right: 8 });
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
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

  onTabChange(index: number) {
    this.currentTabIndex = index;
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '特产文创', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });
        Column() {
          this.CommodityTabBar()
          Tabs({ index: this.currentTabIndex, controller: this.tabsController }) {
            TabContent() {
              this.CommodityWaterFlowBuilder(this.vm.specialCommodityList);
            }
            TabContent() {
              this.CommodityWaterFlowBuilder(this.vm.culturalCommodityList);
            }
          }
          .barHeight(0)
          .scrollable(true)
          .onAnimationStart((index: number, targetIndex: number) => {
            this.onTabChange(targetIndex);
          })
          .layoutWeight(1)
        }
        .margin({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding, top: 8 })
        .constraintSize({ maxWidth: Constant.FULL_PERCENT })
        .width(Constant.FULL_PERCENT)
        .layoutWeight(1);
      };
    }.hideTitleBar(true).backgroundColor($r('sys.color.background_secondary'));
  }
}
