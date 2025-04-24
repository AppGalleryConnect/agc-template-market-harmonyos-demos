import { Constants } from 'utils';
import { ProductViewModel } from '../viewmodel/ProductViewModel';
import { ProductOnShow } from 'external_interactions';

@ComponentV2
export struct ProductPage {
  @Param pathStack: NavPathStack = new NavPathStack();
  productViewModel: ProductViewModel = new ProductViewModel();

  @Builder
  BuildTitle() {
    Text('产品')
      .fontSize(20)
      .fontWeight(FontWeight.Medium)
      .margin({ top: Constants.PAGE_MARGIN_TOP });
  }

  @Builder
  BuildBanner() {
    Image($r('app.media.product_banner'))
      .width('90%')
      .margin({ top: 20 });
  }

  @Builder
  BuildProduct(index: number, productOnShow: ProductOnShow) {
    Row() {
      Text(index.toString());

      Column() {
        Image(productOnShow.image)
          .objectFit(ImageFit.Contain);
      }
      .margin({ left: 10 })
      .height(50)
      .width(50);

      Text(productOnShow.name)
        .margin({ left: 10 })
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .fontSize(16);

      Blank();

      Text(productOnShow.desc)
        .fontColor('#999999')
        .fontSize(14);
    }
    .width('90%')
  }

  @Builder
  BuildProductsTitle() {
    Row() {
      Text('30天激活榜')
        .fontColor('#333333')
        .fontSize(16);
    }
    .width('90%')
    .height('15%')
  }

  @Builder
  BuildProductsItem() {
    List({ space: 35 }) {
      ForEach(this.productViewModel.productsOnShow, (item: ProductOnShow, index: number) => {
        ListItem() {
          this.BuildProduct(index + 1, item);
        }
      }, (item: ProductOnShow, index: number) => item.name);
    }
    .scrollBar(BarState.Off)
    .alignListItem(ListItemAlign.Center)
    .height('85%');
  }

  @Builder
  BuildProducts() {
    Column() {
      this.BuildProductsTitle();
      this.BuildProductsItem();
    }
    .width('90%')
    .height('65%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 20 });
  }

  build() {
    Navigation(this.pathStack) {
      Scroll(){
        Column() {
          this.BuildTitle();
          this.BuildBanner();
          this.BuildProducts();
        }
      }
      .scrollBar(BarState.Off);
    }
    .backgroundColor(Constants.NAV_DESTINATION_BACKGROUND_COLOR)
    .hideTitleBar(true);
  }
}