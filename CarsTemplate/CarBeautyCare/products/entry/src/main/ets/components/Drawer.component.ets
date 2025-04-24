import { ProductCard } from '@ohos_agcit/car_beauty_care_product'
import { ProductCardComponent } from './ProductCardComponent'
import { PRODUCT_CLASSIFICATION, BEAUTY_DATA,TIRE_DATA,MAINTENANCE_DATA,BEAUTY,TIRE,MAINTENANCE} from '@ohos_agcit/car_beauty_care_product'
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@Component
export struct Drawer {
  productType:PRODUCT_CLASSIFICATION = PRODUCT_CLASSIFICATION.BEAUTY;
  private listScroller: Scroller = new Scroller();
  @State cardList: ProductCard[] = [];
  @State groupData: ProductCard[][] = [];
  data: string [] = [];
  @State selectedIndex:number = 0;
  @Builder carContent() {
      List({scroller: this.listScroller}) {
        ForEach(this.groupData, (ele:ProductCard[]) => {
          if (ele[0] && ele[0].classifieds) {
            ListItemGroup({header:this.itemHead(ele[0].classifieds)}) {
              ForEach(ele, (item:ProductCard) => {
                ListItem() {
                  ProductCardComponent({
                    card:item
                  })
                }
                .margin({
                  bottom:10
                })
              })
            }
          }
        }, (item:ProductCard) => JSON.stringify(item))
      }
      .layoutWeight(1)
      .padding({
        left:10,
        right:10
      })
      .onScrollIndex((firstIndex: number) => {
        this.selectedIndex = firstIndex;
      })
  }

  aboutToAppear(): void {
   if (this.productType === PRODUCT_CLASSIFICATION.BEAUTY) {
     this.cardList = BEAUTY_DATA;
     this.data = Object.values(BEAUTY)
   }
   if (this.productType === PRODUCT_CLASSIFICATION.TIRE) {
     this.cardList = TIRE_DATA
     this.data = Object.values(TIRE)
   }
   if (this.productType === PRODUCT_CLASSIFICATION.MAINTENANCE) {
     this.cardList = MAINTENANCE_DATA
     this.data = Object.values(MAINTENANCE)
   }
   this.divideIntoGroups();
  }

  divideIntoGroups(): void {
    const groupData:ProductCard[][] = []
    this.data.forEach((item: string) => {
      const currentData:ProductCard[] = this.cardList.filter((ele:ProductCard) => {
        return ele.classifieds === item;
      })
      groupData.push(currentData)
    })
    this.groupData = groupData;
  }

  @Builder itemHead(text: string) {
    Text(text)
      .fontSize(12)
      .width(CommonConstants.FULL_WIDTH)
      .fontColor('#737373')
      .margin({
        bottom:8
      })
      .backgroundColor('#fff')
  }

  build() {
    Row() {
      List() {
        ForEach(this.data , (item:string, index: number) => {
          ListItem() {
            Text(item)
              .height(48)
              .fontSize(12)
              .fontColor('#737373')
              .backgroundColor(this.selectedIndex === index?'#fff':'#f1f3f5')
              .width(72)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                this.selectedIndex = index;
                this.listScroller.scrollToIndex(index)
              })
          }
        })
      }
      .width(72)
      this.carContent()
    }
    .width(CommonConstants.FULL_WIDTH)
    .alignItems(VerticalAlign.Top)
  }
}