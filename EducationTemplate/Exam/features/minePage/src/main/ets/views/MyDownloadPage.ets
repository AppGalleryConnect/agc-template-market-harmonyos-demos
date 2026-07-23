import { UIDialog } from '@hw-agconnect/ui-dialog';
import {
  Logger,
  TopBar,
  BreakpointType,
  RouterMap,
  RouterModule,
  viewFile,
  viewPDF,
  viewWord
} from 'commonlib';
import { UserInfo } from 'login_info';
import { MineVM } from '../viewModel/MineVM';
import { AppStorageV2 } from '@kit.ArkUI';
import { DownloadInfo, DownloadModel, SubjectExercises, SUB_EXERCISES_DATA } from '../model/CollectionModel';

const TAG = 'MyDownloadPage';

@ComponentV2
export struct MyDownloadPage {
  @Local isSelectDelete: boolean = false;
  @Local swipeDelete: boolean = false;
  @Local isSelectAll: boolean = false;
  @Local selectCount: number = 0;
  // 获取用户信息
  private userInfo?: UserInfo = RouterModule.getNavParam({ url: RouterMap.MY_DOWNLOAD_PAGE });
  @Local downloadInfo: DownloadInfo = AppStorageV2.connect(DownloadInfo, () => new DownloadInfo())!;
  private subExercisesListData: SubjectExercises[] = SUB_EXERCISES_DATA;
  @Local downloadModels: DownloadModel[] = [];
  uiContext = this.getUIContext();
  mineVM: MineVM = MineVM.instance;

  aboutToAppear(): void {
    this.subExercisesListData.forEach((item: SubjectExercises) => {
      if(this.downloadInfo.downloadMaterials.includes(item.name)) {
        let historyModel: DownloadModel = new DownloadModel();
        historyModel.name = item.name;
        historyModel.imageSrc = item.imageSrc;
        historyModel.progress = item.progress;
        historyModel.total = item.total;
        historyModel.type = item.type;
        historyModel.url = item.url;
        historyModel.isDelete = false;
        this.downloadModels.push(historyModel);
      }
    });
  }

  aboutToDisappear(): void {
    Logger.info(TAG, 'aboutToDisappear');
  }

