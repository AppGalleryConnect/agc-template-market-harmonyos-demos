import { PersistenceV2 } from '@kit.ArkUI';
import { LoginSheetUtils } from 'aggregated_login';
import { MemberSheetUtils } from 'membership';
import { LoginManageUtil, MemberManageUtil, MemberStatus, UPDATE_MEMBER_STATUS } from 'module_base';
import { PHOTO_FRAMES } from '../constant/PhotoFrameData';
import { PhotoFrameModel } from '../model/PhotoFrameModel';
import { getInstance } from '../util/RouteModule';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';
import PhotoFrameVM from '../model/Index';

@Builder
export function PhotoFramePageBuilder() {
  PhotoFramePage();
}

@ComponentV2
export struct PhotoFramePage {
  @Local uri: string = '';
  @Local vm: PhotoFrameVM = new PhotoFrameVM();
  @Local isMember: boolean = false;
  @Local frameIndex: number = 0;
  @Local dispW: Array<number> = new Array<number>(PHOTO_FRAMES.length).fill(1200);
  @Local dispH: Array<number> = new Array<number>(PHOTO_FRAMES.length).fill(1600);
  @Local dragStartX: number = 0;
  @Local dragStartY: number = 0;
  @Local scaleStart: number = 0;
  @Local rotateStart: number = 0;
  @Local itemX: number = 0;
  @Local itemY: number = 0;
  @Local itemScale: number = 1;
  @Local itemRotate: number = 0;

  async aboutToAppear(): Promise<void> {
    this.isMember = await MemberManageUtil.queryMemberStatus(this.getUIContext());
    this.getUIContext().getHostContext()!.eventHub.on(UPDATE_MEMBER_STATUS, (status: boolean) => {
      this.isMember = status;
    });
  }

  aboutToDisappear(): void {
    this.getUIContext().getHostContext()!.eventHub.off(UPDATE_MEMBER_STATUS);
  }

  handleFrameClick(frame: RepeatItem<PhotoFrameModel>) {
    let loginManageUtil = new LoginManageUtil(this.getUIContext());
    if (!frame.item.isVip) {
      this.frameIndex = frame.index;
      this.vm.selectFrame(frame.item);
    } else {
      if (loginManageUtil.userInfoModel.isLogin && this.isMember) {
        this.frameIndex = frame.index;
        this.vm.selectFrame(frame.item);
      } else {
        if (!loginManageUtil.userInfoModel.isLogin) {
          LoginSheetUtils.open(loginManageUtil.params, this.getUIContext());
        } else if (!this.isMember) {
          let memberManageUtil = new MemberManageUtil(this.getUIContext());
          MemberSheetUtils.open(memberManageUtil.productsInfo, this.getUIContext());
        }
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.chevron_left'))
            .height(40)
            .width(40)
            .onClick(() => {
              getInstance().pop();
            });

          SaveButton({ text: SaveDescription.SAVE }).onClick(() => {
            ImageProcessingUtil.saveToAlbum('photoFrame', this.getUIContext(), 'image/png');
          });
        }
        .width('90%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ bottom: 30 });

        Stack() {
          Stack() {
            Image(this.uri)
              .scale({ x: this.itemScale, y: this.itemScale })
              .rotate({ angle: this.itemRotate })
              .height('100%')
              .objectFit(ImageFit.Contain)
              .gesture(
                GestureGroup(GestureMode.Parallel,
                  PinchGesture()
                    .onActionStart((e: GestureEvent) => {
                      this.scaleStart = this.itemScale;
                    })
                    .onActionUpdate((event: GestureEvent) => {
                      this.itemScale = this.scaleStart * event.scale;
                    })
                    .onActionEnd(() => {
                    }),
                  RotationGesture()
                    .onActionStart((event: GestureEvent | undefined) => {
                      this.rotateStart = this.itemRotate;
                    })
                    // 当旋转手势生效时，通过旋转手势的回调函数获取旋转角度，从而修改组件的旋转角度
                    .onActionUpdate((event: GestureEvent | undefined) => {
                      if (event) {
                        this.itemRotate = this.rotateStart + event.angle;
                      }
                    })
                    // 当旋转结束抬手时，固定组件在旋转结束时的角度
                    .onActionEnd(() => {
                    }),
                ),
              );
          }
          .position({ x: this.itemX, y: this.itemY })
          .gesture(
            GestureGroup(GestureMode.Parallel,
              PanGesture()
                .onActionStart((e: GestureEvent) => {
                  this.dragStartX = this.itemX;
                  this.dragStartY = this.itemY;
                })
                .onActionUpdate((event: GestureEvent) => {
                  if (event) {
                    if (this.dragStartX + event.offsetX * this.itemScale) {
                      this.itemX = this.dragStartX + event.offsetX * this.itemScale;
                    }
                    this.itemY = this.dragStartY + event.offsetY * this.itemScale;
                  }
                }),
            ),
          );

          Image(this.vm.photoFrame.background)
            .objectFit(ImageFit.Contain)
            .onComplete((e) => {
              if (e?.loadingStatus === 1) {
                this.dispW[this.frameIndex] = e.contentWidth;
                this.dispH[this.frameIndex] = e.contentHeight;
              }
            })
            .hitTestBehavior(HitTestMode.Transparent);
        }
        .height('calc(100% - 200vp)')
        .width(this.dispW[this.frameIndex] + 'px')
        .id('photoFrame')
        .clip(true);

        Blank()
          .layoutWeight(1);

        Row() {
          List() {
            Repeat(PHOTO_FRAMES)
              .each((frame: RepeatItem<PhotoFrameModel>) => {
                ListItem() {
                  Stack() {
                    Stack({ alignContent: Alignment.TopStart }) {
                      Image(frame.item.image)
                        .height(100)
                        .objectFit(ImageFit.Contain)
                        .borderRadius(5);

                      if (frame.item.isVip) {
                        Image($r('app.media.vip_decorate'))
                          .size({ width: 12, height: 12 }).margin({ left: 2, top: 2 });
                      }
                    };

                    if (this.frameIndex === frame.index) {
                      Image($r('app.media.bc_bg_photo_frame_selected'))
                        .height(100)
                        .objectFit(ImageFit.Contain)
                        .borderRadius(5);
                    }
                  };
                }
                .padding({ left: 5, right: 5 })
                .onClick(() => {
                  this.handleFrameClick(frame);
                });
              });
          }
          .scrollBar(BarState.Off)
          .height(120)
          .alignListItem(ListItemAlign.Center)
          .listDirection(Axis.Horizontal);
        };
      };
    }
    .hideTitleBar(true).onReady((ctx) => {
      this.uri = ctx.pathInfo.param as string;
    });
  }
}