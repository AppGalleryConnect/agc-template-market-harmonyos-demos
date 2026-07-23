import { AppStorageV2 } from '@kit.ArkUI';
import {
  BreakpointModel,
  BreakpointNameEnum,
  BreakpointType,
  Constant,
  GridRowColSetting,
  LazyDataSource,
} from 'common';
import { NoteInfo } from 'types';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function HotNotesBuilder() {
  HotNotes();
}

@ComponentV2
export struct HotNotes {
  vm: HomePageVM = HomePageVM.instance;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      this.NoteWaterFlowBuilder(this.vm.noteList);
    };
  }

  @Builder
  NoteCardBuilder(note: NoteInfo) {
    Stack() {
      Column() {
        Image(note.banner).width('100%').aspectRatio(1);
        Column({ space: 8 }) {
          Text(note.name)
            .maxLines(2)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'));
          Row() {
            Text(note.location).fontColor($r('sys.color.font_secondary')).fontSize($r('sys.float.Body_S'));
            Row({ space: 4 }) {
              SymbolGlyph($r('sys.symbol.hand_thumbsup'))
                .width(16)
                .height(16)
                .fontColor([$r('sys.color.icon_tertiary')]);
              Text(`${note.thumbsup}`).fontColor($r('sys.color.font_tertiary')).fontSize($r('sys.float.Caption_M'));
            };
          }.width('100%').justifyContent(FlexAlign.SpaceBetween);
        }.alignItems(HorizontalAlign.Start).padding(8);

      }
      .width('100%')
      .clip(true)
      .backgroundColor($r('sys.color.font_on_primary'))
      .borderRadius(8)
      .onClick(() => {
        this.mainPathStack.pushPathByName('PageDetail', note.noteId);
      });

      Flex({
        direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center,
      }) {
        Text(this.vm.getHotNoteTypeName(note.tag))
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Caption_M'));
      }
      .componentStyle()
      .backgroundColor(this.vm.getHotNoteTypeBgColor(note.tag))
      .margin({ left: 2, top: 2 })
      .visibility(note.tag ? Visibility.Visible : Visibility.Hidden);
    }.alignContent(Alignment.TopStart);

  }

  @Builder
  NoteWaterFlowBuilder(noteList: LazyDataSource<NoteInfo>) {
    Grid() {
      LazyForEach(noteList, (item: NoteInfo, index: number) => {
        GridItem() {
          this.NoteCardBuilder(item);
        }.onAppear(() => { // 即将触底时提前增加数据，即执行数据预加载
          if (index === noteList.totalCount()) {
            for (let i = 0; i < 10; i++) {
              noteList.addLastItem();
            }
          }
        }).width(Constant.FULL_PERCENT);
      }, (item: NoteInfo, index: number) => index + '__' + item.noteId.toString());
    }
    .edgeEffect(EdgeEffect.Spring)
    .columnsTemplate(new BreakpointType({
      [BreakpointNameEnum.SM]: '1fr '.repeat(2),
      [BreakpointNameEnum.MD]: '1fr '.repeat(3),
      [BreakpointNameEnum.LG]: '1fr '.repeat(4),
      [BreakpointNameEnum.XL]: '1fr '.repeat(5),
    }).getValue(this.breakPointModel.currentBreakpoint))
    .backgroundColor($r('sys.color.background_secondary'))
    .cachedCount(10)
    .columnsGap(GridRowColSetting.getGutter(this.breakPointModel.currentBreakpoint))
    .rowsGap(12)
    .width(Constant.FULL_PERCENT);
  }
}

@Styles
function componentStyle() {
  .width(36).height(16).padding({
    left: 8,
    top: 1,
    right: 8,
    bottom: 1,
  }).borderRadius({
    topLeft: 8,
    topRight: 0,
    bottomRight: 8,
    bottomLeft: 0,
  });
}