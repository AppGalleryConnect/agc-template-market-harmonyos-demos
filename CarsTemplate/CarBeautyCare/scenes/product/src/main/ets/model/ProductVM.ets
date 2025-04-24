import { ProductCard, BEAUTY_DATA } from './ProductData'

@ObservedV2
export class ProductVM {
  @Trace selectProduct:ProductCard[] = [];
  @Trace paidAmount: number = 0;
  @Trace discountAmount: number = 0;
  @Trace viewProductDetailData: ProductCard = BEAUTY_DATA[0];
  private static _instance: ProductVM;
  public static get instance() {
    if (!ProductVM._instance) {
      ProductVM._instance = new ProductVM();
    }
    return ProductVM._instance
  }

   public addSelectProduct(product: ProductCard) {
      const hasAdd:boolean = this.selectProduct.some((item: ProductCard) => product.id === item.id)
     if (!hasAdd) {
       this.selectProduct.push(product);
       this.calculateAmount()
     }
   }

   public removeSelectProduct(product: ProductCard) {
      const index = this.selectProduct.findIndex((item:ProductCard) => item.id === product.id)
      if (index !== -1) {
        this.selectProduct.splice(index, 1)
      }
      this.calculateAmount();
   }

   calculateAmount() {
     let paidAmount:number = 0;
     this.selectProduct.forEach((data:ProductCard) => {
       paidAmount = Number(data.price) + paidAmount;
     })
     this.paidAmount = paidAmount;
   }

   public updateProductDetail(data: ProductCard) {
      this.viewProductDetailData = data;
   }

   public clearSelectProduct() {
     this.paidAmount = 0;
     this.discountAmount = 0;
     this.selectProduct = [];
   }
}