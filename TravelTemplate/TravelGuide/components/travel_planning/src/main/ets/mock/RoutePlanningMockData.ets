/**
 * 线路规划Mock数据
 */

import { RouteItem } from '../model/RouteListModel'

// 景点信息接口
export interface AttractionInfo {
  name: string
  image: ResourceStr
  description: string
}

// 北京的景点列表
const beijingAttractions: AttractionInfo[] = [
  {
    name: '天安门广场',
    image: $r('app.media.post_cover_01'),
    description: '天安门广场位于北京市中心，是世界上最大的城市广场之一，是中华人民共和国的象征。'
  },
  {
    name: '故宫博物院',
    image: $r('app.media.post_cover_02'),
    description: '故宫博物院是中国明清两朝的皇家宫殿，现为世界文化遗产，是中国古代宫廷建筑之精华。'
  },
  {
    name: '天坛公园',
    image: $r('app.media.ic_city_guide_temple_heaven'),
    description: '天坛公园是明清两朝皇帝"祭天"和"祈谷"的场所，是中国现存最大的古代祭祀性建筑群。'
  },
  {
    name: '颐和园',
    image: $r('app.media.ic_city_guide_summer_palace'),
    description: '颐和园是中国古典园林之首，是清朝时期的皇家园林，被誉为"皇家园林博物馆"。'
  },
  {
    name: '圆明园',
    image: $r('app.media.post_cover_03'),
    description: '圆明园是清代大型皇家园林，有"万园之园"之称，现为爱国主义教育基地。'
  },
  {
    name: '北京环球度假区',
    image: $r('app.media.post_cover_04'),
    description: '北京环球度假区是亚洲第三座、全球第五座环球影城主题公园，是集主题公园、度假酒店、商业娱乐于一体的旅游度假区。'
  },
  {
    name: '前门大街',
    image: $r('app.media.post_cover_05'),
    description: '前门大街是北京著名的商业街，有着600多年的历史，是北京老字号最集中的地方。'
  },
  {
    name: '中国国家博物馆',
    image: $r('app.media.post_cover_06'),
    description: '中国国家博物馆是中华文化的祠堂和祖庙，是历史与艺术并重，集收藏、展览、研究、考古、公共教育、文化交流于一体的综合性博物馆。'
  },
  {
    name: '八达岭长城',
    image: $r('app.media.post_cover_01'),
    description: '八达岭长城是明长城中保存最好、最具代表性的一段，是万里长城的精华，被称为"天下九塞"之一。'
  },
  {
    name: '明十三陵',
    image: $r('app.media.post_cover_02'),
    description: '明十三陵是明朝皇帝的陵墓群，是中国现存规模最大、帝后陵寝最多的一处皇陵建筑群。'
  },
  {
    name: '鸟巢',
    image: $r('app.media.post_cover_03'),
    description: '鸟巢是2008年北京奥运会主体育场，现已成为北京的新地标和旅游景点。'
  },
  {
    name: '水立方',
    image: $r('app.media.post_cover_04'),
    description: '水立方是2008年北京奥运会游泳、跳水、花样游泳项目的比赛场馆，现为多功能水上运动中心。'
  },
  {
    name: '什刹海',
    image: $r('app.media.post_cover_05'),
    description: '什刹海是北京内城唯一一处具有开阔水面的开放型景区，也是北京城内面积最大、风貌保存最完整的一片历史街区。'
  },
  {
    name: '南锣鼓巷',
    image: $r('app.media.post_cover_06'),
    description: '南锣鼓巷是北京最古老的街区之一，是最赋有老北京风情的街巷，是北京旅游的热门景点。'
  },
  {
    name: '798艺术区',
    image: $r('app.media.post_cover_01'),
    description: '798艺术区是北京的文化创意产业集聚区，是当代艺术的展示、创作、交易中心。'
  },
  {
    name: '雍和宫',
    image: $r('app.media.post_cover_02'),
    description: '雍和宫是北京最大的藏传佛教寺院，是清朝中后期全国规格最高的一座佛教寺院。'
  },
  {
    name: '恭王府',
    image: $r('app.media.post_cover_03'),
    description: '恭王府是清代规模最大的一座王府，曾先后作为和珅、永璘的宅邸，现为全国重点文物保护单位。'
  },
  {
    name: '景山公园',
    image: $r('app.media.post_cover_04'),
    description: '景山公园是元、明、清三代的皇家御苑，是北京中轴线上的制高点，可以俯瞰整个紫禁城。'
  },
  {
    name: '北海公园',
    image: $r('app.media.post_cover_05'),
    description: '北海公园是中国现存最古老、最完整、最具综合性和代表性的皇家园林之一。'
  },
  {
    name: '王府井大街',
    image: $r('app.media.post_cover_06'),
    description: '王府井大街是北京著名的商业街，有着"金街"的美誉，是北京最繁华的商业区之一。'
  },
  {
    name: '三里屯',
    image: $r('app.media.post_cover_01'),
    description: '三里屯是北京著名的时尚地标，是集购物、餐饮、娱乐、文化于一体的国际化商业区。'
  },
  {
    name: '后海',
    image: $r('app.media.post_cover_02'),
    description: '后海是北京内城唯一一处具有开阔水面的开放型景区，是北京著名的酒吧街和夜生活区。'
  },
  {
    name: '钟鼓楼',
    image: $r('app.media.post_cover_03'),
    description: '钟鼓楼是元、明、清三代都城的报时中心，是北京中轴线上的重要建筑。'
  },
  {
    name: '孔庙',
    image: $r('app.media.post_cover_04'),
    description: '孔庙是元、明、清三代祭祀孔子的场所，是中国现存规模最大的孔庙。'
  },
  {
    name: '国子监',
    image: $r('app.media.post_cover_05'),
    description: '国子监是中国元、明、清三代国家管理教育的最高行政机关和国家设立的最高学府。'
  },
  {
    name: '大观园',
    image: $r('app.media.post_cover_06'),
    description: '大观园是依据中国古典文学名著《红楼梦》中描述的"大观园"建造的古典文化园林。'
  },
  {
    name: '香山公园',
    image: $r('app.media.post_cover_01'),
    description: '香山公园是北京著名的赏红叶胜地，是集自然风光、人文景观于一体的综合性公园。'
  },
  {
    name: '植物园',
    image: $r('app.media.post_cover_02'),
    description: '北京植物园是集植物科学研究、植物知识普及、游览观赏休憩、种质资源保护、新优植物推广等功能为一体的大型综合性植物园。'
  },
  {
    name: '动物园',
    image: $r('app.media.post_cover_03'),
    description: '北京动物园是中国最大的动物园之一，是集动物保护、科学研究、科普教育、休闲娱乐于一体的综合性动物园。'
  },
  {
    name: '海洋馆',
    image: $r('app.media.post_cover_04'),
    description: '北京海洋馆是世界最大的内陆水族馆，是集观赏、科普教育、休闲娱乐为一体的大型海洋生物科普基地。'
  }
]

