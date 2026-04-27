/**
 * 城市指南Mock数据
 */

export interface CityGuideInfo {
  cityName: string
  headerImage: ResourceStr
  introduction: string
  attractions: CityAttraction[]
}

export interface CityAttraction {
  name: string
  image: ResourceStr
  description: string
}

// 北京数据
const beijingAttractions: CityAttraction[] = [
  {
    name: '颐和园',
    image: $r('app.media.ic_city_guide_summer_palace'),
    description: '颐和园位于北京市西郊，距市中心约15公里，是清朝时期的皇家园林，原名清漪园，始建于1750年，1860年被英法联军焚毁，1886年开始重建，1888年更名为颐和园，是慈禧太后晚年颐养天年的地方。颐和园以杭州西湖为蓝本，汲取江南园林的设计手法和北方皇家园林的宏伟气势，是中国古典园林艺术的巅峰之作，也是世界上规模最大、保存最完整的皇家园林之一。'
  },
  {
    name: '天坛公园',
    image: $r('app.media.ic_city_guide_temple_heaven'),
    description: '天坛公园是明清两朝皇帝"祭天"和"祈谷"的场所，位于北京市东城区永定门内大街东侧。天坛始建于1420年，初名天地坛，兼具祭天和祭地功能。1530年，天地分祭，改称天坛。明清两朝共有22位皇帝在此举行过654次祭天大典。1918年1月1日，天坛正式对外开放，成为公园。天坛占地面积约273万平方米，整体布局呈"北圆南方"，象征"天圆地方"。天坛分为内坛和外坛，主要建筑集中在内坛。内坛由东西向的墙分为南北两部分，北为"祈年殿"，南为"圜丘坛"，两坛由一条长360米的丹陛桥相连，形成一条长1200米的南北建筑轴线，两侧是大面积的古柏林。'
  }
]

const beijingGuide: CityGuideInfo = {
  cityName: '北京',
  headerImage: $r('app.media.ic_city_guide_beijing_header'),
  introduction: '北京是中华人民共和国的首都，拥有约3000年的历史，历史文化底蕴深厚。这里有天安门广场、人民大会堂、故宫、颐和园、天坛等展现皇家气派的建筑，也有三里屯、什刹海等现代时尚的夜生活场所。',
  attractions: beijingAttractions
}

// 南京数据
const nanjingAttractions: CityAttraction[] = [
  {
    name: '明城墙',
    image: $r('app.media.ic_city_guide_ming_wall'),
    description: '南京明城墙是中国现存规模最大、保存最完整的古代城墙，也是世界上现存最长的砖石结构古代城墙，被誉为"中华瑰宝，世界奇观"。明城墙始建于明朝（1366-1393年），历时27年建成，是明太祖朱元璋为巩固首都防御而修建的。明城墙是明清两朝城市建设的杰出代表，集军事防御、防洪、城市规划于一体，展现了高超的建筑技艺。1988年被列为全国重点文物保护单位，2012年被列入中国世界文化遗产预备名单。如今，明城墙已成为南京的标志性建筑，城墙沿线形成了风景带，连接了多个景点，可以欣赏到秦淮河、紫金山等美景。'
  },
  {
    name: '中山陵',
    image: $r('app.media.ic_city_guide_sun_mausoleum'),
    description: '中山陵是中国民主革命先行者孙中山先生的陵墓及其附属纪念建筑群，位于南京市玄武区紫金山南麓，毗邻明孝陵、灵谷寺等历史名胜，占地面积超过8万平方米，是中国规模最大、保存最完整的近代纪念建筑群之一。中山陵是纪念孙中山先生、弘扬民主革命精神的重要场所，也是中国民主革命的精神象征，建筑风格融合了中国传统宫殿式建筑和西方现代设计理念。1961年被列为全国重点文物保护单位，2007年被评为国家5A级旅游景区，2019年入选"中国20世纪建筑遗产"名录。中山陵是南京最具代表性的旅游景点之一，每年吸引数百万游客前来参观，其周边的附属建筑也是热门的打卡地。'
  }
]

const nanjingGuide: CityGuideInfo = {
  cityName: '南京',
  headerImage: $r('app.media.ic_city_guide_nanjing_header'),
  introduction: '南京是一座历史文化名城，是江苏省省会，长江三角洲核心城市，国家历史文化名城，重要的科教中心。南京拥有千年历史底蕴与现代活力，既有"六朝金粉地"的优雅风韵，也有"十朝都会"的雄伟气魄，是一座集历史、科技、生态、人文于一体的城市。',
  attractions: nanjingAttractions
}

// 城市指南数据映射
const cityGuideMap: Map<string, CityGuideInfo> = new Map([
  ['北京', beijingGuide],
  ['南京', nanjingGuide]
])

/**
 * 根据城市名称获取城市指南信息
 * @param cityName 城市名称
 * @returns 城市指南信息，如果不存在则返回南京的数据
 */
export function getCityGuideByCityName(cityName: string): CityGuideInfo {
  // 处理城市名称，去除"市"后缀
  const normalizedCityName = cityName.replace(/市$/, '')
  
  // 如果城市是北京，返回北京数据；否则返回南京数据
  if (normalizedCityName === '北京') {
    return cityGuideMap.get('北京') || nanjingGuide
  } else {
    return cityGuideMap.get('南京') || nanjingGuide
  }
}

