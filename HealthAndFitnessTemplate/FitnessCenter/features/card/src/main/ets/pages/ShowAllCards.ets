import { CardInfo, MockService, SportType } from 'external_interactions';
import { CardContent } from '../components/CardContent'
import { SearchFilterContent, Type } from 'module_search_filter';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { ScreenPropStorage} from 'external_interactions'
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct ShowAllCards {
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Local showCardList: CardInfo[] = MockService.cardList;
  @Local cardList: CardInfo[] = this.showCardList
  @Local listLength: number = 0;
  @Local sportType: number = 0
  sportTypeList: SportType[] = [{
    name: '全部',
    typeEnum: 0,
    icon: '',
    advImage: []
  }];
  cardNatureList: string[] = ['全部']
  @Param @Once list: string[] = []
  @Local sportSelectIndex: number = 0;
  @Local searchWord: string = ''
  aboutToAppear(): void {
    this.sportTypeList = this.sportTypeList.concat(MockService.sportTypeList)
    this.cardNatureList = this.cardNatureList.concat(MockService.cardNatureList)
    this.list = this.cardNatureList
    this.listLength = this.showCardList.length
  }
  private handleBack(nature: string, index: number, searchWord: string){
    this.showCardList = MockService.getCardListBySearchAndFilter(this.cardList, searchWord, index, nature)
    this.listLength = this.showCardList?.length
  }
  build() {
    NavDestination() {
      TitleBar({ title: '本店卡项',
        onBackClick:()=>{
          this.pathStack.pop()
        }
      }).margin({ left: 16, right: 16 })

      Scroll() {
        Column() {
          SearchFilterContent({
            placeHolder: '请输入卡项名称',
            typeList: this.list,
            onContentChange: (nature: string, index: number, searchWord: string) => {
              this.handleBack(nature, index, searchWord)
            }
          })
          CardContent({
            cardList: this.showCardList,
            onChildClick: (id: string)=>{
              this.pathStack.pushPath({name: 'card/cardDetail', param: MockService.cardIdMap.get(id)})
            }
          })
          Column() {
            Image($r('app.media.no_result'))
              .width(144)
              .height(144)
              .margin({ bottom: 12 })
            Text('未查询到卡项信息')
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor('#999999')
          }
          .height('50%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .visibility(
            this.listLength > 0 ? Visibility.None : Visibility.Visible
          )
        }
        .margin({ bottom: 50 })
      }
      .align(Alignment.Top)
      .layoutWeight(1)
      .margin({ left: 16, right: 16 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
      if (ctx.pathInfo.param) {
        this.showCardList = ctx?.pathInfo?.param as CardInfo[]
      } else {
        this.showCardList = MockService.cardList
      }
      this.cardList = this.showCardList
    })
    .hideTitleBar(true)
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight) })
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .onAppear(()=>this.handleBack('', 0, ''))
  }
}
