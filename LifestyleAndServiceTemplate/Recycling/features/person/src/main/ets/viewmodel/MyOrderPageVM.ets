import { OrderDetailBean } from 'module_time_line'

@ObservedV2
export class MyOrderPageVM {
  private static _instance: MyOrderPageVM;

  public static get instance() {
    if (!MyOrderPageVM._instance) {
      MyOrderPageVM._instance = new MyOrderPageVM();
    }
    return MyOrderPageVM._instance;
  }

  // 物流信息
  @Trace timeLineList: OrderDetailBean[] = [
    {
      nodeName: '上门取件',
      nodeStatus: 0,
      nodeContent: [],
      nodeTime: '2025年11月20日 10:00-12:00'
    },
    {
      nodeName: '运输中',
      nodeStatus: 0,
      nodeContent: [
        {
          nodeName: '快件已到达北京市 海淀区 西四环 复兴路分拣中心',
          color: 'rgba(142, 142, 142, 1)'
        }
      ],
      nodeTime: '2025年11月22日 10:00-12:00'
    },
    {
      nodeName: '派件中',
      nodeStatus: 0,
      nodeContent: [
        {
          nodeName: '快件已到达北京市 海淀区 西四环 复兴路800号',
          color: 'rgba(142, 142, 142, 1)'
        },
        {
          nodeName: '鲁师傅  188**20029988',
          color: 'rgba(255, 75, 75, 1)'
        }
      ],
      nodeTime: '2025年11月23日 10:00 已送达'
    },
    {
      nodeName: '已送达',
      nodeStatus: 1,
      nodeContent: [],
      nodeTime: '2025年11月23日 12:00  前台已签收'
    }
  ]
  // 订单退回物流信息1
  @Trace cancelTimeLineList1: OrderDetailBean[] = [
    {
      nodeName: '邮寄寄出',
      nodeStatus: 0,
      nodeContent: [],
      nodeTime: '2025年11月25日 10:00-12:00'
    },
    {
      nodeName: '运输中',
      nodeStatus: 0,
      nodeContent: [
        {
          nodeName: '快件已到达南京市',
          color: 'rgba(142, 142, 142, 1)'
        }
      ],
      nodeTime: '2025年11月26日 10:00-12:00'
    },
    {
      nodeName: '派件中',
      nodeStatus: 0,
      nodeContent: [
        {
          nodeName: '南京市 建邺区 永初路 金陵天地商城A栋1102',
          color: 'rgba(142, 142, 142, 1)'
        },
        {
          nodeName: '张师傅  133**778852',
          color: 'rgba(255, 75, 75, 1)'
        }
      ],
      nodeTime: '2025年11月26日 18:00 已送达'
    },
    {
      nodeName: '已送达',
      nodeStatus: 1,
      nodeContent: [],
      nodeTime: '2025年11月26日 19:00  前台已签收'
    }
  ]
  // 订单退回物流信息2
  @Trace cancelTimeLineList2: OrderDetailBean[] = [
    {
      nodeName: '邮寄寄出',
      nodeStatus: 0,
      nodeContent: [],
      nodeTime: '2025年11月25日 10:00-12:00'
    },
    {
      nodeName: '运输中',
      nodeStatus: 0,
      nodeContent: [
        {
          nodeName: '快件已到达南京市',
          color: 'rgba(142, 142, 142, 1)'
        }
      ],
      nodeTime: '2025年11月26日 10:00-12:00'
    },
    {
      nodeName: '派件中',
      nodeStatus: 0,
      nodeContent: [
        {
          nodeName: '南京市 建邺区 永初路 金陵天地商城A栋1102',
          color: 'rgba(142, 142, 142, 1)'
        },
        {
          nodeName: '张师傅  133**778852',
          color: 'rgba(255, 75, 75, 1)'
        }
      ],
      nodeTime: '2025年11月26日 18:00 已送达'
    },
    {
      nodeName: '平台拒签',
      nodeStatus: 0,
      nodeContent: [],
      nodeTime: '2025年11月26日 19:00  前台已签收'
    },
    {
      nodeName: '邮寄寄回',
      nodeStatus: 1,
      nodeContent: [{
        nodeName: '快件已到达南京市',
        color: 'rgba(142, 142, 142, 1)'
      }],
      nodeTime: '2025年11月27日 10:00'
    }
  ]
  // 订单配置对象：公用
  orderConfig: OrderMasterInfo = new OrderMasterInfo(123456789123, '张师傅', $r('app.media.image_master_avatar'), 5,
    '优质服务', '11月20日(周一)10:00-12:00',
    new OrderLocationInfo('南京市 建邺区 永初路 金陵天地商城A栋1102', '100****0000', '用户7292dr'),
    new OrderProcessInfo(0, this.timeLineList),
    new OrderProcessInfo(0, this.cancelTimeLineList1),
    new OrderProcessInfo(0, this.cancelTimeLineList2), '66688800000252555555555', '66688800000252555558885')
  // 订单列表
  @Trace orderList: Array<OrderItem> = [
    new OrderItem(123456789123, '华为 Mart 60 Pro   512GB+12GB', $r('app.media.image_demo_phone3'), 1, 3000,
      'XXX的小店', '待发货',
      '2025-11-12  09:30:00', '', '中国银行|61************5566', 2000, this.orderConfig, ''),
    new OrderItem(123456789124, '华为 Mart 60 Pro   512GB+12GB', $r('app.media.image_demo_phone3'), 1, 3000,
      'XXX的小店', '待处理',
      '2025-11-12  09:30:00', '', '中国银行|61************5566', 2000, this.orderConfig, '待处理1'),
    new OrderItem(123456789125, '华为 Mart 60 Pro   512GB+12GB', $r('app.media.image_demo_phone3'), 1, 3000,
      'XXX的小店', '待处理-已质检',
      '2025-11-12  09:30:00', '', '中国银行|61************5566', 2000, this.orderConfig, '待处理2', true),
    new OrderItem(123456789126, '华为 Mart 60 Pro   512GB+12GB', $r('app.media.image_demo_phone3'), 1, 3000,
      'XXX的小店', '待处理-已质检-确认收款',
      '2025-11-12  09:30:00', '', '中国银行|61************5566', 2000, this.orderConfig, '待处理2', true),
    new OrderItem(123456789127, '华为 Mart 60 Pro   512GB+12GB', $r('app.media.image_demo_phone3'), 1, 3000,
      'XXX的小店', '已完成',
      '2025-11-12  09:30:00', '', '中国银行|61************5566', 2000, this.orderConfig, ''),
    new OrderItem(123456789128, '华为 Mart 60 Pro   512GB+12GB', $r('app.media.image_demo_phone3'), 1, 3000,
      'XXX的小店', '已取消',
      '2025-11-12  09:30:00', '2025-11-12  10:30:00', '中国银行|61************5566', 2000, this.orderConfig,
      '已取消1'),
    new OrderItem(123456789129, '华为 Mart 60 Pro   512GB+12GB', $r('app.media.image_demo_phone3'), 1, 3000,
      'XXX的小店', '已取消-已质检',
      '2025-11-12  09:30:00', '2025-11-12  10:30:00', '中国银行|61************5566', 2000, this.orderConfig,
      '已取消2'),
  ]
  // 订单页面状态列表项
  orderStatusList: Array<string> = ['全部', '待发货', '待处理', '已完成', '已取消']
  // 选中的tab下标
  @Trace selectedTabIndex: number = 0
  // 删除订单的对话框id
  @Trace deleteDialogId: number = 0
  // 取消订单的对话框id
  @Trace cancelDialogId: number = 0
  // 确认收款对话框id
  @Trace confirmDialogId: number = 0
}

