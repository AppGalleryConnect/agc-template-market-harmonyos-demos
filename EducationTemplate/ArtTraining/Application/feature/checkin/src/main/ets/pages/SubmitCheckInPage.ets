import { PickerPreviewItem, PickerResourceType, PickerUtil } from 'commonlib';
import { CommonButton, CommonHeader, ContainerColumn } from 'componentlib';
import { SubmitCheckInVM } from '../viewmodels/SubmitCheckInVM';

@Builder
export function submitCheckInPageBuilder() {
  SubmitCheckInPage();
}

@ComponentV2
export struct SubmitCheckInPage {
  vm: SubmitCheckInVM = SubmitCheckInVM.instance;

  build() {
    NavDestination() {
      CommonHeader({ title: '提交打卡' });
      Column() {
        // 打卡信息
        this.taskDetailBuilder();
        // 打卡内容
        this.checkInInputBuilder();
      }
      .backgroundColor($r('app.color.system_color_background_auxiliary'))
      .padding($r('app.string.padding_l'))
      .layoutWeight(1)
      .width($r('app.string.width_percent_full'));

      this.bottomButtonBuilder();
    }
    .hideTitleBar(true)
    .onReady(() => {
      this.vm.initRecord();
    })
    .onBackPressed(() => {
      this.vm.clearData();
      return false;
    });
  }

  @Builder
  taskDetailBuilder() {
    ContainerColumn({
      title: '任务详情',
    }) {
      if (this.vm.taskItem) {
        Text(this.vm.taskItem.taskName)
          .fontColor($r('app.color.font_color_level1'))
          .fontSize($r('app.string.font_size_12'))
          .margin({ bottom: $r('app.string.margin_xs') })
          .fontWeight(FontWeight.Medium);
        Text(this.vm.taskItem.taskDetail).cardContentStyle();
      }
      if (this.vm.activity) {
        Text(this.vm.activity.summary).cardContentStyle();
        if (this.vm.activity.requirement.textSwitch) {
          Text(`文字要求: 不少于${this.vm.activity.requirement.textMinLimit}字`).cardContentStyle();
        }
        if (this.vm.activity.requirement.pictureSwitch) {
          Text(`图片要求: 不少于${this.vm.activity.requirement.pictureMinLimit}张`).cardContentStyle();
        }
        if (this.vm.activity.requirement.videoSwitch) {
          Text('视频要求: 至少上传1个打卡视频').cardContentStyle();
        }
        if (this.vm.activity.requirement.audioSwitch) {
          Text('音频要求: 至少上传1个打卡音频').cardContentStyle();
        }
      }
    };
  }

  @Builder
  checkInInputBuilder() {
    ContainerColumn() {
      TextArea({
        placeholder: '请输入打卡内容',
        text: this.vm.checkInData.textDetail,
      })
        .placeholderFont({ size: $r('app.string.font_size_14') })
        .placeholderColor($r('app.color.font_color_level3'))
        .height(150)
        .maxLength(200)
        .borderRadius($r('app.string.border_radius_8'))
        .showCounter(true)
        .fontSize($r('app.string.font_size_14'))
        .fontColor($r('app.color.font_color_level1'))
        .backgroundColor($r('app.color.system_color_background_grey_level2'))
        .onChange((value: string) => {
          this.vm.checkInData.textDetail = value;
        });
      Row() {
        this.filePickButtonBuilder($r('app.media.ic_camera'), PickerResourceType.IMAGE);
        this.filePickButtonBuilder($r('app.media.ic_video'), PickerResourceType.VIDEO);

      }
      .width($r('app.string.width_percent_full'))
      .justifyContent(FlexAlign.SpaceAround)
      .margin({
        top: $r('app.string.margin_xl'),
        bottom: $r('app.string.margin_xs'),
      });

      if (PickerUtil.mediaPreviewList.length) {
        this.mediaPreviewBuilder();
      }
    };

  }

  @Builder
  bottomButtonBuilder() {
    Row() {
      CommonButton({
        title: '提交打卡',
        handleClick: () => {
          this.vm.submitRecord();
        },
      });
    }
    .padding($r('app.string.padding_s'));
  }

  @Builder
  filePickButtonBuilder(src: ResourceStr, type: PickerResourceType) {
    Image(src)
      .width($r('app.integer.icon_size_24'))
      .height($r('app.integer.icon_size_24'))
      .onClick(() => {
        PickerUtil.selectResource(type);
      });
  }

  @Builder
  mediaPreviewBuilder() {
    Grid() {
      ForEach(PickerUtil.mediaPreviewList, (item: PickerPreviewItem, index: number) => {
        GridItem() {
          this.mediaItemBuilder(item, index);
        }
        .width(96)
        .height(96)
        .onClick(() => {
          this.vm.jumpToFullScreenPage(item.type, item.uri);
        });
      }, (item: PickerPreviewItem, index: number) => index + JSON.stringify(item.uri));
    }
    .columnsTemplate('1fr 1fr 1fr')
    .columnsGap(8)
    .rowsGap(8)
    .margin({ top: $r('app.string.margin_m') })
    .height(this.vm.previewGridHeight);
  }

  @Builder
  mediaItemBuilder(item: PickerPreviewItem, index: number) {
    Row() {
      Image($r('app.media.ic_delete_circle'))
        .width(16)
        .height(16)
        .zIndex(9)
        .position({ right: 8, top: 8 })
        .onClick(() => {
          PickerUtil.deleteItem(index);
        });

      if (item.type === PickerResourceType.IMAGE) {
        Image(item.uri);
      } else {
        Stack({ alignContent: Alignment.Center }) {
          Image(item.type === PickerResourceType.VIDEO ?
          $r('app.media.ic_record_video') :
          $r('app.media.ic_record_audio'))
            .width($r('app.integer.icon_size_24'));
        }
        .width($r('app.string.width_percent_full'))
        .height($r('app.string.height_percent_full'))
        .backgroundColor($r('app.color.system_color_background_grey_level1'));
      }
    }
    .width(96)
    .height(96)
    .borderRadius($r('app.string.border_radius_16'))
    .clip(true);
  }
}


@Extend(Text)
function cardContentStyle() {
  .fontSize($r('app.string.font_size_12'))
  .margin({ bottom: $r('app.string.margin_xs') })
  .fontColor($r('app.color.font_color_level2'));
}