// 南京的景点列表
const nanjingAttractions: AttractionInfo[] = [
  {
    name: '中山陵',
    image: $r('app.media.post_cover_01'),
    description: '中山陵是中国民主革命先行者孙中山先生的陵墓，是中国规模最大、保存最完整的近代纪念建筑群之一。'
  },
  {
    name: '明孝陵',
    image: $r('app.media.post_cover_05'),
    description: '明孝陵是明朝开国皇帝朱元璋和皇后马氏的合葬陵墓，是中国现存规模最大的帝王陵寝之一。'
  },
  {
    name: '夫子庙',
    image: $r('app.media.post_cover_06'),
    description: '夫子庙是中国第一所国家最高学府，是中国四大文庙之一，是南京的文化地标。'
  },
  {
    name: '秦淮河',
    image: $r('app.media.post_cover_01'),
    description: '秦淮河是南京的母亲河，是南京历史文化的重要载体，是南京最著名的旅游景点之一。'
  },
  {
    name: '总统府',
    image: $r('app.media.post_cover_02'),
    description: '总统府是中国近代建筑遗存中规模最大、保存最完整的建筑群，是中国近代历史的重要见证。'
  },
  {
    name: '南京博物院',
    image: $r('app.media.post_cover_03'),
    description: '南京博物院是中国三大博物馆之一，是中国第一座由国家投资兴建的大型综合类博物馆。'
  },
  {
    name: '玄武湖',
    image: $r('app.media.post_cover_04'),
    description: '玄武湖是江南地区最大的城内公园，是中国最大的皇家园林湖泊，是南京的"城市客厅"。'
  },
  {
    name: '鸡鸣寺',
    image: $r('app.media.post_cover_05'),
    description: '鸡鸣寺是南京最古老的梵刹之一，是南朝时期中国的佛教中心，有"南朝第一寺"的美誉。'
  },
  {
    name: '南京大屠杀纪念馆',
    image: $r('app.media.post_cover_06'),
    description: '南京大屠杀纪念馆是中国人民抗日战争的重要纪念地，是进行爱国主义教育的重要基地。'
  },
  {
    name: '雨花台',
    image: $r('app.media.post_cover_01'),
    description: '雨花台是南京著名的风景名胜区，是革命烈士的纪念地，是进行爱国主义教育的重要场所。'
  },
  {
    name: '紫金山',
    image: $r('app.media.post_cover_02'),
    description: '紫金山是南京的"城市绿肺"，是集自然风光、人文景观、科学教育于一体的综合性风景名胜区。'
  },
  {
    name: '南京城墙',
    image: $r('app.media.post_cover_01'),
    description: '南京明城墙是中国现存规模最大、保存最完整的古代城墙，是世界上现存最长的砖石结构古代城墙。'
  },
  {
    name: '中华门',
    image: $r('app.media.post_cover_03'),
    description: '中华门是南京明城墙的十三座明代京城城门之一，是中国现存规模最大的城门，是世界上保存最完好、结构最复杂的堡垒瓮城。'
  },
  {
    name: '瞻园',
    image: $r('app.media.post_cover_04'),
    description: '瞻园是南京现存历史最久的明代古典园林，是江南四大名园之一，是"金陵第一园"。'
  },
  {
    name: '莫愁湖',
    image: $r('app.media.post_cover_05'),
    description: '莫愁湖是南京著名的古典园林，是江南古典名园之一，有着"金陵第一名胜"的美誉。'
  },
  {
    name: '栖霞山',
    image: $r('app.media.post_cover_06'),
    description: '栖霞山是南京著名的风景名胜区，是中国四大赏枫胜地之一，有着"金陵第一明秀山"的美誉。'
  },
  {
    name: '牛首山',
    image: $r('app.media.post_cover_01'),
    description: '牛首山是南京著名的佛教名山，是集文化、旅游、休闲于一体的综合性风景名胜区。'
  },
  {
    name: '老门东',
    image: $r('app.media.post_cover_02'),
    description: '老门东是南京传统民居聚集地，是南京历史文化的重要载体，是南京旅游的热门景点。'
  },
  {
    name: '新街口',
    image: $r('app.media.post_cover_03'),
    description: '新街口是南京的商业中心，是集购物、餐饮、娱乐、文化于一体的现代化商业区。'
  },
  {
    name: '南京大学',
    image: $r('app.media.post_cover_04'),
    description: '南京大学是中国著名的高等学府，是中国"双一流"建设高校，是南京的文化地标。'
  },
  {
    name: '东南大学',
    image: $r('app.media.post_cover_05'),
    description: '东南大学是中国著名的高等学府，是中国"双一流"建设高校，是南京的文化地标。'
  },
  {
    name: '阅江楼',
    image: $r('app.media.post_cover_06'),
    description: '阅江楼是中国十大文化名楼之一，是江南四大名楼之一，是南京的标志性建筑。'
  },
  {
    name: '朝天宫',
    image: $r('app.media.post_cover_01'),
    description: '朝天宫是江南地区现存建筑等级最高、规模最大、保存最为完整的明清官式古建筑群落。'
  },
  {
    name: '甘熙故居',
    image: $r('app.media.post_cover_02'),
    description: '甘熙故居是南京现存面积最大、保存最完整的清代私人住宅，是南京民俗博物馆的所在地。'
  },
  {
    name: '大报恩寺',
    image: $r('app.media.post_cover_03'),
    description: '大报恩寺是南京著名的佛教寺院，是中国历史上规模最大、规格最高的寺院，是"天下第一塔"的所在地。'
  },
  {
    name: '南京眼',
    image: $r('app.media.post_cover_04'),
    description: '南京眼是南京的标志性建筑，是长江上首座观光步行桥，是南京的新地标。'
  },
  {
    name: '青奥公园',
    image: $r('app.media.post_cover_05'),
    description: '青奥公园是2014年南京青奥会的主会场，是集体育、文化、休闲于一体的综合性公园。'
  },
  {
    name: '绿博园',
    image: $r('app.media.post_cover_06'),
    description: '绿博园是南京的"城市绿肺"，是集生态、文化、休闲于一体的综合性公园。'
  },
  {
    name: '红山森林动物园',
    image: $r('app.media.post_cover_01'),
    description: '红山森林动物园是南京最大的动物园，是集动物保护、科学研究、科普教育、休闲娱乐于一体的综合性动物园。'
  },
  {
    name: '珍珠泉',
    image: $r('app.media.post_cover_02'),
    description: '珍珠泉是南京著名的风景名胜区，是集自然风光、人文景观、休闲娱乐于一体的综合性风景名胜区。'
  }
]

