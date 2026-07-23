import { abilityAccessCtrl } from '@kit.AbilityKit';
import { WaterMark, Logger, BaseTitle, CustomFilter, CommonConstants } from 'commonlib';
import { LutCameraPageVM } from '../viewmodel/LutCameraPageVM';
import { OperateButton } from '../components/OperateButton';


@Builder
export function LutCameraPageBuilder() {
  LutCameraPage();
}


@ComponentV2
export struct LutCameraPage {
  vm: LutCameraPageVM = LutCameraPageVM.instance;
  private context: Context = this.getUIContext().getHostContext()!;

  aboutToAppear(): void {
    this.vm.uiContext = this.getUIContext();
    this.vm.context = this.context;
  }

  aboutToDisappear() {
    // 页面销毁时，需要重置对象
    LutCameraPageVM.instance = new LutCameraPageVM();
  }

  async requestPermissionsFn(): Promise<void> {
    if (this.context) {
      try {
        let atManager = abilityAccessCtrl.createAtManager();
        const permission = 'ohos.permission.CAMERA'
        let res = await atManager.requestPermissionsFromUser(this.context, [permission]);
        for (let i = 0; i < res.permissions.length; i++) {
          if (permission === res.permissions[i] && res.authResults[i] === 0) {
            this.vm.isShow = true;
          }
        }
      } catch (error) {
        Logger.error(`requestPermissionsFromUser failed. error: ${JSON.stringify(error)}`)
      }
    }
  }

  build() {
    NavDestination() {
      this.cameraHeader()

      Column() {
        Stack({ alignContent: Alignment.Bottom }) {
          Stack({ alignContent: Alignment.Bottom }) {
            if (this.vm.isShow) {
              Image(this.vm.pixelMap)
                .width(this.vm.preWidth)
                .height(this.vm.preHeight)
            }

            if (this.vm.isShowWatermark) {
              Row() {
                WaterMark()
              }
              .margin({ bottom: 168 })
              .id(this.vm.markId)
            }
          }
          .width(this.vm.preWidth)
          .height(this.vm.preHeight)

          // 操作
          this.operateBuilder()
        }
        .onSizeChange((_oldSize, newSize) => {
          this.vm.containerWidth = newSize.width as number;
          this.vm.containerHeight = newSize.height as number;
          this.vm.handlePreSize();
        })
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
      }
      .layoutWeight(1)
      .backgroundColor($r('sys.color.comp_foreground_primary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .hideTitleBar(true)
    .onWillShow(async () => {
      await this.requestPermissionsFn();
      await this.vm.initImageReceiver();
      this.vm.initCamera();
    })
    .onWillHide(() => {
      this.vm.releaseCamera();
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  @Builder
  cameraHeader() {
    Row() {
      BaseTitle({
        title: '相机',
        showBackBtn: true,
        titleFontSize: $r('sys.float.Title_S'),
        rightPartBuilder: () => {
          this.headerRightBuilder()
        },
      });
    }
    .width('100%')
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
    })
  }

  @Builder
  headerRightBuilder() {
    Button() {
      SymbolGlyph($r('sys.symbol.switch_camera'))
        .fontColor([$r('sys.color.font_primary')])
        .fontWeight(FontWeight.Normal)
        .fontSize(24)
    }
    .width(40)
    .height(40)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .onClick(() => {
      this.vm.changeCameraPosition();
    })
  }

  @Builder
  filterItemBuilder(ri: RepeatItem<CustomFilter>) {
    ListItem() {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.TopStart }) {
          Image(ri.item.image)
            .height(80)
            .width(60)
            .borderRadius(8);
        };

        Column() {
          Text('');
          if (this.vm.selectedFilterIndex === ri.index) {
            Image($r('app.media.ic_filter_checked')).size({ width: 24, height: 24 });
          }
          Text(ri.item.name)
            .fontSize(12)
            .fontColor($r('sys.color.font_on_primary'))
            .padding({ bottom: 8 });
        }.height(80).justifyContent(FlexAlign.SpaceBetween);
      }
      .border({
        width: this.vm.selectedFilterIndex === ri.index ? 1 : 0,
        color: $r('sys.color.icon_on_primary'),
        radius: 8,
      });
    }
    .onClick(() => {
      this.vm.selectedFilter(ri);
    });
  }

  @Builder
  operateBuilder() {
    Column() {
      if (this.vm.showFilterBar) {
        List({ space: 16 }) {
          Repeat(this.vm.filterList)
            .each((ri: RepeatItem<CustomFilter>) => {
              this.filterItemBuilder(ri);
            });
        }
        .scrollBar(BarState.Off)
        .height(80)
        .listDirection(Axis.Horizontal)
        .margin({ bottom: 16 });
      }

      Column({ space: 16 }) {
        Text('拍照').fontSize($r('sys.float.Subtitle_M')).fontColor($r('sys.color.font_on_primary')).lineHeight(21);
        Row() {
          OperateButton({
            symbol: $r('sys.symbol.line_below_seal'),
            text: '水印',
            isActive: this.vm.isShowWatermark,
            onTap: () => {
              this.vm.showFilterBar = false;
              this.vm.isShowWatermark = !this.vm.isShowWatermark;
            }
          });

          Image($r('app.media.ic_picture_camera'))
            .width(68)
            .height(68)
            .onClick(async () => {
              this.vm.capture();
            });

          OperateButton({
            symbol: $r('sys.symbol.camera_filters'),
            text: '滤镜',
            isActive: this.vm.showFilterBar,
            onTap: () => {
              this.vm.showFilterBar = !this.vm.showFilterBar;
            }
          });
        }
        .width('100%')
        .height(84)
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceAround)
      }.width('100%');
    }
  }
}