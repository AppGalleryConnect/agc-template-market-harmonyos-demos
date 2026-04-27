import { LoginManageUtil, MemberManageUtil } from 'module_base';
import { LoginSheetUtils } from 'aggregated_login';
import { MemberSheetUtils } from 'membership';
import { FixedCollage } from './FixedCollage';
import { FreeCollage } from './FreeCollage';
import { PosterCollage } from './PosterCollage';
import { JoinImage } from './JoinImage';
import { LayoutTemplateModel } from '../model/LayoutTemplateModel';
import PosterTemplateModel from '../model/PosterTemplateModel';
import FreeCollageModel from '../model/FreeCollageModel';
import { getInstance } from '../util/RouteModule';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';
import { CollageVM } from '../viewmodel/CollageVM';
import { FREE_TEMPLATES } from '../constant/TemplateData';
import { CollageMode } from '../constant/Enum';

@Builder
export function CollagePageBuilder() {
  CollagePage();
}

@ComponentV2
export struct CollagePage {
  @Local isMember: boolean = false;
  vm: CollageVM = CollageVM.instance;
  uiContext: UIContext = this.getUIContext();

  async aboutToAppear(): Promise<void> {
    this.isMember = await MemberManageUtil.queryMemberStatus(this.getUIContext());
    this.vm.init(this.uiContext);
  }

  aboutToDisappear(): void {
    // 清空模板和海报
    this.vm.clear();
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Image($r('app.media.chevron_left'))
              .height(40)
              .width(40)
              .onClick(() => {
                getInstance().pop();
              });

            SaveButton({ text: SaveDescription.SAVE }).onClick(() => {
              ImageProcessingUtil.saveToAlbum('collage', this.uiContext);
            });
          }
          .padding({ left: 16, right: 16 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);

          Column() {
            // 4种模式的展示
            if (this.vm.mode === CollageMode.FIXED) {
              FixedCollage();
            } else if (this.vm.mode === CollageMode.POSTER) {
              PosterCollage();
            } else if (this.vm.mode === CollageMode.FREE) {
              FreeCollage();
            } else if (this.vm.mode === CollageMode.JOIN) {
              JoinImage();
            }
          }
          .margin({ top: 12 })
          .id('collage');
        };

        Column({ space: 8 }) {
          Row() {
            Text('固定拼接')
              .onClick(() => {
                this.vm.setMode(CollageMode.FIXED);
                this.vm.selectLayout(this.vm.fixedLayout[this.vm.fixedIndex]);
              }).fontColor(this.vm.mode === CollageMode.FIXED ? $r('sys.color.multi_color_09') :
              $r('sys.color.font_primary'));
            Text('海报模式')
              .onClick(() => {
                this.vm.setMode(CollageMode.POSTER);
                this.vm.selectPoster(this.vm.posterList[this.vm.posterIndex]);
              }).fontColor(this.vm.mode === CollageMode.POSTER ? $r('sys.color.multi_color_09') :
              $r('sys.color.font_primary'));
            Text('自由拼接')
              .onClick(() => {
                this.vm.setMode(CollageMode.FREE);
              }).fontColor(this.vm.mode === CollageMode.FREE ? $r('sys.color.multi_color_09') :
              $r('sys.color.font_primary'));
            Text('拼长图')
              .onClick(() => {
                this.vm.setMode(CollageMode.JOIN);
              }).fontColor(this.vm.mode === CollageMode.JOIN ? $r('sys.color.multi_color_09') :
              $r('sys.color.font_primary'));
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);

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
                          Image($r('app.media.vip_decorate'))
                            .size({ width: 12, height: 12 }).margin({ left: 2, top: 2 });
                        }
                      };
                    }
                    .onClick(() => {
                      let loginManageUtil = new LoginManageUtil(this.getUIContext());
                      if (!ri.item.isVip) {
                        this.vm.fixedIndex = ri.index;
                        this.vm.selectPoster(ri.item);
                      } else {
                        if (loginManageUtil.userInfoModel.isLogin && this.isMember) {
                          this.vm.fixedIndex = ri.index;
                          this.vm.selectPoster(ri.item);
                        } else {
                          if (!loginManageUtil.userInfoModel.isLogin) {
                            LoginSheetUtils.open(loginManageUtil.params, this.getUIContext());
                          } else if (!this.isMember) {
                            let memberManageUtil = new MemberManageUtil(this.getUIContext());
                            MemberSheetUtils.open(memberManageUtil.productsInfo, this.getUIContext());
                          }
                        }
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
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .constraintSize({ maxHeight: 80 })
          .alignItems(VerticalAlign.Center);
        }.padding(16);
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .height('100%');
    }.hideTitleBar(true).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}
