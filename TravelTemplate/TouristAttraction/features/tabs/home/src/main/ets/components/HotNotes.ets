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
    NavDestination() {
      this.NoteWaterFlowBuilder(this.vm.noteList);
    };
  }

  @Builder
  NoteCardBuilder(note: NoteInfo) {
    Column() {
      Image(note.banner)
        .borderRadius(8)
        .objectFit(ImageFit.Contain)
        .interpolation(ImageInterpolation.High)
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
    }.onClick(() => {
      this.mainPathStack.pushPathByName('NoteDetail', note.noteId);
    }).backgroundColor(Color.White).borderRadius(8);
  }

  @Builder
  NoteWaterFlowBuilder(noteList: LazyDataSource<NoteInfo>) {
    WaterFlow() {
      LazyForEach(noteList, (item: NoteInfo, index: number) => {
        FlowItem() {
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
    .backgroundColor('#F1F3F5')
    .cachedCount(10)
    .columnsTemplate('1fr 1fr')
    .columnsGap(6)
    .rowsGap(6)
    .width(Constant.FULL_PERCENT)
    .layoutWeight(1);
  }
}