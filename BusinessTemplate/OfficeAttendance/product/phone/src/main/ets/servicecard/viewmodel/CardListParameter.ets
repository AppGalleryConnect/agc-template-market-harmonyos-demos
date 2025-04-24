export class CardListParameter {
  /**
   * Card background color.
   */
  backgroundColor: ResourceColor = '';
  /**
   * Background image.
   */
  backgroundImage?: ResourceStr;
  /**
   * ImageSize of background image.
   */
  backgroundImageSize?: ImageSize;
  /**
   * Whether to set mask.
   */
  isMask?: boolean;
  /**
   * Mask color.
   */
  maskColor?: ResourceColor;
  /**
   * Whether to set item count.
   */
  isItemCount?: boolean;
  /**
   * Item count.
   */
  itemCount?: number;
  /**
   * Item count color.
   */
  itemCountColor?: ResourceColor;
  /**
   * Item count background color.
   */
  itemCountBackgroundColor?: ResourceColor;
  /**
   * Card list title.
   */
  title: ResourceStr = '';
  /**
   * Card list title color.
   */
  titleColor?: ResourceColor;
  /**
   * Logo icon.
   */
  logo?: ResourceStr;
  /**
   * Whether to display the bottom icon.
   */
  isBottomIcon?: boolean;
  /**
   * Bottom icon.
   */
  bottomIcon?: ResourceStr;

  constructor(backgroundColor: ResourceColor, title: ResourceStr, backgroundImage?: ResourceStr,
    backgroundImageSize?: ImageSize, logo?: ResourceStr, isMask?: boolean, maskColor?: ResourceColor,
    isItemCount?: boolean, itemCount?: number, itemCountColor?: ResourceColor,
    itemCountBackgroundColor?: ResourceColor, titleColor?: ResourceColor, isBottomIcon?: boolean,
    bottomIcon?: ResourceStr) {
    this.backgroundColor = backgroundColor;
    this.title = title;
    this.backgroundImage = backgroundImage;
    this.backgroundImageSize = backgroundImageSize;
    this.logo = logo;
    this.isMask = isMask;
    this.maskColor = maskColor;
    this.isItemCount = isItemCount;
    this.itemCount = itemCount;
    this.itemCountColor = itemCountColor;
    this.itemCountBackgroundColor = itemCountBackgroundColor;
    this.titleColor = titleColor;
    this.isBottomIcon = isBottomIcon;
    this.bottomIcon = bottomIcon;
  }
}