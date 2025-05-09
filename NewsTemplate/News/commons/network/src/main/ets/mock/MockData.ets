import { AddCarReq, AddDnOrderReq, CommonReq, GoodReq, MyOrderReq } from '../models/RequestModel';
import {
  CarGoodInfo,
  CouponResp,
  DishesType,
  GetGoodSpecResp,
  GetHelpMsgResp,
  GetHmSystemResp,
  GetMyCarResp,
  GetMyOrderResp,
  GetStoreInfoResp,
  GetTableInfoResp,
  GetUserInfoResp,
  Good,
  GoodsOfOrder,
  GoodSpec,
  MyCouponResp,
  OrderModel,
  OrderTable,
  Reduction,
  StoreInfo,
  StoreSet,
  TableTitle,
} from '../models/ResponseModel';
import { Decimal } from '@kit.ArkTS';
import { DnState, GoodSpecEnum, OrderStateEnum } from '../constants/Common';

export class MockData {
  static specJson1 =
    `[{"specId":"1","specName":"奶油","specValId":"11","specVal":[{"specValId":"11","specValName":"动物奶油","specValLogo":"","specValNum":"1"},{"specValId":"12","specValName":"植物奶油","specValLogo":"","specValNum":"1"}]},{"specId":"2","specName":"糖类选择","specValId":"22","specVal":[{"specValId":"21","specValName":"蔗糖","specValLogo":"","specValNum":"1"},{"specValId":"22","specValName":"赤鲜糖醇（0糖）","specValLogo":"","specValNum":"1"}]},{"specId":"3","specName":"尺寸","specValId":"31","specVal":[{"specValId":"31","specValName":"6寸","specValLogo":"","specValNum":"1"},{"specValId":"32","specValName":"9寸","specValLogo":"","specValNum":"1"},{"specValId":"33","specValName":"12寸","specValLogo":"","specValNum":"1"}]}]`
  static specJson2 =
    `[{"specId":"1","specName":"招牌菜品  （必选）","specValId":"11","specVal":[{"specValId":"11","specValName":"黄金炙烤谷饲战斧牛排","specValLogo":"test-1pvkp/CateringOrderTemplate/good_spec_logo1.png","specValNum":"2"}]},{"specId":"2","specName":"特色配菜 3选 1","specValId":"23","specVal":[{"specValId":"21","specValName":"蔬菜沙拉","specValLogo":"test-1pvkp/CateringOrderTemplate/good_spec_logo2.png","specValNum":"1"},{"specValId":"22","specValName":"酸橘汁配虾仁和橙子双拼","specValLogo":"test-1pvkp/CateringOrderTemplate/good_spec_logo3.png","specValNum":"1"},{"specValId":"23","specValName":"豌豆炒虾仁","specValLogo":"test-1pvkp/CateringOrderTemplate/good_spec_logo4.png","specValNum":"1"}]},{"specId":"3","specName":"主食  2选 1","specValId":"32","specVal":[{"specValId":"31","specValName":"意大利面","specValLogo":"test-1pvkp/CateringOrderTemplate/good_spec_logo5.png","specValNum":"2"},{"specValId":"32","specValName":"披萨","specValLogo":"test-1pvkp/CateringOrderTemplate/good_spec_logo6.png","specValNum":"1"}]},{"specId":"4","specName":"甜品  4选 1","specValId":"43","specVal":[{"specValId":"41","specValName":"蜂蜜柚子茶","specValLogo":"test-1pvkp/CateringOrderTemplate/good_spec_logo7.png","specValNum":"1"},{"specValId":"42","specValName":"鲜榨果汁（口味备注，默认随机）...","specValLogo":"test-1pvkp/CateringOrderTemplate/good_spec_logo8.png","specValNum":"2"},{"specValId":"43","specValName":"冰橙美式咖啡","specValLogo":"test-1pvkp/CateringOrderTemplate/good_spec_logo9.png","specValNum":"2"},{"specValId":"44","specValName":"柠檬红茶","specValLogo":"test-1pvkp/CateringOrderTemplate/good_spec_logo10.png","specValNum":"1"}]}]`
  static goodMustJson =
    `{"id": "99","name": "纸巾","logo": "test-1pvkp/CateringOrderTemplate/good_logo_cutlery.png","bigImg": ["test-1pvkp/CateringOrderTemplate/good_logo_cutlery.png"],"money": "2","money2": "2","content": "纸巾","sales": "200","specType": "1","details": "餐具","num": "200","isMust": "1","spec": [],"boxMoney": "0"  }`
  static good1: Good = {
    id: '1',
    name: '圆形面包',
    logo: 'test-1pvkp/CateringOrderTemplate/good_logo1.png',
    bigImg: ['test-1pvkp/CateringOrderTemplate/good_logo1-1.png', 'test-1pvkp/CateringOrderTemplate/good_logo1-2.png',
      'test-1pvkp/CateringOrderTemplate/good_logo1-3.png'],
    money: '16.4',
    money2: '16.4',
    content: '圆形奶油面包',
    sales: '200',
    specType: '2',
    details: '圆形奶油面包',
    num: '200',
    isMust: '0',
    spec: [],
    boxMoney: '1',
  }
  static good2: Good = {
    id: '2',
    name: '冰橙美式咖啡',
    logo: 'test-1pvkp/CateringOrderTemplate/good_logo2.png',
    bigImg: ['test-1pvkp/CateringOrderTemplate/good_logo2.png'],
    money: '25',
    money2: '25',
    content: '冰橙美式咖啡',
    sales: '200',
    specType: '1',
    details: '冰橙美式咖啡',
    num: '200',
    isMust: '0',
    spec: [],
    boxMoney: '1',
  }
  static good3: Good = {
    id: '3',
    name: '四色马卡龙',
    logo: 'test-1pvkp/CateringOrderTemplate/good_logo2.png',
    bigImg: ['test-1pvkp/CateringOrderTemplate/good_logo2.png'],
    money: '58',
    money2: '58',
    content: '四色马卡龙',
    sales: '200',
    specType: '1',
    details: '四色马卡龙',
    num: '200',
    isMust: '0',
    spec: [],
    boxMoney: '1',
  }
  static good4: Good = {
    id: '4',
    name: '圆形面包',
    logo: 'test-1pvkp/CateringOrderTemplate/good_logo1.png',
    bigImg: ['test-1pvkp/CateringOrderTemplate/good_logo1.png'],
    money: '13',
    money2: '13',
    content: '圆形奶油面包',
    sales: '200',
    specType: '1',
    details: '圆形奶油面包',
    num: '200',
    isMust: '0',
    spec: [],
    boxMoney: '1',
  }
  static goodPkg1: Good = {
    id: '5',
    name: '初见欢双人餐',
    logo: 'test-1pvkp/CateringOrderTemplate/good_pkg_logo1.png',
    bigImg: ['test-1pvkp/CateringOrderTemplate/good_pkg_logo1.png'],
    money: '75.4',
    money2: '116.0',
    discount: '6.5',
    content: '周一至周日|免预约|随时退',
    sales: '200',
    specType: '3',
    details: '周一至周日|免预约|随时退',
    num: '200',
    isMust: '0',
    spec: [],
    boxMoney: '1',
  }
  static goodPkg2: Good = {
    id: '6',
    name: '招牌三文鱼寿司单人餐',
    logo: 'test-1pvkp/CateringOrderTemplate/good_pkg_logo2.png',
    bigImg: ['test-1pvkp/CateringOrderTemplate/good_pkg_logo2.png'],
    money: '59.9',
    money2: '92.2',
    discount: '6.5',
    content: '周一至周日|免预约|随时退',
    sales: '200',
    specType: '3',
    details: '周一至周日|免预约|随时退',
    num: '200',
    isMust: '0',
    spec: [],
    boxMoney: '1',
  }
  static goodPkg3: Good = {
    id: '7',
    name: '大吉大利，今晚吃鸡双人吃鸡套餐',
    logo: 'test-1pvkp/CateringOrderTemplate/good_pkg_logo3.png',
    bigImg: ['test-1pvkp/CateringOrderTemplate/good_pkg_logo3.png'],
    money: '59.9',
    money2: '92.2',
    discount: '6.5',
    content: '圆形奶油面包',
    sales: '200',
    specType: '3',
    details: '圆形奶油面包',
    num: '200',
    isMust: '0',
    spec: [],
    boxMoney: '1',
  }
  static couponsOri: Array<CouponResp> =
    [new CouponResp('1', '新人优惠券', ['此券仅供新品类产品使用', '本券仅限堂食就餐时使用，每桌限用一张'], '2024-12-01',
      '2124-12-01', '0', '1', '1', '100', '100', '2', 2),
      new CouponResp('2', '无门槛优惠券', ['此券仅供新品类产品使用', '本券仅限堂食就餐时使用，每桌限用一张'],
        '2024-12-01', '2124-12-01', '0', '1', '1', '100', '100', '2',
        2),
      new CouponResp('3', '满10减5', ['此券仅供新品类产品使用', '本券仅限堂食就餐时使用，每桌限用一张'], '2024-12-01',
        '2124-12-01', '10', '5', '1', '100', '100', '2', 2),
      new CouponResp('4', '满20减10', ['此券仅供新品类产品使用', '本券仅限堂食就餐时使用，每桌限用一张'], '2024-12-01',
        '2124-12-01', '20', '10', '1', '100', '100', '2',
        2),
      new CouponResp('5', '满50减30', ['此券仅供新品类产品使用', '本券仅限堂食就餐时使用，每桌限用一张'], '2024-12-01',
        '2024-12-01', '50', '30', '1', '100', '100', '2',
        2),
    ]