/**
 * 根据景点名称获取缩略图（优先从数据中查找，找不到则使用默认逻辑）
 */
export function getAttractionThumbnail(attraction: string, cityName?: string): ResourceStr {
  // 优先从景点数据中查找
  const attractions = cityName === '北京' ? beijingAttractions : 
                      cityName === '南京' ? nanjingAttractions : 
                      [...beijingAttractions, ...nanjingAttractions]
  
  const foundAttraction = attractions.find(item => item.name === attraction || item.name.includes(attraction))
  if (foundAttraction) {
    return foundAttraction.image
  }
  
  // 如果找不到，使用备用逻辑
  const imageList: ResourceStr[] = [
    $r('app.media.post_cover_01'),
    $r('app.media.post_cover_02'),
    $r('app.media.post_cover_03'),
    $r('app.media.post_cover_04'),
    $r('app.media.post_cover_05'),
    $r('app.media.post_cover_06')
  ]
  
  // 根据景点名称返回对应的图片
  if (attraction.includes('天坛') || attraction.includes('天坛公园')) {
    return $r('app.media.ic_city_guide_temple_heaven')
  } else if (attraction.includes('颐和园')) {
    return $r('app.media.ic_city_guide_summer_palace')
  } else if (attraction.includes('北京')) {
    return $r('app.media.ic_city_guide_beijing_header')
  } else if (attraction.includes('南京')) {
    return $r('app.media.ic_city_guide_nanjing_header')
  }
  
  // 默认情况下，根据景点名称的字符码总和选择不同的图片，降低重复率
  let hash = 0
  for (let i = 0; i < attraction.length; i++) {
    hash = hash * 31 + attraction.charCodeAt(i)
  }
  // 使用绝对值确保索引为正数，然后取模
  return imageList[Math.abs(hash) % imageList.length]
}

