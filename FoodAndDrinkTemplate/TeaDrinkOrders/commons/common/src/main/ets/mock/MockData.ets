import { AddCarReq, AddDnOrderReq, AddressReq, CommonReq, GoodReq, MyOrderReq } from '../models/RequestModel';
import {
  AddressInfo,
  BaseResponse,
  CarGoodInfo,
  CouponResp,
  DishesType,
  Good,
  GoodsOfOrder,
  GoodSpec,
  GoodSpecInfo,
  HmSystem,
  MyCar,
  MyCoupon as MyCoupon,
  MyOrderInfo,
  OrderModel,
  Reduction,
  StoreInfo,
  UserInfo,
} from '../models/ResponseModel';
import { Decimal } from '@kit.ArkTS';
import { map } from '@kit.MapKit';
import { CouponStateEnum, GoodSpecEnum, OrderListTypeEnum, OrderStateEnum, OrderTypeEnum } from '../constants/Common';
import { getFullDate } from '../utils/Utils';

export class MockData {
  static timer: number = 0
  static resultSuccess: BaseResponse = new BaseResponse(0, 'success', undefined)
  static resultFailed: BaseResponse = new BaseResponse(1, 'failed', undefined)
  static specJson1 =
    `[{"specId":"1","specName":"奶油","specValId":"11","specVal":[{"specValId":"11","specValName":"动物奶油","specValLogo":"","specValNum":"1"},{"specValId":"12","specValName":"植物奶油","specValLogo":"","specValNum":"1"}]},{"specId":"2","specName":"糖类选择","specValId":"22","specVal":[{"specValId":"21","specValName":"蔗糖","specValLogo":"","specValNum":"1"},{"specValId":"22","specValName":"赤鲜糖醇（0糖）","specValLogo":"","specValNum":"1"}]},{"specId":"3","specName":"尺寸","specValId":"31","specVal":[{"specValId":"31","specValName":"6寸","specValLogo":"","specValNum":"1"},{"specValId":"32","specValName":"9寸","specValLogo":"","specValNum":"1"},{"specValId":"33","specValName":"12寸","specValLogo":"","specValNum":"1"}]}]`
  static specJson2 =
    `[{"specId":"1","specName":"A（选择1个）","specVal":[{"specValId":"11","id":"1","name":"甜橙咖啡","logo":"TeaDrinkOrders/good_logo1.png"},{"specValId":"12","id":"2","name":"甜橙美式咖啡","logo":"TeaDrinkOrders/good_logo1.png"},{"specValId":"13","id":"3","name":"柠檬咖啡","logo":"TeaDrinkOrders/good_logo2.png"}]},{"specId":"2","specName":"B（选择1个）","specValId":"23","specVal":[{"specValId":"21","id":"4","name":"奶昔美式","logo":"TeaDrinkOrders/good_logo3.png"}]}]`
  static good1: Good = {
    id: '1',
    name: '甜橙美式咖啡',
    logo: 'TeaDrinkOrders/good_logo1.png',
    bigImg: ['TeaDrinkOrders/good_big1.png', 'TeaDrinkOrders/good_big1.png',
      'TeaDrinkOrders/good_big1.png'],
    money: '16.4',
    content: '甜橙美式咖啡',
    sales: '200',
    specType: '2',
    details: `<image src='https://agc-storage-drcn.platform.dbankcloud.cn/v0/test-1pvkp/TeaDrinkOrders/good_big1.png' style='width: 100%;height: auto;'></image>`,
    num: 200,
    spec: [],
    boxMoney: '1',
  }
  static good2: Good = {
    id: '2',
    name: '柠檬咖啡',
    logo: 'TeaDrinkOrders/good_logo2.png',
    bigImg: ['TeaDrinkOrders/good_logo2.png'],
    money: '25',
    content: '柠檬咖啡',
    sales: '200',
    specType: '2',
    details: '柠檬咖啡',
    num: 200,
    spec: [],
    boxMoney: '1',
  }
  static good3: Good = {
    id: '3',
    name: '奶昔美式',
    logo: 'TeaDrinkOrders/good_logo3.png',
    bigImg: ['TeaDrinkOrders/good_logo3.png'],
    money: '58',
    content: '奶昔美式',
    sales: '200',
    specType: '2',
    details: '奶昔美式',
    num: 200,
    spec: [],
    boxMoney: '1',
  }
  static good4: Good = {
    id: '4',
    name: '草莓抹茶奶冻',
    logo: 'TeaDrinkOrders/good_logo4.png',
    bigImg: ['TeaDrinkOrders/good_logo4.png'],
    money: '13',
    content: '草莓抹茶奶冻',
    sales: '200',
    specType: '2',
    details: '草莓抹茶奶冻',
    num: 200,
    spec: [],
    boxMoney: '1',
  }
  static goodPkg1: Good = {
    id: '5',
    name: '水果美式套餐',
    logo: 'TeaDrinkOrders/good_pkg_logo.png',
    bigImg: ['TeaDrinkOrders/good_pkg_logo.png'],
    money: '75.4',
    content: '周一至周日|免预约|随时退',
    sales: '200',
    specType: '3',
    details: '周一至周日|免预约|随时退',
    num: 200,
    spec: [],
    boxMoney: '1',
  }
  static goodPkg2: Good = {
    id: '6',
    name: '招牌美式套餐',
    logo: 'TeaDrinkOrders/good_pkg_logo.png',
    bigImg: ['TeaDrinkOrders/good_pkg_logo.png'],
    money: '59.9',
    content: '周一至周日|免预约|随时退',
    sales: '200',
    specType: '3',
    details: '周一至周日|免预约|随时退',
    num: 200,
    spec: [],
    boxMoney: '1',
  }
  static goodPkg3: Good = {
    id: '7',
    name: '大吉大利，今晚吃鸡双人吃鸡套餐',
    logo: 'TeaDrinkOrders/good_pkg_logo.png',
    bigImg: ['TeaDrinkOrders/good_pkg_logo.png'],
    money: '59.9',
    content: '大吉大利，今晚吃鸡双人吃鸡套餐',
    sales: '200',
    specType: '3',
    details: '大吉大利，今晚吃鸡双人吃鸡套餐',
    num: 200,
    spec: [],
    boxMoney: '1',
  }
  static couponsOri: Array<CouponResp> =
    [new CouponResp('1', '新人优惠券', ['此券仅供新品类产品使用', '本券仅限堂食就餐时使用，每桌限用一张'], '2024-12-01',
      '2124-12-01', '0', '1', 100, '100', 0),
      new CouponResp('2', '无门槛优惠券', ['适用所有商品', '本券仅限堂食就餐时使用，每桌限用一张'], '2024-12-01',
        '2124-12-01', '0', '1', 100, '100', 0),
      new CouponResp('3', '满10减5', ['适用所有商品', '本券仅限堂食就餐时使用，每桌限用一张'], '2024-12-01',
        '2124-12-01', '10', '5', 100, '100', 0),
      new CouponResp('4', '满20减10', ['适用所有商品', '本券仅限堂食就餐时使用，每桌限用一张'], '2024-12-01',
        '2124-12-01', '20', '10', 100, '100', 0),
      new CouponResp('5', '满50减30', ['适用所有商品', '本券仅限堂食就餐时使用，每桌限用一张'], '2024-12-01',
        '2024-12-01', '50', '30', 100, '100', 0),
      new CouponResp('6', '满50减30', ['适用所有商品', '本券仅限堂食就餐时使用，每桌限用一张'], '2024-12-01',
        '2024-12-01', '50', '30', 100, '100', 0),
    ]
  static getBannerList: Array<string> = [];

