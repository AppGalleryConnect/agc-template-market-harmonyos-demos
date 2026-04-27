import { DetailsFeatures, tableItem, tableContent } from 'common_travel_guide'

// 详情特色
export const detailsFeaturesList: DetailsFeatures[] = [
  {
    id: 1,
    icon: 'app.media.icon_details_features_01',
    title: '行程安排',
    describe: ['适合大部分用户，保障适当时间欣赏美景，也提供适当休息空间']
  },
  {
    id: 2,
    icon: 'app.media.icon_details_features_02',
    title: '交通',
    describe: ['飞机往返，航班时间可选', '提供目的地专车接机服务']
  },
  {
    id: 3,
    icon: 'app.media.icon_details_features_03',
    title: '游玩',
    describe: ['11个景点/场馆', '部分景点不含门票', '无购物', '含4晚4钻酒店']
  },
  {
    id: 4,
    icon: 'app.media.icon_details_features_04',
    title: '住宿',
    describe: ['含酒店']
  },
  {
    id: 5,
    icon: 'app.media.icon_details_features_05',
    title: '餐食',
    describe: ['成人含早餐午餐，自理', '儿童含午餐，自理']
  }
]

// 购买须知
export const purchaseNoteList: DetailsFeatures[] = [
  {
    id: 1,
    icon: 'app.media.icon_purchase_note_01',
    title: '预定限制',
    describe: '年龄限制、人群限制、其他限制'
  },
  {
    id: 2,
    icon: 'app.media.icon_purchase_note_02',
    title: '单人/多人入住政策',
    describe: '单房差、多人入住'
  },
  {
    id: 3,
    icon: 'app.media.icon_purchase_note_03',
    title: '成团说明',
    describe: '成团说明、出团通知、拼团说明'
  },
  {
    id: 4,
    icon: 'app.media.icon_purchase_note_04',
    title: '违约条款',
    describe: ''
  },
  {
    id: 5,
    icon: 'app.media.icon_purchase_note_05',
    title: '预定及出行须知',
    describe: ''
  },
  {
    id: 6,
    icon: 'app.media.icon_purchase_note_06',
    title: '保障提示',
    describe: ''
  }
]

// 预定限制
export const reserveLimit: tableItem[] = [
  {
    title: '年龄限制',
    contentList: ['此线路行程强度较大，请确保身体健康 适宜旅游，如出行人中有70周岁（含）以上老人，须至少有1位18周岁-69周岁',
      '亲友陪同方可参团，敬请谅解', '出于安全考虑，18岁以下未成年人需要至少一名成年旅客陪同'],
  },
  {
    title: '国籍限制',
    contentList: ['此线路因服务能力有限，暂仅接受持有中国大陆、中国香港、中国澳门、中国台湾有效身份证件的客人预订，敬请谅解'],
  },
  {
    title: '人群限制',
    contentList: ['出于安全考虑，本产品不接受孕妇预订，敬请谅解'],
  },
  {
    title: '其他限制',
    contentList: ['如产品确认单或补充条款中的约定与旅游合同主协议不一致的，以产品确认单或补充条款为准'],
    color: '#FF4A26'
  }
]

// 单人/多人入住政策
export const checkInPolicy: tableItem[] = [
  {
    title: '单房差',
    contentList: ['综合考量目前常规团队出行人群结构并考虑实际入住体验等因素，本产品暂时无法提供拼房。报价是按照2成人入住1间房计算的价格，请在页面中选择所需房间数或单人房差选项'],
    color: '#FF4A26'
  },
  {
    title: '多人入住',
    contentList: [
      '本产品可尝试申请3人间或加床服务，如您需3成人入住1间房，在预订时备注，后续是否可以安排及相关费用以员工回复为准（温馨提示：当地酒店面积小，加床可能会引起您的不便）',
    ]
  }
]

// 成团说明
export const groupNotes: tableItem[] = [
  {
    title: '成团说明',
    contentList: [
      '本产品最少成团人数1人，订单一经旅行网以书面形式确认后均默认发团，若因旅行社原因未发团，旅行社将按双方合同约定的违约条款予以赔付每团最多人数为20人（含占座儿童），如实际出行人数超出范围，一经核查，按订单总额10%赔付',
    ]
  },
  {
    title: '出团通知',
    contentList: [
      '最晚在出行前1天20:00，您将收到《出团通知书》（付款时间在出发前1天18:00后的，会于出发当天12:00前发送）。如未收到请及时联系工作人员。集合时间可参考网站披露，具体请以《出团通知书》或服务人员通知为准'
    ]
  },
  {
    title: '拼团说明',
    contentList: [
      '本线路在不影响您行程的情况下，部分行程段可能会与其他客人合并用车，共同游玩。如有入住其他不同酒店的客人，当地司导人员会根据团队实际情况安排接送事宜，敬请谅解',
    ],
    color: '#FF4A26'
  }
]

