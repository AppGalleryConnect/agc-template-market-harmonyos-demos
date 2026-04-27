import { Constants, GlobalContext, RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { PhotoUtils } from '../utils/PhotoUtils';
import { DrawingHistoryItem } from '../viewmodel/DrawingHistoryVM';
import { DrawingBoardBuilder } from '../views/DrawingBoardPage';
import { baseToast } from './ConfirmDialog';


@ComponentV2
export struct DrawingItem {
  @Local drawingName: string = ''
  @Param @Require drawing: DrawingHistoryItem
  @Param @Require mangerMode: boolean = false
  @Param @Require idLists: string[] = []
  @Event deleteItem: (id: string) => void = (id: string) => {
  }
  @Event editItem: (id: string) => void = (id: string) => {
  }

  private updateName(history: DrawingHistoryItem, id: string) {
    this.drawing.drawingName = history.drawingName;
    baseToast.show({
      type: 'dialog',
      hasTitle: $r('app.string.update_name'),
      cancelColor: $r('sys.color.icon_secondary'),
      confirmColor: $r('app.color.theme_color'),
      messageBuilder: () => {
        this.updateTitle();
      },
      confirmAction: async () => {
        this.drawing.drawingName = this.drawingName
        baseToast.hide();
        GlobalContext.getUIContext().getPromptAction().showToast({ message: '保存成功' })
      },
      cancelAction: () => {
        baseToast.hide();
      },
    });
  }

  build() {
    ListItem() {

      Flex({ direction: FlexDirection.Row }) {
        if (this.mangerMode) {
          Column() {
            Image(this.idLists.includes(this.drawing.id) ? $r('app.media.icon_selected_active') :
              $r('app.media.icon_selected'))
              .objectFit(ImageFit.Cover)
              .width(26)
              .height(26)
              .onClick(() => {
                this.editItem(this.drawing.id)
              })
          }
          .height(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.Center)
          .margin({ right: 12 })
        }
        Row() {
          Image(this.drawing.drawingBoardPath)
            .width(86)
            .height(86)
            .border({ width: 0.2, color: '#48000000', radius: $r('sys.float.corner_radius_level4') });

          this.drawingInfoBuilder()

          Column() {
            Image($r('app.media.ic_edit'))
              .width(16)
              .height(16)
              .onClick(() => {
                this.updateName(this.drawing, this.drawing.id);
              });
          }
          .height(86)
          .justifyContent(FlexAlign.Start);
        }
        .backgroundColor(Color.White)
        .padding(12)
        .width(Constants.FULL_SIZE)
        .borderRadius($r('sys.float.corner_radius_level8'))
        .flexShrink(1)
      }
    }
    .width(Constants.FULL_SIZE)
    .height(110)
    .margin({ top: 12 })
    .swipeAction({
      end: {
        builder: () => {
          if (!this.mangerMode) {
            this.deleteBuilder()
          }
        },
        onAction: () => {
        }
      },
      edgeEffect: SwipeEdgeEffect.None
    })
  }

  @Builder
  drawingInfoBuilder() {
    Column() {
      Column() {
        Text(this.drawing.drawingName)
          .width(Constants.FULL_SIZE)
          .textAlign(TextAlign.Start)
          .height($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize($r('sys.float.Body_L'));
        Text(this.drawing.lastEditTime)
          .margin({ top: 8, bottom: 8 })
          .width(Constants.FULL_SIZE)
          .textAlign(TextAlign.Start)
          .fontSize($r('sys.float.Body_S'))
          .lineHeight($r('sys.float.Body_S'))
          .fontColor($r('sys.color.icon_secondary'));
      };

      Row() {
        Button($r('app.string.continue_editing'))
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('app.color.theme_color'))
          .backgroundColor(Color.White)
          .border({ width: 1, color: $r('app.color.theme_color'), radius: 15 })
          .height(24)
          .margin({ right: 8 })
          .onClick(() => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.DRAWING_BOARD,
              builder: wrapBuilder(DrawingBoardBuilder),
              param: this.drawing
            });
          });
        SaveButton({
          text: SaveDescription.SAVE_TO_GALLERY,
          buttonType: ButtonType.Capsule
        })
          .fontSize($r('sys.float.Body_S'))
          .height(24)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.theme_color'))
          .onClick(async (event, result: SaveButtonOnClickResult) => {
            if (result === SaveButtonOnClickResult.SUCCESS) {
              PhotoUtils.saveImageToAlbum(this.drawing.drawingBoardPath);
            }
          });
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.Start);
    }
    .layoutWeight(1)
    .height(86)
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ left: 8, right: 20 })
  }

  @Builder
  deleteBuilder() {
    Column() {
      Text($r('app.string.delete'))
        .fontColor(Color.White)
        .fontSize($r('sys.float.Body_L'))
    }
    .backgroundColor('#E6E52424')
    .width('30%')
    .height(Constants.FULL_SIZE)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .borderRadius({
      topRight: $r('sys.float.corner_radius_level8'),
      bottomRight: $r('sys.float.corner_radius_level8')
    })
    .onClick(() => {
      baseToast.show({
        type: 'dialog',
        cancelColor: $r('sys.color.icon_secondary'),
        confirmColor: $r('app.color.theme_color'),
        message: $r('app.string.confirm_delete_picture_book'),
        confirmAction: () => {
          this.deleteItem(this.drawing.id)
          baseToast.hide()
        },
      })
    })
  }

  @Builder
  updateTitle() {
    Column() {
      TextInput({
        text: this.drawing.drawingName,
        placeholder: $r('app.string.input_new_placeholder_name'),
      })
        .fontSize($r('sys.float.Body_M'))
        .onChange((value) => {
          this.drawingName = value;
        })
        .width(Constants.FULL_SIZE)
        .height($r('app.float.vp_40'))
        .borderRadius($r('sys.float.corner_radius_level10'))
    }
    .width(Constants.FULL_SIZE)
  }
}