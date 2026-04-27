export interface AttractionDetail {
  id: number
  name: string
  headerImage: Resource
  openingHours: string
  location: string
  locationDetail: string
  distance: string
  introduction: string
  themeZones: ThemeZone[]
}

export interface ThemeZone {
  name: string
  image: Resource | string
  description: string
}

// 定义主题园区数据
const themeZones1: ThemeZone[] = [
  {
    name: '太和殿',
    image: $r('app.media.hotel_01'),
    description: '太和殿是故宫最重要的建筑之一，是明清两朝皇帝举行重大典礼的地方。殿内金碧辉煌，气势恢宏，展现了古代皇家建筑的极致工艺。'
  },
  {
    name: '乾清宫',
    image: $r('app.media.hotel_02'),
    description: '乾清宫是皇帝处理日常政务的地方，也是皇帝居住的主要宫殿。这里保存了大量珍贵的历史文物和艺术品。'
  },
  {
    name: '御花园',
    image: $r('app.media.hotel_03'),
    description: '御花园是故宫内最大的花园，园内古树参天，假山叠石，是皇帝和后妃们休闲娱乐的场所。'
  }
]

const themeZones2: ThemeZone[] = [
  {
    name: '北八楼',
    image: $r('app.media.hotel_04'),
    description: '北八楼是八达岭长城的最高点，登顶后可俯瞰整个长城蜿蜒曲折的壮丽景色，是拍照留念的最佳位置。'
  },
  {
    name: '好汉坡',
    image: $r('app.media.hotel_05'),
    description: '好汉坡是八达岭长城最陡峭的一段，攀登难度较大，但登顶后的成就感无与伦比，正所谓"不到长城非好汉"。'
  },
  {
    name: '长城博物馆',
    image: $r('app.media.hotel_06'),
    description: '长城博物馆展示了长城的历史文化、建筑工艺和防御体系，是了解长城文化的重要场所。'
  }
]

const themeZones3: ThemeZone[] = [
  {
    name: '变形金刚基地',
    image: $r('app.media.ic_attraction_detail_bg_1'),
    description: '这是全世界首个变形金刚主题景区。充满赛博坦风格的建筑和先进的科技感，让游客仿佛置身于变形金刚的世界。这里有刺激的霸天虎过山车，也有适合全家一起体验的变形金刚:火种源争夺战，还能在变形金刚:传奇现场与擎天柱等汽车人面对面交流。'
  },
  {
    name: '哈利波特的魔法世界',
    image: $r('app.media.ic_attraction_detail_bg_2'),
    description: '沉浸式体验哈利波特的魔法世界，参观霍格沃茨城堡，体验禁忌之旅，在奥利凡德魔杖店挑选专属魔杖，品尝黄油啤酒。'
  },
  {
    name: '小黄人乐园',
    image: $r('app.media.ic_attraction_detail_bg_3'),
    description: '充满欢乐的小黄人主题园区，适合全家游玩。体验神偷奶爸小黄人闹翻天，与小黄人互动，购买特色纪念品。'
  },
  {
    name: '功夫熊猫盖世之地',
    image: $r('app.media.ic_attraction_detail_bg_4'),
    description: '以功夫熊猫为主题的中国风园区，体验中国传统文化与动画的完美结合，感受功夫的魅力。'
  },
  {
    name: '侏罗纪世界努布拉岛',
    image: $r('app.media.hotel_01'),
    description: '进入侏罗纪世界，与恐龙近距离接触，体验惊险刺激的冒险之旅，感受史前世界的震撼。'
  },
  {
    name: '好莱坞',
    image: $r('app.media.hotel_02'),
    description: '好莱坞主题园区，体验电影制作的魅力，观看精彩的表演，感受好莱坞的星光璀璨。'
  },
  {
    name: '未来水世界',
    image: $r('app.media.hotel_03'),
    description: '未来水世界主题园区，观看精彩的水上特技表演，体验未来世界的科幻魅力。'
  }
]

