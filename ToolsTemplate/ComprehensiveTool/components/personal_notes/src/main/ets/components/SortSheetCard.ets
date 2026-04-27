import { ShowMethod, SortEnum } from '../commons/Enum';
import { NoteOperateType } from '../commons/Interface';
import { SortController } from '../controller/SortController';


@ComponentV2
export struct SortSheetCard {
  @Param title: string = '';
  @Param data: NoteOperateType[] = [];
  @Param type: string = ''
  @Param showListType: ShowMethod  = ShowMethod.normalList;
  @Event handleEvent: (type: ShowMethod | SortEnum) => void = (type: ShowMethod | SortEnum) => {}

  sortController: SortController = SortController.instance;

  build() {
    Column() {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({bottom: 16});

      List({ space: 24 }) {
        ForEach(this.data, (item: NoteOperateType) => {
          ListItem() {
            Row() {
              Text(item.name)
                .fontSize(16)
                .fontColor($r('sys.color.font_primary'))
              Blank();
              Radio({ value: item.type, group: this.type })
                .checked(this.sortController.sortBy === item.type || this.showListType === item.type)
                .onChange((isChecked: boolean) => {
                  if (isChecked === true) {
                    this.handleEvent && this.handleEvent(item.type)
                  }
                });
            }
            .width('100%')
            .padding({left: 12, right: 12 })
            .onClick(() => {
              this.handleEvent && this.handleEvent(item.type)
            });
          }
        }, (item: NoteOperateType) => JSON.stringify(item))
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(8)
      .padding({ top: 16, bottom: 16 })
      .divider({
        strokeWidth:1,
        startMargin:12,
        endMargin:12
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .padding({
      top: 20,
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
  }
}