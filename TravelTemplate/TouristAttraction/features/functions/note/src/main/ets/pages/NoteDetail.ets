import { Constant, LazyDataSource } from 'common';
import { SwiperComponent, TitleBar } from 'components';
import { https } from 'network';
import { NoteInfo } from 'types';
import { mapperNoteInfo } from '../mapper/Index';

@Builder
export function NoteDetailBuilder() {
  NoteDetail();
}

@ComponentV2
export struct NoteDetail {
  @Local banners: LazyDataSource<ResourceStr> = new LazyDataSource();
  @Local noteInfo: NoteInfo = new NoteInfo();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  getNoteById(noteId: number) {
    https.getNoteDetail(noteId).then((res) => {
      this.noteInfo = mapperNoteInfo(res.data);
      this.banners.pushArrayData(this.noteInfo.banners);
    });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: this.noteInfo?.name, clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column() {
          SwiperComponent(this.banners);
        };

        Column() {
          Text(this.noteInfo.name)
            .fontSize(20)
            .fontWeight(700)
            .maxLines(2)
            .margin({ bottom: 16 })
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Text(this.noteInfo.detail).lineHeight(20).fontSize(14);
        }.padding(16).width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Start);
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.getNoteById(context.pathInfo.param as number);
    });
  }
}