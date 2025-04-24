export class Constants {
  static HARMONY_HEITI: string = 'HarmonyHeiTi';
  static UNION_ID: string = 'unionId';
  static CURRENT_USER_BASIC: string = 'currentUserBasic';
  static CURRENT_USER_FULL: string = 'currentFullUserInfo';
  static CURRENT_USER_LIKE_FEED_ID: string = 'currentUserLikeFeedIds';
  static CURRENT_USER_COMMENT_LIST: string = 'currentUserCommentList';
  static CURRENT_USER_FEED_LIST: string = 'currentUserFeedList';
  static FIRST_LOGIN_FLAG: string = 'firstLoginFlag';
  static NEW_REGISTER_FLAG: string = 'newRegisterFlag';
  static GENDER: string = '性别';
  static HEIGHT_PREFIX: string = '身高';
  static HEIGHT_SUFFIX: string = 'cm';
  static CURRENT_RESIDENCE_PREFIX: string = '现居';
  static ORIGIN_FROM_PREFIX: string = '籍贯';
  static INCOME_PREFIX: string = '月入';
  static AGE_PREFIX: string = '年龄';
  static BIRTH_DATE: string = '出生日期';
  static EDUCATION_PREFIX: string = '学历';
  static ETHNIC_GROUP_PREFIX: string = '民族';
  static WORK_PREFIX: string = '职业';
  static HAS_CHILDREN_PREFIX: string = '当前孩子情况';
  static EXPECTATION_OF_CHILDREN: string = '是否想要孩子';
  static SMOKING_PREFIX: string = '是否吸烟';
  static DRINKING_PREFIX: string = '是否喝酒';
  static WHEN_TO_MARRY_PREFIX: string = '何时结婚';
  static MARRIAGE_STATUS_PREFIX: string = '婚姻状况';
  static REAL_NAME_AUTH_PREFIX: string = '实名认证';
  static CAR_PREFIX: string = '购车情况';
  static HOUSE_PREFIX: string = '购房情况';
  static PLEASE_CHOOSE: string = '请选择';
  static TO_BE_SET: string = '';
  static DEFAULT_SELF_INTRO: string = '介绍一下自己，让异性更快了解你';
  static MAX_RECOMMEND_USER_NORMAL = 2;
  static MAX_RECOMMEND_USER_VIP = 10;
  static ENUM_ALL: string = '-1';
  static ENUM_ALL_NUMBER: number = -1;
  static PAGE_INDEX_HOME = 0;
  static PAGE_INDEX_FEED = 1;
  static PAGE_INDEX_MEMBER = 2;
  static PAGE_INDEX_PERSONAL = 3;
  static FEED_IMAGE_SIZE = 100;
  static NO = 0;
  static YES = 1;
  static RET_SUCCESS_CODE = 0;
  static ID_CARD_NO_REGEX: string = '^[1-9]\\d{5}(18|19|20)\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])\\d{3}(\\d|X)$';
  static CHINESE_PAUSE_MARK: string = '、';
  static BAR: string = '-';
  static ADULT_AGE = 18;
  static MAX_AGE = 99;
  static MIN_HEIGHT = 140;
  static MAX_HEIGHT = 239;
  static MIN_WEIGHT = 30;
  static MAX_WEIGHT = 140;
  static NICK_NAME_MAX_LENGTH: number = 10;
  static NUMBER_MAX_LENGTH_THREE: number = 3;
  static WEIXIN_NO_MAX_LENGTH: number = 20;
  static HOBBIES_MAX_LENGTH: number = 64;
  static DATE_PICKER_DEFAULT = 20;
  static CHAR_NUMBER_OF_PER_LINE = 20;
  static DEFAULT_ROW_HEIGHT = 30;
  static MAX_LIKE_NUMBER_SUPPORTED = 999;
  static DEFAULT_SHOW_LIKE_TEXT_LEN = 21;
  static COMMENT_TYPE_NORMAL = 0;
  static COMMENT_TYPE_REPLY = 1;
  static FEED_PAGE_TYPE_LIST = 0;
  static FEED_PAGE_TYPE_DETAIL = 1;
  static FEED_PAGE_TYPE_COMMENT = 2;
  static QUERY_FEED_RECOMMEND = 0;
  static QUERY_FEED_FOLLOWED = 1;
  static QUERY_FEED_BY_USER = 2;
  static FEED_MAX_IMAGES = 9;
  static FEED_MSG_MAX_LINES = 15;
  static FEED_MSG_MAX_LENGTH = 300;
  static COMMENT_MAX_LENGTH = 256;
  static COMMENT_MAX_LINES = 12;
  static COMMENT_SHEET_HEIGHT_DEFAULT= 360;
  static ETHNIC_GROUPS: TextCascadePickerRangeContent[] =
    [{ text: '汉族' }, { text: '蒙古族' }, { text: '回族' }, { text: '藏族' },
      { text: '维吾尔族' }, { text: '苗族' }, { text: '彝族' }, { text: '壮族' }, { text: '布依族' },
      { text: '朝鲜族' }, { text: '满族' },
      { text: '侗族' }, { text: '瑶族' }, { text: '白族' }, { text: '土家族' }, { text: '哈尼族' },
      { text: '哈萨克族' }, { text: '傣族' }, { text: '黎族' },
      { text: '傈僳族' }, { text: '佤族' }, { text: '畲族' }, { text: '高山族' }, { text: '拉祜族' }, { text: '水族' },
      { text: '东乡族' }, { text: '纳西族' },
      { text: '景颇族' }, { text: '柯尔克孜族' }, { text: '土族' }, { text: '达斡尔族' }, { text: '仫佬族' },
      { text: '羌族' }, { text: '布朗族' },
      { text: '撒拉族' }, { text: '毛南族' }, { text: '仡佬族' }, { text: '锡伯族' }, { text: '阿昌族' },
      { text: '普米族' }, { text: '塔吉克族' },
      { text: '怒族' }, { text: '乌孜别克族' }, { text: '俄罗斯族' }, { text: '鄂温克族' }, { text: '德昂族' },
      { text: '保安族' }, { text: '裕固族' },
      { text: '京族' }, { text: '塔塔尔族' }, { text: '独龙族' }, { text: '鄂伦春族' }, { text: '赫哲族' },
      { text: '门巴族' }, { text: '珞巴族' },
      { text: '基诺族' }, { text: '其他' }];
  static CITY_PICKER: TextCascadePickerRangeContent[] = [
    { text: '北京' }, { text: '上海' }, { text: '天津' }, { text: '重庆' },
    {
      text: '辽宁',
      children: [{ text: '沈阳' }, { text: '大连' }, { text: '鞍山' }, { text: '抚顺' }, { text: '本溪' },
        { text: '丹东' }, { text: '锦州' },
        { text: '营口' }, { text: '阜新' }, { text: '辽阳' }, { text: '盘锦' }, { text: '铁岭' }, { text: '朝阳' },
        { text: '葫芦岛' }]
    },
    {
      text: '吉林',
      children: [{ text: '长春' }, { text: '吉林' }, { text: '四平' }, { text: '辽源' }, { text: '通化' },
        { text: '白山' }, { text: '松原' },
        { text: '白城' }, { text: '延边朝鲜族自治州' }]
    },
    {
      text: '黑龙江',
      children: [{ text: '哈尔滨' }, { text: '齐齐哈尔' }, { text: '鸡西' }, { text: '鹤岗' }, { text: '双鸭山' },
        { text: '大庆' }, { text: '伊春' },
        { text: '佳木斯' }, { text: '七台河' }, { text: '牡丹江' }, { text: '黑河' }, { text: '绥化' },
        { text: '大兴安岭地区' }]
    },
    {
      text: '江苏',
      children: [{ text: '南京' }, { text: '无锡' }, { text: '徐州' }, { text: '常州' }, { text: '苏州' },
        { text: '南通' },
        { text: '连云港' }, { text: '淮安' }, { text: '盐城' }, { text: '扬州' }, { text: '镇江' }, { text: '泰州' },
        { text: '宿迁' }]
    },
    {
      text: '河北',
      children: [{ text: '石家庄' }, { text: '唐山' }, { text: '秦皇岛' }, { text: '邯郸' }, { text: '邢台' },
        { text: '保定' },
        { text: '张家口' }, { text: '承德' }, { text: '沧州' }, { text: '廊坊' }]
    },
    {
      text: '山西',
      children: [{ text: '太原' }, { text: '大同' }, { text: '阳泉' }, { text: '长治' }, { text: '晋城' },
        { text: '朔州' }, { text: '晋中' },
        { text: '运城' }, { text: '忻州' }, { text: '临汾' }, { text: '吕梁' }]
    },
    {
      text: '内蒙古',
      children: [{ text: '呼和浩特' }, { text: '包头' }, { text: '乌海' }, { text: '赤峰' }, { text: '通辽' },
        { text: '鄂尔多斯' },
        { text: '呼伦贝尔' }, { text: '巴彦淖尔' }, { text: '乌兰察布' }, { text: '兴安盟' }, { text: '锡林郭勒盟' },
        { text: '阿拉善盟' }]
    },
    {
      text: '浙江',
      children: [{ text: '杭州' }, { text: '宁波' }, { text: '温州' }, { text: '嘉兴' }, { text: '湖州' },
        { text: '绍兴' }, { text: '金华' },
        { text: '衢州' }, { text: '舟山' }, { text: '台州' }, { text: '丽水' }]
    },
    {
      text: '安徽',
      children: [{ text: '合肥' }, { text: '芜湖' }, { text: '蚌埠' }, { text: '淮南' }, { text: '马鞍山' },
        { text: '淮北' }, { text: '铜陵' },
        { text: '安庆' }, { text: '黄山' }, { text: '滁州' }, { text: '阜阳' }, { text: '宿州' }, { text: '六安' },
        { text: '亳州' }, { text: '池州' },
        { text: '宣城' }]
    },
    {
      text: '福建',
      children: [{ text: '福州' }, { text: '厦门' }, { text: '莆田' }, { text: '三明' }, { text: '泉州' },
        { text: '漳州' }, { text: '南平' },
        { text: '龙岩' }, { text: '宁德' }]
    },
    {
      text: '江西',
      children: [{ text: '南昌' }, { text: '景德镇' }, { text: '萍乡' }, { text: '九江' }, { text: '新余' },
        { text: '鹰潭' }, { text: '赣州' },
        { text: '吉安' }, { text: '宜春' }, { text: '抚州' }, { text: '上饶' }]
    },
    {
      text: '山东',
      children: [{ text: '济南' }, { text: '青岛' }, { text: '淄博' }, { text: '枣庄' }, { text: '东营' },
        { text: '烟台' }, { text: '潍坊' },
        { text: '济宁' }, { text: '泰安' }, { text: '威海' }, { text: '日照' }, { text: '临沂' }, { text: '德州' },
        { text: '聊城' }, { text: '滨州' },
        { text: '菏泽' }]
    },
    {
      text: '河南',
      children: [{ text: '郑州' }, { text: '开封' }, { text: '洛阳' }, { text: '平顶山' }, { text: '安阳' },
        { text: '鹤壁' }, { text: '新乡' },
        { text: '焦作' }, { text: '濮阳' }, { text: '许昌' }, { text: '漯河' }, { text: '三门峡' }, { text: '南阳' },
        { text: '商丘' }, { text: '信阳' },
        { text: '周口' }, { text: '驻马店' }]
    },
    {
      text: '湖北',
      children: [{ text: '武汉' }, { text: '黄石' }, { text: '十堰' }, { text: '宜昌' }, { text: '襄阳' },
        { text: '鄂州' }, { text: '荆门' },
        { text: '孝感' }, { text: '荆州' }, { text: '黄冈' }, { text: '咸宁' }, { text: '随州' },
        { text: '恩施土家族苗族自治州' }, { text: '仙桃' },
        { text: '潜江' }, { text: '天门' }, { text: '神农架林区' }]
    },
    {
      text: '湖南',
      children: [{ text: '长沙' }, { text: '株洲' }, { text: '湘潭' }, { text: '衡阳' }, { text: '邵阳' },
        { text: '岳阳' }, { text: '常德' },
        { text: '张家界' }, { text: '益阳' }, { text: '郴州' }, { text: '永州' }, { text: '怀化' }, { text: '娄底' },
        { text: '湘西土家族苗族自治州' }]
    },
    {
      text: '广东',
      children: [{ text: '广州' }, { text: '韶关' }, { text: '深圳' }, { text: '珠海' }, { text: '汕头' },
        { text: '佛山' }, { text: '江门' },
        { text: '湛江' }, { text: '茂名' }, { text: '肇庆' }, { text: '惠州' }, { text: '梅州' }, { text: '汕尾' },
        { text: '河源' }, { text: '阳江' },
        { text: '清远' }, { text: '东莞' }, { text: '中山' }, { text: '潮州' }, { text: '揭阳' }, { text: '云浮' }]
    },
    {
      text: '广西',
      children: [{ text: '南宁' }, { text: '柳州' }, { text: '桂林' }, { text: '梧州' }, { text: '北海' },
        { text: '防城港' }, { text: '钦州' },
        { text: '贵港' }, { text: '玉林' }, { text: '百色' }, { text: '贺州' }, { text: '河池' }, { text: '来宾' },
        { text: '崇左' }]
    },
    {
      text: '海南',
      children: [{ text: '海口' }, { text: '三亚' }, { text: '三沙' }, { text: '儋州' }]
    },
    {
      text: '四川',
      children: [{ text: '成都' }, { text: '自贡' }, { text: '攀枝花' }, { text: '泸州' }, { text: '德阳' },
        { text: '绵阳' }, { text: '广元' },
        { text: '遂宁' }, { text: '内江' }, { text: '乐山' }, { text: '南充' }, { text: '眉山' }, { text: '宜宾' },
        { text: '广安' }, { text: '达州' },
        { text: '雅安' }, { text: '巴中' }, { text: '资阳' }, { text: '阿坝藏族羌族自治州' },
        { text: '甘孜藏族自治州' }, { text: '凉山彝族自治州' }]
    },
    {
      text: '贵州',
      children: [{ text: '贵阳' }, { text: '六盘水' }, { text: '遵义' }, { text: '安顺' }, { text: '毕节' },
        { text: '铜仁' },
        { text: '黔西南布依族苗族自治州' }, { text: '黔东南苗族侗族自治州' }, { text: '黔南布依族苗族自治州' }]
    },
    {
      text: '云南',
      children: [{ text: '昆明' }, { text: '曲靖' }, { text: '玉溪' }, { text: '保山' }, { text: '昭通' },
        { text: '丽江' }, { text: '普洱' },
        { text: '临沧' }, { text: '楚雄彝族自治州' }, { text: '红河哈尼族彝族自治州' }, { text: '文山壮族苗族自治州' },
        { text: '西双版纳傣族自治州' },
        { text: '大理白族自治州' }, { text: '德宏傣族景颇族自治州' }, { text: '怒江傈僳族自治州' },
        { text: '迪庆藏族自治州' }]
    },
    {
      text: '西藏',
      children: [{ text: '拉萨' }, { text: '日喀则' }, { text: '昌都' }, { text: '林芝' }, { text: '山南' },
        { text: '那曲' }, { text: '阿里地区' }]
    },
    {
      text: '陕西',
      children: [{ text: '西安' }, { text: '铜川' }, { text: '宝鸡' }, { text: '咸阳' }, { text: '渭南' },
        { text: '延安' }, { text: '汉中' },
        { text: '榆林' }, { text: '安康' }, { text: '商洛' }]
    },
    {
      text: '甘肃',
      children: [{ text: '兰州' }, { text: '嘉峪关' }, { text: '金昌' }, { text: '白银' }, { text: '天水' },
        { text: '武威' }, { text: '张掖' },
        { text: '平凉' }, { text: '酒泉' }, { text: '庆阳' }, { text: '定西' }, { text: '陇南' },
        { text: '临夏回族自治州' }, { text: '甘南藏族自治州' }]
    },
    {
      text: '青海',
      children: [{ text: '西宁' }, { text: '海东' }, { text: '海北藏族自治州' }, { text: '黄南藏族自治州' },
        { text: '海南藏族自治州' },
        { text: '果洛藏族自治州' }, { text: '玉树藏族自治州' }, { text: '海西蒙古族藏族自治州' }]
    },
    {
      text: '宁夏',
      children: [{ text: '银川' }, { text: '石嘴山' }, { text: '吴忠' }, { text: '固原' }, { text: '中卫' }]
    },
    {
      text: '新疆',
      children: [{ text: '乌鲁木齐' }, { text: '克拉玛依' }, { text: '吐鲁番' }, { text: '哈密' },
        { text: '昌吉回族自治州' },
        { text: '博尔塔拉蒙古自治州' }, { text: '巴音郭楞蒙古自治州' }, { text: '阿克苏地区' },
        { text: '克孜勒苏柯尔克孜自治州' }, { text: '喀什地区' },
        { text: '和田地区' }, { text: '伊犁哈萨克自治州' }, { text: '塔城地区' }, { text: '阿勒泰地区' }]
    },
    { text: '香港特别行政区' },
    { text: '澳门特别行政区' }
  ];
  static ABOVE: string = '以上';
  static BELOW: string = '以下';
  static AGE: string = '岁';
  static UN_SET: string = '未设置';
  static INVALID: string = '无效值';
  static MARRIAGE_STATUS_UNMARRIED = 0;
  static MARRIAGE_STATUS_DIVORCED = 1;
  static MARRIAGE_STATUS_WIDOWED = 2;
  static MARRIAGE_STATUS_DISPLAY_VALUES: string[] = ['未婚', '离异', '丧偶'];
  static MONTHLY_INCOME_BELOW_3000: number = 0;
  static MONTHLY_INCOME_BETWEEN_3001_AND_5000 = 1;
  static MONTHLY_INCOME_BETWEEN_5001_AND_8000 = 2;
  static MONTHLY_INCOME_BETWEEN_8001_AND_10000 = 3;
  static MONTHLY_INCOME_BETWEEN_10001_AND_20000 = 4;
  static MONTHLY_INCOME_BETWEEN_20001_AND_50000 = 5;
  static MONTHLY_INCOME_MORE_THAN_50000 = 6;
  static MONTHLY_INCOME_DISPLAY_VALUES: string[] =
    ['¥3000以下', '¥3001-6000', '¥6001-8000', '¥8001-10000', '¥10001-20000', '¥20001-50000', '¥50000以上'];
  static INCOME_FOR_SEARCH_BELOW_3000: number = 0;
  static INCOME_FOR_SEARCH_ABOVE_3000: number = 1;
  static INCOME_FOR_SEARCH_ABOVE6000: number = 2;
  static INCOME_FOR_SEARCH_ABOVE_10000: number = 3;
  static INCOME_FOR_SEARCH_DISPLAY_VALUES: string[] =
    ['3千以下', '3千以上', '6千以上', '1万以上'];
  static GENDER_MALE = 0;
  static GENDER_FEMALE = 1;
  static GENDER_DISPLAY_VALUES: string[] = ['男', '女'];
  static REAL_NAME_AUTH_NO = 0;
  static REAL_NAME_AUTH_YES = 1;
  static REAL_NAME_AUTH_VALUES: string[] = ['未实名', '已实名'];
  static REAL_NAME_AUTH_VALUES_FOR_SEARCH: string[] = ['已实名'];
  static HAS_CAR_NO = 0;
  static HAS_CAR_YES = 1;
  static HAS_CAR_VALUES: string[] = ['未购车', '已购车'];
  static EDUCATION_MIDDLE_SCHOOL = 0;
  static EDUCATION_HIGH_SCHOOL = 1;
  static EDUCATION_COLLEGE = 2;
  static EDUCATION_UNDERGRADUATE = 3;
  static EDUCATION_MASTER = 4;
  static EDUCATION_DOCTOR = 5;
  static EDUCATION_DISPLAY_VALUES: string[] = ['初中', '高中/中专', '大专', '本科', '硕士', '博士'];
  static EDU_FOR_SEARCH_HIGH_SCHOOL = 0;
  static EDU_FOR_SEARCH_COLLEGE = 1;
  static EDU_FOR_SEARCH_UNDERGRADUATE = 2;
  static EDUCATION_MASTER_AND_ABOVE = 3;
  static EDU_FOR_SEARCH_DISPLAY_VALUES: string[] = ['高中/中专', '大专', '本科', '硕士及以上'];
  static HAS_CHILDREN_NO = 0;
  static HAS_CHILDREN_AND_LIVE_TOGETHER = 1;
  static HAS_CHILDREN_AND_STAY_TOGETHER_OCCASIONALLY = 2;
  static HAS_CHILDREN_BUT_NOT_LIVE_TOGETHER = 3;
  static HAS_CHILDREN_DISPLAY_VALUES: string[] =
    ['没有孩子', '有孩子且住在一起', '有孩子且偶尔住一起', '有孩子但不在身边'];
  static EXPECTATION_OF_CHILDREN_WANT_CHILDREN = 0;
  static EXPECTATION_OF_CHILDREN_DO_NOT_WANT_CHILDREN = 1;
  static EXPECTATION_OF_CHILDREN_IT_DEPENDS = 2;
  static EXPECTATION_OF_CHILDREN_DISPLAY_VALUES: string[] = ['想要孩子', '不想要孩子', '看情况'];
  static SMOKING_NOT_AT_ALL = 0;
  static SMOKING_A_LITTLE = 1;
  static SMOKING_MUCH = 2;
  static SMOKING_DISPLAY_VALUES: string[] = ['不吸烟', '稍微吸一点', '吸得很多'];
  static DRINKING_NOT_AT_ALL = 0;
  static DRINKING_A_LITTLE = 1;
  static DRINKING_MUCH = 2;
  static DRINKING_DISPLAY_VALUES: string[] = ['不喝酒', '稍微喝一点', '喝得很多'];
  static HOUSE_BOUGHT_ALREADY = 0;
  static HOUSE_INTEND_TO_BUY_AFTER_GOT_MARRIED = 1;
  static HOUSE_LIVE_WITH_FAMILY = 2;
  static HOUSE_DISPLAY_VALUES: string[] = ['已购房', '打算婚后购房', '和家人同住'];
  static WHEN_TO_MARRY_AGREE_WITH_FLASH_MARRIAGE = 0;
  static WHEN_TO_MARRY_IN_ONE_YEAR = 1;
  static WHEN_TO_MARRY_IN_TWO_YEARS = 2;
  static WHEN_TO_MARRY_IN_THREE_YEARS = 3;
  static WHEN_TO_MARRY_WHEN_THE_TIME_IS_RIGHT = 4;
  static WHEN_TO_MARRY_DISPLAY_VALUES: string[] = ['认同闪婚', '一年内', '两年内', '三年内', '时机成熟就结婚'];
  static WORK_IN_IT = 0;
  static WORK_IN_MANUFACTURE = 1;
  static WORK_IN_MEDICAL = 2;
  static WORK_IN_FINANCE = 3;
  static WORK_IN_BUSINESS = 4;
  static WORK_IN_CULTURE = 5;
  static WORK_IN_ENTERTAINMENT = 6;
  static WORK_IN_LAW = 7;
  static WORK_IN_EDUCATION = 8;
  static WORK_IN_GOV = 9;
  static WORK_IN_STUDENT = 10;
  static WORK_IN_MILITARY = 11;
  static WORK_OTHER = 12;
  static WORK_DISPLAY_VALUES: string[] =
    ['计算机/互联网', '生产/制造', '医疗/护理', '金融/银行', '商业/服务业',
      '广告/传媒', '娱乐/艺术', '律师/法务', '教育/培训', '公务员', '学生', '军人', '其他职业'];
  static MEMBER_SERVICES: string[] =
    ['更多匹配推荐', '高级搜索', '一对一红娘服务', '开放隐藏会员', '牵线 约见', '点赞和评论详情查看'];
  static EMPTY_LIKE_PAGE_TAB2: string[] =
    ['收到的赞', '暂时还没有人给你点赞', '赶紧发个动态让别人认识你吧', '发布动态', 'NewFeed', 'app.media.img_like'];
  static EMPTY_LIKE_PAGE_TAB1: string[] =
    ['我点赞的', '你还没有点赞过任何人呢', '去广场看看吧', '去点赞', 'FeedList', 'app.media.img_like'];
  static EMPTY_FOLLOW_PAGE_TAB2: string[] =
    ['关注我的', '暂时还没有人关注你', ' 赶紧发个动态让别人认识你吧', '发布动态', 'NewFeed', 'app.media.img_follow'];
  static EMPTY_FOLLOW_PAGE_TAB1: string[] =
    ['我关注的', '你还没关注过任何人呢', '去广场看看吧', '前往广场', 'FeedList', 'app.media.img_follow'];
  static EMPTY_COMMENT_PAGE_TAB2: string[] =
    ['收到的评论', '暂时还没有评论', '快去发表动态吧', '发布动态', 'NewFeed', 'app.media.img_comment'];
  static EMPTY_COMMENT_PAGE_TAB1: string[] =
    ['我评论的', '你还没有对别人评论', '去广场查看动态并评论吧', '前往广场', 'FeedList', 'app.media.img_comment'];

  static getMarriageStatusDisplayValue(marriageStatus: number | null | undefined): string {
    if (marriageStatus == null || marriageStatus === undefined) {
      return Constants.UN_SET;
    }
    if (marriageStatus < Constants.MARRIAGE_STATUS_UNMARRIED || marriageStatus > Constants.MARRIAGE_STATUS_WIDOWED) {
      return Constants.INVALID;
    }
    return Constants.MARRIAGE_STATUS_DISPLAY_VALUES[marriageStatus];
  }

  static getMonthlyIncomeDisplayValue(income: number | null | undefined): string {
    if (income == null || income === undefined) {
      return Constants.UN_SET;
    }
    if (income < Constants.MONTHLY_INCOME_BELOW_3000 || income > Constants.MONTHLY_INCOME_MORE_THAN_50000) {
      return Constants.INVALID;
    }
    return Constants.MONTHLY_INCOME_DISPLAY_VALUES[income];
  }


  static getGenderDisplayValue(gender: number | null | undefined): string {
    if (gender == null || gender === undefined) {
      return Constants.UN_SET;
    }
    if (gender < Constants.GENDER_MALE || gender > Constants.GENDER_FEMALE) {
      return Constants.INVALID;
    }
    return Constants.GENDER_DISPLAY_VALUES[gender];
  }

  static getEducationDisplayValue(edu: number | null | undefined): string {
    if (edu == null || edu === undefined) {
      return Constants.UN_SET;
    }
    if (edu < Constants.EDUCATION_MIDDLE_SCHOOL || edu > Constants.EDUCATION_DOCTOR) {
      return Constants.INVALID;
    }
    return Constants.EDUCATION_DISPLAY_VALUES[edu];
  }

  static getHasChildrenDisplayValue(hasChildren: number | null | undefined): string {
    if (hasChildren == null || hasChildren === undefined) {
      return Constants.UN_SET;
    }
    if (hasChildren < Constants.HAS_CHILDREN_NO || hasChildren > Constants.HAS_CHILDREN_BUT_NOT_LIVE_TOGETHER) {
      return Constants.INVALID;
    }
    return Constants.HAS_CHILDREN_DISPLAY_VALUES[hasChildren];
  }

  static getExpectationOfChildrenDisplayValue(expectationOfChildren: number | null | undefined): string {
    if (expectationOfChildren == null || expectationOfChildren === undefined) {
      return Constants.UN_SET;
    }
    if (expectationOfChildren < Constants.EXPECTATION_OF_CHILDREN_WANT_CHILDREN ||
      expectationOfChildren > Constants.EXPECTATION_OF_CHILDREN_IT_DEPENDS) {
      return Constants.INVALID;
    }
    return Constants.EXPECTATION_OF_CHILDREN_DISPLAY_VALUES[expectationOfChildren];
  }

  static getWhenToMarryDisplayValue(whenToMarry: number | null | undefined) {
    if (whenToMarry == null || whenToMarry === undefined) {
      return Constants.UN_SET;
    }
    if (whenToMarry < Constants.WHEN_TO_MARRY_AGREE_WITH_FLASH_MARRIAGE ||
      whenToMarry > Constants.WHEN_TO_MARRY_WHEN_THE_TIME_IS_RIGHT) {
      return Constants.INVALID;
    }
    return Constants.WHEN_TO_MARRY_DISPLAY_VALUES[whenToMarry];
  }

  static getHouseDisplayValue(house: number | null | undefined) {
    if (house == null || house === undefined) {
      return Constants.UN_SET;
    }
    if (house < Constants.HOUSE_BOUGHT_ALREADY || house > Constants.HOUSE_LIVE_WITH_FAMILY) {
      return Constants.INVALID;
    }
    return Constants.HOUSE_DISPLAY_VALUES[house];
  }

  static getDrinkingDisplayValue(drinking: number | null | undefined) {
    if (drinking == null || drinking === undefined) {
      return Constants.UN_SET;
    }
    if (drinking < Constants.DRINKING_NOT_AT_ALL || drinking > Constants.DRINKING_MUCH) {
      return Constants.INVALID;
    }
    return Constants.DRINKING_DISPLAY_VALUES[drinking];
  }

  static getSmokingDisplayValue(smoking: number | null | undefined) {
    if (smoking == null || smoking === undefined) {
      return Constants.UN_SET;
    }
    if (smoking < Constants.SMOKING_NOT_AT_ALL || smoking > Constants.SMOKING_MUCH) {
      return Constants.INVALID;
    }
    return Constants.SMOKING_DISPLAY_VALUES[smoking];
  }

  static getHasBuyCarDisplayValue(hasBuyCar: number | null | undefined) {
    if (hasBuyCar == null || hasBuyCar === undefined) {
      return Constants.UN_SET;
    }
    if (hasBuyCar < Constants.HAS_CAR_NO || hasBuyCar > Constants.HAS_CAR_YES) {
      return Constants.INVALID;
    }
    return Constants.HAS_CAR_VALUES[hasBuyCar];
  }

  /**
   * 获取元素在数组中的下标
   *
   * @param item 元素值
   * @param arr 数组
   * @returns 下标或null
   */
  static getIndex(item: string, arr: string[]): number | null {
    for (let i = 0; i < arr.length; i += 1) {
      if (arr[i] === item) {
        return i;
      }
    }
    return null;
  }
}

export enum QueryFeedType {
  QUERY_RECOMMEND,
  QUERY_FOLLOWED,
  QUERY_MY_LIKE,
  QUERY_LIKED_BY_OTHERS,
  QUERY_MY_COMMENTED,
  QUERY_COMMENTED_BY_OTHERS,
  QUERY_BY_USER
}

export enum QueryFollowUserType {
  QUERY_FOLLOWED_BY_ME,
  QUERY_MY_FANS
}