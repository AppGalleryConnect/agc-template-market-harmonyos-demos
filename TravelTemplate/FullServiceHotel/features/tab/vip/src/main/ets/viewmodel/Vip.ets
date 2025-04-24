export default interface Vip {
  title: string;
  cardType: number;
  benefits: Benefit[];
}

export interface Benefit {
  name: string;
  icon: PixelMap | ResourceStr | DrawableDescriptor;
}
