import { LISTMODE, MusicItem } from '../components/MusicItem';
import { MusicViewModel } from '../viewModel/MusicViewModel';

@ComponentV2
export struct MusicListView {
  @Param pageType?: string = ''
  @Param @Require musicItemOnclick: (item: MusicViewModel) => void
  @Param @Require musicItemOnChange: (item: MusicViewModel, checkBoxStatus: boolean) => void
  @Param listMode: LISTMODE = 'click' //列表操作模式，默认单选模式
  @Param selectedMusicList?: MusicViewModel[] = []

  aboutToAppear(): void {
  }

  build() {
    Column() {
      List() {
        ForEach(this.selectedMusicList, (item: MusicViewModel) => {
          ListItem() {
            MusicItem({
              item: item,
              musicItemOnclick: this.musicItemOnclick,
              musicItemOnChange: this.musicItemOnChange,
              listMode: this.listMode
            })
              .padding({ left: 16, right: 16 })
          }.margin({ top: 12 })
        }, (item: MusicViewModel) => JSON.stringify(item))
          .onMove((from: number, to: number) => {
            if (this.selectedMusicList) {
              let tmp = this.selectedMusicList.splice(from, 1);
              this.selectedMusicList.splice(to, 0, tmp[0]);
            }
          })
      }.width('100%').height('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
    }.width('100%').height('100%')
    .backgroundColor('#0A0D1E')
  }
}