// 定义详情数据
const detail1: AttractionDetail = {
  id: 1,
  name: '故宫博物院',
  headerImage: $r('app.media.ic_attraction_detail_bg_1'),
  openingHours: '今天10:00-22:00开放',
  location: '位于「天安门/王府井」王府井大街277号44号楼老北京风景街院内',
  locationDetail: '距中国国家博物馆直线距离999m',
  distance: '北京 距离你35公里',
  introduction: '故宫博物院是中国明清两朝的皇家宫殿，位于北京市中心，是世界上现存规模最大、保存最为完整的木质结构古建筑群。这里收藏了大量珍贵文物，展现了中华文明的博大精深。',
  themeZones: themeZones1
}

const detail2: AttractionDetail = {
  id: 2,
  name: '八达岭长城',
  headerImage: $r('app.media.ic_attraction_detail_bg_2'),
  openingHours: '今天08:00-17:00开放',
  location: '位于北京市延庆区八达岭镇',
  locationDetail: '距北京市中心直线距离60km',
  distance: '北京 距离你60公里',
  introduction: '八达岭长城是中国古代伟大的防御工程万里长城的重要组成部分，是明长城的一个隘口。这里地势险要，城墙坚固，是观赏长城壮丽景色的绝佳地点。',
  themeZones: themeZones2
}

const detail3: AttractionDetail = {
  id: 3,
  name: '北京环球度假区',
  headerImage: $r('app.media.ic_attraction_detail_bg_3'),
  openingHours: '今天10:00-22:00开放',
  location: '位于北京市通州区，毗邻东六环和京哈高速',
  locationDetail: '距北京市中心直线距离30km',
  distance: '北京 距离你30公里',
  introduction: '北京环球影城是全球第五家、亚洲第三家环球影城主题公园，位于北京市通州区，毗邻东六环和京哈高速。这里汇聚了全球顶级的娱乐设施和主题园区，为游客带来沉浸式的娱乐体验。',
  themeZones: themeZones3
}

// 旅游热点对应的详情数据
const themeZones4: ThemeZone[] = [
  {
    name: '冬季主题园区',
    image: $r('app.media.hotel_01'),
    description: '冬季假日主题园区是北京环球度假区在冬季推出的特别活动区域。这里装饰着精美的圣诞元素和冬季主题装饰，营造出浓厚的节日氛围。游客可以在这里体验各种冬季限定活动，品尝特色美食，购买限定纪念品。园区内还有精彩的冬季主题表演，为游客带来难忘的冬季体验。'
  },
  {
    name: '冰雪奇缘主题区',
    image: $r('app.media.hotel_02'),
    description: '冰雪奇缘主题区是冬季假日的亮点之一，以迪士尼经典动画《冰雪奇缘》为主题。这里还原了电影中的经典场景，包括艾莎的冰雪城堡、安娜的小屋等。游客可以在这里与艾莎和安娜互动，观看精彩的冰雪表演，体验冰雪魔法带来的奇妙感受。'
  },
  {
    name: '冬季美食街',
    image: $r('app.media.hotel_03'),
    description: '冬季美食街汇聚了各种冬季特色美食，包括热巧克力、烤红薯、糖葫芦等传统冬季小吃，还有各种国际美食。在这里，游客可以一边品尝美食，一边欣赏园区内的冬季装饰，感受浓浓的节日氛围。'
  }
]

const themeZones5: ThemeZone[] = [
  {
    name: '水上航线起点',
    image: $r('app.media.hotel_04'),
    description: '北京首条28公里水上航线的起点站，位于北京市中心区域。这里设有现代化的码头设施，游客可以在这里登船，开始精彩的水上之旅。起点站周边还有各种餐饮和购物设施，方便游客在出发前做好准备。'
  },
  {
    name: '沿途风景',
    image: $r('app.media.hotel_05'),
    description: '水上航线沿途经过多个著名景点，包括颐和园、圆明园、什刹海等。游客可以在船上欣赏到北京独特的城市风光和历史文化景观。航线设计充分考虑了游客的观赏需求，确保沿途风景的最佳观赏角度。'
  },
  {
    name: '终点站',
    image: $r('app.media.hotel_06'),
    description: '水上航线的终点站位于北京郊区，这里设有完善的旅游设施，包括餐厅、商店、休息区等。游客可以在这里下船，继续探索周边的景点，或者选择返程。终点站周边还有多个著名景点，是游客深度游览北京的好起点。'
  }
]

