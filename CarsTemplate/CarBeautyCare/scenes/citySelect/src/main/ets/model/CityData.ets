
export class Cities {
  type: string;
  cities: string[];

  constructor(type: string , cities: string[]) {
    this.type = type;
    this.cities = cities
  }
}

export const CITY_DATA = [
  new Cities( 'A', ['鞍山市', '安庆市', '安阳市', '安康市', '阿坝藏族羌族自治州']),
  new Cities( 'B', ['北京市', '包头市', '保定市', '宝鸡市', '本溪市', '白山市', '蚌埠市', '滨州市']),
  new Cities( 'C', ['重庆市', '成都市', '长沙市', '长春市', '常州市', '滁州市', '常德市', '郴州市']),
  new Cities( 'D', ['大连市', '东莞市', '大庆市', '德州市', '东营市', '大同市', '丹东市']),
  new Cities( 'E', ['鄂尔多斯市', '恩施土家族苗族自治州', '鄂州市']),
  new Cities( 'F', ['佛山市', '福州市', '抚顺市', '阜阳市', '抚州市', '防城港市']),
  new Cities( 'G', ['广州市', '贵阳市', '桂林市', '赣州市', '广元市', '广安市', '固原市']),
  new Cities( 'H', ['杭州市', '合肥市', '哈尔滨市', '海口市', '惠州市', '呼和浩特市', '衡阳市']),
  new Cities( 'J', ['济南市', '青岛市', '嘉兴市', '金华市', '九江市', '吉林市', '江门市']),
  new Cities( 'K', ['昆明市', '开封市', '喀什地区', '克拉玛依市', '库尔勒市']),
  new Cities( 'L', ['兰州市', '洛阳市', '临沂市', '柳州市', '廊坊市', '泸州市', '丽水市']),
  new Cities( 'M', ['绵阳市', '马鞍山市', '茂名市', '梅州市', '牡丹江市']),
  new Cities( 'N', ['南京市', '宁波市', '南宁市', '南昌市', '南通市', '南充市', '宁德市']),
  new Cities( 'P', ['莆田市', '平顶山市', '盘锦市', '攀枝花市', '普洱市']),
  new Cities( 'Q', ['青岛市', '泉州市', '秦皇岛市', '齐齐哈尔市', '衢州市']),
  new Cities( 'R', ['日照市', '日喀则市']),
  new Cities( 'S', ['上海市', '深圳市', '苏州市', '沈阳市', '石家庄市', '绍兴市', '三亚市']),
  new Cities( 'T', ['天津市', '太原市', '唐山市', '泰州市', '台州市', '铁岭市']),
  new Cities( 'W', ['武汉市', '无锡市', '温州市', '乌鲁木齐市', '威海市', '渭南市']),
  new Cities( 'X', ['西安市', '厦门市', '徐州市', '湘潭市', '西宁市', '新乡市']),
  new Cities( 'Y', ['银川市', '烟台市', '扬州市', '盐城市', '宜宾市', '岳阳市']),
  new Cities( 'Z', ['郑州市', '珠海市', '淄博市', '镇江市', '张家口市', '漳州市'])
]

export interface CityCallBack{
  updateLocationName:(cityName:string) => void;
  getLocationName:() => string | Resource;
}

// 热门城市
export const HOT_CITY = ['北京', '上海', '广州', '深圳', '杭州', '南京', '苏州', '天津', '武汉', '长沙', '重庆', '成都'];

// AlphabetIndexer字母索引
export const ALPHABET_VALUE = ['当','热', 'A', 'B', 'C', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M','N', 'P' ,'Q', 'R', 'S', 'T', 'W', 'X', 'Y', 'Z'];