  build() {
    Column() {
      // 顶部`
      this.topBuilder();
      Column() {
        if (this.downloadModels.length > 0) {
          // 浏览列表
          this.browseListBuilder();
        } else {
          Text('当前暂无下载文件。')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.icon_secondary'))
            .height('100%');
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM]);
  }

  confirmDialog(confirmCallback: () => void) {
    UIDialog.open({
      title: `是否删除${this.selectCount || 1}条记录？`,
      contentOptions: {
        content: '将在同账号其他设备的数据中同步删除',
        contentFontSize: 14,
        contentFontWeight: 400,
        contentFontColor: 'rgba(0, 0, 0, 0.9)'
      },
      confirmButtonOptions: {
        button: '删除',
        buttonFontColor: 'rgba(232, 64, 38, 1)',
      },
      cancelButtonOptions: {
        button: '取消',
        buttonFontColor: 'rgba(0, 0, 0, 0.9)',
      },
      showConfirmButton: true,
      showCancelButton: true,
      onConfirm: confirmCallback
    })
  }

  // 移除所选中的
  deleteSelectData() {
    this.downloadModels = this.downloadModels.filter((it: DownloadModel) => it.isDelete === false);
    this.isSelectDelete = false;
  }

  // 是否全选
  isSelectAllClick() {
    if (!this.isSelectAll) {
      this.downloadModels.forEach((item: DownloadModel) => {
        item.isDelete = true;
      });
      this.isSelectAll = true;
      this.selectCount = this.downloadModels.length;
    } else {
      this.downloadModels.forEach((item: DownloadModel) => {
        item.isDelete = false;
      });
      this.isSelectAll = false;
      this.selectCount = 0;
    }
  }

  /**
   * 浏览列表
   */
  @Builder
  browseListBuilder() {
    List({ space: 8 }) {
      ForEach(this.downloadModels, ((item: DownloadModel, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Row() {
                Image(item.imageSrc)
                  .width(48)
                  .height(48)
                Text(item.name)
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Regular)
                  .fontFamily('HarmonyHeiTi')
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ left: 8 });
              };
              // 父组件 点击右上角删除按钮显示  否则不显示
              if (this.isSelectDelete) {
                Row() {
                  Image(item.isDelete ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
                    .width($r('app.float.vp_20'))
                    .height($r('app.float.vp_20'));
                }
                .height($r('app.float.vp_24'))
                .onClick(() => {
                  item.isDelete = !item.isDelete;
                  if (item.isDelete) {
                    this.selectCount++;
                  } else {
                    this.selectCount--;
                  }
                  if (this.selectCount < this.downloadModels.length) {
                    this.isSelectAll = false;
                  } else {
                    this.isSelectAll = true;
                  }
                });
              }
            }
            .padding({ top: $r('app.float.vp_4') })
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%');

            Row() {
              Text('已有423人浏览')
                .fontWeight(FontWeight.Regular)
                .fontSize($r('sys.float.Body_S'))
                .fontColor('rgba(0, 0, 0, 0.4)')
                .padding({ left: $r('app.float.vp_6'), top: $r('app.float.vp_6') })

              Text('下载23次')
                .fontWeight(FontWeight.Regular)
                .fontSize($r('sys.float.Body_S'))
                .fontColor('rgba(0, 0, 0, 0.4)')
                .padding({ left: $r('app.float.vp_6'), top: $r('app.float.vp_6') })
            }
            .width('100%')
          }
          .width('100%')
          .padding($r('app.float.vp_12'))
          .borderRadius($r('app.float.vp_16'))
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .onClick(() => {
            if (!this.isSelectDelete) {
              // 预览
              if (item.type === 'pdf') {
                viewPDF(this.uiContext, item.name);
              } else if (item.type === 'zip') {
                viewFile('test.zip', '', this.uiContext);
              } else if (item.type === 'word') {
                viewWord(this.uiContext, item.name)
              }
            }
          });
        }
        .clip(true)
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.itemEnd(item, index);
            },
            actionAreaDistance: 26,
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.isSelectAll = false;
                this.selectCount = 0;
                this.isSelectDelete = false;
                this.swipeDelete = true;
                this.downloadModels.forEach((item: DownloadModel) => {
                  item.isDelete = false;
                });
              } else if (state === SwipeActionState.COLLAPSED) {
                this.swipeDelete = false;
              }
            },
          }
        });
      }), (item: DownloadModel, index: number) => item.name + index);
    }
    .width('100%')
    .height('auto')
    .scrollBar(BarState.Off)
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_20'),
      bottom: $r('app.float.vp_46')
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .lanes(new BreakpointType<number>({
      sm: 1,
      md: 2,
      lg: 3,
      xl: 3
    }).getValue(this.mineVM.breakPointModel.currentBreakpoint), 12);
  }

  @Builder
  itemEnd(_item: DownloadModel, index: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .height($r('app.float.vp_40'))
        .width($r('app.float.vp_40'))
        .margin({ left: $r('app.float.vp_12') })
        .onClick(() => {
          this.confirmDialog(() => {
            this.downloadModels.splice(index, 1);
            this.swipeDelete = false;
          })
        });
    }.padding($r('app.float.vp_4')).justifyContent(FlexAlign.SpaceEvenly);
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      // 我的下载
      TopBar({
        onClickBack: () => {
          RouterModule.pop();
        },
        title: '我的下载'
      });
      Row() {
        Image($r('app.media.ic_public_trash'))
          .height($r('app.float.vp_40'))
          .width($r('app.float.vp_40'))
          .opacity(this.downloadModels.length === 0 || this.swipeDelete || !this.selectCount ? 0.4 : 1)
          .margin({ left: $r('app.float.vp_8') })
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            if (this.selectCount > 0) {
              // 删除选中
              this.confirmDialog(() => {
                this.deleteSelectData()
              })
            }
          })

        Image($r('app.media.ic_edit'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .visibility(this.isSelectDelete ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            if (!this.swipeDelete && this.downloadModels.length > 0) {
              this.isSelectDelete = !this.isSelectDelete;
              if (!this.isSelectDelete) {
                this.selectCount = 0;
                this.isSelectAll = false;
                this.downloadModels.forEach((item: DownloadModel) => {
                  item.isDelete = false;
                });
              }
            }
          });

        Image(this.isSelectAll ? $r('app.media.icon_select_all') : $r('app.media.icon_select_all_off'))
          .height($r('app.float.vp_40'))
          .width($r('app.float.vp_40'))
          .onClick(() => {
            this.isSelectAllClick();
          })
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.None);
      }
      .onClick(() => {
      });
    }
    .width('100%')
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), top: $r('app.float.vp_10') })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM]);
  }
}

@Builder
export function MyDownloadPageBuilder() {
  MyDownloadPage();
}



