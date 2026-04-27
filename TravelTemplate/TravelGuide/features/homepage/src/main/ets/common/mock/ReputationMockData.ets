
export interface ReputationItem {
  id: number
  rank: number
  image: Resource | string,
  name: string
  reviewCount: string
  travelHotspot: string
  date: string
  annualList: string
  location: string
}

export const reputationList: ReputationItem[] = [
  {
    id: 1,
    rank: 1,
    image: $r('app.media.ic_city_guide_sun_mausoleum'),
    name: '中山陵',
    reviewCount: '8.7w',
    travelHotspot: '南京多个景点淡季开放时间调整',
    date: '2025.11.01',
    annualList: '连续4年入选年度榜单',
    location: '南京 距离你15公里'
  },
  {
    id: 2,
    rank: 2,
    image: $r('app.media.ic_city_guide_ming_wall'),
    name: '明孝陵',
    reviewCount: '16.5w',
    travelHotspot: '南京明孝陵银杏叶黄，古韵秋色美如画',
    date: '2025.11.05',
    annualList: '连续3年入选年度榜单',
    location: '南京 距离你12公里'
  },
  {
    id: 3,
    rank: 3,
    image: $r('app.media.ic_city_guide_nanjing_header'),
    name: '夫子庙',
    reviewCount: '15.2w',
    travelHotspot: '南京夫子庙秦淮河夜景璀璨，游客如织',
    date: '2025.11.08',
    annualList: '连续5年入选年度榜单',
    location: '南京 距离你8公里'
  },
  {
    id: 4,
    rank: 4,
    image: $r('app.media.ic_attraction_detail_bg_1'),
    name: '总统府',
    reviewCount: '14.8w',
    travelHotspot: '南京总统府历史文化展即将开幕',
    date: '2025.11.10',
    annualList: '连续2年入选年度榜单',
    location: '南京 距离你7公里'
  },
  {
    id: 5,
    rank: 5,
    image: $r('app.media.ic_attraction_detail_bg_2'),
    name: '玄武湖',
    reviewCount: '13.6w',
    travelHotspot: '南京玄武湖公园免费开放，市民休闲好去处',
    date: '2025.11.12',
    annualList: '连续3年入选年度榜单',
    location: '南京 距离你10公里'
  },
  {
    id: 6,
    rank: 6,
    image: $r('app.media.ic_attraction_detail_bg_3'),
    name: '南京博物院',
    reviewCount: '12.4w',
    travelHotspot: '南京博物院新展《六朝风采》即将开展',
    date: '2025.11.15',
    annualList: '连续2年入选年度榜单',
    location: '南京 距离你11公里'
  },
  {
    id: 7,
    rank: 7,
    image: $r('app.media.ic_attraction_detail_bg_4'),
    name: '鸡鸣寺',
    reviewCount: '11.9w',
    travelHotspot: '南京鸡鸣寺樱花季即将到来，提前预约',
    date: '2025.11.18',
    annualList: '连续4年入选年度榜单',
    location: '南京 距离你9公里'
  },
  {
    id: 8,
    rank: 8,
    image: $r('app.media.hotel_01'),
    name: '南京城墙',
    reviewCount: '10.7w',
    travelHotspot: '南京城墙夜游活动正式启动',
    date: '2025.11.20',
    annualList: '连续2年入选年度榜单',
    location: '南京 距离你6公里'
  },
  {
    id: 9,
    rank: 9,
    image: $r('app.media.hotel_02'),
    name: '雨花台',
    reviewCount: '9.8w',
    travelHotspot: '南京雨花台烈士陵园红色旅游热度不减',
    date: '2025.11.22',
    annualList: '连续3年入选年度榜单',
    location: '南京 距离你13公里'
  },
  {
    id: 10,
    rank: 10,
    image: $r('app.media.hotel_03'),
    name: '紫金山',
    reviewCount: '9.2w',
    travelHotspot: '南京紫金山秋色正浓，登山赏景正当时',
    date: '2025.11.25',
    annualList: '连续2年入选年度榜单',
    location: '南京 距离你14公里'
  }
]