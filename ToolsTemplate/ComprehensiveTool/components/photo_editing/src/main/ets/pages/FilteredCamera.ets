import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { LoginManageUtil, MemberManageUtil, UPDATE_MEMBER_STATUS } from 'module_base';
import { LoginSheetUtils } from 'aggregated_login';
import { MemberSheetUtils } from 'membership';
import { CustomFilter } from '../model/CustomFilter';
import { CameraVM } from '../viewmodel/CameraVM';
import { getInstance } from '../util/RouteModule';

@Builder
export function FilteredCameraBuilder() {
  FilteredCamera();
}

@ComponentV2
export struct FilteredCamera {
  @Local showFilterBar: boolean = false;
  @Local isShow: boolean = false;
  private uiContext: UIContext = this.getUIContext();
  @Local context: Context | undefined = this.uiContext.getHostContext();
  private cameraPermission: Permissions = 'ohos.permission.CAMERA';
  cameraVM: CameraVM = CameraVM.instance;

  async aboutToAppear(): Promise<void> {
    this.cameraVM.isMember = await MemberManageUtil.queryMemberStatus(this.getUIContext());
    this.getUIContext().getHostContext()!.eventHub.on(UPDATE_MEMBER_STATUS, (status: boolean) => {
      this.cameraVM.isMember = status;
    });
  }

  aboutToDisappear(): void {
    this.getUIContext().getHostContext()!.eventHub.off(UPDATE_MEMBER_STATUS)
  }

  handleFilterClick(ri: RepeatItem<CustomFilter>) {
    let loginManageUtil = new LoginManageUtil(this.getUIContext());
    if (!ri.item.isVip) {
      this.cameraVM.selectedFilterIndex = ri.index;
      this.cameraVM.setFilter(ri.index);
    } else {
      if (loginManageUtil.userInfoModel.isLogin && this.cameraVM.isMember) {
        this.cameraVM.selectedFilterIndex = ri.index;
        this.cameraVM.setFilter(ri.index);
      } else {
        if (!loginManageUtil.userInfoModel.isLogin) {
          LoginSheetUtils.open(loginManageUtil.params, this.getUIContext());
        } else if (!this.cameraVM.isMember) {
          let memberManageUtil = new MemberManageUtil(this.getUIContext());
          MemberSheetUtils.open(memberManageUtil.productsInfo, this.getUIContext());
        }
      }
    }
  }

  async requestPermissionsFn(): Promise<void> {
    let atManager = abilityAccessCtrl.createAtManager();
    if (this.context) {
      let res = await atManager.requestPermissionsFromUser(this.context, [this.cameraPermission]);
      for (let i = 0; i < res.permissions.length; i++) {
        if (this.cameraPermission.toString() === res.permissions[i] && res.authResults[i] === 0) {
          this.isShow = true;
        }
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isShow) {
          Stack() {
            if (!this.cameraVM.isBusy) {
              Image(this.cameraVM.pixelMap)
                .width('100%')
                .height('100%')
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
            }

            Column() {
              Row() {
                Image($r('app.media.chevron_left_light')).size({ width: 40, height: 40 }).onClick(() => {
                  getInstance().pop();
                });

                Image($r('app.media.ic_switch_camera'))
                  .height(24)
                  .width(24)
                  .onClick(() => {
                    this.cameraVM.changeCameraPosition();
                  });
              }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 16, right: 16 });

              Column() {
                if (this.showFilterBar) {
                  List({ space: 16 }) {
                    Repeat(this.cameraVM.filters)
                      .each((ri: RepeatItem<CustomFilter>) => {
                        ListItem() {
                          Stack({ alignContent: Alignment.Bottom }) {
                            Stack({ alignContent: Alignment.TopStart }) {
                              Image(ri.item.image)
                                .height(80)
                                .width(60)
                                .borderRadius(8);

                              if (ri.item.isVip) {
                                Image($r('app.media.vip_decorate'))
                                  .size({ width: 12, height: 12 }).margin({ left: 2, top: 2 });
                              }
                            };

                            Column() {
                              Text('');
                              if (this.cameraVM.selectedFilterIndex === ri.index) {
                                Image($r('app.media.ic_filter_checked')).size({ width: 24, height: 24 });
                              }
                              Text(ri.item.name)
                                .fontSize(12)
                                .fontColor($r('sys.color.font_on_primary'))
                                .padding({ bottom: 8 });
                            }.height(80).justifyContent(FlexAlign.SpaceBetween);
                          }
                          .border({
                            width: this.cameraVM.selectedFilterIndex === ri.index ? 1 : 0,
                            color: $r('sys.color.icon_on_primary'),
                            radius: 8,
                          });
                        }
                        .onClick(() => {
                          this.handleFilterClick(ri);
                        });
                      });
                  }
                  .scrollBar(BarState.Off)
                  .height(80)
                  .listDirection(Axis.Horizontal)
                  .margin({ bottom: 16 });
                }

                Row({ space: 60 }) {
                  Text('');

                  Image($r('app.media.ic_take_camera'))
                    .height(80)
                    .width(80)
                    .onClick(() => {
                      this.showFilterBar = false;
                      this.cameraVM.capture();
                    });

                  Image(this.showFilterBar ? $r('app.media.ic_camera_filters_active') :
                    $r('app.media.ic_camera_filters'))
                    .height(24)
                    .width(24)
                    .onClick(() => {
                      this.showFilterBar = !this.showFilterBar;
                    });
                }
                .padding({ bottom: 16 })
                .width('100%')
                .justifyContent(FlexAlign.Center);
              };
            }.height('100%').justifyContent(FlexAlign.SpaceBetween);
          };
        }
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('sys.color.comp_foreground_primary'))
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }
    .hideTitleBar(true)
    .onWillShow(async () => {
      UtilLog.error(`申请权限失败`);
      this.cameraVM.context = this.context;
      await this.requestPermissionsFn();
      await this.cameraVM.initImageReceiver();
      this.cameraVM.initCamera();
    })
    .onWillHide(() => {
      this.cameraVM.releaseCamera();
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}
