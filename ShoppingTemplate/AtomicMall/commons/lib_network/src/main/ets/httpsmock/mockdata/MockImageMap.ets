export enum MockImageMap {
  /**
   * 首页轮播
   */
  HOME_BANNER_1 = 'mock_homepage_banner1.png',
  HOME_BANNER_2 = 'mock_homepage_banner2.jpg',
  /**
   * 首页分类图标
   */
  HOME_CATEGORY_1 = 'icon1.png',
  HOME_CATEGORY_2 = 'icon2.png',
  HOME_CATEGORY_3 = 'icon3.png',
  HOME_CATEGORY_4 = 'icon4.png',
  HOME_CATEGORY_5 = 'icon5.png',
  HOME_CATEGORY_6 = 'icon6.png',
  HOME_CATEGORY_7 = 'icon7.png',
  HOME_CATEGORY_8 = 'icon8.png',
  HOME_CATEGORY_9 = 'icon9.png',
  HOME_CATEGORY_10 = 'icon10.png',
  /**
   * 商品图
   */
  PRODUCT_10001_GREEN = 'product_10001_green.png',
  PRODUCT_10001_PINK = 'product_10001_pink.png',
  PRODUCT_10001_STRIPE = 'product_10001_stripe.png',
  PRODUCT_10001_YELLOW = 'product_10001_yellow.png',
  PRODUCT_20001_BLACK = 'product_20001_black.png',
  PRODUCT_20001_BLUE = 'product_20001_blue.png',
  PRODUCT_20001_SHIRT = 'product_20001_shirt.png',
  PRODUCT_20001_WHITE = 'product_20001_white.png',
  PRODUCT_30001 = 'product_30001.png',
  PRODUCT_30002 = 'product_30002.png',
  PRODUCT_30003 = 'product_30003.png',
  PRODUCT_30004 = 'product_30004.png',
  PRODUCT_30005 = 'product_30005.png',
  /**
   * 默认头像
   */
  DEFAULT_AVATAR = 'ic_default_avatar.png',
}

export class MockImageData {
  public static getImageResource(src: string): string {
    const CLOUD_STORAGE_DOMAIN: string =
      'https://agc-storage-drcn.platform.dbankcloud.cn/v0/mall-r3mfm/comprehensive-mall%2F';

    return CLOUD_STORAGE_DOMAIN + src;
  }
}