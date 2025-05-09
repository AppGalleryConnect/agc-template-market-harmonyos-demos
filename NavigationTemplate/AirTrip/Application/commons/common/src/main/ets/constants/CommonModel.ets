import { DayInfo } from '../model/CalendarModel'

@ObservedV2
export class UserInfo {
  idToken: string = ''
  authCode: string = ''
  @Trace avatar: string = ''
  @Trace phoneNumber: string = ''
  @Trace userName: string = ''

  constructor(userInfo?: UserInfo) {
    this.idToken = userInfo?.idToken || ''
    this.authCode = userInfo?.authCode || ''
    this.avatar = userInfo?.avatar || ''
    this.phoneNumber = userInfo?.phoneNumber || ''
    this.userName = userInfo?.userName || ''
  }
}

export interface WebPageParams {
  linkUrl: ResourceStr;
  title?: ResourceStr;
}

export class BaseTabBarItem {
  type: string = ''
  text: ResourceStr = ''
  icon?: ResourceStr = ''

  constructor(type: string, text: ResourceStr, icon?: ResourceStr) {
    this.type = type
    this.text = text
    this.icon = icon
  }
}

// 选择列表弹框
export class BaseSelectedListItem {
  type: string = ''
  label: ResourceStr = ''

  constructor(type: string, label: ResourceStr) {
    this.type = type
    this.label = label
  }
}

// 用户登录信息数据
@ObservedV2
export class UserInfoStorage {
  @Trace isLogin: boolean = false;
  userInfo: UserInfo = new UserInfo();
}

@ObservedV2
export class DataStorage {
  @Trace curCity?: string = ''
  // 出发城市
  @Trace departureCity?: City
  // 到达城市
  @Trace destinationCity?: City
  // 出发日期
  @Trace departureDate?: DayInfo
  // 返程日期
  @Trace returnDate?: DayInfo
  // 日期页面选择的列表index
  selectCalendarListIndex: number = 0
  // 订单支付的最后时间
  @Trace payOrderTime: string = ''
}

@ObservedV2
export class City {
  cityId: string = ''
  cityCode: string = ''
  @Trace cityName: string = ''
}

// 定义城市类型类
export class CityType {
  name: string;
  cityList: string[];

  constructor(name: string, cityList: string[]) {
    this.name = name;
    this.cityList = cityList;
  }
}

export class CityDataModel {