const themeZones6: ThemeZone[] = [
  {
    name: '三里屯太古里',
    image: $r('app.media.ic_attraction_detail_bg_1'),
    description: '三里屯太古里是北京最时尚的购物和娱乐中心之一，在秋天更是美不胜收。这里的建筑风格现代而独特，秋天时，街道两旁的银杏树叶子变成金黄色，与现代化的建筑形成美丽的对比。游客可以在这里购物、品尝美食、欣赏秋景，感受北京秋天的独特魅力。'
  },
  {
    name: '三里屯酒吧街',
    image: $r('app.media.ic_attraction_detail_bg_2'),
    description: '三里屯酒吧街是北京最著名的夜生活区域之一。秋天时，这里的氛围更加温馨浪漫。街道两旁的各种酒吧和餐厅在秋日的阳光下显得格外迷人。游客可以在这里享受美食，品尝美酒，感受北京夜生活的独特魅力。'
  },
  {
    name: '三里屯公园',
    image: $r('app.media.ic_attraction_detail_bg_3'),
    description: '三里屯公园是附近居民和游客休闲的好去处。秋天时，公园内的树木叶子变成各种颜色，形成美丽的秋景。这里还有各种休闲设施，包括步道、健身器材、儿童游乐区等，是放松身心的好地方。'
  }
]

const themeZones7: ThemeZone[] = [
  {
    name: '红叶观赏区',
    image: $r('app.media.ic_attraction_detail_bg_4'),
    description: '八达岭长城的红叶观赏区是秋季最受欢迎的景点之一。每年10月中旬到11月初，这里的枫叶、黄栌等树木叶子变成红色和黄色，形成壮观的"红季"景观。游客可以沿着长城步道漫步，欣赏沿途的红叶美景，感受秋天的魅力。'
  },
  {
    name: '长城登高',
    image: $r('app.media.hotel_01'),
    description: '秋季是登长城的最佳季节之一，天气凉爽，视野开阔。从长城上俯瞰，可以看到漫山遍野的红叶，景色壮丽。登高望远，不仅能欣赏到美丽的秋景，还能感受到长城的雄伟壮观，是一次难忘的体验。'
  },
  {
    name: '秋季特色活动',
    image: $r('app.media.hotel_02'),
    description: '八达岭长城在秋季会举办各种特色活动，包括红叶节、摄影大赛、文化展览等。这些活动为游客提供了更多了解长城文化和欣赏秋景的机会。游客可以参与这些活动，体验更加丰富的旅游内容。'
  },
  {
    name: '周边美食',
    image: $r('app.media.hotel_03'),
    description: '八达岭长城周边有各种特色美食，包括农家菜、烤全羊、山野菜等。秋季时，这里的食材更加新鲜，味道更加鲜美。游客可以在游览完长城后，品尝这些特色美食，感受当地的风土人情。'
  }
]

const detail4: AttractionDetail = {
  id: 4,
  name: '北京环球"冬季假日"正式回归',
  headerImage: $r('app.media.ic_attraction_detail_bg_4'),
  openingHours: '今天10:00-22:00开放',
  location: '位于北京市通州区，毗邻东六环和京哈高速',
  locationDetail: '距北京市中心直线距离30km',
  distance: '距离你35公里',
  introduction: '北京环球度假区"冬季假日"活动正式回归，为游客带来全新的冬季体验。活动期间，园区内装饰着精美的冬季主题装饰，包括圣诞树、雪花、彩灯等，营造出浓厚的节日氛围。游客可以在这里体验各种冬季限定活动，观看精彩的冬季主题表演，品尝特色美食，购买限定纪念品。这是一个适合全家出游的冬季旅游目的地。',
  themeZones: themeZones4
}

