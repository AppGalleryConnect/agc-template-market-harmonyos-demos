import { SkeletonType, UISkeleton } from '@hw-agconnect/ui-skeleton';
import { RouterMap } from 'lib_foundation';
import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct MainService {
  vm: HomePageVM = HomePageVM.instance;
  @Param loading: boolean = false;

  @Builder
  buttonBuilder(image: ResourceStr, title: string, tip: string, router: RouterMap) {
    Row() {
      Image(image)
        .width(60)
        .height(60)
      Column({ space: 2 }) {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Text(tip)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis})
      }
      .alignItems(HorizontalAlign.Start)
    }
    .onClick(() => {
      this.vm.loginJumpPage(router);
    })
  }

  build() {
    Column() {
      UISkeleton({
        options: [{
          type: SkeletonType.RECT,
          radius: 16,
          width: '100%',
          height: 84,
        }],
        loading: this.loading
      }) {
        Flex({ justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
          this.buttonBuilder($r('app.media.ic_car'), '寄快递', '一小时取件', RouterMap.EXPRESS_PAGE)
          this.buttonBuilder($r('app.media.ic_car'), '发物流', '大件/整车/零担', RouterMap.EXPRESS_PAGE)
        }
        .height('100%')
        .backgroundColor(Color.White)
        .padding({ left: 12, right: 12 })
        .borderRadius(16)
      }
    }
    .height(84)
    .margin({ top: 12 })
  }
}