import {newsData,swiperData} from '../mock/MockData'
import {newsItem,SwiperInterface} from '../model/Interface'
import { RouteEntryVM } from 'common'
@Builder
export function HomePageBuilder() {
  HomePage()
}

@Component
export struct HomePage{
  @StorageLink('isLogin') isLogin: boolean = AppStorage.get('isLogin') ?? false;
  @StorageLink('cloudCard') cloudCard: boolean = AppStorage.get('cloudCard') ?? false;
  vm: RouteEntryVM = RouteEntryVM.instance;
  @Styles imageFancy(){
    .height(32)
    .width(32)
  }
  build() {
    NavDestination(){
      Scroll(){
        Column(){
          this.topTitle();
          this.showSwiper();
          this.listPageButton();
          this.showNewsBulletin();
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
      .padding({left:16,right:16})
    }
    .hideTitleBar(true)

  }
  @Builder
  topTitle(){
    Row(){
      Text('首页')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(70)
    .padding({left:12})
    .justifyContent(FlexAlign.Start)
  }
  @Builder
  showSwiper() {
    Swiper() {
      //轮播swiper
      ForEach(swiperData, (item: SwiperInterface) => {
        Image(item.image)
      },(item:SwiperInterface)=>item.id)
    }
    .indicator(
      Indicator.dot()
        .itemWidth(6)
        .itemHeight(6)
        .color($r('sys.color.comp_background_secondary'))
        .selectedItemWidth(12)
        .selectedItemHeight(6)
        .selectedColor($r('app.color.system_color_green'))
    )
    .autoPlay(true)
    .borderRadius(12)
    .margin({ bottom: 16 })
    .onClick(()=>{
      this.vm.toRouteDetail('NewsDetail')
    })
  }

  @Builder
  listPageButton(){
    Row(){
      Column(){
        Image($r('app.media.h_newspoint'))
          .imageFancy()
          .margin({bottom:8})
        Text($r('app.string.news_point'))
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
      }
      .onClick(()=>{
        this.vm.toRouteDetail('NewsHotspot')
      })

      Column(){
        Image($r('app.media.h_buscode'))
          .imageFancy()
          .margin({bottom:8})
        Text($r('app.string.bus_code'))
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
      }
      .onClick(()=>{
        if(this.isLogin===true&&this.cloudCard===true){
          this.vm.toRouteDetail('CodeScanPage')
        }else{
          this.vm.toRouteDetail('CloudCard')
        }
      })

      Column(){
        Image($r('app.media.h_prohibititem'))
          .imageFancy()
          .margin({bottom:8})
        Text($r('app.string.prohibited_item'))
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
      }
      .onClick(()=>
        this.vm.toRouteDetail('ProhibitedItemsPage')
      )
      Column(){
        Image($r('app.media.h_lostfind'))
          .imageFancy()
          .margin({bottom:8})
        Text($r('app.string.transport_lostandfound'))
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
      }
      .onClick(()=>{
        this.vm.toRouteDetail('LostFind')
      })

    }
    .padding(12)
    .height(80)
    .width('100%')
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({bottom:16})
    .backgroundColor($r('sys.color.white'))
  }

  @Builder
  showNewsBulletin(){
    Column(){
      Row(){
        Text($r('app.string.news_bulletin'))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .margin({left:13})
        Row(){
          Text('更多')
            .height(14)
            .width(20)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.mask_tertiary'))
            .margin({right:4})
          Image($r('app.media.h_icon_right'))
            .height(12)
            .width(12)
        }
        .margin({right:13})
      }
      .width(328)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(()=>{
        this.vm.toRouteDetail('NewsHotspot')
      })
      Column(){
        ForEach(newsData,(item:newsItem)=>{
          NewsList(item)
        },(item:newsItem)=>item.id)
      }
      .onClick(()=>{
        this.vm.toRouteDetail('NewsDetail')
      })

    }
    // .width(328)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({left:13,right:13,top:12})
  }
}

@Builder
export function NewsList(item:newsItem){
  Row(){
    Image(item.image)
      .height(54)
      .width(96)
      .borderRadius(8)

    Column(){
      Text(item.title)
        .height(19)
        .width(196)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#E6000000')

      Text(item.time)
        .height(16)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .margin({top:19})
    }
    .width(196)
    .margin({left:8})
    .alignItems(HorizontalAlign.Start)
  }
  .justifyContent(FlexAlign.SpaceAround)
  .margin({top:12,bottom:12})
  Divider()
    .margin({  left: 104, right: '12vp' })
    .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))

}