const detail5: AttractionDetail = {
  id: 5,
  name: '北京首条! 28公里水上航线正式通航',
  headerImage: $r('app.media.ic_reputation_header'),
  openingHours: '今天08:00-18:00开放',
  location: '位于北京市中心区域，起点站位于什刹海附近',
  locationDetail: '距天安门广场直线距离5km',
  distance: '距离你35公里',
  introduction: '北京首条28公里水上航线正式通航，为游客提供了一种全新的游览北京的方式。这条航线连接了北京市中心的多个著名景点，包括颐和园、圆明园、什刹海等。游客可以在船上欣赏到北京独特的城市风光和历史文化景观，感受这座古都的魅力。航线采用现代化的游船，设施完善，服务周到，是一次舒适而难忘的水上之旅。',
  themeZones: themeZones5
}

const detail6: AttractionDetail = {
  id: 6,
  name: '秋天的北京三里屯有多美',
  headerImage: $r('app.media.ic_travel_hotspot_header'),
  openingHours: '全天开放',
  location: '位于北京市朝阳区三里屯',
  locationDetail: '距国贸CBD直线距离2km',
  distance: '距离你35公里',
  introduction: '秋天的北京三里屯是一个充满魅力的地方。这里的建筑风格现代而独特，秋天时，街道两旁的银杏树叶子变成金黄色，与现代化的建筑形成美丽的对比。三里屯不仅是购物和娱乐的中心，更是一个欣赏秋景的好地方。游客可以在这里购物、品尝美食、欣赏秋景，感受北京秋天的独特魅力。无论是白天还是夜晚，三里屯都有不同的美，值得游客细细品味。',
  themeZones: themeZones6
}

const detail7: AttractionDetail = {
  id: 7,
  name: '八达岭红季游玩攻略',
  headerImage: $r('app.media.ic_attraction_detail_bg_1'),
  openingHours: '今天08:00-17:00开放',
  location: '位于北京市延庆区八达岭镇',
  locationDetail: '距北京市中心直线距离60km',
  distance: '距离你35公里',
  introduction: '八达岭长城的"红季"是秋季最受欢迎的旅游时段之一。每年10月中旬到11月初，这里的枫叶、黄栌等树木叶子变成红色和黄色，形成壮观的"红季"景观。游客可以沿着长城步道漫步，欣赏沿途的红叶美景，感受秋天的魅力。除了欣赏红叶，游客还可以登高望远，感受长城的雄伟壮观，参与各种秋季特色活动，品尝周边美食，体验更加丰富的旅游内容。',
  themeZones: themeZones7
}

// 南京景点主题园区数据
const nanjingThemeZones1: ThemeZone[] = [
  {
    name: '博爱坊',
    image: $r('app.media.hotel_01'),
    description: '博爱坊是中山陵的入口，牌坊上刻有"博爱"二字，体现了孙中山先生博爱天下的伟大胸怀。这里是游客进入中山陵的第一站，也是拍照留念的绝佳位置。'
  },
  {
    name: '祭堂',
    image: $r('app.media.hotel_02'),
    description: '祭堂是中山陵的主体建筑，位于陵墓的最高处。这里安放着孙中山先生的坐像，是瞻仰和缅怀孙中山先生的重要场所。建筑风格庄严肃穆，体现了对伟人的敬仰。'
  },
  {
    name: '音乐台',
    image: $r('app.media.hotel_03'),
    description: '音乐台是中山陵景区内的一个重要景点，这里经常举办各种音乐会和演出活动。建筑风格独特，环境优美，是游客休闲娱乐的好去处。'
  }
]

