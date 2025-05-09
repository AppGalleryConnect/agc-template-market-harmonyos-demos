import {HotNewsSegmentInterface} from '../model/Interface'
import {hotNewsPiece} from '../mock/MockData'
import { RouteEntryVM } from 'common'
import { common } from '@kit.AbilityKit';

@Builder
export function NewsHotspotBuilder() {
  NewsHotspot()
}

@Component
export struct NewsHotspot{
  vm: RouteEntryVM = RouteEntryVM.instance;


  build() {

    NavDestination(){
      Scroll(){
        Column(){
          this.showTitleImage();
          this.presentHotNewsFeed();

        }
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .backgroundImageSize(ImageSize.Auto)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .scrollBarWidth('0vp')
      .edgeEffect(EdgeEffect.None)
      .backgroundColor('#F5F5F5')
    }
    .hideTitleBar(false)
    .title('新闻热点')
    .backgroundColor('#F5F5F5')
  }



  @Builder
  showTitleImage(){
    Column(){
      Stack({ alignContent: Alignment.TopStart }){
        Image($r('app.media.newimage_1'))
          .height('180lpx')
          .width('326lpx')
          .borderRadius(8)
        Column(){
          Row(){
            Image($r('app.media.news_flame'))
              .height(15)
              .width(13)
            Text('热门')
              .fontSize(14)
              .fontColor($r('sys.color.white'))
              .fontWeight(FontWeight.Medium)
              .margin({left:6})
          }
          .width(56)
          .height(24)
          .backgroundColor('#baf40000')
          .margin({left:8,top:12,bottom:88})
          .padding(3)
          .borderRadius(8)

          Row(){
            Text($r('app.string.hot_title'))
              .fontSize(16)
              .fontColor($r('sys.color.white'))
              .fontWeight(FontWeight.Medium)
              .maxLines(2)
          }
          .padding({left:6,right:6,top:4,bottom:4})
          .width(225)
          .backgroundColor($r('sys.color.mask_tertiary'))
          .borderRadius(4)
          .margin({left:8,bottom:8})
        }
        .alignItems(HorizontalAlign.Start)
      }
    }
    .height('180lpx')
    .width('326lpx')
    .margin({top:12})
    .onClick(()=>{
      this.vm.toRouteDetail('NewsDetail')
    })
  }
  @Builder
  presentHotNewsFeed(){
    Column(){
      ForEach(hotNewsPiece,(item:HotNewsSegmentInterface)=>{
        hotNewsFeed(item)
      },(item:HotNewsSegmentInterface)=>item.id)
    }
    .margin({top:16})
    .onClick(()=>{
      this.vm.toRouteDetail('NewsDetail')
    })
  }
}

@Builder
export function hotNewsFeed(item:HotNewsSegmentInterface){
  Row(){
    Column(){
      Column(){
        Text(item.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
      }
      .height(38)
      .width(201)
      .margin({bottom:28})
      .alignItems(HorizontalAlign.Start)
      Row(){
        Text(item.time)
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .width(61)
        Text('访问次数:  ')
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .margin({left:8})
        Text(item.visit)
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width(201)
    Image(item.image)
      .height(80)
      .width(120)
      .margin({left:8})
  }
  .margin({bottom:12})
}
