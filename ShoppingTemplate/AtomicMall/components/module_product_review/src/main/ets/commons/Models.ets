import { ReviewDraft, ReviewMediaItem, SkuReview } from './Types';

@ObservedV2
export class ReviewDraftModel implements ReviewDraft {
  @Trace
  shipmentRating: number = 0;
  @Trace
  serviceRating: number = 0;
  @Trace
  feedback: string = '';
  @Trace
  date: number = 0;
  @Trace
  reviewList: SkuReviewModel[] = [];
}

@ObservedV2
export class SkuReviewModel implements SkuReview {
  @Trace
  productId: string = '';
  @Trace
  skuCode: string = '';
  @Trace
  skuDesc: string = '';
  @Trace
  rating: number = 0;
  @Trace
  content: string = '';
  @Trace
  mediaList: ReviewMediaItem[] = [];
}
