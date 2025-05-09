

export interface CardContent {
  constructionType: string;
  preset: string;
  data: string;
}

export interface ProductCardContents {
  banner: CardContent[];
  title: CardContent[];
  label: CardContent[];
  promotion: CardContent[];
  milestone: CardContent[];
  price: CardContent[];
}

export interface ProductCardModel {
  productId: string;
  contents: ProductCardContents;
}