  static get getCouponsResp(): Array<CouponResp> {
    return this.couponsOri
  }

  static myCoupons: MyCoupon[] = []
  static getLqCoupons = (params: CommonReq) => {
    let coupon = this.getCouponsResp.find(item => item.id === params.couponId)
    if (coupon) {
      coupon.state = 1
      let myCoupon: MyCoupon = new MyCoupon()
      myCoupon.id = this.myCoupons.length + 1 + '';
      myCoupon.couponId = coupon.id;
      myCoupon.state = 1;
      myCoupon.full = coupon.full;
      myCoupon.reduce = coupon.reduce;
      myCoupon.name = coupon.name;
      myCoupon.startTime = coupon.startTime;
      myCoupon.endTime = coupon.endTime;
      myCoupon.desc = coupon.desc;
      this.myCoupons.push(myCoupon)
      return this.resultSuccess
    } else {
      return this.resultFailed
    }
  }

  static get getMyCoupons(): BaseResponse<MyCoupon[]> {
    if (!this.myCoupons.length) {
      let coupon = new MyCoupon()
      coupon.id = '99';
      coupon.couponId = '99';
      coupon.state = 1;
      coupon.full = '50';
      coupon.reduce = '30';
      coupon.name = '满50减30';
      coupon.startTime = '2024-11-01';
      coupon.endTime = '2024-12-01';
      coupon.desc = ['适用所有商品', '本券仅限堂食就餐时使用，每桌限用一张'];
      this.myCoupons.push(coupon)
      coupon = new MyCoupon()
      coupon.id = '98';
      coupon.couponId = '98';
      coupon.state = 2;
      coupon.full = '100';
      coupon.reduce = '50';
      coupon.name = '满100减50';
      coupon.startTime = '2024-11-01';
      coupon.endTime = '2034-12-01';
      coupon.desc = ['适用所有商品', '本券仅限堂食就餐时使用，每桌限用一张'];
      this.myCoupons.push(coupon)
    }
    return new BaseResponse(0, 'success', this.myCoupons)
  }

