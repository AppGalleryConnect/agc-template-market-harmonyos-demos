import { OrderInfo, OrderCardDto, LogisticsItemDto, OrderSkuDto } from '@common/customtypes';

export class MockDatabase {
  public static readonly PRODUCT_TABLE: ProductData[] = [
    {
      skuCode: 'sku_100001',
      productId: 'product_10001',
      skuDesc: '粉色;160/80A',
      stock: 7,
      banner: 'app://dev/media/spec/mock_spec_pink.jpg',
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 188,
    },
    {
      skuCode: 'sku_100002',
      productId: 'product_10001',
      skuDesc: '粉色;165/84A',
      stock: 1,
      banner: 'app://dev/media/spec/mock_spec_pink.jpg',
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 188,
    },
    {
      skuCode: 'sku_100003',
      productId: 'product_10001',
      skuDesc: '粉色;170/88A',
      stock: 3,
      banner: 'app://dev/media/spec/mock_spec_pink.jpg',
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 188,
    },
    {
      skuCode: 'sku_100004',
      productId: 'product_10001',
      skuDesc: '白色;160/80A',
      stock: 5,
      banner: 'app://dev/media/spec/mock_spec_white.jpg',
      title: '时尚轻商务系列针织打底纯羊毛内搭',
      serviceDesc: '运费险｜7天无理由',
      price: 200,
    },
  ];
  public static readonly ORDER_LIST: OrderCardDto[] = [
    {
      type: 0,
      time: '2025-03-01 08:00:00',
      orderCode: 'mock_order_code_0',
      statusDesc: '已完成',
      skuList: [
        {
          skuCode: 'sku_100001',
          skuDesc: '粉色;160/80A',
          count: 1,
          banner: 'app://dev/media/spec/mock_spec_pink.jpg',
          title: '时尚轻商务系列针织打底纯羊毛内搭',
          serviceDesc: '运费险｜7天无理由',
          price: 188
        },
        {
          skuCode: 'sku_100004',
          skuDesc: '白色;160/80A',
          count: 3,
          banner: 'app://dev/media/spec/mock_spec_white.jpg',
          title: '时尚轻商务系列针织打底纯羊毛内搭',
          serviceDesc: '运费险｜7天无理由',
          price: 600
        }
      ],
      logisticsInfo: [
        {
          icon: 'app://dev/media/icon/ic_car.svg',
          status: '',
          desc: '您提交了订单，请等待系统确认',
          time: '2025-03-01 09:00:00'
        },
        {
          icon: 'app://dev/media/icon/ic_car.svg',
          status: '',
          desc: '您的订单已经安排车辆',
          time: '2025-03-01 09:05:00'
        },
        {
          icon: 'app://dev/media/icon/ic_car.svg',
          status: '运输中',
          desc: '预计XX月XX日送达',
          time: '2025-03-01 10:00:00'
        }
      ],
      totalPrice: 788
    },
    {
      type: 2,
      time: '2025-03-01 09:00:00',
      orderCode: 'mock_order_code_1',
      statusDesc: '待发货',
      skuList: [
        {
          skuCode: 'sku_100002',
          skuDesc: '粉色;165/84A',
          count: 3,
          banner: 'app://dev/media/spec/mock_spec_pink.jpg',
          title: '时尚轻商务系列针织打底纯羊毛内搭',
          serviceDesc: '运费险｜7天无理由',
          price: 564
        }
      ],
      logisticsInfo: [
      ],
      totalPrice: 564
    },
    {
      type: 3,
      time: '2025-03-02 17:30:00',
      orderCode: 'mock_order_code_2',
      statusDesc: '待收货',
      skuList: [
        {
          skuCode: 'sku_100002',
          skuDesc: '粉色;165/84A',
          count: 5,
          banner: 'app://dev/media/spec/mock_spec_pink.jpg',
          title: '时尚轻商务系列针织打底纯羊毛内搭',
          serviceDesc: '运费险｜7天无理由',
          price: 940
        }
      ],
      logisticsInfo: [
      ],
      totalPrice: 940
    },
    {
      type: 0,
      time: '2025-03-15 12:00:00',
      orderCode: 'mock_order_code_3',
      statusDesc: '已取消',
      skuList: [
        {
          skuCode: 'sku_100001',
          skuDesc: '粉色;160/80A',
          count: 1,
          banner: 'app://dev/media/spec/mock_spec_pink.jpg',
          title: '时尚轻商务系列针织打底纯羊毛内搭',
          serviceDesc: '运费险｜7天无理由',
          price: 188
        }
      ],
      logisticsInfo: [
      ],
      totalPrice: 188
    },
    {
      type: 0,
      time: '2025-04-01 05:27:19',
      orderCode: 'mock_order_code_4',
      statusDesc: '已退款',
      skuList: [
        {
          skuCode: 'sku_100002',
          skuDesc: '粉色;165/84A',
          count: 2,
          banner: 'app://dev/media/spec/mock_spec_pink.jpg',
          title: '时尚轻商务系列针织打底纯羊毛内搭',
          serviceDesc: '运费险｜7天无理由',
          price: 376
        }
      ],
      logisticsInfo: [
      ],
      totalPrice: 376
    }
  ];
}

interface ProductData {
  skuCode: string; // 主键
  productId: string;
  skuDesc: string;
  stock: number;
  banner: string;
  title: string;
  serviceDesc: string;
  price: number;
}