const nanjingThemeZones2: ThemeZone[] = [
  {
    name: '神道',
    image: $r('app.media.hotel_04'),
    description: '明孝陵神道是通往陵墓的主要道路，两侧排列着石像生，包括石兽、石人等，展现了明代皇家陵寝的威严。神道全长约600米，是明孝陵的重要组成部分。'
  },
  {
    name: '方城明楼',
    image: $r('app.media.hotel_05'),
    description: '方城明楼是明孝陵的核心建筑，是明太祖朱元璋的陵墓所在地。建筑宏伟壮观，体现了明代建筑艺术的最高水平。这里是了解明代历史和文化的重要场所。'
  },
  {
    name: '梅花山',
    image: $r('app.media.hotel_06'),
    description: '梅花山位于明孝陵景区内，是南京著名的赏梅胜地。每年春季，这里梅花盛开，香气四溢，吸引了大量游客前来观赏。秋季时，这里的银杏叶也格外美丽。'
  }
]

const nanjingThemeZones3: ThemeZone[] = [
  {
    name: '大成殿',
    image: $r('app.media.ic_attraction_detail_bg_1'),
    description: '大成殿是夫子庙的核心建筑，是祭祀孔子的主要场所。殿内供奉着孔子的塑像，是了解儒家文化的重要地方。建筑风格古朴典雅，体现了中国传统文化的深厚底蕴。'
  },
  {
    name: '秦淮河',
    image: $r('app.media.ic_attraction_detail_bg_2'),
    description: '秦淮河是南京的母亲河，也是夫子庙景区的重要组成部分。夜晚时分，秦淮河两岸灯火辉煌，游船穿梭，景色美不胜收。这里还有各种传统小吃和特色商品。'
  },
  {
    name: '江南贡院',
    image: $r('app.media.ic_attraction_detail_bg_3'),
    description: '江南贡院是中国古代最大的科举考场，是了解中国古代科举制度的重要场所。这里保存了大量历史文物和资料，展现了古代科举考试的盛况。'
  }
]

const nanjingThemeZones4: ThemeZone[] = [
  {
    name: '总统府办公楼',
    image: $r('app.media.ic_attraction_detail_bg_4'),
    description: '总统府办公楼是民国时期的重要建筑，见证了近代中国的历史变迁。这里曾是国民政府的主要办公场所，现在作为博物馆对外开放，展示了丰富的历史文物。'
  },
  {
    name: '煦园',
    image: $r('app.media.hotel_01'),
    description: '煦园是总统府内的古典园林，是典型的江南园林风格。园内亭台楼阁、假山池沼，景色优美，是游客休闲游览的好去处。'
  },
  {
    name: '历史展览馆',
    image: $r('app.media.hotel_02'),
    description: '历史展览馆展示了总统府的历史变迁和重要事件，通过丰富的文物和资料，让游客了解近代中国的历史发展。'
  }
]

const nanjingThemeZones5: ThemeZone[] = [
  {
    name: '环湖步道',
    image: $r('app.media.hotel_03'),
    description: '玄武湖环湖步道全长约10公里，是南京市民和游客休闲健身的好去处。沿途风景优美，可以欣赏到湖光山色，感受大自然的魅力。'
  },
  {
    name: '五洲',
    image: $r('app.media.hotel_04'),
    description: '玄武湖内有五个小岛，被称为"五洲"，每个洲都有不同的特色和景观。游客可以乘船游览，也可以步行游览，体验不同的风景。'
  },
  {
    name: '玄武门',
    image: $r('app.media.hotel_05'),
    description: '玄武门是玄武湖的主要入口，也是南京古城墙的一部分。这里保存了古城墙的遗迹，是了解南京历史文化的重要场所。'
  }
]

const nanjingThemeZones6: ThemeZone[] = [
  {
    name: '历史馆',
    image: $r('app.media.hotel_06'),
    description: '南京博物院历史馆展示了从史前到近代的江苏历史，通过丰富的文物和展品，让游客了解江苏地区的历史文化发展。'
  },
  {
    name: '艺术馆',
    image: $r('app.media.ic_attraction_detail_bg_1'),
    description: '艺术馆收藏了大量珍贵的艺术品，包括书画、陶瓷、玉器等，展现了中华文明的博大精深。这里经常举办各种专题展览。'
  },
  {
    name: '特展馆',
    image: $r('app.media.ic_attraction_detail_bg_2'),
    description: '特展馆定期举办各种专题展览，包括《六朝风采》等特色展览，为游客提供更加丰富的文化体验。'
  }
]

