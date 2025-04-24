import { TabListItem, ServiceEntryItem, SwiperBanner, MineServiceItem } from '../types/Types';

export const TAB_LIST: TabListItem[] = [
  {
    label: $r('app.string.home_page'),
    icon: $r('app.media.ic_home'),
    iconChecked: $r('app.media.ic_home_checked'),
  },
  {
    label: $r('app.string.car_service'),
    icon: $r('app.media.ic_car_lined'),
    iconChecked: $r('app.media.ic_car_lined_chekced'),
  },
  {
    label: $r('app.string.mine'),
    icon: $r('app.media.ic_mine'),
    iconChecked: $r('app.media.ic_mine_checked'),
  },
];

export const SERVICE_ENTRY_LIST:ServiceEntryItem[] = [
  {
    label: $r('app.string.car_maintenance'),
    icon: $r('app.media.baoyang'),
    tabIndex: 2,
  },
  {
    label: $r('app.string.car_battery'),
    icon: $r('app.media.dianping'),
    tabIndex: 4,
  },
  {
    label: $r('app.string.car_wash'),
    icon: $r('app.media.xiche'),
    tabIndex: 3,
  },
  {
    label: $r('app.string.transmission_oil'),
    icon: $r('app.media.biansuxiangyou'),
    tabIndex: 5,
  },
  {
    label: $r('app.string.car_beauty'),
    icon: $r('app.media.meirong'),
    tabIndex: 0,
  },
  {
    label: $r('app.string.decarbonization'),
    icon: $r('app.media.chujitan'),
    tabIndex: 6,
  },
  {
    label: $r('app.string.car_tires'),
    icon: $r('app.media.luntai'),
    tabIndex: 1,
  },
  {
    label: $r('app.string.appointment'),
    icon: $r('app.media.yuyue'),
    tabIndex: 7,
  },
]

export const SWIPER_BANNER:SwiperBanner[] = [
  {
    imgUrl: $r('app.media.banner'),
    href: 'developer.huawei.com/consumer/cn',
  },
  {
    imgUrl: $r('app.media.banner'),
    href: 'developer.huawei.com/consumer/cn',
  },
  {
    imgUrl: $r('app.media.banner'),
    href: 'developer.huawei.com/consumer/cn',
  }
]

export const MINE_LIST:MineServiceItem[] = [
  {
    label:$r('app.string.my_order'),
    icon: $r('app.media.order_icon'),
    routePath: 'orderCard'
  },
  {
    label:$r('app.string.my_appointment'),
    icon:$r('app.media.appointment_icon'),
    routePath: 'reservedCardList'
  },
  {
    label:$r('app.string.my_coupon'),
    icon: $r('app.media.coupon_icon'),
    routePath: 'myCouponList'
  },
  {
    label:$r('app.string.my_car'),
    icon:$r('app.media.car_icon'),
    routePath: 'garagePage'
  },
  {
    label:$r('app.string.contacts_message'),
    icon: $r('app.media.contact_icon'),
    routePath: 'contact'
  },
]