/**
 * 获取指定城市和天数的线路规划
 */
export function getRoutes(city: string, days: number): RouteItem[] {
  const cityName = city.replace('市', '')
  const attractions = cityName === '北京' ? beijingAttractions : nanjingAttractions
  
  // 如果选择1天，返回多个一日游选项，每个选项一天游玩一个地点
  if (days === 1) {
    return attractions.slice(0, 15).map((attraction: AttractionInfo, index: number): RouteItem => {
      return {
        id: `${cityName}_1day_${index + 1}`,
        title: `${cityName}一日游-${attraction.name}`,
        days: 1,
        locations: 1,
        attractions: [attraction.name],
        coverImage: attraction.image, // 直接使用景点数据中的图片
        city: cityName
      }
    })
  }

  // 多天线路规划
  const routes: RouteItem[] = []
  const routeCount = 5 // 每种天数生成5条线路
  
  for (let i = 0; i < routeCount; i++) {
    const startIndex = (i * days) % attractions.length
    const selectedAttractions: AttractionInfo[] = []
    
    // 根据天数选择景点
    for (let j = 0; j < days; j++) {
      const index = (startIndex + j) % attractions.length
      selectedAttractions.push(attractions[index])
    }
    
    const routeItem: RouteItem = {
      id: `${cityName}_${days}day_${i + 1}`,
      title: `${cityName}${days}日游-${selectedAttractions[0].name}:${selectedAttractions[0].name}深度游`,
      days: days,
      locations: days,
      attractions: selectedAttractions.map(item => item.name),
      coverImage: selectedAttractions[0].image, // 使用第一个景点的图片作为封面
      city: cityName
    }
    routes.push(routeItem)
  }
  
  return routes
}