/**
 * 订单类
 */
@ObservedV2
export class OrderItem {
  // 订单id
  @Trace id: number = 0
  // 订单商品名称
  @Trace name: string = ''
  // 订单商品图片
  @Trace image: ResourceStr = ''
  // 订单商品数量
  @Trace count: number = 0
  // 订单商品价格
  @Trace price: number = 0
  // 订单商品店铺
  @Trace shop: string = ''
  // 订单处理状态
  @Trace status: string = ''
  // 订单时间
  @Trace time: string = ''
  // 订单取消时间
  @Trace cancelTime: string = ''
  // 收款方式：xx银行|银行卡号
  @Trace payType: string = ''
  // 订单商品收回价格
  @Trace refundPrice: number = 0
  // 订单配置对象
  @Trace orderConfig: OrderMasterInfo =
    new OrderMasterInfo(0, '', '', 0, '', '', new OrderLocationInfo('', '', ''), new OrderProcessInfo(0, []),
      new OrderProcessInfo(0, []), new OrderProcessInfo(0, []), '', '')
  // 订单的备注
  @Trace remark: string = ''
  // 订单商品是否质检
  @Trace isQuality: boolean = false
  @Trace selections: string = ''

  constructor(id: number, name: string, image: ResourceStr, count: number, price: number, shop: string, status: string,
    time: string, cancelTime: string, payType: string, refundPrice: number, orderConfig: OrderMasterInfo,
    remark: string,
    isQuality: boolean = false) {
    this.id = id
    this.name = name
    this.image = image
    this.count = count
    this.price = price
    this.shop = shop
    this.status = status
    this.time = time
    this.cancelTime = cancelTime
    this.payType = payType
    this.refundPrice = refundPrice
    this.orderConfig = orderConfig
    this.remark = remark
    this.isQuality = isQuality
  }
}