  static get getAllGoodList(): Array<Good> {
    return [this.good1, this.good2, this.good3, this.good4, this.goodPkg1, this.goodPkg2, this.goodPkg3]
  }

  static get getHmSystemResp(): BaseResponse<HmSystem> {
    let result = new BaseResponse(0, 'success', new HmSystem('10000000000'))
    return result
  }

  static userInfo: UserInfo

  static get getUserInfo(): UserInfo {
    if (!this.userInfo) {
      this.userInfo = new UserInfo()
      this.userInfo.id = '1'
      this.userInfo.name = '华为用户'
      this.userInfo.sex = 0
      this.userInfo.totalScore = '1074'
      this.userInfo.sixProcess = 2
      this.userInfo.level = 1
    }
    return this.userInfo
  }

  static modifyUserInfo = (params: CommonReq): BaseResponse<UserInfo> => {
    this.userInfo.name = params.name
    this.userInfo.sex = params.sex
    return new BaseResponse(0, 'success', this.getUserInfo)
  }

  static get getUserInfoResp(): BaseResponse<UserInfo> {
    return new BaseResponse(0, 'success', this.getUserInfo)
  }

  static get getOpenLogin(): BaseResponse<UserInfo> {
    this.userInfo.userTel = '10000000001'
    return new BaseResponse(0, 'success', this.userInfo)
  }

  static get getCloseLogin(): UserInfo {
    this.userInfo.userTel = ''
    return this.userInfo
  }

