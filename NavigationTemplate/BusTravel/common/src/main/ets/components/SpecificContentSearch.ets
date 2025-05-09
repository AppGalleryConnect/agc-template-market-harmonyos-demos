import prompt from '@ohos.prompt';
import { SearchSet } from '../model/commonInterface';
import { RouteEntryVM } from '../utils/RouteEntryVM';
import { promptAction, SymbolGlyphModifier } from '@kit.ArkUI';

@Builder
export function SpecificContentSearchBuilder() {
  SpecificContentSearch()
}

@Component
export struct SpecificContentSearch {
  @State changeValue: string = ''
  @State searchNewListData: Array<string> = []
  @State searchContentList: Array<string> = []
  controller: SearchController = new SearchController()
  scroller: Scroller = new Scroller()
  private scrollerForList: Scroller = new Scroller()
  vm: RouteEntryVM = RouteEntryVM.instance;

  searchFunc(value: string) {
    let newListData: Array<string> = [];

    if (this.searchContentList.length) {
      for (let i = 0; i < this.searchContentList.length; i++) {
        // 通过includes对输入的字符进行查询
        if (this.searchContentList[i].toLowerCase().includes(value.toLowerCase())) {
          newListData.push(this.searchContentList[i]);
        }
      }
    }
    // 判断是否有输入的值
    if (value.length !== 0) {
      // 去重
      let uniqueLine = new Set(newListData)
      let lines2 = Array.from(uniqueLine)
      this.searchNewListData = lines2
    } else {
      this.searchNewListData = []
    }
  }

  @Builder
  ListContent(param: Array<string>) {
    Row() {
      Image($r('app.media.ic_car_gps'))
        .height('24lpx')
        .width('24lpx')
        .margin({ left: '24lpx', right: '4lpx' })
      Text('站点')
        .fontSize('18fp')
        .fontWeight(500)
    }
    .width('100%')
    .height('56lpx')

    List({ initialIndex: 0, scroller: this.scrollerForList }) {
      ForEach(param, (item: string) => {
        ListItem() {
          Row() {
            Text(item)
              .fontSize(14)
              .margin({ left: '51' })
              .maxLines(1)
              .textOverflow({
                overflow: TextOverflow.Ellipsis
              })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
        }
        .height('48lpx')
        .onClick(() => {
          this.vm.popValue(item)
        })
      },(item:string)=>item)
    }
    .backgroundColor($r('app.color.background_color_white'))
    .width('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .alignListItem(ListItemAlign.Start)
    .divider({
      strokeWidth: 1,
      color: '#EDEDED',
      startMargin: 12,
      endMargin: 12
    })
  }

  @Builder
  SearchContentInfo() {
    Column() {
      Column() {
        Row() {
          Image($r('app.media.ic_public_back'))
            .height('24lpx')
            .width('24lpx')
            .onClick(() => {
              this.vm.pop()
            })
            .margin({ left: '24lpx', right: '16lpx' })

          Search({
            value: this.changeValue,
            placeholder: '搜索公交路线、站点',
            controller: this.controller
          })
            .caretStyle({width:1.5, color:$r('app.color.system_color_green')})
            .width('272lpx')
            .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')).fontSize('16vp'))
            .defaultFocus(true)
            .borderColor(Color.Blue)
            .backgroundColor($r('sys.color.ohos_id_color_background'))
            .placeholderFont({ size: $r('sys.float.ohos_id_text_size_body1') , weight: 400 })
            .textFont({ size: $r('sys.float.Body_L'), weight: 400 })
            .onSubmit((value: string) => {
              if (!value) {
                promptAction.showToast({
                  message: '输入内容不能为空',
                  duration: 2000,
                  bottom: 80
                });
                return;
              }
              this.vm.popValue(value)
            })
            .onChange((value: string) => {
              this.changeValue = value
              this.searchFunc(value)
            })

        }
        .height('56lpx')
        .width('100%')
        .backgroundColor('#62B42E')
        .padding({ top: '8lpx', bottom: '8lpx' })
      }

      if (this.searchNewListData.length) {
        Scroll(this.scroller){
          Column() {
            this.ListContent(this.searchNewListData)
          }
          .width('100%')
        }
        .edgeEffect(EdgeEffect.Spring)
      }


    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }

  build() {
    NavDestination() {
      Column() {
        this.SearchContentInfo()
      }
      // .height('100%')
      .backgroundColor('#F1F3F5')
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      // 在NavDestination中能够拿到传来的NavPathInfo和当前所处的NavPathStack
      try {
        this.searchContentList = JSON.parse(JSON.stringify(ctx?.pathInfo.param))
      } catch (e) {
        console.log(`testTag onReady catch exception: ${JSON.stringify(e)}`)
      }
    })
  }
}