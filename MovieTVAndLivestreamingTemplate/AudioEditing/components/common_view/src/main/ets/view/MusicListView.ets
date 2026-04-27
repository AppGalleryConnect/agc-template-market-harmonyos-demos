import { MusicListViewModel, MusicViewModelArray } from '../viewModel/MusicListViewModel';
import { LISTMODE, MusicItem } from '../components/MusicItem';
import { MusicViewModel } from '../viewModel/MusicViewModel';
import { MusicListViewController, MusicParam } from '../controller/MusicListViewController';
import { NoMusicData } from '../components/NoMusicData';

export const selectTabSubData = ['音乐库', '作品集']

@ComponentV2
export struct MusicListView {
  @Local tabActiveIndex: number = 0
  @Local tabsData: MusicViewModelArray[] = []
  @Local musicListVM: MusicListViewModel = new MusicListViewModel();
  @Local workListVM: MusicListViewModel = new MusicListViewModel()
  @Param @Require musicItemOnclick: (item: MusicViewModel) => void
  @Param @Require musicItemOnChange: (item: MusicViewModel, checkBoxStatus: boolean) => void
  @Param @Require musicListViewController: MusicListViewController
  @Param listMode: LISTMODE = 'click' //列表操作模式，默认单选模式
  @Param isSearchPage?: boolean = false
  @Param selectedMusicList?: MusicViewModel[] = [] //选中的音频列表，用于合成功能
  @Event activeIndexChange: (index: number) => void = (index: number) => {
  }
  private ctx: UIContext = this.getUIContext();
  addData = (musicData: MusicParam, type: 'music' | 'work') => {
    this.musicListVM.addData(musicData, type)
    this.tabsData[0] = this.musicListVM.list
  }
  filterData = (val: string) => {
    if (!val) {
      this.tabsData[0] = this.musicListVM.list
      this.tabsData[1] = this.workListVM.list
    } else {
      this.tabsData[0] = this.musicListVM.list.filter(item => item.title.indexOf(val) > -1)
      this.tabsData[1] = this.workListVM.list.filter(item => item.title.indexOf(val) > -1)
    }
  }
  filterSelect = () => {
    let selectUri: string [] = []
    let selectSourcePath: string [] = []
    if (this.selectedMusicList?.length) {
      selectUri = this.selectedMusicList?.map((item) => item.uri)
      selectSourcePath = this.selectedMusicList?.map((item) => item.sourcePath)
    }
    this.tabsData[0].forEach((item) => {
      item.checkBoxStatus = selectUri.includes(item.uri)
    })
    this.tabsData[1].forEach((item) => {
      item.checkBoxStatus = selectSourcePath.includes(item.sourcePath)
    })
  }

  aboutToAppear(): void {
    this.musicListVM.loadData('music')
    this.workListVM.loadData('work')
    this.tabsData[0] = this.musicListVM.list
    this.tabsData[1] = this.workListVM.list
    this.musicListViewController.addData = this.addData
    this.musicListViewController.filterData = this.filterData
    this.musicListViewController.filterSelect = this.filterSelect
    this.filterSelect()
  }

  @Builder
  TabTileBuilder(val: string, index: number) {
    Text(val)
      .width(96)
      .height(36)
      .borderRadius(21)
      .textAlign(TextAlign.Center)
      .halfLeading(true)
      .fontSize(14)
      .fontColor(this.tabActiveIndex === index ? '#01FCEA' : '#99FFFFFF')
      .backgroundColor(this.tabActiveIndex === index ? '#33FFFFFF' : Color.Transparent)
      .onClick(() => {
        this.tabActiveIndex = index
        this.activeIndexChange(index)
      })
  }

  @Builder
  itemEnd(index: number, type: number) {
    if (this.isSearchPage) {
      Row().width(0).height(0)
    } else {
      Row() {
        Text('删除')
          .margin({ left: 8 })
          .fontSize(16)
          .backgroundColor('#19FFFFFF')
          .fontColor(Color.White)
          .borderRadius(16)
          .textAlign(TextAlign.Center)
          .width(70)
          .height(70)
          .onClick(() => {
            if (type === 0) {
              this.musicListVM.delData([this.musicListVM.list[index]], true)
              this.tabsData[0] = this.musicListVM.list
              this.ctx.getPromptAction().showToast({ message: '删除成功' })
            } else {
              this.workListVM.delData([this.workListVM.list[index]])
              this.tabsData[1] = this.workListVM.list
              this.ctx.getPromptAction().showToast({ message: '删除成功' })
            }
          });
      }.padding(4).justifyContent(FlexAlign.SpaceEvenly)
    }
  }

  build() {
    Column() {
      Row() {
        ForEach(selectTabSubData, (item: string, index: number) => {
          this.TabTileBuilder(item, index)
        }, (item: string, index: number) => {
          return index.toString()
        })
      }.width('100%').margin({ top: 25 })

      Tabs() {
        ForEach(selectTabSubData, (item: string, indexTab: number) => {
          TabContent() {
            List() {
              if (!this.tabsData[this.tabActiveIndex].length) {
                NoMusicData()
              }
              ForEach(this.tabsData[this.tabActiveIndex], (item: MusicViewModel, index: number) => {
                ListItem() {
                  MusicItem({
                    item: item,
                    musicItemOnclick: this.musicItemOnclick,
                    musicItemOnChange: this.musicItemOnChange,
                    listMode: this.listMode
                  })
                }.margin({ top: 12 })
                .swipeAction({
                  end: {
                    builder: () => {
                      this.itemEnd(index, this.tabActiveIndex)
                    },
                    onAction: () => {
                    },
                    actionAreaDistance: 300,
                  },
                  edgeEffect: SwipeEdgeEffect.Spring
                });
              }, (item: MusicViewModel) => JSON.stringify(item))
            }.height('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
            .scrollBar(BarState.Off)
          }.height('100%')
        }, (item: string, index: number) => {
          return index.toString()
        })
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 10 })
      .barHeight(0)
      .scrollable(false)
    }.width('100%').height('100%')
    .padding({ left: 16, right: 16 })
  }
}