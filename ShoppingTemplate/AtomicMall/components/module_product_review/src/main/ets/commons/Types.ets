import { ReviewMediaType } from './Enums';

export interface ProductReviewItem {
  productId: string;
  userAvatar: ResourceStr;
  userName: string;
  skuCode: string;
  skuDesc: string[];
  rating: number;
  date: number; //时间戳
  content: string;
  mediaList: ReviewMediaItem[];
}

export interface MovingPhotoUri {
  imageUri: string
  videoUri: string
}

export interface ReviewMediaItem {
  uri: ResourceStr;
  movingPhotoUri?: MovingPhotoUri
  type: ReviewMediaType;
}

export interface OrderSkuItem {
  productId: string;
  skuCode: string;
  skuDesc: string;
  count: number;
  banner: ResourceStr;
  title: string;
  serviceDesc: string;
  dashPrice: number;
  price: number;
}

export interface ReviewDraft {
  shipmentRating: number;
  serviceRating: number;
  feedback: string;
  date: number;
  reviewList: SkuReview[];
}

export interface SkuReview {
  productId: string;
  skuCode: string;
  skuDesc: string;
  rating: number;
  content: string;
  mediaList: ReviewMediaItem[];
}
