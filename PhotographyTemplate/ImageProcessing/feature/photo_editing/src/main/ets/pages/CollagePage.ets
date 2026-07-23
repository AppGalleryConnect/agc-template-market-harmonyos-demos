import { LoginSheetUtils } from 'aggregated_login';
import { MemberSheetUtils } from 'membership';
import { LoginUtil, SheetMemberUtil } from 'mine';
import { BaseTitle, CommonConstants } from 'commonlib';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';
import { CollageVM } from '../viewmodel/CollageVM';
import { CollageMode } from '../constant/Enum';
import { FixedCollage } from '../views/FixedCollage';
import { PosterCollage } from '../views/PosterCollage';
import { FreeCollage } from '../views/FreeCollage';
import { JoinImage } from '../views/JoinImage';
import { PosterTemplateModel, CollageModeInfo, FreeCollageModel, LayoutTemplateModel } from '../model/CollageModel';
import { FREE_TEMPLATES } from '../constant/TemplateData';

@Builder
export function CollagePageBuilder() {
  CollagePage();
}

@ComponentV2
export struct CollagePage {
  @Local isMember: boolean = false;
  vm: CollageVM = CollageVM.instance;
  uiContext: UIContext = this.getUIContext();

  aboutToAppear() {
    this.isMember = this.vm.userInfo.isLogin && this.vm.userInfo.isVip
    this.vm.init();
  }

  aboutToDisappear(): void {
    // 页面销毁时，需要重置对象
    CollageVM.instance = new CollageVM();
  }

  build() {
    NavDestination() {
      Column() {
        // 头部
        this.collageHeader()

        // 4种模式的展示
        Column() {
          if (this.vm.mode === CollageMode.FIXED) {
            FixedCollage()
          } else if (this.vm.mode === CollageMode.POSTER) {
            PosterCollage()
          } else if (this.vm.mode === CollageMode.FREE) {
            FreeCollage()
          } else if (this.vm.mode === CollageMode.JOIN) {
            JoinImage()
          }
        }
        .id('collage')
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
        .backgroundColor($r('sys.color.comp_background_gray'))
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          this.vm.collageAreaWidth = this.uiContext.vp2px(newValue.width as number)
          this.vm.collageAreaHeight = this.uiContext.vp2px(newValue.height as number)
          this.vm.setFixedLayoutRegion();
        })

        Column({ space: CommonConstants.SPACE_S }) {
          Row() {
            ForEach(this.vm.collageModeList, (item: CollageModeInfo) => {
              if (item.show) {
                this.collageModeItem(item)
              }
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.SpaceEvenly)

          Row() {
            if (this.vm.mode === CollageMode.FIXED) {
              // 显示固定拼接的模板选项
              List({ space: 24 }) {
                Repeat(this.vm.fixedLayout)
                  .each((ri: RepeatItem<LayoutTemplateModel>) => {
                    ListItem() {
                      Image(this.vm.fixedIndex === ri.index ? ri.item.selectedImage : ri.item.image)
                        .size({ width: 48, height: 48 });
                    }
                    .onClick(() => {
                      this.vm.fixedIndex = ri.index;
                      this.vm.selectLayout(ri.item);
                    });
                  });
              }
              .scrollBar(BarState.Off)
              .listDirection(Axis.Horizontal);
            } else if (this.vm.mode === CollageMode.POSTER) {
              // 显示海报模式的模板选项
              List({ space: 24 }) {
                Repeat(this.vm.posterList)
                  .each((ri: RepeatItem<PosterTemplateModel>) => {
                    ListItem() {
                      Stack({ alignContent: Alignment.TopStart }) {
                        Image(ri.item.background)
                          .height(70)
                          .width(70).borderRadius(8);

                        if (ri.item.isVip) {
                          Image($r('app.media.ic_beauty_vip'))
                            .size({ width: 12, height: 12 }).margin({ left: 2, top: 2 });
                        }
                      };
                    }
                    .onClick(() => {
                      if (!ri.item.isVip) {
                        this.vm.fixedIndex = ri.index;
                        this.vm.selectPoster(ri.item);
                        return
                      }
                      // 未登录
                      if (!this.vm.userInfo.isLogin) {
                        LoginUtil.loginSuccessCallback = () => {
                          LoginSheetUtils.close();
                        }
                        LoginSheetUtils.open(this.uiContext, LoginUtil.loginParam);
                        return
                      }
                      // 未订阅
                      if (!this.vm.userInfo.isVip) {
                        let sheetMemberUtil = new SheetMemberUtil(this.uiContext);
                        MemberSheetUtils.open(sheetMemberUtil.productsInfo, this.uiContext);
                        return
                      }
                      // 会员订阅
                      if (this.vm.userInfo.isVip) {
                        this.vm.fixedIndex = ri.index;
                        this.vm.selectPoster(ri.item);
                      }
                    });
                  });
              }
              .scrollBar(BarState.Off)
              .listDirection(Axis.Horizontal);
            } else if (this.vm.mode === CollageMode.FREE) {
              List({ space: 24 }) {
                Repeat(FREE_TEMPLATES)
                  .each((ri: RepeatItem<FreeCollageModel>) => {
                    ListItem() {
                      Image(ri.item.background)
                        .height(70)
                        .width(70).borderRadius(8);
                    }
                    .onClick(() => {
                      this.vm.freeIndex = ri.index;
                      this.vm.selectFree(ri.item);
                    });
                  });
              }
              .scrollBar(BarState.Off)
              .listDirection(Axis.Horizontal);
            }
          }
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)
          .constraintSize({ maxHeight: 80 })
          .alignItems(VerticalAlign.Center)
        }
        .padding({
          top: CommonConstants.PADDING_M
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_primary'))
      .padding({
        left: this.vm.breakPointModel.pagePadding,
        right: this.vm.breakPointModel.pagePadding
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  @Builder
  collageHeader() {
    BaseTitle({
      title: '拼图',
      showBackBtn: true,
      rightPartBuilder: () => {
        this.headerRightBuilder()
      },
    })
  }

  @Builder
  headerRightBuilder() {
    SaveButton({ icon: SaveIconStyle.FULL_FILLED, buttonType: ButtonType.Circle })
      .size({ width: 40, height: 40 })
      .iconColor($r('sys.color.font_primary'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        ImageProcessingUtil.saveToAlbum('collage', this.uiContext, () => {
          this.uiContext.getPromptAction().showToast({ message: '已保存至相册~' });
        });
      });
  }

  @Builder
  collageModeItem($$: CollageModeInfo) {
    Text($$.name)
      .fontColor(this.vm.mode === $$.mode ? $r('sys.color.multi_color_09') :
        $r('sys.color.font_primary'))
      .onClick(() => {
        $$.clickAction();
      })
  }
}