  static get getCouponsResp(): Array<CouponResp> {
    return this.couponsOri
  }

  static myCoupons: MyCouponResp[] = []
  static getLqCoupons = (params: CommonReq) => {
    let coupon = this.getCouponsResp.find(item => item.id === params.couponId)
    if (coupon) {
      coupon.state = 1
      let myCoupon: MyCouponResp = {
        id: this.myCoupons.length + 1 + '',
        couponId: coupon.id,
        state: '0',
        type: coupon.type,
        full: coupon.full,
        reduce: coupon.reduce,
        name: coupon.name,
        //店内、外卖和店内
        couponType: coupon.couponsType,
        endTime: coupon.endTime,
        desc: coupon.desc,
      }
      this.myCoupons.push(myCoupon)
      return 1
    } else {
      return 0
    }

  }

  static get getMyCoupons(): MyCouponResp[] {
    return this.myCoupons
  }

  static get getIsNew(): number {
    // 1 新用户 2老用户
    return 1
  }

  static get getGoodMust(): Good {
    return JSON.parse(this.goodMustJson)
  }

  static get getAllGoodList(): Array<Good> {
    return [this.getGoodMust, this.good1, this.good2, this.good3, this.good4, this.goodPkg1, this.goodPkg2,
      this.goodPkg3]
  }

