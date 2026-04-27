import { DateConstants } from '../commons/Constant';
import { SelectedController } from '../controller/SelectedController';
import { Note } from '../models/Note'
import { DateUtil } from '../utils/DateUtil';


@ComponentV2
export struct NoteItemCard {
  @Param @Require item: Note
  @Param maxLines: number = 1
  @Event onClickAction: () => void = () => {}

  selectedController: SelectedController = SelectedController.instance;

  @Computed
  get noteItemCardBgColor() {
    if (this.selectedController.isCtrl) {
      return this.item.isSelected ? $r('sys.color.background_tertiary') : $r('sys.color.comp_background_list_card');
    }
    return $r('sys.color.comp_background_list_card');
  }

  // 选择的图标
  @Computed
  get selectedImage() {
    return this.item.isSelected ? $r('app.media.selected') : $r('app.media.unselected');
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column({ space: 12 }) {
        Text(this.item.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.item.description)
          .maxLines(this.maxLines)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(14)
          .lineHeight(19)
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)

        Text(DateUtil.getFormatDateStr(this.item.createTime, DateConstants.DATE_FORMAT4))
          .fontSize(12)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(this.noteItemCardBgColor)
      .borderRadius(16)
      .width('100%')
      .padding(12)

      if (this.selectedController.isCtrl) {
        Image(this.selectedImage)
          .width(35)
          .height(35)
          .padding({ top: 10, right: 10})
      }
    }
    .onClick(() => {
      this.onClickAction && this.onClickAction()
    });
  }
}