export interface swiperContentInterface{
  image:Resource
}

export const swiperContent:swiperContentInterface[] = [
  {
    image:$r('app.media.swiper_image_1')
  },
  {
    image:$r('app.media.swiper_image_1')
  },
  {
    image:$r('app.media.swiper_image_1')
  }
]

export interface functionRegionInterface{
  image:Resource,
  text:string,
  uri?:string
}

export const functionRegion:functionRegionInterface[] = [
  {
    image:$r('app.media.stationInformation'),
    text:'站点信息',
    uri:'StationsInformationPage'
  },
  {
    image:$r('app.media.purchaseTickets'),
    text:'优惠购票',
    uri:'BuyTicketsPage'
  },
  {
    image:$r('app.media.prohibitedArticles'),
    text:'禁携物品',
    uri:'ProhibitArticlePage'
  },
  {
    image:$r('app.media.ConnectUs'),
    text:'联系客服'
  },
]

export interface newsInformationInterface{
  image:Resource,
  title:string,
  time:string
  uri?:string
  content:Resource|string
}

export const newsInformation:newsInformationInterface[] = [
  {
    image:$r('app.media.newsInformationImage_1'),
    title: '出行多样化，你知道南京交通到底有多便利',
    time:'2025.03.17',
    content:$r('app.string.newsContent1')
  },
  {
    image:$r('app.media.newsInformationImage_2'),
    title: '南京10条地铁建设新进展！',
    time:'2025.03.17',
    content:$r('app.string.newsContent1')
  },
  {
    image:$r('app.media.newsInformationImage_3'),
    title: '南京出租车收费新标准！',
    time:'2025.03.16',
    content:$r('app.string.newsContent1')
  },
  {
    image:$r('app.media.newsInformationImage_4'),
    title: '南京地铁地图已更新！',
    time:'2025.02.26',
    content:$r('app.string.newsContent1')
  },
  {
    image:$r('app.media.newsInformationImage_5'),
    title: '周边露营，地铁出行！',
    time:'2025.02.16',
    content:$r('app.string.newsContent1')
  },
  {
    image:$r('app.media.newsInformationImage_6'),
    title: '现场直击，南京地铁早高峰！',
    time:'2025.03.16',
    content:$r('app.string.newsContent1')
  },
  {
    image:$r('app.media.newsInformationImage_7'),
    title: '南京地铁，为爱发电！',
    time:'2025.02.26',
    content:'1'
  },
]

export interface station{
  name:string
  latitude:number
  longitude:number
  firstTime?:string
  lastTime?:string
  serial:number
}

export const line1:station[] = [
  {
    name:'八卦洲大桥南',
    latitude:32.1456125,
    longitude:118.8424186,
    firstTime:'05:30',
    lastTime:'23:08',
    serial:1
  },
  {
    name:'笆斗山',
    latitude:32.143253,
    longitude:118.8294176,
    firstTime:'05:32',
    lastTime:'23:10',
    serial:2
  },
  {
    name:'燕子矶',
    latitude:32.1360475,
    longitude:118.8215899,
    firstTime:'05:34',
    lastTime:'23:12',
    serial:3
  }
]

