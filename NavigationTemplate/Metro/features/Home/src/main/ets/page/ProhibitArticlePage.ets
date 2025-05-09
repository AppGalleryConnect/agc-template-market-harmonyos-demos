import { MainEntryVM } from 'commonlib';
import { BaseTitle } from 'componentlib';

@Builder
export function ProhibitArticlePageBuilder(name: string, param: Object){
  ProhibitArticlePage()
}


@Component
export struct ProhibitArticlePage{
  vm: MainEntryVM = MainEntryVM.instance;

  @Builder
  ProhibitArticleBuilder() {
    Text('禁携物品')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    NavDestination(){
      BaseTitle({
        customTitle: () => {
          this.ProhibitArticleBuilder()
        },
        showBackBtn: true,
        onBack: () => {
          this.vm.navStack.pop()
        },
      });

      Scroll(){
        Column(){
         Image($r('app.media.ProhibitArticle'))
           .width(328)
           .height(202)
         Text($r('app.string.weight_rule')).margin({left:12,top:8,right:20})
         Text($r('app.string.weight_rule_content')).fontColor($r('app.color.font_color_gray')).margin({top:4,left:12,right:20})
         Text($r('app.string.prohibit_article')).margin({top:16,left:12,right:20})
         Text($r('app.string.prohibit_article_content')).fontColor($r('app.color.font_color_gray')).margin({top:4,left:12,right:20})
         Text($r('app.string.province_prohibit_article')).margin({top:16,left:12,right:20})
         Text($r('app.string.province_prohibit_article_content')).fontColor($r('app.color.font_color_gray')).margin({top:4,left:12,right:20})
        }
        .borderRadius({bottomLeft:8,bottomRight:8})
        .backgroundColor(Color.White)
        .alignItems(HorizontalAlign.Start)
        .width(328)
      }
      .margin({top:8})
      .scrollBar(BarState.Off)
    }
    .backgroundColor($r('app.color.stationsInformation_background_color'))
    .hideTitleBar(true)
  }
}