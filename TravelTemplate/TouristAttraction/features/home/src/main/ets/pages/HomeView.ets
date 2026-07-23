import { AppStorageV2 } from '@kit.ArkUI';
import { AttractionLive } from 'attraction_live';
import { AppBaseModel, BreakpointModel, Constant } from 'common';
import { ImagePreview, ImagePreviewOptions } from 'image_preview';
import { FullLoadingComponent } from 'uicomponents';
import { FunctionModuleData, getFunctionModuleInfo } from '../model/FunctionModuleInfo';
import { getHotAreaInfo, HotAreaInfo } from '../model/HotAreaInfo';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function HomeBuilder() {
  HomeView();
}

@Extend(Row)
function realTimeRow() {
  .justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);
}

@ComponentV2
export struct HomeView {
  vm: HomePageVM = HomePageVM.instance;
  @Local isShow: boolean = false;
  @Local appBaseModel: AppBaseModel = AppStorageV2.connect(AppBaseModel, () => new AppBaseModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Consumer('homeTabIndex') homeTabIndex: number = 0;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  options: ImagePreviewOptions = new ImagePreviewOptions();

  @Builder
  FunctionModuleBuilder() {
    Row() {
      ForEach(getFunctionModuleInfo(this.mainPathStack, (index: number) => {
        this.appBaseModel.mainTabIndex = index;
      }), (item: FunctionModuleData) => {
        Column() {
          Image(item.icon).size({ width: 48, height: 48 });
          Text(item.title).fontSize(12).fontColor($r('sys.color.font_primary')).margin({ top: 4 });
        }.layoutWeight(1).onClick(item.click);
      }, (item: FunctionModuleData) => JSON.stringify(item));
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(Constant.FULL_PERCENT)
    .backgroundColor($r('sys.color.font_on_primary'))
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16,
    })
    .borderRadius(16);
  }

  @Builder
  HotInfoBuilder(itemName: string, component: WrappedBuilder<[]>, routeEvent: (event: ClickEvent) => void) {
    Column() {
      Row() {
        Text(itemName)
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_primary'));
        Row({ space: 4 }) {
          Text('更多').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'));
          Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
        }.onClick(routeEvent);
      }.realTimeRow().margin({ bottom: 8 });

      component.builder();
    }.margin({ top: 24 });
  }

  @Builder
  ScenicInfoBuilder() {
    Row({ space: 8 }) { // 展示首条
      Text(`${this.vm.bulletinList.getData(0)?.title ?? '查看公告'}`)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('90%');
      Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
    }
    .onClick(() => {
      this.mainPathStack.pushPathByName('Bulletins', null, false);
    })
    .padding(12)
    .backgroundColor($r('sys.color.font_on_primary'))
    .borderRadius(16)
    .margin({ bottom: 12 })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  aboutToAppear(): void {
    this.vm.getBulletinList();
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.vm.isLoading) {
        FullLoadingComponent();
      } else {
        List({ scroller: this.vm.scroller }) {
          ListItem() {
            Swiper() {
              LazyForEach(this.vm.scenicImages, (item: ResourceStr, index: number) => {
                Image(item)
                  .size({ width: '100%', height: this.vm.breakPointModel.isLargeScreen ? 279 : 316 })
                  .borderRadius(this.vm.breakPointModel.isLargeScreen ? 16 : 0)
                  .id(this.options.snapshotId(item, index))
                  .onClick(() => {
                    this.options
                      .setImageList(this.vm.resources)
                      .setInitIndex(index);
                    ImagePreview.open(this.getUIContext(), this.options);
                  });
              }, (item: string) => item);
            }
            .margin({ left: this.vm.breakPointModel.isLargeScreen ? 36 : 0 })
            .itemSpace(16)
            .displayCount(this.vm.breakPointModel.isLargeScreen ? 2 : 1)
            .nextMargin(this.vm.breakPointModel.isLargeScreen ? 128 : 0)
            .indicator(this.vm.breakPointModel.isLargeScreen ? false :
              new DotIndicator().selectedColor($r('sys.color.multi_color_04')),
            )
            .gesture(
              LongPressGesture({ repeat: true, duration: 400 })
                .onAction((event: GestureEvent) => {
                  return true;
                })
                .onActionEnd((event: GestureEvent) => {
                }),
            );
          };

          ListItem() {
            Column() {
              this.ScenicInfoBuilder();
              this.FunctionModuleBuilder();

              AttractionLive({ attractionLiveInfo: this.vm.attractionLiveInfo });
              ForEach(getHotAreaInfo(this.mainPathStack), (item: HotAreaInfo) => {
                this.HotInfoBuilder(item.itemTitle, item.component, item.routeEvent);
              }, (item: HotAreaInfo) => JSON.stringify(item.itemTitle));
            }
            .padding({
              top: 12,
              bottom: 12,
              left: this.breakPointModel.pagePadding,
              right: this.breakPointModel.pagePadding,
            });
          };
        }
        .padding({ top: this.vm.breakPointModel.isLargeScreen ? 56 + 8 + this.vm.windowBottomHeight : 0 })
        .backgroundColor($r('sys.color.background_secondary'))
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .contentEndOffset(this.vm.isTabVertical ? this.vm.windowBottomHeight :
          Constant.BOTTOM_TAB_BAR_HEIGHT + this.vm.windowBottomHeight)
        .onDidScroll(() => {
          const offset = this.vm.scroller.currentOffset();
          this.vm.scrollOffset = offset.yOffset;
        });
      }

      Column() {
        Row().height(this.vm.windowTopHeight);
        Row() {
          Text('首页').fontSize(26).fontWeight(700);
        }
        .width('100%')
        .height(56)
        .padding({ left: this.breakPointModel.pagePadding });
      }.width('100%').backgroundColor(this.vm.getTitleBarBgColor()).backdropBlur(this.vm.getTitleBarBackDropBar());
    };
  }
}