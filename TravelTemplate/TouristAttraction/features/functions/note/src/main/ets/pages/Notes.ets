import { Constant, LazyDataSource } from 'common';
import { TitleBar } from 'components';
import { NoteInfo } from 'types';
import { NotePageVM } from '../viewmodel/NotePageVM';

@Builder
export function NotesBuilder() {
  Notes();
}

@ComponentV2
export struct Notes {
  vm: NotePageVM = NotePageVM.instance;
  private scroller: Scroller = new Scroller();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '游玩攻略', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });
        this.NoteWaterFlowBuilder(this.vm.noteList);
      };
    }.hideTitleBar(true);
  }

  @Builder
  NoteCardBuilder(note: NoteInfo) {
    Column() {
      Image(note.banner).objectFit(ImageFit.Contain).borderRadius(8).margin({ bottom: 8 });
      Text(note.name).fontSize(14).opacity(0.9).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis });
    }.alignItems(HorizontalAlign.Start).onClick(() => {
      this.mainPathStack.pushPathByName('NoteDetail', note.noteId);
    });
  }

  @Builder
  NoteWaterFlowBuilder(noteList: LazyDataSource<NoteInfo>) {
    WaterFlow({ scroller: this.scroller }) {
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
    .cachedCount(10)
    .columnsTemplate('1fr 1fr')
    .columnsGap(8)
    .rowsGap(16)
    .width(Constant.FULL_PERCENT)
    .layoutWeight(1)
    .padding(12);
  }
}