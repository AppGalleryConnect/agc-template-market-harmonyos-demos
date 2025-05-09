import { MainEntryVM, recordingList, RecordingList } from 'commonlib'
import { BaseTitle } from 'componentlib'
import { recordingComponent } from '../components/recordingComponent'


@Builder
export function RecordingPageBuilder(name: string, param: Object){
  RecordingPage()
}


@Component
export struct RecordingPage{
  @State totalSelected:number = 0
  @State totalPrice:number = 0
  @State listItem: RecordingList[] = recordingList[0]
  @State selectAll:boolean = false
  vm: MainEntryVM = MainEntryVM.instance;

  @Builder
  RecordingBuilder() {
    Text('乘车记录')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    NavDestination(){
      BaseTitle({
        customTitle: () => {
          this.RecordingBuilder()
        },
        showBackBtn: true,
        onBack: () => {
          this.vm.navStack.pop()
        },
      });

      recordingComponent({totalSelected:this.totalSelected,
        totalPrice:this.totalPrice,
        listItem:this.listItem,
        selectAll:this.selectAll})
    }
    .backgroundColor($r('app.color.background_color'))
    .hideTitleBar(true)
  }

}