  static get getHmSystemResp(): GetHmSystemResp {
    let result = new GetHmSystemResp(1, 'success', '26', 2)
    return result
  }

  static userInfo = new GetUserInfoResp(1, 'success', '1', '华为用户', '', '', '', '88', '200', '')

  static get getUserInfoResp(): GetUserInfoResp {
    return this.userInfo
  }

  static get getOpenLogin(): GetUserInfoResp {
    this.userInfo.userTel = '10000002222'
    this.userInfo.name = '华为用户'
    return this.userInfo
  }

  static get getCloseLogin(): GetUserInfoResp {
    this.userInfo.userTel = ''
    return this.userInfo
  }

  static get getStoreInfoResp(): GetStoreInfoResp {
    const storeInfo =
      new StoreInfo('id', '点餐', '南京市雨花台区华为路华为云楼', '09:00', '12:00', '13:00', '23:30', '10000001111',
        '周年店庆全场优惠促销，优惠力度空前，进店享受全场五折优惠！！！', 'test-1pvkp/CateringOrderTemplate/store_logo.png',
        '',
        '31.986317609142370,118.76031315908297',
        'test-1pvkp/CateringOrderTemplate/store_yyzz.png', 'test-1pvkp/CateringOrderTemplate/store_yyzz.png',
        ['test-1pvkp/CateringOrderTemplate/store_environment1.png',
          'test-1pvkp/CateringOrderTemplate/store_environment2.png',
          'test-1pvkp/CateringOrderTemplate/store_environment3.png'], '0')
    const storeSet = new StoreSet('1', '少糖；不要奶油奶沫；动物奶油；少糖；少糖；动物奶油；少糖；不要奶油奶沫；动物奶油')
    const reductionList: Reduction[] = [{
      id: '1',
      name: '满10减1',
      full: '10',
      reduction: '1',
      type: '0',
    }]
    let result = new GetStoreInfoResp(storeInfo, reductionList, storeSet)
    return result
  }