  // 模拟获取城市数据
  static getCityData(): CityType[] {
    return [
      new CityType('A', ['阿尔山', '阿克苏', '阿拉善右旗', '阿拉善左旗', '阿勒泰', '阿里', '阿拉尔', '安康', '安庆', '鞍山', '安顺', '安阳', '安吉', '澳门']),
      new CityType('B', ['白城', '百色', '白山', '保山', '包头', '巴彦淖尔', '巴中', '北海', '北京', '蚌埠', '毕节', '博乐', '布尔津',
        '巴里坤', '滨州', '亳州']),
      new CityType('C', ['沧源', '长春', '常德', '昌都', '长沙', '常州', '承德', '成都', '郴州', '赤峰', '池州', '重庆',
        '长治', '朝阳', '崇礼']),
      new CityType('D', ['大理', '大连', '丹东', '大庆', '大同', '达州', '丹东', '丹凤', '儋州', '稻城', '东营', '德令哈', '德清', '迪庆', '敦煌', '东莞', '东阳']),
      new CityType('E', ['鄂州', '恩施', '鄂尔多斯', '额济纳旗', '二连浩特', '鄂托克旗', '鄂托克前旗']),
      new CityType('F', ['阜阳', '福州', '佛山', '抚远', '富蕴']),
      new CityType('G', ['甘南', '赣州', '甘孜', '格尔木', '广州', '根河', '固原', '贵阳', '根河', '广元', '果洛', '广汉']),
      new CityType('H', ['哈尔滨', '哈密', '海北', '海口', '邯郸', '汉中', '杭州', '河池', '合肥', '和田', '黑河', '衡阳', '红原',
        '呼和浩特', '花土沟', '淮安', '怀化', '黄山', '惠州', '霍林郭勒', '和静', '菏泽', '葫芦岛', '呼伦贝尔', '呼玛']),
      new CityType('J', ['济南', '济宁', '鸡西', '加格达奇', '佳木斯', '嘉峪关', '建三江', '揭阳', '金昌', '锦州', '景德镇', '井冈山',
        '九寨沟', '吉林', '建德', '荆州', '九江']),
      new CityType('K', ['喀什', '克拉玛依', '库车', '库尔勒', '昆明', '凯里']),
      new CityType('L', ['拉萨', '澜沧', '兰坪', '兰州', '丽江', '连云港', '临汾', '临沂', '林芝', '六盘水', '柳州', '陇川', '陇南',
        '泸州', '洛阳', '吕梁', '阆中', '连城', '临沧', '丽水', '罗定']),
      new CityType('M', ['满洲里', '芒市', '梅州', '牡丹江', '绵阳', '漠河']),
      new CityType('N', ['南宁', '南阳', '南京', '南通', '南昌', '南充', '嫩江', '宁波', '宁蒗']),
      new CityType('P', ['攀枝花', '普洱', '盘锦', '普兰']),
      new CityType('Q', ['齐齐哈尔', '黔南州', '且末', '秦皇岛', '青岛', '庆阳', '琼海', '衢州', '泉州', '黔东南', '奇台']),
      new CityType('R', ['日照', '日喀则', '若羌']),
      new CityType('S', ['三沙', '三亚', '莎车', '沙县', '上海', '上饶', '邵阳', '沈阳', '深圳', '石河子', '石家庄', '十堰', '松原',
        '山南市', '鄯善', '韶关', '神农架', '朔州', '苏州']),
      new CityType('T', ['塔城', '太原', '台州', '唐山', '腾冲', '天津', '天水', '通化', '铜仁', '通辽', '吐鲁番', '图木舒克', '突泉',
        '台北', '台东', '台南', '台中']),
      new CityType('W', ['万州', '潍坊', '威海', '文山', '温州', '五大连池', '武汉', '无锡', '乌海', '乌兰察布', '乌拉特中旗', '乌鲁木齐', '乌兰浩特',
        '武夷山', '梧州', '围场', '芜湖', '乌审旗' ]),
      new CityType('X', ['西安', '西昌', '锡林浩特', '西宁', '西双版纳', '厦门', '襄阳', '信阳', '新源', '忻州', '兴义', '徐州', '镶黄旗', '湘西', '仙桃',
        '新巴尔虎右旗', '邢台', '西乌珠穆沁旗', '香港']),
      new CityType('Y', ['延安', '盐城', '延吉', '烟台', '扬州', '宜宾', '宜昌', '宜春', '伊春', '义乌', '银川', '营口', '永州', '榆林', '玉树',
        '于田', '岳阳', '运城', '盐池', '阳江', '叶城', '伊犁', '玉林']),
      new CityType('Z', ['扎兰屯', '湛江', '张家界', '张家口', '张掖', '昭通', '郑州', '中卫', '舟山', '珠海', '株洲', '遵义', '扎赉特旗',
        '肇东', '昭苏', '镇江', '中山', '自贡']),
    ]
  }

  // 获取热门城市数据
  static getHotCityList(): City[] {
    let list: City[] = []
    let citys: string[] = [
      '北京', '上海', '深圳', '广州', '成都',
      '重庆', '昆明', '西安', '杭州', '武汉',
      '长沙', '南京', '海口', '郑州', '哈尔滨',
      '青岛', '厦门', '贵阳', '乌鲁木齐', '沈阳',
    ]
    for (let i = 0; i < citys.length; i++) {
      let item: City = new City()
      item.cityId = 'id_' + i
      item.cityCode = citys[i] + '_code'
      item.cityName = citys[i]

      list.push(item)
    }
    return list
  }

  // 模拟获取城市字母索引
  static getLetterList(): string[] {
    return ['A', 'B', 'C', 'D', 'E', 'F', 'G',
      'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'W', 'X', 'Y', 'Z']
  }
}