/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { IntroType, TypeGood } from '../common/Constant';
import { IAddrInfo, IGoodCategory, IGoodInfo, IHomeInfo, IUserInfo, LoginWithHuaweiIDResp } from '../model/IResponse';

/**
 * Mock数据类
 */
export class MockData {
  static USER_ID: number = 1;
  static LOGIN_RESP: LoginWithHuaweiIDResp = {
    token: '',
    userId: MockData.USER_ID.toString(),
  };
  static USER_INFO: IUserInfo = {
    userId: MockData.USER_ID,
    nickName: '',
    avatar: 'resourceImage://ic_user_default',
  };
  static ADDRESS_LIST: IAddrInfo[] = [
    {
      id: 123456,
      name: '宜悦城',
      address: '江苏省南京市雨花台区安德门大街36号',
      contactName: '张三',
      contactPhone: '12345678901',
    },
  ];
  static HOME_INFO: IHomeInfo = {
    currentCity: '',
    citySelected: '北京',
    hotline: '100-000-000',
    officialWebsite: 'https://www.example.com',
    bannerGoods: [],
  };
  static ALL_CATEGORY_SERVICES: IGoodCategory[] = [
    {
      categoryId: 'season_hot',
      categoryLabel: '当季热门',
      list: [],
    },
    {
      categoryId: 'home_clean',
      categoryLabel: '家庭清洁',
      list: [],
    },
    {
      categoryId: 'baby_care',
      categoryLabel: '保姆月嫂',
      list: [],
    },
    {
      categoryId: 'pipe_clear',
      categoryLabel: '管道疏通',
      list: [],
    },
    {
      categoryId: 'domestic_repair',
      categoryLabel: '家电维修',
      list: [],
    },
    {
      categoryId: 'house_repair',
      categoryLabel: '房屋维修',
      list: [],
    },
    {
      categoryId: 'clothes_wash',
      categoryLabel: '衣物洗护',
      list: [],
    },
    {
      categoryId: 'digital_product_repair',
      categoryLabel: '数码维修',
      list: [],
    },
    {
      categoryId: 'closet_storage_organization',
      categoryLabel: '衣柜收纳',
      list: [],
    },
    {
      categoryId: 'window_clean',
      categoryLabel: '全屋擦窗',
      list: [],
    },
    {
      categoryId: 'refrigerator_clean',
      categoryLabel: '冰箱蒸洗',
      list: [],
    },
  ];
  static ALL_GOOD_LIST: IGoodInfo[] = [
    {
      type: TypeGood.PAY,
      classId: 'home_clean',
      id: 'home_clean_0',
      title: '日常保洁',
      subTitle: '高温消毒｜除尘除垢',
      image: 'mockImage://good_1.png?token=dae0dc9b-e842-4e72-b410-9ad61f5e2e24',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_detail_1.png?token=f174f65d-9d99-48d2-8e3f-09ac6a7b8c9e',
        },
      ],
      price: 119,
      vipPrice: 41,
      soldNum: 800,
      serviceContentList: [
        {
          title: '基础保洁：',
          content: '适合日常维护，快速清洁，保持家居整洁。',
        },
        {
          title: '清洁范围：',
          content: '地面、桌面、台面、家具表面除尘、垃圾清理、卫生间简单清洁等。',
        },
        {
          title: '服务时长：',
          content: '2小时起',
        },
      ],
      serviceDetailList: [
        {
          title: '日常保洁2小时',
          subTitle: '适用50㎡以内',
          prices: [
            {
              desc: '买#count次(#price/小时)',
              count: 1,
              price: 46.55,
              extraCount: 2,
            },
            {
              desc: '买#count次(#price/小时)',
              count: 2,
              price: 45.55,
              extraCount: 2,
            },
          ],
        },
        {
          title: '日常保洁3小时',
          subTitle: '适用51-99㎡',
          prices: [
            {
              desc: '买#count次(#price/小时)',
              count: 1,
              price: 45,
              extraCount: 3,
            },
            {
              desc: '买#count次(#price/小时)',
              count: 2,
              price: 43,
              extraCount: 3,
            },
          ],
        },
        {
          title: '日常保洁4小时',
          subTitle: '适用100-119㎡',
          prices: [
            {
              desc: '买#count次(#price/小时)',
              count: 1,
              price: 42,
              extraCount: 4,
            },
            {
              desc: '买#count次(#price/小时)',
              count: 2,
              price: 41,
              extraCount: 4,
            },
          ],
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排保洁人员。',
        '3、上门服务： 保洁人员按时上门，提供专业服务。',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '收费标准： 根据服务类型、房屋面积、服务时长等因素综合计算。',
        '支付方式： 支持华为支付。',
      ],
      qaList: [
        {
          question: '如何预约保洁服务？',
          answer: '您可以点击详情页预约按钮、或电话进行预约。',
        },
        {
          question: '保洁人员是否经过培训？',
          answer: '我们的保洁人员均经过专业培训，持证上岗，服务规范。',
        },
        {
          question: '服务过程中出现问题怎么办？',
          answer: '您可以随时联系客服，我们会及时为您解决问题。',
        },
        {
          question: '可以指定保洁人员吗？',
          answer: '您可以根据保洁人员的评价和资料进行选择。',
        },
        {
          question: '服务完成后不满意怎么办？',
          answer: '您可以联系客服进行反馈，我们会根据实际情况进行处理。',
        },
      ],
    },
    {
      type: TypeGood.PAY,
      classId: 'pipe_clear',
      id: 'pipe_clear_0',
      title: '厨房下水道疏通',
      subTitle: '菜渣油污堵塞，一次搞定',
      image: 'mockImage://good_4.png?token=51b6a72d-3601-4a55-ac51-8eb43e4e1b78',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_detail_2.png?token=38b6f16b-2f8b-46a2-963d-4c838b8a8423',
        },
      ],
      price: 165,
      vipPrice: 60,
      soldNum: 600,
      serviceContentList: [
        {
          title: '全屋管道疏通：',
          content: '厨房下水道疏通（菜渣油污堵塞）\u000A卫生间管道疏通（毛发、纸巾等异物堵塞）\u000A地漏/马桶疏通（顽固性堵塞）',
        },
        {
          title: '专项服务：',
          content: '主管道疏通（一楼或公共管道堵塞）\u000A油污软化清洗（预防性管道养护）\u000A管道消毒杀菌（异味治理）',
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排师傅上门。',
        '3、上门服务：专业师傅30分钟响应，携带工具包。',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '普通管道疏通： 50-100元\u000A主管道疏通： 150-300元\u000A夜间紧急服务 ：加收30%费用\u000A高层住宅需加收楼层费（5楼以上每层+5元）\u000A复杂堵塞（如硬物卡管）需使用机械疏通，费用按实际耗时计算',
      ],
      qaList: [
        {
          question: '师傅是否持证上岗？',
          answer: '平台所有师傅均通过实名认证+技能考核，服务全程可追溯。',
        },
        {
          question: '疏通后再次堵塞怎么办？',
          answer: '72小时内免费返修，超时可享8折优惠（需提供原始服务单）。',
        },
        {
          question: '能否自行处理简单堵塞？',
          answer: '建议尝试以下方法后再预约：\u000A倒入小苏打+白醋溶解油污2\u000A用皮搋子反复抽压排水口',
        },
        {
          question: '管道材质影响服务方式吗？？',
          answer: 'PVC/铸铁管道均适用，特殊材质（如陶瓷）需提前告知师傅。',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'domestic_repair',
      id: 'domestic_repair_1',
      title: '家用空调维修',
      subTitle: '空调不制冷/制热检测维修',
      image: 'mockImage://good_ac.png?token=b5d4adc8-8b47-464f-b781-42ada9b56891',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_ac_detail.png?token=35bdfe1c-354d-45b6-a14a-a7f42dece83b',
        },

      ],
      price: 170,
      vipPrice: 80,
      soldNum: 900,
      serviceContentList: [
        {
          title: '基础维修项目：',
          content: '空调不制冷/不制热检测维修\u000A加氟/加雪种（1P-3P机型全覆盖）\u000A内机异响、漏水、电路故障维修\u000A外机风扇、压缩机、电容更换\u000A遥控失灵、自动开关机故障排查',
        },
        {
          title: '增值服务：',
          content: '高温消毒杀菌（消灭大肠杆菌等常见菌群）\u000A深度清洗保养（含滤网、蒸发器、冷凝器清洗）\u000A高空作业服务（2层以上外机维修专属通道）',
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排师傅上门。',
        '3、上门服务：专业师傅30分钟响应，携带工具包。',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '基础上门费 ：30元 （含3公里内交通费）\u000A加氟（1.5P挂机）： 150-260元 根据雪种类型浮动[[1]2\u000A高空作业费： 2-10层100元/10层+ 200元（外机维修必选）\u000A深度清洗： 挂机99元/柜机159元（含消毒杀菌服务）\u000A电容更换 ：80-190元 （根据品牌型号定价）',
      ],
      qaList: [
        {
          question: '师傅是否持证上岗？',
          answer: '平台所有师傅均通过实名认证+技能考核，服务全程可追溯。',
        },
        {
          question: '半夜空调坏了能紧急处理吗？',
          answer: '夜间服务时段（22:00-次日6:00）收取50%加急费，2小时内上门。',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'domestic_repair',
      id: 'domestic_repair_2',
      title: '家用洗衣机维修',
      subTitle: '上下水故障/电机检测维修',
      image: 'mockImage://good_washing.png?token=c28e9230-9746-4a74-921a-0a3b03a925a5',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_washing_detail.png?token=f59e9672-c744-4fb9-b9d3-348d6773bc63',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 900,
      serviceContentList: [
        {
          title: '全故障维修：',
          content: '不进水/进水不止、不排水/边进边排、脱水异响、波轮单项转等\n' +
            '电机/离合器/水位传感器/电脑板等核心部件更换\n' +
            '排水阀堵塞清理、皮带调整、电路检测等',
        },
        {
          title: '附加服务：',
          content: '深度清洁：内筒、滤网、橡胶密封圈杀菌除霉\n' +
            '保养检测：水管检查、负载调试、放置稳固度调整',
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排师傅上门。',
        '3、上门服务：专业师傅30分钟响应，携带工具包。',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '上门检测费： 0元， 检测后不维修仅收30元交通费\n' +
          '基础维修费 ：50-200元 ，根据故障复杂度定价（如排水阀清理50元）\n' +
          '配件更换费： 80元起 ，明码标价，提供旧件展示\n' +
          '深度清洗服务： 120-200元， 含内筒、滤网、密封圈杀菌',
      ],
      qaList: [
        {
          question: '维修费用受哪些因素影响？',
          answer: '故障类型、配件成本、机型复杂度（如滚筒＞波轮）',
        },
        {
          question: '周末/节假日能否预约？',
          answer: '支持24小时紧急预约，夜间服务加收30%费用',
        },
      ],
    },
    {
      type: TypeGood.PAY,
      classId: 'house_repair',
      id: 'house_repair_0',
      title: '水龙头安装/维修',
      subTitle: '服务专业，安全放心',
      image: 'mockImage://good_house_repair.png?token=cd4d8d14-b626-4823-be63-ecaa594172da',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_house_repair_detail.png?token=984358f6-035c-4ecb-88ba-b13cce3a696b',
        },
      ],
      price: 99,
      vipPrice: 69,
      soldNum: 900,
      serviceContentList: [
        {
          title: '厨房龙头安装：',
          content: '单孔固定型、抽拉式龙头，确保稳固性和防松动处理',
        },
        {
          title: '面盆/洗手台龙头：',
          content: '适配专用角阀，规范冷热水管间距（15cm），避免漏水风险',
        },
        {
          title: '旧龙头拆卸清理：',
          content: '免费冲洗水管泥沙杂质，延长新龙头使用寿命',
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排师傅上门。',
        '3、上门服务：专业师傅30分钟响应，携带工具包。',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '标准安装： 80-150元 单孔龙头/面盆龙头，普通台面\n' +
          '复杂安装： 200-300元 暗装预埋、恒温龙头、墙体开孔\n' +
          '配件增购： 另计 生料带/角阀/软管等（明码标价）',
      ],
      qaList: [
        {
          question: '需要自备工具或材料吗？',
          answer: '基础工具（扳手、生料带等）由师傅携带，特殊配件（如角阀、装饰罩）需提前沟通',
        },
        {
          question: '安装后漏水怎么办？',
          answer: '质保期内免费返修，非人为损坏全额赔付。',
        },
        {
          question: '老房子水管较短/位置偏移能装吗？',
          answer: '支持水管延长或调节拐子修正（需加收材料费）',
        },
        {
          question: '安装前需要做什么准备？',
          answer: '确保水闸可关闭，台面预留安装空间，拆除旧龙头（如需拆卸服务+30元）。',
        },
      ],
    },
    {
      type: TypeGood.PAY,
      classId: 'digital_product_repair',
      id: 'digital_product_repair_0',
      title: '手机换屏',
      subTitle: '服务专业，安全放心',
      image: 'mockImage://good_phone.png?token=f5b1142b-1bcd-4d6e-8e51-1345aa466460',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_phone_detail.png?token=b994e9e0-5144-499c-a71e-53c0863c61d0',
        },
      ],
      price: 60,
      vipPrice: 39,
      soldNum: 800,
      serviceContentList: [
        {
          title: '全机型适配：',
          content: '覆盖iPhone全系/主流机型（含华为、小米、OPPO等）屏幕更换',
        },
        {
          title: '配件类型：',
          content: '提供原厂品质屏（含OLED/液晶屏）+高透钢化膜免费贴附',
        },
        {
          title: '附加服务：',
          content: '屏幕功能检测（触控/显示/色准测试）防水胶重封服务（苹果机型专属）\n旧屏数据迁移协助（指纹/面容识别模块）',
        },
      ],
      servicePipeList: [
        '1、在线预约：选择机型→故障描述→选择上门/到店',
        '2、工程师响应：30分钟内确认订单（含配件库存核查）',
        '3、透明施工：全程录像操作，更换过程可视化 ',
        '4、三重质检：装机测试→功能验证→防水检测 ',
      ],
      feeList: [
        'iPhone系列：普通液晶屏：299元起 ，原装OLED屏：599元起\n' +
          '其他系列：直面屏：199-399元 ，曲面屏：499-899元',
      ],
      qaList: [
        {
          question: '维修需要多久？',
          answer: '标准机型60分钟完成（含华为P系列/Mate系列、iPhone12以上机型需增加30分钟防水处理）',
        },
        {
          question: '更换后影响面容识别吗？ ',
          answer: '使用原厂排线模块，确保生物识别功能正常（特殊机型需提前告知）',
        },
        {
          question: '维修会丢失数据吗？',
          answer: '仅更换屏幕组件，不涉及主板操作，数据0风险',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'baby_care',
      id: 'baby_care_0',
      title: '住家保姆',
      subTitle: '适合工作繁忙，需要长期看护的家庭',
      image: 'mockImage://good_care.png?token=5eba6c40-3d5e-404e-92ca-941156203059',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_care_detail.png?token=c4066aac-0dba-492d-8a7e-e3f86101b840',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 800,
      serviceContentList: [
        {
          title: '日常照料：',
          content: '老人/儿童看护：喂食、起居照料、简单医疗护理。',
        },
        {
          title: '婴幼儿专项：',
          content: '辅食制作、早教互动、作息规律培养',
        },
        {
          title: '家务处理：',
          content: '全屋清洁：每日2次基础打扫（含扫地/拖地/桌面整理）',
        },
        {
          title: '餐饮服务：',
          content: '定制3餐（忌口/营养搭配可备注）',
        },
        {
          title: '附加服务（需提前沟通）：',
          content: '代购生活用品 | 宠物临时照看 | 夜间陪护（+30元/小时）',
        },
      ],
      servicePipeList: [
        '1、服务前沟通\n' +
          '签署电子合同，明确服务内容、周期及费用。\n' +
          '保姆提供健康证明、职业资格证等资料备案',
        '2、日常服务安排\n' +
          '老人/儿童看护、全屋清洁、餐饮服务等。',
      ],
      feeList: [
        '住家保姆： 6800元/月（8小时/天） 免费更换1次人员\n' +
          '白班保姆 ：85元/小时（最低4小时起订） 赠送月度深度保洁1次\n' +
          '特殊需求： 早7点前/晚10点后服务按1.5倍计费',
      ],
      qaList: [
        {
          question: '保姆损坏物品怎么处理？',
          answer: '通过平台投诉通道，48小时内启动保险理赔流程',
        },
        {
          question: '法定节假日如何计费？',
          answer: '春节/国庆等法定假日按双倍工资计算，需提前3天预约',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'baby_care',
      id: 'baby_care_1',
      title: '月嫂',
      subTitle: '科学坐月子，呵护新生儿',
      image: 'mockImage://good_baby.png?token=02310c0f-a1a8-49ef-962b-bc187672767a',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_baby_detail.png?token=3dc037dd-42f8-4d2b-b6fe-ba9b1b1eb999',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 900,
      serviceContentList: [
        {
          title: '母婴护理：',
          content: '产妇护理：每日健康监测（乳房护理、恶露观察）、伤口消毒、产后恢复操指导、心理疏导。\u000A新生儿护理：喂养（母乳/配方奶）、洗澡抚触、脐带消毒、黄疸监测、早教训练（视听触觉开发）。\u000A家务支持：母婴衣物清洗消毒、房间通风清洁、简单餐食制作（以产妇营养餐为主）',
        },
        {
          title: '专业增值服务：',
          content: '母乳喂养指导、新生儿常见病预防（如尿布疹、鹅口疮）。\u000A产后心理调适、新生儿作息规律培养',
        },
      ],
      servicePipeList: [
        '1、服务前沟通\u000A签署电子合同，明确服务内容、周期及费用。\u000A月嫂提供健康证明、职业资格证等资料备案',
        '2、日常服务安排\u000A每日按需哺乳（母乳喂养2-3小时/次，配方奶3小时/次）。\u000A标准化流程：晨间护理→喂养→早教互动→产妇护理→家务整理→夜间值守。',
        '3、服务结束交接\u000A提交《母婴护理日志》，指导家庭延续科学照护方法。',
      ],
      feeList: [
        '基础套餐：26天服务周期，费用￥12,800起（初级月嫂）~￥28,800（金牌月嫂）。\u000A包含项目：\u000A月嫂工资、基础体检、意外保险。\u000A新生儿护理耗材（如消毒棉签、护臀霜）。\u000A增值项：\u000A延长服务：￥500/天；夜间专项护理：￥200/晚。',
      ],
      qaList: [
        {
          question: '月嫂资质如何保障？',
          answer: '均持“母婴护理师证”“催乳师证”，平台验证健康证及无犯罪记录。',
        },
        {
          question: '服务期间生病怎么办？',
          answer: '月嫂因病缺勤，平台提供替岗或按日费用退款。',
        },
      ],
    },
    {
      type: TypeGood.PAY,
      classId: 'digital_product_repair',
      id: 'digital_product_repair_1',
      title: '电脑重装系统',
      subTitle: '服务专业，安全放心',
      image: 'mockImage://good_pc.png?token=6997e195-4fd7-470a-86d5-8ed2d1fad320',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_pc_detail.png?token=20937091-1fa9-401a-b988-897f72ee7e54',
        },
      ],
      price: 99,
      vipPrice: 59,
      soldNum: 800,
      serviceContentList: [
        {
          title: '全系统支持：',
          content: 'Windows 10/11 官方原版系统安装，可选家庭版/专业版。系统优化与驱动更新（含显卡、声卡、主板等必备驱动）。基础软件预装（办公套件、浏览器、安全软件等）',
        },
        {
          title: '数据安全保障：',
          content: 'C盘及桌面文件备份（需提前告知重要数据位置）。系统安装后提供临时存储转移服务（如迁移至D盘）',
        },
        {
          title: '附加服务：',
          content: 'BIOS/UEFI启动模式调试（解决启动盘识别问题）。系统激活（需用户提供正版密钥或代购服务）',
        },
      ],
      servicePipeList: [
        '1、在线预约：选择服务类型（上门/远程）、系统版本、附加需求。',
        '2、工程师对接： 上门服务：携带专业工具包，含启动盘、驱动库、备用配件；远程服务：通过安全软件远程操控，全程可视化操作。',
        '3、系统安装与调试：重装系统（约40-60分钟），安装后基础性能测试。',
      ],
      feeList: [
        '标准远程重装： ￥50-80 含系统安装+基础驱动+办公软件\n' +
          '上门基础服务：￥120-150 市区内上门，含系统优化\n' +
          '高端定制服务： ￥200+ 数据迁移+专业软件配置+1年保修',
      ],
      qaList: [
        {
          question: '重装系统会丢失我的文件吗？',
          answer: '仅格式化C盘，其他分区数据默认保留。建议提前备份重要文件至云端或移动硬盘',
        },
        {
          question: '需要自己准备系统镜像吗？',
          answer: '无需！工程师提供正版镜像，支持微软官方或纯净版系统',
        },
        {
          question: '远程操作安全吗？',
          answer: '使用加密通道，工程师仅操作系统安装步骤，无权限访问个人文件。',
        },
        {
          question: '苹果电脑能否重装系统？',
          answer: '支持MacOS系统降级/升级服务，需提前预约并确认机型兼容性。',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'window_clean',
      id: 'window_clean_0',
      title: '擦窗户',
      subTitle: '明码标价，拒绝乱收费',
      image: 'mockImage://good_window.png?token=f8c4cc0f-0315-45df-97f5-18a4ab9e2ad7',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_window_detail.png?token=bdf078d0-6272-442e-a597-91dcc6e4de1c',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 800,
      serviceContentList: [
        {
          title: '全面清洁：',
          content: '室内外玻璃双面擦拭，彻底清除灰尘、水渍、油污及顽固污渍。',
        },
        {
          title: '细节处理：',
          content: '窗框、窗槽、轨道深度清洁，避免积灰残留。',
        },
        {
          title: '安全防护：',
          content: '高层配备专业伸缩杆、防坠绳及双层保险，无需用户爬窗。',
        },
        {
          title: '环保用料：',
          content: '使用无腐蚀性清洁剂，保护玻璃镀膜，不留化学残留。',
        },
        {
          title: '增值服务：',
          content: '可选玻璃防雾涂层（+30元/扇），雨天防模糊。',
        },
      ],
      servicePipeList: [
        '1、预约下单\n' +
          '选择窗户类型（普通/落地窗/百叶窗）、数量及楼层信息。',
        '2、专业准备\n' +
          '工具包含刮水板、超细纤维布、喷壶等，30分钟快速响应',
        '3、标准作业：\n' +
          '第一步：喷洒清洁泡沫软化污渍，用刮板彻底清除1。\n' +
          '第二步：湿布+干布交替擦拭，确保无水痕2。\n' +
          '第三步：窗框缝隙用小刷子清理，顽固污渍人工二次处理。',
        '4、验收结单\n' +
          '用户检查后确认，提供72小时质保。',
      ],
      feeList: [
        '普通窗户（单扇）：25元起 含内外双面，≤1.5㎡\n' +
          '落地窗/大面积玻璃： 50元/㎡ 按实际面积测量计价\n' +
          '高层加价（≥6楼）： +10元/扇 含高空作业设备及保险费用',
      ],
      qaList: [
        {
          question: '擦窗需要多久？',
          answer: '普通家庭全屋约2-3小时，根据窗户数量及面积调整。',
        },
        {
          question: '擦窗会损坏窗帘或家具吗？',
          answer: '作业前会铺设防污垫，全程轻拿轻放，工具分区使用。',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'refrigerator_clean',
      id: 'refrigerator_clean_0',
      title: '家用冰箱蒸洗',
      subTitle: '冰箱不制冷/异响漏水检测维修',
      image: 'mockImage://good_refrigerator.png?token=17350c36-f14e-4473-bce2-c47c32da2faa',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_refrigerator_detail.png?token=bd1fd682-83f9-4e98-bfbe-c13ab1abba52',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 800,
      serviceContentList: [
        {
          title: '全面故障检测：',
          content: '包含制冷系统、压缩机、温控器、冷凝器等核心部件检测',
        },
        {
          title: '维修项目：',
          content: '制冷剂（雪种）加注/泄漏修复\n' +
            '压缩机卡缸/抱轴故障处理\n' +
            '门封条更换与密封性优化（含A4纸检测法）\n' +
            '排水管疏通与冷凝水异常处理',
        },
        {
          title: '附加服务：',
          content: '电路老化排查、除霜系统维护、日常使用保养指导',
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排师傅上门。',
        '3、上门服务：专业师傅30分钟响应，携带工具包。',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '基础检测费 ：30元（维修成功可抵扣）\n' +
          '常规维修 ：80-300元（含人工费，按故障复杂度分级）\n' +
          '制冷剂加注： 150-400元（根据型号及剂量）\n' +
          '配件更换：明码标价，采用国标级配件',
      ],
      qaList: [
        {
          question: '冰箱不制冷怎么办？',
          answer: '先检查门封密封性（可用纸币测试），若压缩机有异常金属碰撞声需立即断电',
        },
        {
          question: '维修后为何仍有噪音？',
          answer: ' 可能因放置不平/顶部物品共振，工程师将提供调平及收纳建议',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'refrigerator_clean',
      id: 'refrigerator_clean_00',
      title: '风冷冰箱蒸洗',
      subTitle: '冰箱不制冷/异响漏水检测维修',
      image: 'mockImage://good_refrigerator_detail.png?token=bd1fd682-83f9-4e98-bfbe-c13ab1abba52',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_refrigerator.png?token=17350c36-f14e-4473-bce2-c47c32da2faa',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 800,
      serviceContentList: [
        {
          title: '全面故障检测：',
          content: '包含制冷系统、压缩机、温控器、冷凝器等核心部件检测',
        },
        {
          title: '维修项目：',
          content: '制冷剂（雪种）加注/泄漏修复\n' +
            '压缩机卡缸/抱轴故障处理\n' +
            '门封条更换与密封性优化（含A4纸检测法）\n' +
            '排水管疏通与冷凝水异常处理',
        },
        {
          title: '附加服务：',
          content: '电路老化排查、除霜系统维护、日常使用保养指导',
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排师傅上门。',
        '3、上门服务：专业师傅30分钟响应，携带工具包。',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '基础检测费 ：30元（维修成功可抵扣）\n' +
          '常规维修 ：80-300元（含人工费，按故障复杂度分级）\n' +
          '制冷剂加注： 150-400元（根据型号及剂量）\n' +
          '配件更换：明码标价，采用国标级配件',
      ],
      qaList: [
        {
          question: '冰箱不制冷怎么办？',
          answer: '先检查门封密封性（可用纸币测试），若压缩机有异常金属碰撞声需立即断电',
        },
        {
          question: '维修后为何仍有噪音？',
          answer: ' 可能因放置不平/顶部物品共振，工程师将提供调平及收纳建议',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'closet_storage_organization',
      id: 'closet_storage_organization_0',
      title: '衣物收纳',
      subTitle: '专业收纳师上门服务',
      image: 'mockImage://good_organize.png?token=f3abfa43-4bd3-4bdd-9045-2347d424d080',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_organize_detail.png?token=0d102ae1-358f-4725-bea2-7d81e724d384',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 800,
      serviceContentList: [
        {
          title: '四季衣物分类整理：',
          content: '按季节/材质/使用频率精细分类，优化衣柜空间利用率。\n' +
            '特殊衣物（真丝、羊毛、泳装等）采用防尘防潮收纳，避免变形褪色。',
        },
        {
          title: '专业清洁预处理：',
          content: '提供代洗代熨服务（需提前预约），确保收纳衣物洁净无污渍。',
        },
        {
          title: '科学收纳方案定制：',
          content: '根据衣柜结构设计分区（悬挂区/折叠区/配件区），搭配可视标签管理',
        },
      ],
      servicePipeList: [
        '1、线上预约沟通： 填写需求表（空间尺寸/衣物类型/特殊需求），30分钟内客服确认细节。',
        '2、专业团队上门： 2名持证收纳师+1名清洁员组合服务，全程穿戴手套鞋套。',
        '3、四步整理法：清空分类→去留筛选→清洁处理→归位收纳，全程透明可监督。',
      ],
      feeList: [
        '基础套餐： 单个衣柜（≤2m³） 399元起\n' +
          '深度套餐： 全屋衣物（含床品） 899元起\n' +
          '增值服务： 代洗代熨/防蛀处理 +50~150元',
      ],
      qaList: [
        {
          question: '整理需要多久？',
          answer: '单个衣柜约2-3小时，全屋衣物通常6-8小时（含清洁时间）。',
        },
        {
          question: '我需要提前准备收纳盒吗？',
          answer: '无需准备！套餐包含无纺布收纳盒、植绒衣架、标签机耗材。',
        },
      ],
    },
    {
      type: TypeGood.PAY,
      classId: 'home_clean',
      id: 'home_clean_1',
      title: '深度保洁',
      subTitle: '每月一次，省心洁净',
      image: 'mockImage://good_deep_clean.png?token=4e852c5f-4035-425c-9e6c-2e33b2eb38ff',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_deep_clean_detail.png?token=8f041937-a22a-4317-bb59-59214cecba8b',
        },
      ],
      price: 128,
      vipPrice: 43,
      soldNum: 800,
      serviceContentList: [
        {
          title: '基础保洁：',
          content: '适合日常维护，快速清洁，保持家居整洁。',
        },
        {
          title: '清洁范围：',
          content: '地面、桌面、台面、家具表面除尘、垃圾清理、卫生间简单清洁等。',
        },
        {
          title: '服务时长：',
          content: '2 小时起',
        },
      ],
      serviceDetailList: [
        {
          title: '日常保洁2小时',
          subTitle: '适用50㎡以内',
          prices: [
            {
              desc: '买#count次(#price/小时)',
              count: 1,
              price: 49,
            },
            {
              desc: '买#count次(#price/小时)',
              count: 2,
              price: 48,
            },
          ],
        },
        {
          title: '日常保洁3小时',
          subTitle: '适用51-99㎡',
          prices: [
            {
              desc: '买#count次(#price/小时)',
              count: 1,
              price: 48,
            },
            {
              desc: '买#count次(#price/小时)',
              count: 2,
              price: 46,
            },
          ],
        },
        {
          title: '日常保洁4小时',
          subTitle: '适用100-119㎡',
          prices: [
            {
              desc: '买#count次(#price/小时)',
              count: 1,
              price: 45,
            },
            {
              desc: '买#count次(#price/小时)',
              count: 2,
              price: 43,
            },
          ],
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排保洁人员。',
        '3、上门服务： 保洁人员按时上门，提供专业服务。',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '收费标准： 根据服务类型、房屋面积、服务时长等因素综合计算。',
        '支付方式： 支持华为支付。',
      ],
      qaList: [
        {
          question: '如何预约保洁服务？',
          answer: '您可以点击详情页预约按钮、或电话进行预约。',
        },
        {
          question: '保洁人员是否经过培训？',
          answer: '我们的保洁人员均经过专业培训，持证上岗，服务规范。',
        },
        {
          question: '服务过程中出现问题怎么办？',
          answer: '您可以随时联系客服，我们会及时为您解决问题。',
        },
        {
          question: '可以指定保洁人员吗？',
          answer: '您可以根据保洁人员的评价和资料进行选择。',
        },
        {
          question: '服务完成后不满意怎么办？',
          answer: '您可以联系客服进行反馈，我们会根据实际情况进行处理。',
        },
      ],
    },
    {
      type: TypeGood.PAY,
      classId: 'clothes_wash',
      id: 'clothes_wash_0',
      title: '洗衣',
      subTitle: '懒人福音，上门取送包邮',
      image: 'mockImage://good_clothes.png?token=542d7d9a-4248-4582-a93a-1e03ee052749',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_clothes_detail.png?token=cfcb4cca-87ba-4398-8927-b4653fe11583',
        },
      ],
      price: 129,
      vipPrice: 30,
      soldNum: 800,
      serviceContentList: [
        {
          title: '全品类覆盖：',
          content: '日常衣物：衬衫、外套、牛仔裤等基础清洗与护理\n' +
            '高端服饰：真丝、羊绒、羊毛、羽绒服等专业养护\n' +
            '婴幼儿衣物：母婴级独立清洗，高温消毒+无荧光剂配方\n' +
            '特殊需求：衣物去渍、染色修复、纽扣加固等',
        },
      ],
      serviceDetailList: [
        {
          title: '春夏季衣物任洗',
          subTitle: '短袖短裤连衣裙夏季长裤等',
          prices: [
            {
              desc: '#count件任洗(#price/件)',
              count: 2,
              price: 15,
            },
            {
              desc: '#count件任洗(#price/件)',
              count: 4,
              price: 15,
            },
          ],
        },
        {
          title: '秋冬衣物任洗',
          subTitle: '外套牛仔裤大衣羽绒服等',
          prices: [
            {
              desc: '外套牛仔裤#count件(#price/件)',
              count: 2,
              price: 25,
            },
            {
              desc: '外套牛仔裤#count件(#price/件)',
              count: 4,
              price: 25,
            },
            {
              desc: '大衣羽绒服#count件(#price/件)',
              count: 2,
              price: 40,
            },
            {
              desc: '大衣羽绒服#count件(#price/件)',
              count: 4,
              price: 40,
            },
          ],
        },
        {
          title: '床单被套任洗',
          subTitle: '',
          prices: [
            {
              desc: '四件套#count套(#price/套)',
              count: 1,
              price: 30,
            },
            {
              desc: '四件套#count套(#price/套)',
              count: 2,
              price: 30,
            },
          ],
        },
      ],
      servicePipeList: [
        '1、一键预约：App下单 → 选择取衣时间（最快2小时上门） → 填写特殊需求备注',
        '2、专业处理：分拣质检：材质识别/污渍标注；科学清洗：30°C护色洗 | 40°C除菌洗 | 手工精洗（高端面料专用）；精细护理：蒸汽除皱 | 立体塑形包装',
        '3、安心交付：48小时内送回（加急服务可选）；全程物流追踪 + 洗护前后对比图反馈',
      ],
      feeList: [
        '基础清洗 ：15-30元/件 清洗/消毒/普通熨烫\n' +
          '高端面料护理： 50-120元/件 手工精洗/塑形养护/去渍\n' +
          '特殊服务： 20-80元/项 染色修复\n' +
          '*加急费（6小时）： +30%基础费 优先处理通道',
      ],
      qaList: [
        {
          question: '取送衣物会接触其他家庭物品吗？',
          answer: '全程使用独立密封包装箱，配送员佩戴手套操作，严格执行「无接触交接」流程。',
        },
        {
          question: '衣物损坏如何赔付？',
          answer: '购买服务自动获赠「洗护险」，出现争议时：72小时响应鉴定 → 按衣物折旧价全额赔付。',
        },
      ],
    },
    {
      type: TypeGood.PAY,
      classId: 'clothes_wash',
      id: 'clothes_wash_1',
      title: '洗鞋',
      subTitle: '懒人福音，上门取送包邮',
      image: 'mockImage://good_shoe.png?token=f4370533-6833-460e-9457-061cbc2e6414',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_shoe_detail.png?token=6cca632a-e131-4045-bae2-34ba26791907',
        },
      ],
      price: 89,
      vipPrice: 20,
      soldNum: 800,
      serviceContentList: [
        {
          title: '全品类覆盖：',
          content: '运动鞋：深层去污 + 网面护理 + 中底清洁\n' +
            '皮鞋/麂皮：专用清洁剂 + 固色抛光 + 皮质保养\n' +
            '帆布鞋/布鞋：去黄去渍 + 定型烘干 + 防水喷雾\n' +
            '特殊材质（如羊毛、丝绸）：手工精洗 + 低温护理',
        },
      ],
      serviceDetailList: [
        {
          title: '鞋靴任洗',
          subTitle: '',
          prices: [
            {
              desc: '#count双任洗(#price/双)',
              count: 1,
              price: 20,
            },
            {
              desc: '#count双任洗(#price/双)',
              count: 2,
              price: 20,
            },
            {
              desc: '#count双任洗(#price/双)',
              count: 3,
              price: 20,
            },
            {
              desc: '#count双任洗(#price/双)',
              count: 4,
              price: 20,
            },
          ],
        },
      ],
      servicePipeList: [
        '1、一键预约：App下单 → 选择取鞋时间（最快2小时上门） → 填写特殊需求备注',
        '2、安心交付：48小时内送回（加急服务可选）；全程物流追踪 + 洗护前后对比图反馈',
      ],
      feeList: [
        '运动鞋/帆布鞋： ¥39 鞋带增白 ¥10，防水喷雾 ¥15\n' +
          '皮鞋/麂皮： ¥69 固色保养 ¥20，皮质修复 ¥30\n' +
          '特殊材质（限量款）： ¥99起 根据材质定制报价3\n',
      ],
      qaList: [
        {
          question: '工作人员损坏物品怎么处理？',
          answer: '通过平台投诉通道，48小时内启动保险理赔流程',
        },
        {
          question: '法定节假日如何计费？',
          answer: '春节/国庆等法定假日按双倍工资计算，需提前3天预约',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'window_clean',
      id: 'window_clean_1',
      title: '落地窗擦洗',
      subTitle: '明码标价，拒绝乱收费',
      image: 'mockImage://good_window_2.png?token=fcf1ca40-abd4-43a0-b2a3-e38e75691d1d',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_window_2_detail.png?token=3ab3287a-22d2-41b0-a94f-3a3b8f4cc604',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 800,
      serviceContentList: [
        {
          title: '细节处理',
          content: '窗框、窗槽、轨道深度清洁，避免积灰残留。',
        },
        {
          title: '全面清洁',
          content: '室内外玻璃双面擦拭，彻底清除灰尘、水渍、油污及顽固污渍。',
        },
        {
          title: '安全防护',
          content: '高层配备专业伸缩杆、防坠绳及双层保险，无需用户爬窗。',
        },
        {
          title: '环保用料',
          content: '使用无腐蚀性清洁剂，保护玻璃镀膜，不留化学残留。',
        },
        {
          title: '增值服务',
          content: '可选玻璃防雾涂层（+30元/扇），雨天防模糊。',
        },
      ],
      servicePipeList: [
        '1、预约下单：选择窗户类型（普通/落地窗/百叶窗）、数量及楼层信息。',
        '2、专业准备：工具包含刮水板、超细纤维布、喷壶等，30分钟快速响应',
        '3、标准作业：第一步：喷洒清洁泡沫软化污渍，用刮板彻底清除。第二步：湿布+干布交替擦拭，确保无水痕。第三步：窗框缝隙用小刷子清理，顽固污渍人工二次处理。',
        '4、验收结单：用户检查后确认，提供72小时质保。',
      ],
      feeList: [
        '普通窗户（单扇）：25元起 含内外双面，≤1.5㎡\n' +
          '落地窗/大面积玻璃： 50元/㎡ 按实际面积测量计价\n' +
          '高层加价（≥6楼）： +10元/扇 含高空作业设备及保险费用',
      ],
      qaList: [
        {
          question: '擦窗需要多久？',
          answer: '普通家庭全屋约2-3小时，根据窗户数量及面积调整。',
        },
        {
          question: '擦窗会损坏窗帘或家具吗？',
          answer: '作业前会铺设防污垫，全程轻拿轻放，工具分区使用。',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'window_clean',
      id: 'window_clean_2',
      title: '高空窗户擦洗',
      subTitle: '明码标价，拒绝乱收费',
      image: 'mockImage://good_window_2_detail.png?token=3ab3287a-22d2-41b0-a94f-3a3b8f4cc604',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_window_2.png?token=fcf1ca40-abd4-43a0-b2a3-e38e75691d1d',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 800,
      serviceContentList: [
        {
          title: '细节处理',
          content: '窗框、窗槽、轨道深度清洁，避免积灰残留。',
        },
        {
          title: '全面清洁',
          content: '室内外玻璃双面擦拭，彻底清除灰尘、水渍、油污及顽固污渍。',
        },
        {
          title: '安全防护',
          content: '高层配备专业伸缩杆、防坠绳及双层保险，无需用户爬窗。',
        },
        {
          title: '环保用料',
          content: '使用无腐蚀性清洁剂，保护玻璃镀膜，不留化学残留。',
        },
        {
          title: '增值服务',
          content: '可选玻璃防雾涂层（+30元/扇），雨天防模糊。',
        },
      ],
      servicePipeList: [
        '1、预约下单：选择窗户类型（普通/落地窗/百叶窗）、数量及楼层信息。',
        '2、专业准备：工具包含刮水板、超细纤维布、喷壶等，30分钟快速响应',
        '3、标准作业：第一步：喷洒清洁泡沫软化污渍，用刮板彻底清除。第二步：湿布+干布交替擦拭，确保无水痕。第三步：窗框缝隙用小刷子清理，顽固污渍人工二次处理。',
        '4、验收结单：用户检查后确认，提供72小时质保。',
      ],
      feeList: [
        '普通窗户（单扇）：25元起 含内外双面，≤1.5㎡\n' +
          '落地窗/大面积玻璃： 50元/㎡ 按实际面积测量计价\n' +
          '高层加价（≥6楼）： +10元/扇 含高空作业设备及保险费用',
      ],
      qaList: [
        {
          question: '擦窗需要多久？',
          answer: '普通家庭全屋约2-3小时，根据窗户数量及面积调整。',
        },
        {
          question: '擦窗会损坏窗帘或家具吗？',
          answer: '作业前会铺设防污垫，全程轻拿轻放，工具分区使用。',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'closet_storage_organization',
      id: 'closet_storage_organization_1',
      title: '包饰收纳整理',
      subTitle: '专业收纳师上门服务',
      image: 'mockImage://good_bag.png?token=7e6824f7-d5e3-476f-a70e-2271c11e683e',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_bag_detail.png?token=41472a1a-d466-45fc-8c17-31c3a06be5c0',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 800,
      serviceContentList: [
        {
          title: '全品类包饰护理',
          content: '皮革/帆布/绒面等材质清洁保养\n' +
            '五金配件抛光防氧化处理\n' +
            '内衬除尘除味服务',
        },
        {
          title: '专属收纳方案',
          content: '1V1需求分析（适用场景：奢侈品收藏、日常收纳等）\n' +
            '3D立体空间效果图预览',
        },
        {
          title: '附加服务',
          content: '可选购环保级收纳盒/防尘罩\n' +
            '季度回访保养（享9折续约优惠）',
        },
      ],
      servicePipeList: [
        '1、线上预约沟通： 填写需求表（空间尺寸/衣物类型/特殊需求），30分钟内客服确认细节。',
        '2、专业团队上门： 2名持证收纳师+1名清洁员组合服务，全程穿戴手套鞋套。',
        '3、四步整理法：清空分类→去留筛选→清洁处理→归位收纳，全程透明可监督。',
      ],
      feeList: [
        '单品类收纳：少于10件， 299元起 2-3小时\n' +
          '全屋包饰整理： 888元起， 5-8小时\n' +
          '年度托管服务： 1980元/年 ，每月上门1次',
      ],
      qaList: [
        {
          question: '整理需要多久？',
          answer: '单个衣柜约2-3小时，全屋衣物通常6-8小时（含清洁时间）。',
        },
        {
          question: '我需要提前准备收纳盒吗？',
          answer: '无需准备！套餐包含无纺布收纳盒、植绒衣架、标签机耗材。',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'house_repair',
      id: 'house_repair_1',
      title: '花洒安装/维修',
      subTitle: '服务专业，安全放心',
      image: 'mockImage://good_shower.png?token=d7060568-acc4-4ca5-9f52-7d0d15f1e457',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_shower_detail.png?token=550d1d1c-7139-4391-9ac0-b9c34d3b96da',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 800,
      serviceContentList: [
        {
          title: '标准花洒安装',
          content: '含手持/顶喷/侧喷花洒固定架定位、进出水管连接、混水阀调试\n' +
            '适配材质：瓷砖/玻璃/实墙，提供免打孔或钻孔安装方案3',
        },
        {
          title: '智能花洒调试',
          content: '恒温阀芯校准、多档出水模式设置、蓝牙或APP联动功能配置',
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排师傅上门。',
        '3、上门服务：专业师傅30分钟响应，携带工具包',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '基础安装费： ¥59-129 含人工+标准辅材（密封胶/生料带）\n' +
          '加急服务：（3小时内） +¥30 仅限主城区\n' +
          '特殊墙体打孔： +¥20/孔 玻璃/大理石需专用钻头\n' +
          '智能花洒调试： +¥50 含电子说明书讲解',
      ],
      qaList: [
        {
          question: '安装需要准备什么？',
          answer: '需提前关闭总水阀，清理安装区域；若自备花洒，请确认配件齐全（参考安装图）',
        },
        {
          question: '旧水管老化怎么办？',
          answer: '加购【水管检测服务】，排查隐患并提供改造方案。',
        },
        {
          question: '能否夜间安装？',
          answer: '18:00-21:00时段需支付夜间服务费¥50，优先推荐工作日白天施工。',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'pipe_clear',
      id: 'pipe_clear_1',
      title: '卫生间马桶下水道疏通',
      subTitle: '服务专业，安全放心',
      image: 'mockImage://good_toilet.png?token=654b762d-b01e-495c-8959-d8a820a7df7a',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_toilet_detail.png?token=4f973f55-1667-4a17-b3f7-0183e6500377',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 800,
      serviceContentList: [
        {
          title: '专业疏通马桶:',
          content: '解决纸巾、清洁球、塑料等软硬物造成的堵塞；\n' +
            '处理马桶冲水缓慢、下水不畅等问题。',
        },
        {
          title: '管道深度疏通',
          content: '清除尿碱、水泥、头发等顽固堵塞；\n' +
            '覆盖卫生间、厨房、阳台下水管道及地漏。',
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排师傅上门。',
        '3、上门服务：专业师傅30分钟响应，携带工具包',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '基础疏通费：80-150元（普通堵塞，30分钟内解决）\n' +
          '深度疏通费：200-400元（尿碱硬化管道变形等复杂问题）',
      ],
      qaList: [
        {
          question: '疏通会破坏马桶釉面吗？',
          answer: '采用软管疏通技术，全程无损作业',
        },
        {
          question: '疏通后再次堵塞怎么办？',
          answer: '提供24小时保修服务，免费返修',
        },
        {
          question: '自行疏通失败，还能补救吗？',
          answer: '可处理因化学药剂、工具操作不当导致的二次堵塞。',
        },
        {
          question: '费用包含管道改造吗？',
          answer: '仅含疏通维修，如需改管需额外评估报价',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'refrigerator_clean',
      id: 'refrigerator_clean_1',
      title: '对开门大冰箱清洗',
      subTitle: '冰箱不制冷/异响漏水检测维修',
      image: 'mockImage://good_fridge2.png?token=e5bab555-0145-44c1-b805-6552b680bdc6',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_fridge2_detail.png?token=a4c08572-0726-4293-a814-dbf98b727454',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 800,
      serviceContentList: [
        {
          title: '全面故障检测',
          content: '包含制冷系统、压缩机、温控器、冷凝器等核心部件检测',
        },
        {
          title: '维修项目',
          content: '制冷剂（雪种）加注/泄漏修复\n' +
            '压缩机卡缸/抱轴故障处理\n' +
            '门封条更换与密封性优化（含A4纸检测法）\n' +
            '排水管疏通与冷凝水异常处理',
        },
        {
          title: '附加服务',
          content: '电路老化排查、除霜系统维护、日常使用保养指导',
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排师傅上门。',
        '3、上门服务：专业师傅30分钟响应，携带工具包。',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '基础检测费 ：30元（维修成功可抵扣）\n' +
          '常规维修 ：80-300元（含人工费，按故障复杂度分级）\n' +
          '制冷剂加注： 150-400元（根据型号及剂量）\n' +
          '配件更换：明码标价，采用国标级配件',
      ],
      qaList: [
        {
          question: '冰箱不制冷怎么办？',
          answer: '先检查门封密封性（可用纸币测试），若压缩机有异常金属碰撞声需立即断电',
        },
        {
          question: '维修后为何仍有噪音？',
          answer: ' 可能因放置不平/顶部物品共振，工程师将提供调平及收纳建议',
        },
      ],
    },
    {
      type: TypeGood.CONSULT,
      classId: 'refrigerator_clean',
      id: 'refrigerator_clean_2',
      title: '三门冰箱清洗',
      subTitle: '冰箱不制冷/异响漏水检测维修',
      image: 'mockImage://good_fridge2_detail.png?token=a4c08572-0726-4293-a814-dbf98b727454',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_fridge2.png?token=e5bab555-0145-44c1-b805-6552b680bdc6',
        },
      ],
      price: 0,
      vipPrice: 0,
      soldNum: 800,
      serviceContentList: [
        {
          title: '全面故障检测',
          content: '包含制冷系统、压缩机、温控器、冷凝器等核心部件检测',
        },
        {
          title: '维修项目',
          content: '制冷剂（雪种）加注/泄漏修复\n' +
            '压缩机卡缸/抱轴故障处理\n' +
            '门封条更换与密封性优化（含A4纸检测法）\n' +
            '排水管疏通与冷凝水异常处理',
        },
        {
          title: '附加服务',
          content: '电路老化排查、除霜系统维护、日常使用保养指导',
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排师傅上门。',
        '3、上门服务：专业师傅30分钟响应，携带工具包。',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '基础检测费 ：30元（维修成功可抵扣）\n' +
          '常规维修 ：80-300元（含人工费，按故障复杂度分级）\n' +
          '制冷剂加注： 150-400元（根据型号及剂量）\n' +
          '配件更换：明码标价，采用国标级配件',
      ],
      qaList: [
        {
          question: '冰箱不制冷怎么办？',
          answer: '先检查门封密封性（可用纸币测试），若压缩机有异常金属碰撞声需立即断电',
        },
        {
          question: '维修后为何仍有噪音？',
          answer: ' 可能因放置不平/顶部物品共振，工程师将提供调平及收纳建议',
        },
      ],
    },
    {
      type: TypeGood.PAY,
      classId: 'home_clean',
      id: 'home_clean_banner1',
      title: '全屋清洁',
      subTitle: '除尘除垢 | 又快又好',
      image: 'mockImage://banner_1.png?token=6292deda-7916-4034-b504-94bae6bd8eeb',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_3.png?token=9f1dc9a5-45d6-49bd-b660-53dfdbe24f96',
        },
      ],
      price: 210,
      vipPrice: 169,
      soldNum: 1000,
      serviceContentList: [
        {
          title: '全屋保洁：',
          content: '适合搬家场景，开荒清洁，解放你的双手。',
        },
        {
          title: '清洁范围：',
          content: '地面、桌面、台面、家具表面除尘、垃圾清理、卫生间清洁等。',
        },
        {
          title: '服务时长：',
          content: '4小时起',
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排保洁人员。',
        '3、上门服务： 保洁人员按时上门，提供专业服务。',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '收费标准： 根据服务类型、房屋面积、服务时长等因素综合计算。',
        '支付方式： 支持华为支付。',
      ],
      qaList: [
        {
          question: '如何预约保洁服务？',
          answer: '您可以点击详情页预约按钮、或电话进行预约。',
        },
        {
          question: '保洁人员是否经过培训？',
          answer: '我们的保洁人员均经过专业培训，持证上岗，服务规范。',
        },
        {
          question: '服务过程中出现问题怎么办？',
          answer: '您可以随时联系客服，我们会及时为您解决问题。',
        },
        {
          question: '可以指定保洁人员吗？',
          answer: '您可以根据保洁人员的评价和资料进行选择。',
        },
        {
          question: '服务完成后不满意怎么办？',
          answer: '您可以联系客服进行反馈，我们会根据实际情况进行处理。',
        },
      ],
    },
    {
      type: TypeGood.PAY,
      classId: 'window_clean',
      id: 'window_clean_banner2',
      title: '全屋擦亮',
      subTitle: '玻璃焕新 | 干净明亮',
      image: 'mockImage://banner_2.jpeg?token=328d0d98-6d7b-4c93-9256-1f86f952523e',
      intro: [
        {
          type: IntroType.IMAGE,
          value: 'mockImage://good_window_detail.png?token=bdf078d0-6272-442e-a597-91dcc6e4de1c',
        },
      ],
      price: 195,
      vipPrice: 129,
      soldNum: 2000,
      serviceContentList: [
        {
          title: '全屋玻璃：',
          content: '专业团队，解决高空玻璃清洁难题。',
        },
        {
          title: '清洁范围：',
          content: '厨房玻璃、阳台玻璃、卫生间玻璃等。',
        },
        {
          title: '服务时长：',
          content: '4小时起',
        },
      ],
      servicePipeList: [
        '1、在线预约： 选择服务类型、时间、地址等信息。',
        '2、确认订单： 客服确认订单信息，安排保洁人员。',
        '3、上门服务： 保洁人员按时上门，提供专业服务。',
        '4、验收评价： 服务完成后，确认服务效果并进行评价。',
      ],
      feeList: [
        '收费标准： 根据服务类型、房屋面积、服务时长等因素综合计算。',
        '支付方式： 支持华为支付。',
      ],
      qaList: [
        {
          question: '如何预约保洁服务？',
          answer: '您可以点击详情页预约按钮、或电话进行预约。',
        },
        {
          question: '保洁人员是否经过培训？',
          answer: '我们的保洁人员均经过专业培训，持证上岗，服务规范。',
        },
        {
          question: '服务过程中出现问题怎么办？',
          answer: '您可以随时联系客服，我们会及时为您解决问题。',
        },
        {
          question: '可以指定保洁人员吗？',
          answer: '您可以根据保洁人员的评价和资料进行选择。',
        },
        {
          question: '服务完成后不满意怎么办？',
          answer: '您可以联系客服进行反馈，我们会根据实际情况进行处理。',
        },
      ],
    },
  ];
}