  static get getTableTitleResp(): Array<TableTitle> {
    let result = [new TableTitle('1', '1号桌', '1人桌', '1', '0'), new TableTitle('2', '2号桌', '2人桌', '2', '0'),
      new TableTitle('3', '3号桌', '3人桌', '3', '0'), new TableTitle('4', '4号桌', '4人桌', '4', '0'),
      new TableTitle('5', '5号桌', '5人桌', '5', '0'), new TableTitle('6', '6号桌', '6人桌', '6', '0'),
      new TableTitle('7', '7号桌', '7人桌', '7', '0'), new TableTitle('8', '8号桌', '8人桌', '8', '0'),
      new TableTitle('9', '9号桌', '9人桌', '9', '0'), new TableTitle('10', '10号桌', '10人桌', '10', '0')]
    return result
  }

  static getTableInfoResp = (params: CommonReq) => {
    let table = this.getTableTitleResp.find(item => item.id === params.id)
    if (table) {
      let result: GetTableInfoResp = {
        status: table.status,
        tableName: table.name,
        typeName: table.typeName,
      }
      return result
    }
    return null
  }

  static get getGoodSpec(): Array<GoodSpec> {
    let goodSpecList: GoodSpec[] = JSON.parse(MockData.specJson1) as GoodSpec[]
    return goodSpecList
  }

  static get getGoodList(): Array<Good> {
    const goodList: Array<Good> = [this.good1, this.good2, this.good3, this.good4]
    return goodList
  }

  static get getGoodPkgList(): Array<Good> {
    const goodList: Array<Good> = [this.goodPkg1, this.goodPkg2, this.goodPkg3]
    return goodList
  }

  static get getDishesList(): Array<Good> {
    const dishesList: Array<DishesType> =
      [new DishesType('1', '热销', this.getGoodList), new DishesType('2', '新品推荐', this.getGoodList),
        new DishesType('3', '美味套餐', this.getGoodPkgList), new DishesType('4', '甜点', this.getGoodList),
        new DishesType('5', '风味套餐集结号', this.getGoodPkgList),
        new DishesType('6', '必选菜品', [this.getGoodMust]),
        new DishesType('7', '菜单名称1', this.getGoodList), new DishesType('8', '菜单名称2', this.getGoodList),
        new DishesType('9', '菜单名称3', this.getGoodList), new DishesType('10', '菜单名称4', this.getGoodList),
        new DishesType('11', '菜单名称5', this.getGoodList), new DishesType('12', '菜单名称6', this.getGoodList)]
    return dishesList
  }

  static getGoodInfoResp = (params: CommonReq): Good | undefined => {
    let good = this.getAllGoodList.find(item => item.id === params.goodId)
    if (good?.specType === GoodSpecEnum.SPEC_TYPE) {
      let spec = JSON.parse(this.specJson1) as GoodSpec[]
      good.spec = spec
    } else if (good?.specType === GoodSpecEnum.PACKAGE_TYPE) {
      let spec = JSON.parse(this.specJson2) as GoodSpec[]
      good.spec = spec
    }
    return good
  }
  static myCar: GetMyCarResp = new GetMyCarResp(0, [], 0, 0)
  static myCarId: number = 0
  static cleanCar = () => {
    this.myCar.boxMoney = 0
    this.myCar.money = 0
    this.myCar.num = 0
    this.myCar.res = []
    return 1
  }

  static get getMyCar(): GetMyCarResp {
    if (!this.myCar) {
      this.myCar = new GetMyCarResp(0, [], 0, 0)
    }
    return this.myCar;
  }