const nanjingThemeZones7: ThemeZone[] = [
  {
    name: '大雄宝殿',
    image: $r('app.media.ic_attraction_detail_bg_3'),
    description: '鸡鸣寺大雄宝殿是寺内的主要建筑，供奉着释迦牟尼佛。建筑风格古朴，香火旺盛，是信众和游客参拜的重要场所。'
  },
  {
    name: '药师佛塔',
    image: $r('app.media.ic_attraction_detail_bg_4'),
    description: '药师佛塔是鸡鸣寺的标志性建筑，塔高七层，登塔可以俯瞰南京城的美景。每年樱花季，这里更是美不胜收。'
  },
  {
    name: '樱花大道',
    image: $r('app.media.hotel_01'),
    description: '鸡鸣寺外的樱花大道是南京著名的赏樱胜地，每年3-4月樱花盛开时，这里游人如织，景色如画，是拍照留念的绝佳地点。'
  }
]

const nanjingThemeZones8: ThemeZone[] = [
  {
    name: '中华门',
    image: $r('app.media.hotel_02'),
    description: '中华门是南京城墙最著名的城门之一，也是世界上保存最完整的瓮城。这里保存了大量历史遗迹，是了解南京城墙历史的重要场所。'
  },
  {
    name: '城墙博物馆',
    image: $r('app.media.hotel_03'),
    description: '城墙博物馆展示了南京城墙的历史、建筑工艺和防御体系，通过丰富的展品和资料，让游客了解这座古城的防御文化。'
  },
  {
    name: '夜游活动',
    image: $r('app.media.hotel_04'),
    description: '南京城墙夜游活动是近年来推出的特色旅游项目，游客可以在夜晚登上城墙，欣赏南京城的夜景，感受古城的魅力。'
  }
]

const nanjingThemeZones9: ThemeZone[] = [
  {
    name: '烈士纪念碑',
    image: $r('app.media.hotel_05'),
    description: '雨花台烈士纪念碑是雨花台的核心建筑，高42.3米，象征着1942年3月。这里是缅怀革命先烈的重要场所，每年都有大量游客前来瞻仰。'
  },
  {
    name: '烈士纪念馆',
    image: $r('app.media.hotel_06'),
    description: '烈士纪念馆展示了雨花台烈士的英勇事迹和革命历史，通过丰富的文物和资料，让游客了解那段艰苦卓绝的革命岁月。'
  },
  {
    name: '雨花石文化区',
    image: $r('app.media.ic_attraction_detail_bg_1'),
    description: '雨花石文化区展示了雨花石的文化内涵和艺术价值，游客可以在这里欣赏到各种精美的雨花石，了解这一独特的文化现象。'
  }
]

const nanjingThemeZones10: ThemeZone[] = [
  {
    name: '天文台',
    image: $r('app.media.ic_attraction_detail_bg_2'),
    description: '紫金山天文台是中国第一座现代天文台，这里保存了大量珍贵的天文仪器和历史资料，是了解中国天文学发展的重要场所。'
  },
  {
    name: '明孝陵',
    image: $r('app.media.ic_attraction_detail_bg_3'),
    description: '明孝陵位于紫金山南麓，是明太祖朱元璋的陵墓。这里保存了完整的明代皇家陵寝建筑，是了解明代历史的重要场所。'
  },
  {
    name: '登山步道',
    image: $r('app.media.ic_attraction_detail_bg_4'),
    description: '紫金山有多条登山步道，适合不同体力的游客。秋季时，山上层林尽染，景色壮丽，是登山赏景的好时节。'
  }
]

