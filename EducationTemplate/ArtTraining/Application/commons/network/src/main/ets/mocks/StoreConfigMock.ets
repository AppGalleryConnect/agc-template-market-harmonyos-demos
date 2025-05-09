import { StoreInfo } from 'commonlib';

export class StoreConfigMock {
  public static readonly banners: ResourceStr[] = [
    $r('app.media.img_course_cover1'),
    $r('app.media.img_course_cover2'),
    $r('app.media.img_course_cover3'),
  ];
  public static readonly storeInfo: StoreInfo = {
    shopName: '琴之美 (鼓楼店)',
    latitude: 32.0603,
    longitude: 118.7969,
    address: '江苏省南京市鼓楼区音乐之路123号',
    phoneNumber: '+86 25 1234 5678',
    email: 'info@musicacademy.com',
    logoUrl: '',
    bannerImg:'',
    desc: '',
    businessTime: '9:00 - 20:00',
  };
}