  static addCar = (params: AddCarReq) => {
    let good = this.getAllGoodList.find(item => item.id === params.goodId)
    let carGoodTemp = this.myCar.res?.find(item => item.goodId === params.goodId && item.spec === params.spec)
    if (carGoodTemp) {
      carGoodTemp.num = new Decimal(carGoodTemp.num || 0).add(new Decimal(params.num!)).toString()
      this.myCar.money = new Decimal(this.myCar.money || 0).add(new Decimal(params.money!).mul(params.num!)).toNumber()
    } else {
      let carGood: CarGoodInfo = {
        id: `${this.myCarId}`,
        goodId: params.goodId,
        num: params.num,
        specType: params.specType,
        spec: params.spec,
        combination: params.combination,
        money: params.money,
        money2: good?.money2,
        discount: good?.discount,
        boxMoney: params.boxMoney,
        logo: good?.logo,
        name: good?.name,
        isMust: good?.isMust,
      }
      if (!this.myCar.res) {
        this.myCar.res = []
      }
      this.myCar.res?.push(carGood)
      let boxMoney = 0
      let money = 0
      this.myCar.res?.forEach(item => {
        boxMoney = new Decimal(boxMoney).add(item.boxMoney || 0).toNumber()
        money = new Decimal(money).add(new Decimal(item.money || 0).mul(item.num || 0)).toNumber()
      })
      this.myCar.num = this.myCar.res?.length
      this.myCar.boxMoney = boxMoney
      this.myCar.money = money
      this.myCarId++
    }

    return 1
  }
  static getUpdCar = (params: CommonReq) => {
    let carGood = this.myCar.res?.find(item => item.id === params.id)
    if (carGood) {
      let numOri: number = Number(carGood.num)
      // 购物车商品数量为0，返回失败
      if (numOri === 0) {
        return 0
      }
      let num = new Decimal(params.num).sub(numOri).toNumber()
      // 购物车商品数量为1，减少时需要移除商品
      if (numOri === 1 && num < 0) {
        this.myCar.res = this.myCar.res?.filter(item => item.id !== params.id)
      }
      carGood.num = params.num
      let boxMoney = 0
      let money = 0
      this.myCar.res?.forEach(item => {
        boxMoney = new Decimal(boxMoney).add(item.boxMoney || 0).toNumber()
        money = new Decimal(money).add(new Decimal(item.money || 0).mul(item.num || 0)).toNumber()
      })
      this.myCar.num = this.myCar.res?.length
      this.myCar.boxMoney = boxMoney
      this.myCar.money = money
      return 1
    } else {
      return 0
    }
  }
  static getGoodSpecInfo = (params: CommonReq): GetGoodSpecResp => {
    let good = this.getAllGoodList.find(item => item.id === params.goodId)
    let result: GetGoodSpecResp = {
      money: good?.money,
      spec: params.spec,
      combination: params.combination,
      goodId: params.goodId,
      specType: good?.specType,
      boxMoney: good?.boxMoney,
      isMust: good?.isMust,
    }
    return result
  }
  // 订单
  static orderList: Array<GetMyOrderResp> = []
  static orderId: number = 1
  static getMyOrder = (params: MyOrderReq): Array<GetMyOrderResp> => {
    let result = this.orderList.filter(item => String(params.dnState).indexOf(item.order?.dnState ?? '') >= 0)
    return result.sort((a: GetMyOrderResp, b: GetMyOrderResp) => new Decimal(a.order?.id || 0).sub(b.order?.id || 0)
      .toNumber() > 0 ? -1 : 1)
  };
  static getOrderInfo = (params: CommonReq) => {
    let order = this.orderList.find(item => item.order?.id === params.orderId)
    return order
  };
  static cancelOrder = (params: CommonReq) => {
    let order = this.orderList.find(item => item.order?.id === params.orderId)
    if (order?.order?.dnState) {
      if (Number(order?.order?.dnState) === OrderStateEnum.noFinished) {
        order.order.dnState = DnState.CANCELED
        return 1
      } else {
        return 2
      }
    } else {
      return 0
    }
  }
  static addOrder = (params: AddDnOrderReq) => {
    let date = new Date()
    let year = date.getFullYear()
    let month = `0${date.getMonth() + 1}`.slice(-2)
    let day = `0${date.getDate()}`.slice(-2)
    let hour = `0${date.getHours()}`.slice(-2)
    let minutes = `0${date.getMinutes()}`.slice(-2)
    let seconds = `0${date.getSeconds()}`.slice(-2)
    let orderModel: OrderModel = {
      id: this.orderId + '',
      orderNum: new Date().getTime() + '',
      time: `${year}-${month}-${day} ${hour}:${minutes}:${seconds}`,
      money: params.money.toString(),
      reductionMoney: params.reductionMoney,
      boxMoney: params.boxMoney.toString(),
      mjMoney: params.mjMoney,
      xyhMoney: params.xyhMoney,
      note: params.note,
      payType: params.payType.toString(),
      orderType: params.orderType.toString(),
      tableware: params.tableware.toString(),
      yhqMoney: params.yhqMoney,
      couponId: params.couponId,
      dnState: DnState.TO_BE_PAID,
      oid: `${80000 + this.orderId}`,
    }
    let sz: Array<GoodReq> = JSON.parse(params.sz)
    let goodList = sz.map(item => {
      let temp = this.getAllGoodList.find(i => i.id === item.id)
      let good: GoodsOfOrder = {
        id: item.id,
        logo: item.img,
        money: item.money,
        money2: temp?.money2 ?? '',
        discount: temp?.discount ?? '',
        name: item.name,
        num: item.num,
        isMust: temp?.isMust ?? '',
        specType: temp?.specType ?? '',
        spec: item.spec,
        combination: item.combination,
      }
      return good
    })
    let table = this.getTableTitleResp.find(item => item.id === params.tableId)
    let temp: OrderTable = {
      id: table?.id ?? '',
      name: table?.name ?? '',
      typeName: table?.typeName ?? '',
    }
    let order: GetMyOrderResp = {
      order: orderModel,
      num: goodList.length,
      good: goodList,
      table: temp,
    }
    this.orderList.push(order)
    this.orderId++
    this.myCar = new GetMyCarResp(0, [], 0, 0)
    return orderModel.id
  }
  static addGoods = (params: CommonReq): number => {
    let order = this.orderList.find(item => item.order?.id === params.orderId)
    if (order?.order?.dnState && Number(order?.order?.dnState) !== OrderStateEnum.noFinished) {
      return 2
    }
    this.deleteOrder(params)
    this.cleanCar()
    order?.good?.forEach(item => {
      let good = this.getAllGoodList.find(i => i.id === item.id)
      let carGood: CarGoodInfo = {
        id: `${this.myCarId}`,
        goodId: item.id,
        num: item.num,
        specType: item.specType,
        spec: item.spec,
        combination: item.combination,
        money: item.money,
        money2: item.money2,
        discount: item.discount,
        boxMoney: good?.boxMoney,
        logo: item.logo,
        name: item.name,
        isMust: item.isMust,
      }
      if (!this.myCar.res) {
        this.myCar.res = []
      }
      this.myCar.res?.push(carGood)
      this.myCarId++
    })
    let boxMoney = 0
    let money = 0
    this.myCar.res?.forEach(item => {
      boxMoney = new Decimal(boxMoney).add(item.boxMoney || 0).toNumber()
      money = new Decimal(money).add(new Decimal(item.money || 0).mul(item.num || 0)).toNumber()
    })
    this.myCar.num = this.myCar.res?.length
    this.myCar.money = money
    this.myCar.boxMoney = boxMoney
    return 1;
  }
  static deleteOrder = (params: CommonReq): number => {
    this.orderList = this.orderList.filter(item => item.order?.id !== params.orderId)
    return 1;
  }
  static getHuaweiPayInfo = (params: CommonReq) => {
    let order = this.orderList.find(item => item.order?.id === params.orderId)
    if (order?.order?.dnState) {
      if (Number(order?.order?.dnState) === OrderStateEnum.noFinished) {
        order.order.dnState = DnState.COMPLETED
        return 1
      } else {
        return 2
      }
    } else {
      return 0
    }
  }
  static getHelp = (): Array<GetHelpMsgResp> => {
    const helpJson: string =
      '[{"id": "1","question": "我们如何收集和使用您的个人信息","answer": "欢迎您使用我们的餐饮模板，您的信任对我们很重要，我们将严格遵守法律法规要求的安全保护措施，保护您的个人信息安全可控。"}]'
    return JSON.parse(helpJson);
  }
}