// 南京景点详情数据
const nanjingDetail1: AttractionDetail = {
  id: 1,
  name: '中山陵',
  headerImage: $r('app.media.ic_city_guide_sun_mausoleum'),
  openingHours: '今天08:30-17:00开放',
  location: '位于南京市玄武区紫金山南麓',
  locationDetail: '距新街口直线距离8km',
  distance: '南京 距离你15公里',
  introduction: '中山陵是中国近代伟大的民主革命先行者孙中山先生的陵墓，位于南京市玄武区紫金山南麓。陵墓建筑宏伟，气势磅礴，体现了对孙中山先生的敬仰和缅怀。这里不仅是重要的历史纪念地，也是南京著名的旅游景点，每年吸引大量游客前来瞻仰。',
  themeZones: nanjingThemeZones1
}

const nanjingDetail2: AttractionDetail = {
  id: 2,
  name: '明孝陵',
  headerImage: $r('app.media.ic_city_guide_ming_wall'),
  openingHours: '今天06:30-18:30开放',
  location: '位于南京市玄武区紫金山南麓',
  locationDetail: '距中山陵直线距离1.5km',
  distance: '南京 距离你12公里',
  introduction: '明孝陵是明太祖朱元璋与马皇后的合葬陵墓，位于南京市玄武区紫金山南麓。这是中国规模最大的帝王陵寝之一，也是世界文化遗产。陵墓建筑宏伟，神道两侧的石像生保存完好，展现了明代皇家陵寝的威严和艺术价值。秋季时，这里的银杏叶格外美丽，是赏秋的好去处。',
  themeZones: nanjingThemeZones2
}

const nanjingDetail3: AttractionDetail = {
  id: 3,
  name: '夫子庙',
  headerImage: $r('app.media.ic_city_guide_nanjing_header'),
  openingHours: '今天09:00-22:00开放',
  location: '位于南京市秦淮区贡院街',
  locationDetail: '距新街口直线距离2km',
  distance: '南京 距离你8公里',
  introduction: '夫子庙是供奉和祭祀孔子的地方，也是南京最著名的历史文化街区之一。这里不仅有古色古香的建筑，还有繁华的商业街和美食街。夜晚时分，秦淮河两岸灯火辉煌，游船穿梭，景色美不胜收。游客可以在这里品尝各种传统小吃，购买特色商品，感受南京的历史文化魅力。',
  themeZones: nanjingThemeZones3
}

const nanjingDetail4: AttractionDetail = {
  id: 4,
  name: '总统府',
  headerImage: $r('app.media.ic_attraction_detail_bg_1'),
  openingHours: '今天08:30-17:00开放',
  location: '位于南京市玄武区长江路292号',
  locationDetail: '距新街口直线距离1.5km',
  distance: '南京 距离你7公里',
  introduction: '总统府是中国近代建筑遗存中规模最大、保存最完整的建筑群，也是南京民国建筑的主要代表之一。这里曾是太平天国天王府、两江总督署、中华民国临时大总统府等，见证了近代中国的历史变迁。现在作为博物馆对外开放，展示了丰富的历史文物和资料。',
  themeZones: nanjingThemeZones4
}

const nanjingDetail5: AttractionDetail = {
  id: 5,
  name: '玄武湖',
  headerImage: $r('app.media.ic_attraction_detail_bg_2'),
  openingHours: '全天开放',
  location: '位于南京市玄武区',
  locationDetail: '距新街口直线距离3km',
  distance: '南京 距离你10公里',
  introduction: '玄武湖是南京最大的城市公园，也是中国最大的皇家园林湖泊之一。这里风景优美，环境宜人，是南京市民和游客休闲娱乐的好去处。湖内有五个小岛，被称为"五洲"，每个洲都有不同的特色和景观。游客可以乘船游览，也可以沿着环湖步道漫步，欣赏湖光山色。',
  themeZones: nanjingThemeZones5
}