/**
 * 订单配置类
 */
@ObservedV2
export class OrderMasterInfo {
  // 订单号
  @Trace orderId: number = 0
  // 订单师傅的名称
  @Trace masterName: string = ''
  // 订单师傅的头像
  @Trace masterAvatar: ResourceStr = ''
  // 订单师傅的等级
  @Trace masterLevel: number = 0
  // 订单师傅的评价
  @Trace masterComment: string = ''
  // 订单上门时间
  @Trace visitTime: string = ''
  // 订单上门地址
  @Trace visitAddress: OrderLocationInfo = new OrderLocationInfo('', '', '')
  // 订单流程对象
  @Trace orderProcess: OrderProcessInfo = new OrderProcessInfo(0, [])
  // 订单回退流程对象1
  @Trace orderProcessBack1: OrderProcessInfo = new OrderProcessInfo(0, [])
  // 订单回退流程对象2
  @Trace orderProcessBack2: OrderProcessInfo = new OrderProcessInfo(0, [])
  // 订单运单号
  @Trace expressNo: string = ''
  // 订单回退物流单号
  @Trace expressNoBack: string = ''

  constructor(orderId: number, masterName: string, masterAvatar: ResourceStr, masterLevel: number,
    masterComment: string, visitTime: string, visitAddress: OrderLocationInfo, orderProcess: OrderProcessInfo,
    orderProcessBack1: OrderProcessInfo, orderProcessBack2: OrderProcessInfo,
    expressNo: string, expressNoBack: string) {
    this.orderId = orderId
    this.masterName = masterName
    this.masterAvatar = masterAvatar
    this.masterLevel = masterLevel
    this.masterComment = masterComment
    this.visitTime = visitTime
    this.visitAddress = visitAddress
    this.orderProcess = orderProcess
    this.orderProcessBack1 = orderProcessBack1
    this.orderProcessBack2 = orderProcessBack2
    this.expressNo = expressNo
    this.expressNoBack = expressNoBack
  }
}

/**
 * 订单地质类
 */
@ObservedV2
export class OrderLocationInfo {
  // 订单地址
  @Trace address: string = ''
  // 订单电话
  @Trace phone: string = ''
  // 订单地址详情
  @Trace user: string = ''

  constructor(address: string, phone: string, user: string) {
    this.address = address
    this.phone = phone
    this.user = user
  }
}

/**
 * 订单流程类
 */
@ObservedV2
export class OrderProcessInfo {
  // 订单流程节点数组
  @Trace processList: Array<string> = ['提交订单', '邮寄寄出', '平台质检', '确认收款', '隐私清除']
  // 订单流程进度下标
  @Trace processIndex: number = 0
  // 订单流程时间轴数组
  @Trace processArray: OrderDetailBean[] = []

  constructor(processIndex: number, processArray: Array<OrderDetailBean>) {
    this.processIndex = processIndex
    this.processArray = processArray
  }

  // 设置订单流程进度下标
  setProcessIndex(processIndex: number) {
    this.processIndex = processIndex
  }

  // 获取订单流程节点文本
  getProcessText(): string {
    if (this.processIndex < 0 || this.processIndex >= this.processList.length) {
      return ''
    }
    return this.processList[this.processIndex]
  }
}

/**
 * 订单详情页参数类
 *
 */
@ObservedV2
export class MyOrderDetailPageInfo {
  // 订单对象
  @Trace orderInfo: OrderItem = new OrderItem(0, '', '', 0, 0, '', '', '', '', '', 0,
    new OrderMasterInfo(0, '', '', 0, '', '', new OrderLocationInfo('', '', ''), new OrderProcessInfo(0, []),
      new OrderProcessInfo(0, []), new OrderProcessInfo(0, []), '', ''), '')
  // 订单流程图类型
  @Trace orderProcessType: string = '上门取件'
  // 订单操作按钮
  @Trace orderButtonType: string = 'cancel'
  // 订单详情是否拓展
  @Trace isExpand: boolean = false
}