// 保障提示
export const assuranceTips: tableItem[] = [
  {
    contentList: [
      '为了维护切实履行好普通消费者权益保护等方面的义务，我们会基于交易安全和公平原则对包括但不限于扰乱系统、网络攻击、刷单、倒卖转售的订单及包括但不限于注册账号、用户信息、交易数量存在异常的订单进行交易风险判定，此部分不符合交易安全和公平原则的订单有权采取警示、暂停或者终止服务等措施且不承担因此原因取消订单的任何责任。'
    ]
  }
]

// 预定及出行须知（title 为空字符串）
export const bookingTravelNotes: tableItem[] = [
  {
    contentList: [
      '如为多人出行，预订人/旅游者代表确认已征得其余全体出行人同意作为本次旅游签约代表，受托人在旅游合同及其附件上的签字全体委托人均予以认可。如您未取得授权，请不要代为预订下单/签署合同'
    ],
    color: '#FF4A26'
  },
  {
    contentList: [
      '为确保未成年人出行安全，建议未成年出行由监护人陪同或同行者持监护人委托证明'
    ]
  },
  {
    contentList: [
      '请您在预订时务必提供准确、完整的信息（姓名、性别、证件号码、国籍、联系方式等），以免产生预订错误，影响出行。如因您提供信息错误而造成损失，由您自行承担'
    ],
    color: '#FF4A26'
  },
  {
    contentList: [
      '本产品目的地海拔较高，有严重高血压、心脏病等疾病的客人及老年客人，请根据自身条件，遵医嘱，谨慎决定是否出行，报名后，请提前备好能够有效缓解因高原反应引起的症状药物，并做好行前各项准备。高原地区气候干燥，日照强烈，紫外线强，建议客人带好墨镜、太阳帽、防晒霜、润唇膏等物品；高原地区早晚温差大，请客人准备长袖衣裤及防寒衣物，另外建议携带感冒药、肠胃药、阿斯匹林、安定、头痛粉等药品，以防高原反应引起的身体不适。行程中，如有身体不适请第一时间通知随团服务人员及旅行社，同时让服务人员协助就医，遵循医嘱'
    ]
  },
  {
    contentList: [
      '请您在下订单时，在备注中提供准确的信息，以便工作人员安排您预订的项目'
    ]
  },
  {
    contentList: [
      '如因意外事件及不可抗力，包括但不限于航空公司运力调配、机场临时关闭、天气原因、航空管制等导致航班取消或延期的，旅行社将尽最大努力协助您办理变更事宜，如产生差价，多退少补'
    ]
  },
  {
    contentList: [
      '【有自费项】本产品会在当地由随团服务人员根据具体情况推荐自费项目，例如导游收取景区小交通、各类演出/体验门票等，您可根据自身需要选择是否参加，绝无强制消费'
    ]
  },
  {
    contentList: [
      '出游过程中，如遇不可抗力因素造成景点/场馆未能正常游玩/参观，服务人员经与您协商一致后可根据实际情况取消或更换该景点/场馆，或由服务人员在现场按旅游产品中的门票价退还费用（退费不以景区/场馆挂牌价为准），敬请谅解'
    ],
    color: '#FF4A26'
  }
]

// 违约条款
export const breachClauseTable: tableItem[] = [
  {
    title: '行程前',
    contentList: [
      '违约金'
    ],
  },
  {
    title: '行程前4-6日',
    contentList: [
      '20%'
    ],
  },
  {
    title: '行程前3-1日',
    contentList: [
      '40%'
    ],
  },
  {
    title: '行程开始当日',
    contentList: [
      '60%'
    ],
  }
]

export const breachClauseContent: tableContent[] = [
  {
    describe:'旅行社违约： ',
    subDescribe:'在行程前解除合同的，旅行社向旅游者退还已收取的全部旅游费用，并按下列标准向旅游者支付违约金：',
    tableList:breachClauseTable,
    remark:'如按上述比例支付的违约金不足以赔偿旅游者的实际损失，旅行社应当按实际损失对旅游者予以赔偿。',
  },
  {
    describe:'旅游者违约：',
    subDescribe:'在行程前解除合同的，必要的费用扣除标准为：',
    tableList:breachClauseTable,
    remark:'如按上述约定比例扣除的必要的费用低于实际发生的费用，旅游者按照实际发生的费用支付，但最高额不应当超过旅游费用总额。 因部分旅游资源需提前预订的特殊性，本产品线路在旅行社成团后至出行前6天外取消的，也将产生实际损失，具体损失包括但不限于机票、酒店等，如旅游者需要取消订单，应及时联系旅行社，旅行社除协助旅游者减损并退还未实际发生的损失费用外不再承担其他赔偿责任。',
    color: '#FF4A26'
  }
]