  static get getStoreList(): BaseResponse<Array<StoreInfo>> {
    let storeList: Array<StoreInfo> = []
    let store1 = new StoreInfo()
    store1.id = '1'
    store1.name = '店铺名称（宜悦城）'
    store1.address = '南京市雨花台区华为路华为云楼'
    store1.time1 = '00:00'
    store1.time2 = '21:30'
    store1.tel = '10000000002'
    store1.logo = 'TeaDrinkOrders/store_logo.png'
    store1.coordinates = '31.97919489020034,118.76224773565536'
    storeList.push(store1)
    let store2 = new StoreInfo()
    store2.id = '2'
    store2.name = '店铺名称（雨花客厅店）'
    store2.address = '南京市雨花台区华为路华为云楼'
    store2.time1 = '09:00'
    store2.time2 = '22:30'
    store2.tel = '10000000003'
    store2.logo = 'TeaDrinkOrders/store_logo.png'
    store2.coordinates = '31.97831,118.76362'
    store2.makingNum = 1
    storeList.push(store2)
    let store3 = new StoreInfo()
    store3.id = '3'
    store3.name = '店铺名称（楚翘城）'
    store3.address = '南京市雨花台区华为路华为云楼'
    store3.time1 = '09:00'
    store3.time2 = '23:59'
    store3.tel = '10000000004'
    store3.logo = 'TeaDrinkOrders/store_logo.png'
    store3.coordinates = '31.97052568354233,118.76447685976373'
    store3.makingNum = 10
    storeList.push(store3)
    return new BaseResponse(0, 'success', storeList);
  }

