import { Constant, LazyDataSource } from 'common';
import { NoteInfo } from 'types';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Builder
export function HotNotesBuilder() {
  HotNotes();
}

@ComponentV2
export struct HotNotes {
  vm: HomePageVM = HomePageVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      this.NoteWaterFlowBuilder(this.vm.noteList)
    }
  }

  @Builder
  NoteCardBuilder(note: NoteInfo) {
    Column() {
      Image(note.banner)
        .width('100%')
        .height(90)
        .borderRadius(8)
        .borderRadius(8)
        .autoResize(true)
        .syncLoad(true);
      Text(note.name)
        .maxLines(2)
        .lineHeight(16)
        .fontSize(12)
        .fontWeight(500)
        .opacity(0.9)
        .width(Constant.FULL_PERCENT)
        .textAlign(TextAlign.Start)
        .padding(10);
    }
    .width(150)
    .height(130)
    .onClick(() => {
      this.mainPathStack.pushPathByName('PageDetail', note.noteId);
    })
    .backgroundColor($r('sys.color.font_on_primary'))
    .borderRadius(8);
  }

  @Builder
  NoteWaterFlowBuilder(noteList: LazyDataSource<NoteInfo>) {
    Grid() {
      LazyForEach(noteList, (item: NoteInfo, index: number) => {
        GridItem() {
          this.NoteCardBuilder(item);
        }.onAppear(() => {
          // 即将触底时提前增加数据，即执行数据预加载
          if (index === noteList.totalCount()) {
            for (let i = 0; i < 10; i++) {
              noteList.addLastItem();
            }
          }
        })
        .width(Constant.FULL_PERCENT);
      }, (item: NoteInfo, index: number) => index + '__' + item.noteId.toString());
    }
    .edgeEffect(EdgeEffect.Spring)
    .columnsTemplate('repeat(auto-stretch, 150)')
    .backgroundColor('#F1F3F5')
    .cachedCount(10)
    .columnsGap(8)
    .rowsGap(8)
    .width(Constant.FULL_PERCENT)
  }
}