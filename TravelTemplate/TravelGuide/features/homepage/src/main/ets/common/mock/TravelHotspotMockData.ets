export interface TravelHotspotItem {
  id: number
  image: Resource | string
  title: string
  viewCount: string
  date?: string
  location?: string
  distance?: string
}

// 定义单个数据项（id对应详情页的id）
const item1: TravelHotspotItem = {
  id: 1,
  image: $r('app.media.hotel_01'),
  title: '南京中山陵秋色正浓，最佳观赏期到来',
  viewCount: '82.1w',
  date: '2025.11.14-2026.01.04',
  location: '中山陵',
  distance: '距离你15公里'
}

const item2: TravelHotspotItem = {
  id: 2,
  image: $r('app.media.hotel_02'),
  title: '南京夫子庙秦淮河夜景璀璨，游客如织',
  viewCount: '75.3w',
  date: '2025.11.10-2026.02.28',
  location: '夫子庙',
  distance: '距离你8公里'
}

const item3: TravelHotspotItem = {
  id: 3,
  image: $r('app.media.hotel_03'),
  title: '南京明孝陵银杏叶黄，古韵秋色美如画',
  viewCount: '68.5w',
  date: '2025.11.01-2025.12.15',
  location: '明孝陵',
  distance: '距离你12公里'
}

const item4: TravelHotspotItem = {
  id: 4,
  image: $r('app.media.hotel_04'),
  title: '南京玄武湖公园免费开放，市民休闲好去处',
  viewCount: '56.2w',
  date: '2025.10.20-2026.03.31',
  location: '玄武湖',
  distance: '距离你10公里'
}

const item5: TravelHotspotItem = {
  id: 5,
  image: $r('app.media.hotel_05'),
  title: '南京鸡鸣寺樱花季即将到来，提前预约',
  viewCount: '49.8w',
  date: '2026.03.01-2026.04.15',
  location: '鸡鸣寺',
  distance: '距离你9公里'
}

const travelHotspotList: TravelHotspotItem[] = [
  item1,
  item2,
  item3,
  item4,
  item5
]

export { travelHotspotList }