const nanjingDetail6: AttractionDetail = {
  id: 6,
  name: '南京博物院',
  headerImage: $r('app.media.ic_attraction_detail_bg_3'),
  openingHours: '今天09:00-17:00开放',
  location: '位于南京市玄武区中山东路321号',
  locationDetail: '距新街口直线距离4km',
  distance: '南京 距离你11公里',
  introduction: '南京博物院是中国三大博物馆之一，也是中国最早创建的博物馆。这里收藏了大量珍贵的历史文物和艺术品，包括书画、陶瓷、玉器、青铜器等，展现了中华文明的博大精深。博物院还定期举办各种专题展览，如《六朝风采》等，为游客提供丰富的文化体验。',
  themeZones: nanjingThemeZones6
}

const nanjingDetail7: AttractionDetail = {
  id: 7,
  name: '鸡鸣寺',
  headerImage: $r('app.media.ic_attraction_detail_bg_4'),
  openingHours: '今天07:30-17:00开放',
  location: '位于南京市玄武区鸡鸣寺路1号',
  locationDetail: '距新街口直线距离3km',
  distance: '南京 距离你9公里',
  introduction: '鸡鸣寺是南京最古老的梵刹之一，有"南朝第一寺"的美誉。这里不仅是重要的佛教圣地，也是南京著名的旅游景点。每年3-4月樱花盛开时，寺外的樱花大道更是美不胜收，吸引了大量游客前来观赏。寺内的药师佛塔是标志性建筑，登塔可以俯瞰南京城的美景。',
  themeZones: nanjingThemeZones7
}

const nanjingDetail8: AttractionDetail = {
  id: 8,
  name: '南京城墙',
  headerImage: $r('app.media.hotel_01'),
  openingHours: '今天08:00-20:00开放',
  location: '位于南京市秦淮区中华门',
  locationDetail: '距新街口直线距离2km',
  distance: '南京 距离你6公里',
  introduction: '南京城墙是中国现存规模最大的城墙，也是世界现存最长的古代城墙之一。城墙全长约35公里，保存完好，是了解中国古代城市防御体系的重要场所。中华门是南京城墙最著名的城门之一，也是世界上保存最完整的瓮城。近年来推出的夜游活动，让游客可以在夜晚登上城墙，欣赏南京城的夜景。',
  themeZones: nanjingThemeZones8
}

const nanjingDetail9: AttractionDetail = {
  id: 9,
  name: '雨花台',
  headerImage: $r('app.media.hotel_02'),
  openingHours: '今天06:00-20:00开放',
  location: '位于南京市雨花台区雨花路215号',
  locationDetail: '距新街口直线距离5km',
  distance: '南京 距离你13公里',
  introduction: '雨花台是南京重要的红色旅游景点，也是全国重点文物保护单位。这里曾是革命先烈英勇就义的地方，现在建有烈士纪念碑、烈士纪念馆等，是缅怀革命先烈的重要场所。雨花台还是雨花石的产地，这里展示的雨花石文化也吸引了大量游客。',
  themeZones: nanjingThemeZones9
}

const nanjingDetail10: AttractionDetail = {
  id: 10,
  name: '紫金山',
  headerImage: $r('app.media.hotel_03'),
  openingHours: '全天开放',
  location: '位于南京市玄武区',
  locationDetail: '距新街口直线距离6km',
  distance: '南京 距离你14公里',
  introduction: '紫金山是南京的"城市绿肺"，也是南京最著名的自然风景区之一。这里不仅有优美的自然风光，还有丰富的历史文化遗迹，包括明孝陵、中山陵、天文台等。秋季时，山上层林尽染，景色壮丽，是登山赏景的好时节。紫金山有多条登山步道，适合不同体力的游客。',
  themeZones: nanjingThemeZones10
}

export const attractionDetailMap: Map<number, AttractionDetail> = new Map([
  [1, nanjingDetail1],
  [2, nanjingDetail2],
  [3, nanjingDetail3],
  [4, nanjingDetail4],
  [5, nanjingDetail5],
  [6, nanjingDetail6],
  [7, nanjingDetail7],
  [8, nanjingDetail8],
  [9, nanjingDetail9],
  [10, nanjingDetail10]
])

export function getAttractionDetailById(id: number): AttractionDetail | undefined {
  return attractionDetailMap.get(id)
}