  static getStoreInfoResp = (params?: CommonReq): StoreInfo => {
    const reductionList: Reduction[] =
      [new Reduction('1', '周年店庆全场优惠促销，优惠力度空前，进店享受下单立减5元！！！', '0', '5', 0),
        new Reduction('2', '新用户加入会员，下单立减5元', '10', '5', 1),
        new Reduction('3', '新用户加入会员，下单立减5元', '10', '5', 0),
        new Reduction('4', '新用户加入会员，下单立减5元', '10', '5', 0),
        new Reduction('5', '新用户加入会员，下单立减5元', '10', '5', 0),
      ]
    let storeId = '1'
    if (params) {
      storeId = params.storeId
    }
    let store = this.getStoreList.data.find(item => item.id === storeId)!
    const storeInfo: StoreInfo = new StoreInfo()
    storeInfo.id = store.id
    storeInfo.name = store.name
    storeInfo.address = store.address
    storeInfo.time1 = store.time1
    storeInfo.time2 = store.time2
    storeInfo.tel = store.tel
    storeInfo.announcement = '周年店庆全场优惠促销，优惠力度空前，进店享受下单立减5元！！！'
    storeInfo.logo = store.logo
    storeInfo.coordinates = store.coordinates
    storeInfo.dpyyzz = 'TeaDrinkOrders/store_yyzz.png'
    storeInfo.spjyxkz = 'TeaDrinkOrders/store_yyzz.png'
    storeInfo.environment = [
      'TeaDrinkOrders/store_environment1.png',
      'TeaDrinkOrders/store_environment2.png',
      'TeaDrinkOrders/store_environment3.png',
    ]
    storeInfo.taste =
      ['少糖', '不要奶油奶沫', '动物奶油', '少糖', '少糖', '动物奶油', '少糖', '不要奶油奶沫', '动物奶油']
    storeInfo.reduction = reductionList
    storeInfo.bagMoney = 4
    storeInfo.makingNum = 2
    storeInfo.makingWaitTime = 2

    return storeInfo
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

  static get getDishesList(): Array<DishesType> {
    const dishesList: Array<DishesType> =
      [
        new DishesType('1', '热销', this.getGoodList), new DishesType('2', '新品推荐', this.getGoodList),
        new DishesType('3', '经典套餐', this.getGoodPkgList), new DishesType('4', '风味套餐集结号', this.getGoodList),
        new DishesType('5', '精品奶茶', this.getGoodList), new DishesType('6', '酸奶罐罐', this.getGoodList),
        new DishesType('7', '饮品名称1', this.getGoodList), new DishesType('8', '饮品名称2', this.getGoodList),
        new DishesType('9', '饮品名称3', this.getGoodList), new DishesType('10', '饮品名称4', this.getGoodList),
        new DishesType('11', '饮品名称5', this.getGoodList), new DishesType('12', '饮品名称6', this.getGoodList),
      ]
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
  static myCar: MyCar = new MyCar(0, [], 0, 0)
  static myCarId: number = 0
  static cleanCar = () => {
    this.myCar.boxMoney = 0
    this.myCar.money = 0
    this.myCar.num = 0
    this.myCar.carGoods = []
    return 1
  }

  static get getMyCar(): MyCar {
    if (!this.myCar) {
      this.myCar = new MyCar(0, [], 0, 0)
    }
    return this.myCar;
  }

  static addCar = (params: AddCarReq) => {
    let good = this.getAllGoodList.find(item => item.id === params.goodId)
    if (!good) {
      return this.resultFailed
    }
    let carGoodTemp = this.myCar.carGoods?.find(item => item.goodId === params.goodId && item.spec === params.spec)
    let carGoodId = `${this.myCarId}`
    if (carGoodTemp) {
      carGoodId = carGoodTemp.id
      carGoodTemp.num = new Decimal(carGoodTemp.num || 0).add(new Decimal(params.num)).toNumber()
      let money = 0
      this.myCar.carGoods.forEach(item => {
        money = new Decimal(money).add(new Decimal(item.money || 0).mul(item.num || 0)).toNumber()
      })
      this.myCar.money = money
    } else {
      let carGood: CarGoodInfo = new CarGoodInfo()
      carGood.id = `${this.myCarId}`
      carGood.goodId = params.goodId
      carGood.num = params.num
      carGood.specType = params.specType
      carGood.spec = params.spec
      carGood.combination = params.combination
      carGood.money = params.money
      carGood.boxMoney = params.boxMoney
      carGood.logo = good?.logo
      carGood.name = good?.name
      if (!this.myCar.carGoods) {
        this.myCar.carGoods = []
      }
      this.myCar.carGoods?.push(carGood)
      // 更新购物车
      let boxMoney = 0
      let money = 0
      this.myCar.carGoods.forEach(item => {
        boxMoney = new Decimal(boxMoney).add(item.boxMoney || 0).toNumber()
        money = new Decimal(money).add(new Decimal(item.money || 0).mul(item.num || 0)).toNumber()
      })
      this.myCar.num = this.myCar.carGoods.length
      this.myCar.boxMoney = boxMoney
      this.myCar.money = money
      this.myCarId++
    }
    return new BaseResponse(0, 'success', carGoodId)
  }
  static getUpdCar = (params: CommonReq) => {
    let carGood = this.myCar.carGoods?.find(item => item.id === params.id)
    if (carGood) {
      let numOri: number = Number(carGood.num)
      // 购物车商品数量为0，返回失败
      if (numOri === 0) {
        return 0
      }
      let num = new Decimal(params.num).sub(numOri).toNumber()
      // 购物车商品数量为1，减少时需要移除商品
      if (numOri === 1 && num < 0) {
        this.myCar.carGoods = this.myCar.carGoods.filter(item => item.id !== params.id)
      }
      carGood.num = params.num
      let boxMoney = 0
      let money = 0
      this.myCar.carGoods.forEach(item => {
        boxMoney = new Decimal(boxMoney).add(item.boxMoney || 0).toNumber()
        money = new Decimal(money).add(new Decimal(item.money || 0).mul(item.num || 0)).toNumber()
      })
      this.myCar.num = this.myCar.carGoods.length
      this.myCar.boxMoney = boxMoney
      this.myCar.money = money
      return 1
    } else {
      return 0
    }
  }
  static getGoodSpecInfo = (params: CommonReq): BaseResponse<GoodSpecInfo | undefined> => {
    let good = this.getAllGoodList.find(item => item.id === params.goodId)
    if (good) {
      let money = '0'
      if (params.spec.indexOf('12寸') >= 0) {
        money = new Decimal(good.money).mul(2).toFixed(1).toString()
      } else if (params.spec.indexOf('9寸') >= 0) {
        money = new Decimal(good.money).mul(1.5).toFixed(1).toString()
      } else {
        money = good.money
      }
      let result: GoodSpecInfo = new GoodSpecInfo()
      result.money = money
      result.spec = params.spec
      result.combination = params.combination
      result.goodId = params.goodId
      result.goodName = good.name || ''
      result.goodLogo = good.logo || ''
      result.specType = good.specType
      result.boxMoney = good.boxMoney
      return new BaseResponse(0, 'success', result)
    }
    return this.resultFailed

  }
  static initOrderList = (): MyOrderInfo => {
    let orderModel: OrderModel = new OrderModel()
    orderModel.id = '1';
    orderModel.orderNum = new Date().getTime().toString();
    orderModel.time = getFullDate(new Date('2025-02-01 10:33:33'))
    orderModel.money = 100;
    orderModel.boxMoney = 0;
    orderModel.bagMoney = 0;
    orderModel.mjMoney = '5';
    orderModel.note = '';
    orderModel.payType = 1;
    orderModel.orderType = 0;
    orderModel.cutlery = '1';
    orderModel.yhqMoney = '5';
    orderModel.couponId = '1';
    orderModel.state = OrderStateEnum.COMPLETED;
    orderModel.oid = `80001`;
    orderModel.storeName = 'AGC奶茶(雨花客厅店)';
    orderModel.address = '南京市雨花台区华为路华为云楼';
    orderModel.tel = '10000000003';
    orderModel.coordinates = '31.97831,118.76362';

    let good: GoodsOfOrder = new GoodsOfOrder()
    good.id = this.good1.id || '';
    good.logo = this.good1.logo || '';
    good.money = this.good1.money || '';
    good.name = this.good1.name || '';
    good.num = 1;
    good.specType = '1';
    good.spec = '';
    good.combination = [];
    let goodList = [good]
    let order: MyOrderInfo = new MyOrderInfo()
    order.order = orderModel;
    order.num = goodList.length;
    order.good = goodList;
    return order
  }
  // 订单
  static orderList: Array<MyOrderInfo> = [this.initOrderList()]
  static orderId: number = 2
  static getMyOrder = (params: MyOrderReq): Array<MyOrderInfo> => {
    let result =
      this.orderList.filter(item => new Date(item.order?.time || '').getTime() < new Date(params.queryDay).getTime())
    if (params.orderListType === OrderListTypeEnum.TODAY_LIST) {
      result = this.orderList.filter(item => item.order?.time?.startsWith(params.queryDay))
    }
    return result.sort((a: MyOrderInfo, b: MyOrderInfo) => new Decimal(a.order?.id || 0).sub(b.order?.id ?? 0)
      .toNumber() > 0 ? -1 : 1)
  };
  static getOrderInfo = (params: CommonReq) => {
    let order = this.orderList.find(item => item.order?.id === params.orderId)
    return order
  };
  static cancelOrder = (params: CommonReq) => {
    let order = this.orderList.find(item => item.order?.id === params.orderId)
    if (order?.order?.state === OrderStateEnum.TO_BE_PAID) {
      order.order.state = OrderStateEnum.CANCELED
      // 还原优惠券
      let coupon = this.myCoupons.find(item => item.id === order?.order.couponId)
      if (coupon) {
        coupon.state = CouponStateEnum.USABLE
      }
      return this.resultSuccess
    } else {
      return this.resultFailed
    }
  }
  static addOrder = (params: AddDnOrderReq) => {
    let orderModel: OrderModel = new OrderModel()
    orderModel.id = this.orderId + '';
    orderModel.orderNum = new Date().getTime().toString();
    orderModel.time = getFullDate(new Date())
    orderModel.money = params.money;
    orderModel.boxMoney = params.boxMoney;
    orderModel.bagMoney = params.bagMoney;
    orderModel.mjMoney = params.mjMoney;
    orderModel.xyhMoney = params.xyhMoney;
    orderModel.note = params.note;
    orderModel.payType = params.payType;
    orderModel.orderType = params.orderType;
    orderModel.cutlery = params.cutlery;
    orderModel.yhqMoney = params.yhqMoney;
    orderModel.couponId = params.couponId;
    orderModel.state = OrderStateEnum.TO_BE_PAID;
    orderModel.oid = `${80000 + this.orderId}`;
    orderModel.storeName = params.storeName;
    orderModel.address = params.address;
    orderModel.tel = params.tel;
    orderModel.coordinates = params.coordinates;
    let sz: Array<GoodReq> = JSON.parse(params.sz)
    let goodList = sz.map(item => {
      let temp = this.getAllGoodList.find(i => i.id === item.goodId)
      let good: GoodsOfOrder = new GoodsOfOrder()
      good.id = item.goodId;
      good.logo = item.img;
      good.money = item.money;
      good.name = item.name;
      good.num = item.num;
      good.specType = temp?.specType ?? '';
      good.spec = item.spec;
      good.combination = item.combination;
      return good
    })
    let order: MyOrderInfo = new MyOrderInfo()
    order.order = orderModel;
    order.num = goodList.length;
    order.good = goodList;
    if (params.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY) {
      order.address.addressPre = params.addressPre
      order.address.addressNum = params.addressNum
      order.address.latitude = params.latitude
      order.address.longitude = params.longitude
      order.address.name = params.addressName
      order.address.tel = params.addressTel
    }
    this.orderList.push(order)
    this.orderId++
    // 更新购物车
    let boxMoney = 0
    let money = 0
    this.myCar.carGoods = this.myCar.carGoods?.filter(item => sz.every(good => good.id !== item.id)) ?? []
    this.myCar.carGoods.forEach(item => {
      boxMoney = new Decimal(boxMoney).add(item.boxMoney || 0).toNumber()
      money = new Decimal(money).add(new Decimal(item.money || 0).mul(item.num || 0)).toNumber()
    })
    this.myCar.num = this.myCar.carGoods.length
    this.myCar.boxMoney = boxMoney
    this.myCar.money = money
    // 核销优惠券
    let coupon = this.myCoupons.find(item => item.id === params.couponId)
    if (coupon) {
      coupon.state = CouponStateEnum.USED
    }
    return orderModel.id
  }
  static deleteOrder = (params: CommonReq): BaseResponse => {
    let order = this.orderList.find(item => item.order?.id === params.orderId);
    if (order) {
      this.orderList = this.orderList.filter(item => item.order?.id !== params.orderId)
      return this.resultSuccess
    }
    return this.resultFailed
  }
  static getHuaweiPayInfo = (params: CommonReq) => {
    let order = this.orderList.find(item => item.order?.id === params.orderId)
    if (order?.order?.state === OrderStateEnum.TO_BE_PAID) {
      order.order.state = OrderStateEnum.MAKING
      order.order.payTime = new Date().getTime()
      if (Number(order.order.orderType) === OrderTypeEnum.PICK_SELF) {
        MockData.startFinishTimer(params.orderId)
      } else {
        MockData.startDeliveringTimer(params.orderId)
        order.delivery.latitude = 31.984119763914883
        order.delivery.longitude = 118.76458756248296
        order.delivery.distance = map.calculateDistance(order.delivery, order.address)
        let date = new Date()
        let hours1 = `0${date.getHours()}`.slice(-2)
        let minutes1 = `0${date.getMinutes()}`.slice(-2)
        date.setMinutes(date.getMinutes() + 5)
        let hours2 = `0${date.getHours()}`.slice(-2)
        let minutes2 = `0${date.getMinutes()}`.slice(-2)
        order.delivery.estimatedTime = `${hours1}:${minutes1}-${hours2}:${minutes2}`
        order.delivery.remainingTime = 10
      }
      return this.resultSuccess
    } else {
      return this.resultFailed
    }
  }
  private static changeOrderState = (orderId: string, state: number) => {
    let order = this.orderList.find(item => item.order?.id === orderId)
    if (order?.order?.state && order?.order?.state < Number(state)) {
      order.order.state = state
      return this.resultSuccess
    } else {
      return this.resultFailed
    }
  }
  static addressList: Array<AddressInfo> = []
  static initAddress: boolean = false

  static get getUserAddressList(): BaseResponse<Array<AddressInfo>> {
    if (!this.initAddress) {
      this.initAddress = true
      for (let i = 1; i < 4; i++) {
        let address = new AddressInfo()
        address.id = i
        address.addressPre = '雨花客厅'
        address.addressNum = 'D1栋xx单元xxxx'
        address.name = '索先生'
        address.sex = true
        address.tel = '10000000005'
        address.tag = i % 3
        address.latitude = 31.9789782
        address.longitude = 118.7641445
        this.addressList.push(address)
      }
    }
    return new BaseResponse(0, 'success', this.addressList);
  }

  static getUserAddress = (params: AddressReq): BaseResponse<AddressInfo | undefined> => {
    let address = this.addressList.find(item => item.id === params.id)
    if (address) {
      return new BaseResponse(0, 'success', address);
    }
    return this.resultFailed
  }
  static modifyUserAddress = (params: AddressReq): BaseResponse => {
    if (!params.id) {
      let address = new AddressInfo()
      address.id = this.addressList.length + 1
      address.addressPre = params.addressPre
      address.addressNum = params.addressNum
      address.name = params.name
      address.sex = params.sex
      address.tel = params.tel
      address.tag = params.tag
      address.latitude = params.latitude
      address.longitude = params.longitude
      this.addressList.push(address)
      return this.resultSuccess
    } else {
      let address = this.addressList.find(item => item.id === params.id)
      if (address) {
        address.addressPre = params.addressPre
        address.addressNum = params.addressNum
        address.name = params.name
        address.sex = params.sex
        address.tel = params.tel
        address.tag = params.tag
        address.latitude = params.latitude
        address.longitude = params.longitude
        return this.resultSuccess
      } else {
        return this.resultFailed
      }
    }
  }
  static deleteUserAddress = (params: AddressReq): BaseResponse => {
    let address = this.addressList.some(item => item.id === params.id);
    if (address) {
      this.addressList = this.addressList.filter(item => item.id !== params.id);
      return this.resultSuccess
    } else {
      return this.resultFailed
    }
  }
  static get getPrivacyInfo(): BaseResponse<string> {
    let json:string = `<h2 class="text-2xl font-bold mb-5">茶饮 元服务 隐私声明</h1>
    <p>茶饮模板是用于茶饮的元服务模板。本隐私声明由我们为处理您的个人信息而制定。</p>
    <p>我们非常重视您的个人信息和隐私保护，将会按照法律要求和业界成熟的安全标准，为您的个人信息提供相应的安全保护措施。</p>

    <h3 class="text-xl font-bold mt-8 mb-3">1. 我们如何收集和使用您的个人信息</h2>
    <p>我们仅在有合法性基础的情形下才会使用您的个人信息。根据适用的法律，我们可能会基于您的同意、为履行/订立您与我们的合同所必需、履行法定义务所必需等合法性基础，使用您的个人信息。</p>

    <h4 class="text-lg font-bold mt-6 mb-2">1.1 我们提供下列服务时会处理必要的个人信息。</h3>
    <p>为了实现应用功能，在获取您的同意后我们需要收集您的精确位置信息、大致位置信息、用户标识符、账号信息、图片。</p>

    <h3 class="text-xl font-bold mt-8 mb-3">2. 设备权限调用</h2>
    <p>位置 （获取设备位置信息、获取设备模糊位置信息）</p>`
    return new BaseResponse(0,'success',json)
  }

  private static startFinishTimer(orderId: string) {
    setTimeout(() => {
      MockData.changeOrderState(orderId, OrderStateEnum.COMPLETED)
    }, 300000)
  }

  private static startDeliveringTimer(orderId: string) {
    setTimeout(() => {
      MockData.changeOrderState(orderId, OrderStateEnum.DELIVERING)
      MockData.startFinishTimer(orderId)
    }, 10000)
  }
}
