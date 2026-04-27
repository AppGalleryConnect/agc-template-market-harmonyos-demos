import { CategoryItem, ModelItemInfo, SubCategoryItem } from 'category_list';
import { RecipeBriefInfo, RecipeCategory } from 'link_category';
import { BrandViewProps, ProductInfo } from '../viewmodel/MainPageVM';

export class MockData {
  // 首页品牌列表
  public static brandList: Array<BrandViewProps> = [
    {
      icon: $r('app.media.img_apple'),
      name: '苹果'
    },
    {
      icon: $r('app.media.img_huawei'),
      name: '华为'
    },
    {
      icon: $r('app.media.img_xiaomi'),
      name: '小米'
    },
    {
      icon: $r('app.media.img_sanxing'),
      name: '三星'
    },
    {
      icon: $r('app.media.img_oppo'),
      name: 'OPPO'
    },
    {
      icon: $r('app.media.img_honor'),
      name: '荣耀'
    },
    {
      icon: $r('app.media.img_vivo'),
      name: 'vivo'
    },
    {
      icon: $r('app.media.img_more'),
      name: '更多'
    }
  ]
  // 首页所有分类品牌列表
  public static allBrandList: Array<BrandViewProps> = [
    {
      icon: $r('app.media.image_demo_phone3'),
      name: '手机'
    },
    {
      icon: $r('app.media.img_demo_padB'),
      name: '平板'
    },
    {
      icon: $r('app.media.img_demo_notebookA'),
      name: '笔记本'
    },
    {
      icon: $r('app.media.img_demo_watchA'),
      name: '手表'
    },
    {
      icon: $r('app.media.img_demo_iWatchA'),
      name: '智能穿戴'
    },
    {
      icon: $r('app.media.img_demo_cameraA'),
      name: '拍照摄影'
    },
    {
      icon: $r('app.media.img_demo_no_personA'),
      name: '无人机'
    },
    {
      icon: $r('app.media.img_more'),
      name: '全部'
    }
  ]
  // 首页手机分类品牌列表
  public static phoneBrandList: Array<BrandViewProps> = [
    {
      icon: $r('app.media.img_huawei'),
      name: '华为'
    },
    {
      icon: $r('app.media.img_phone_brand'),
      name: '品牌1'
    },
    {
      icon: $r('app.media.img_phone_brand'),
      name: '品牌2'
    },
    {
      icon: $r('app.media.img_phone_brand'),
      name: '品牌3'
    },
    {
      icon: $r('app.media.img_phone_brand'),
      name: '品牌4'
    },
    {
      icon: $r('app.media.img_phone_brand'),
      name: '品牌5'
    },
    {
      icon: $r('app.media.img_phone_brand'),
      name: '品牌6'
    },
    {
      icon: $r('app.media.img_more'),
      name: '更多'
    }
  ]
  // 首页平板分类品牌列表
  public static padBrandList: Array<BrandViewProps> = [
    {
      icon: $r('app.media.img_huawei'),
      name: '华为'
    },
    {
      icon: $r('app.media.img_pad_brand'),
      name: '品牌1'
    },
    {
      icon: $r('app.media.img_pad_brand'),
      name: '品牌2'
    },
    {
      icon: $r('app.media.img_pad_brand'),
      name: '品牌3'
    },
    {
      icon: $r('app.media.img_pad_brand'),
      name: '品牌4'
    },
    {
      icon: $r('app.media.img_pad_brand'),
      name: '品牌5'
    },
    {
      icon: $r('app.media.img_pad_brand'),
      name: '品牌6'
    },
    {
      icon: $r('app.media.img_more'),
      name: '更多'
    }
  ]
  // 首页电脑分类品牌列表
  public static noteBookBrandList: Array<BrandViewProps> = [
    {
      icon: $r('app.media.img_huawei'),
      name: '华为'
    },
    {
      icon: $r('app.media.img_notebook_brand'),
      name: '品牌1'
    },
    {
      icon: $r('app.media.img_notebook_brand'),
      name: '品牌2'
    },
    {
      icon: $r('app.media.img_notebook_brand'),
      name: '品牌3'
    },
    {
      icon: $r('app.media.img_notebook_brand'),
      name: '品牌4'
    },
    {
      icon: $r('app.media.img_notebook_brand'),
      name: '品牌5'
    },
    {
      icon: $r('app.media.img_notebook_brand'),
      name: '品牌6'
    },
    {
      icon: $r('app.media.img_more'),
      name: '更多'
    }
  ]
  // 首页手表分类品牌列表
  public static watchBrandList: Array<BrandViewProps> = [
    {
      icon: $r('app.media.img_watch_brand'),
      name: '品牌1'
    },
    {
      icon: $r('app.media.img_watch_brand'),
      name: '品牌2'
    },
    {
      icon: $r('app.media.img_watch_brand'),
      name: '品牌3'
    },
    {
      icon: $r('app.media.img_watch_brand'),
      name: '品牌4'
    },
    {
      icon: $r('app.media.img_watch_brand'),
      name: '品牌5'
    },
    {
      icon: $r('app.media.img_watch_brand'),
      name: '品牌6'
    },
    {
      icon: $r('app.media.img_watch_brand'),
      name: '品牌7'
    },
    {
      icon: $r('app.media.img_more'),
      name: '更多'
    }
  ]
  // 首页智能穿戴分类品牌列表
  public static smartWatchBrandList: Array<BrandViewProps> = [
    {
      icon: $r('app.media.img_huawei'),
      name: '华为'
    },
    {
      icon: $r('app.media.img_smart_watch_brand'),
      name: '品牌1'
    },
    {
      icon: $r('app.media.img_smart_watch_brand'),
      name: '品牌2'
    },
    {
      icon: $r('app.media.img_smart_watch_brand'),
      name: '品牌3'
    },
    {
      icon: $r('app.media.img_smart_watch_brand'),
      name: '品牌4'
    },
    {
      icon: $r('app.media.img_smart_watch_brand'),
      name: '品牌5'
    },
    {
      icon: $r('app.media.img_smart_watch_brand'),
      name: '品牌6'
    },
    {
      icon: $r('app.media.img_more'),
      name: '更多'
    }
  ]
  // 首页相机分类品牌列表
  public static cameraBrandList: Array<BrandViewProps> = [
    {
      icon: $r('app.media.img_huawei'),
      name: '华为'
    },
    {
      icon: $r('app.media.img_camera_brand'),
      name: '品牌1'
    },
    {
      icon: $r('app.media.img_camera_brand'),
      name: '品牌2'
    },
    {
      icon: $r('app.media.img_camera_brand'),
      name: '品牌3'
    },
    {
      icon: $r('app.media.img_camera_brand'),
      name: '品牌4'
    },
    {
      icon: $r('app.media.img_camera_brand'),
      name: '品牌5'
    },
    {
      icon: $r('app.media.img_camera_brand'),
      name: '品牌6'
    },
    {
      icon: $r('app.media.img_more'),
      name: '更多'
    }
  ]
  // 首页无人机分类品牌列表
  public static noPersonBrandList: Array<BrandViewProps> = [
    {
      icon: $r('app.media.img_huawei'),
      name: '华为'
    },
    {
      icon: $r('app.media.img_no_person_brand'),
      name: '品牌1'
    },
    {
      icon: $r('app.media.img_no_person_brand'),
      name: '品牌2'
    },
    {
      icon: $r('app.media.img_no_person_brand'),
      name: '品牌3'
    },
    {
      icon: $r('app.media.img_no_person_brand'),
      name: '品牌4'
    },
    {
      icon: $r('app.media.img_no_person_brand'),
      name: '品牌5'
    },
    {
      icon: $r('app.media.img_no_person_brand'),
      name: '品牌6'
    },
    {
      icon: $r('app.media.img_more'),
      name: '更多'
    }
  ]
  // 商品列表
  public static phoneProductList: Array<ProductInfo> = [
    {
      // 产品名称
      name: 'HUAWEI Pura Pro Max  512 灰色   国行  全网通 ',
      // 产品标签
      labels: '手机',
      // 产品图片
      image: $r('app.media.image_demo_phone3'),
      // 产品价格
      price: 4680,
      // 产品价格描述
      priceDes: '¥3880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '华为 Mate 60 Pro  512 麒麟9000S芯片 微曲屏',
      // 产品标签
      labels: '手机',
      // 产品图片
      image: $r('app.media.image_demo_phone2'),
      // 产品价格
      price: 2089,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: 'HUAWEI Pura Pro Max  512 灰色   国行  全网通 ',
      // 产品标签
      labels: '手机',
      // 产品图片
      image: $r('app.media.image_demo_phone3'),
      // 产品价格
      price: 1680,
      // 产品价格描述
      priceDes: '¥880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '华为 Mate 60 Pro  512 麒麟9000S芯片 微曲屏',
      // 产品标签
      labels: '手机',
      // 产品图片
      image: $r('app.media.image_demo_phone2'),
      // 产品价格
      price: 2089,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: 'HUAWEI Pura Pro Max  512 灰色   国行  全网通 ',
      // 产品标签
      labels: '手机',
      // 产品图片
      image: $r('app.media.image_demo_phone3'),
      // 产品价格
      price: 4680,
      // 产品价格描述
      priceDes: '¥3880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '华为 Mate 60 Pro  512 麒麟9000S芯片 微曲屏',
      // 产品标签
      labels: '手机',
      // 产品图片
      image: $r('app.media.image_demo_phone2'),
      // 产品价格
      price: 4089,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '华为 Pura 70 Pro  512G 麒麟9000S芯片 微曲屏',
      // 产品标签
      labels: '手机',
      // 产品图片
      image: $r('app.media.image_demo_phone2'),
      // 产品价格
      price: 3089,
      // 产品价格描述
      priceDes: '¥3880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    }
  ]
  // 平板商品列表
  public static padProductList: Array<ProductInfo> = [
    {
      // 产品名称
      name: '华为m5青春版保护套8英寸 玫瑰粉  512',
      // 产品标签
      labels: '平板',
      // 产品图片
      image: $r('app.media.img_demo_padA'),
      // 产品价格
      price: 1680,
      // 产品价格描述
      priceDes: '¥880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '2023年新品华为huawei matepad pro 13   1T',
      // 产品标签
      labels: '平板',
      // 产品图片
      image: $r('app.media.img_demo_padB'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '华为m5青春版保护套8英寸 玫瑰粉  512',
      // 产品标签
      labels: '平板',
      // 产品图片
      image: $r('app.media.img_demo_padA'),
      // 产品价格
      price: 1680,
      // 产品价格描述
      priceDes: '¥880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '2023年新品华为huawei matepad pro 13   1T',
      // 产品标签
      labels: '平板',
      // 产品图片
      image: $r('app.media.img_demo_padB'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '华为m5青春版保护套8英寸 玫瑰粉  512',
      // 产品标签
      labels: '平板',
      // 产品图片
      image: $r('app.media.img_demo_padA'),
      // 产品价格
      price: 1680,
      // 产品价格描述
      priceDes: '¥880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '2023年新品华为huawei matepad pro 13   1T',
      // 产品标签
      labels: '平板',
      // 产品图片
      image: $r('app.media.img_demo_padB'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    }
  ]
  // 笔记本商品列表
  public static notebookProductList: Array<ProductInfo> = [
    {
      // 产品名称
      name: '全新华为笔记本 MateBook16',
      // 产品标签
      labels: '笔记本',
      // 产品图片
      image: $r('app.media.img_demo_notebookA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '2023年新品华为huawei matepad pro 13   1T',
      // 产品标签
      labels: '笔记本',
      // 产品图片
      image: $r('app.media.img_demo_notebookB'),
      // 产品价格
      price: 2680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '全新华为笔记本 MateBook16',
      // 产品标签
      labels: '笔记本',
      // 产品图片
      image: $r('app.media.img_demo_notebookA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '2023年新品华为huawei matepad pro 13   1T',
      // 产品标签
      labels: '笔记本',
      // 产品图片
      image: $r('app.media.img_demo_notebookB'),
      // 产品价格
      price: 2680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '全新华为笔记本 MateBook16',
      // 产品标签
      labels: '笔记本',
      // 产品图片
      image: $r('app.media.img_demo_notebookA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '2023年新品华为huawei matepad pro 13   1T',
      // 产品标签
      labels: '笔记本',
      // 产品图片
      image: $r('app.media.img_demo_notebookB'),
      // 产品价格
      price: 2680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    }
  ]
  // 手表商品列表
  public static watchProductList: Array<ProductInfo> = [
    {
      // 产品名称
      name: '精英男士进口高端定制款手表',
      // 产品标签
      labels: '手表',
      // 产品图片
      image: $r('app.media.img_demo_watchA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '精致女士进口高端定制款蓝钻手表',
      // 产品标签
      labels: '手表',
      // 产品图片
      image: $r('app.media.img_demo_watchB'),
      // 产品价格
      price: 2680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '精英男士进口高端定制款手表',
      // 产品标签
      labels: '手表',
      // 产品图片
      image: $r('app.media.img_demo_watchA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '精致女士进口高端定制款蓝钻手表',
      // 产品标签
      labels: '手表',
      // 产品图片
      image: $r('app.media.img_demo_watchB'),
      // 产品价格
      price: 2680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '精英男士进口高端定制款手表',
      // 产品标签
      labels: '手表',
      // 产品图片
      image: $r('app.media.img_demo_watchA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '精致女士进口高端定制款蓝钻手表',
      // 产品标签
      labels: '手表',
      // 产品图片
      image: $r('app.media.img_demo_watchB'),
      // 产品价格
      price: 2680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    }
  ]
  // 智能穿戴商品列表
  public static iWatchProductList: Array<ProductInfo> = [
    {
      // 产品名称
      name: '华为HUAWVEI手机专场荣耀经典黑手环',
      // 产品标签
      labels: '智能穿戴',
      // 产品图片
      image: $r('app.media.img_demo_iWatchA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: 'huawei watch gt2 华为运动智能手表 蓝',
      // 产品标签
      labels: '智能穿戴',
      // 产品图片
      image: $r('app.media.img_demo_iWatchB'),
      // 产品价格
      price: 2680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '华为HUAWVEI手机专场荣耀经典黑手环',
      // 产品标签
      labels: '智能穿戴',
      // 产品图片
      image: $r('app.media.img_demo_iWatchA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: 'huawei watch gt2 华为运动智能手表 蓝',
      // 产品标签
      labels: '智能穿戴',
      // 产品图片
      image: $r('app.media.img_demo_iWatchB'),
      // 产品价格
      price: 2680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '华为HUAWVEI手机专场荣耀经典黑手环',
      // 产品标签
      labels: '智能穿戴',
      // 产品图片
      image: $r('app.media.img_demo_iWatchA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: 'huawei watch gt2 华为运动智能手表 蓝',
      // 产品标签
      labels: '智能穿戴',
      // 产品图片
      image: $r('app.media.img_demo_iWatchB'),
      // 产品价格
      price: 2680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    }
  ]
  // 相机商品列表
  public static cameraProductList: Array<ProductInfo> = [
    {
      // 产品名称
      name: 'xiangji  EOS  原装镜头带2T内存卡',
      // 产品标签
      labels: '拍照摄像',
      // 产品图片
      image: $r('app.media.img_demo_cameraA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: 'xiangji   相机原装进口摄像机带镜头  2T  黑色',
      // 产品标签
      labels: '拍照摄像',
      // 产品图片
      image: $r('app.media.img_demo_cameraB'),
      // 产品价格
      price: 9880,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: 'xiangji  EOS  原装镜头带2T内存卡',
      // 产品标签
      labels: '拍照摄像',
      // 产品图片
      image: $r('app.media.img_demo_cameraA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: 'xiangji   相机原装进口摄像机带镜头  2T  黑色',
      // 产品标签
      labels: '拍照摄像',
      // 产品图片
      image: $r('app.media.img_demo_cameraB'),
      // 产品价格
      price: 9880,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: 'xiangji  EOS  原装镜头带2T内存卡',
      // 产品标签
      labels: '拍照摄像',
      // 产品图片
      image: $r('app.media.img_demo_cameraA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: 'xiangji   相机原装进口摄像机带镜头  2T  黑色',
      // 产品标签
      labels: '拍照摄像',
      // 产品图片
      image: $r('app.media.img_demo_cameraB'),
      // 产品价格
      price: 9880,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    }
  ]
  // 无人机商品列表
  public static noPersonProductList: Array<ProductInfo> = [
    {
      // 产品名称
      name: '大疆发布随身无人机终结原价6490',
      // 产品标签
      labels: '无人机',
      // 产品图片
      image: $r('app.media.img_demo_no_personA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '深度解读消费级无人机市场',
      // 产品标签
      labels: '无人机',
      // 产品图片
      image: $r('app.media.img_demo_no_personB'),
      // 产品价格
      price: 9880,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '大疆发布随身无人机终结原价6490',
      // 产品标签
      labels: '无人机',
      // 产品图片
      image: $r('app.media.img_demo_no_personA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '深度解读消费级无人机市场',
      // 产品标签
      labels: '无人机',
      // 产品图片
      image: $r('app.media.img_demo_no_personB'),
      // 产品价格
      price: 9880,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '大疆发布随身无人机终结原价6490',
      // 产品标签
      labels: '无人机',
      // 产品图片
      image: $r('app.media.img_demo_no_personA'),
      // 产品价格
      price: 3680,
      // 产品价格描述
      priceDes: '¥2880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '深度解读消费级无人机市场',
      // 产品标签
      labels: '无人机',
      // 产品图片
      image: $r('app.media.img_demo_no_personB'),
      // 产品价格
      price: 9880,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    }
  ]
  // 商品列表
  public static homePageProductList: Array<ProductInfo> = [
    {
      // 产品名称
      name: 'shouji 17 Pro Max   512 灰色   国行  全网通 ',
      // 产品标签
      labels: '手机',
      // 产品图片
      image: $r('app.media.image_demo_phoneA'),
      // 产品价格
      price: 4680,
      // 产品价格描述
      priceDes: '¥3880',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '满1000减200',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: 'xiangji   相机原装进口摄像机带镜头  2T  黑色',
      // 产品标签
      labels: '相机',
      // 产品图片
      image: $r('app.media.img_demo_cameraA'),
      // 产品价格
      price: 4089,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '2023年新品华为huawei matepad pro 13   1T',
      // 产品标签
      labels: '平板',
      // 产品图片
      image: $r('app.media.img_demo_padB'),
      // 产品价格
      price: 4680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: 'huawei watch gt2 华为运动智能手表 蓝',
      // 产品标签
      labels: '智能穿戴',
      // 产品图片
      image: $r('app.media.img_demo_iWatchA'),
      // 产品价格
      price: 4089,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '华为笔记本MateBook13 2021款11代',
      // 产品标签
      labels: '笔记本',
      // 产品图片
      image: $r('app.media.img_demo_notebookA'),
      // 产品价格
      price: 2680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品满减描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    },
    {
      // 产品名称
      name: '精致女士进口高端定制款蓝钻手表',
      // 产品标签
      labels: '手表',
      // 产品图片
      image: $r('app.media.img_demo_watchB'),
      // 产品价格
      price: 2680,
      // 产品价格描述
      priceDes: '',
      // 产品评价描述
      evaluateDes: '同款好评率超99%',
      // 产品崭新度描述
      newDes: '99新',
      // 产品崭新度描述
      discountDes: '',
      // 商品图片集合
      imagesList: []
    }
  ]
  public static recipeCategoryList: RecipeCategory[] = [
    {
      id: 1001,
      name: '品牌型号',
      recipeList: [
        { id: 1, title: '不限型号' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1002,
      name: '整体成色',
      recipeList: [
        { id: 1, title: '99新|几乎没有使用痕迹' } as RecipeBriefInfo,
        { id: 2, title: '95新|轻微使用痕迹' } as RecipeBriefInfo,
        { id: 3, title: '9新|中度使用痕迹' } as RecipeBriefInfo,
        { id: 4, title: '8新|明显使用痕迹' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1003,
      name: '容量',
      recipeList: [
        { id: 1, title: '24GB+1T' } as RecipeBriefInfo,
        { id: 2, title: '18GB+640G' } as RecipeBriefInfo,
        { id: 3, title: '16GB+512G' } as RecipeBriefInfo,
        { id: 4, title: '12GB+256G' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1004,
      name: '保修时间',
      recipeList: [
        { id: 1, title: '30天' } as RecipeBriefInfo,
        { id: 2, title: '180天' } as RecipeBriefInfo,
        { id: 3, title: '一年' } as RecipeBriefInfo,
        { id: 4, title: '两年' } as RecipeBriefInfo,
        { id: 5, title: '三年' } as RecipeBriefInfo,
        { id: 6, title: '五年' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1005,
      name: '版本',
      recipeList: [
        { id: 1, title: 'HarmonyOs17' } as RecipeBriefInfo,
        { id: 2, title: '苹果Os15' } as RecipeBriefInfo,
        { id: 3, title: 'HarmonyOs16' } as RecipeBriefInfo,
        { id: 4, title: 'HarmonyOs15' } as RecipeBriefInfo,
        { id: 5, title: 'HarmonyOs14' } as RecipeBriefInfo,
        { id: 6, title: 'HarmonyOs13及以下' } as RecipeBriefInfo,
        { id: 7, title: '苹果Os14' } as RecipeBriefInfo,
        { id: 8, title: '苹果Os13' } as RecipeBriefInfo,
        { id: 9, title: '苹果Os12' } as RecipeBriefInfo,
        { id: 10, title: '苹果Os11及以下' } as RecipeBriefInfo,
        { id: 11, title: '安式Os14' } as RecipeBriefInfo,
        { id: 12, title: '安式Os13' } as RecipeBriefInfo,
        { id: 13, title: '安式Os12' } as RecipeBriefInfo,
        { id: 14, title: '安式Os11' } as RecipeBriefInfo,
        { id: 15, title: '安式Os10及以下' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1006,
      name: '上市时间',
      recipeList: [
        { id: 1, title: '2025年10月' } as RecipeBriefInfo,
        { id: 2, title: '2025年5月' } as RecipeBriefInfo,
        { id: 3, title: '2024年10月' } as RecipeBriefInfo,
        { id: 4, title: '2024年5月' } as RecipeBriefInfo,
        { id: 5, title: '2023年10月' } as RecipeBriefInfo,
        { id: 6, title: '2023年5月' } as RecipeBriefInfo,
        { id: 7, title: '2022年10月及以前' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1007,
      name: '精选机况',
      recipeList: [
        { id: 1, title: '安式Os账号' } as RecipeBriefInfo,
        { id: 2, title: '苹果账号' } as RecipeBriefInfo,
        { id: 3, title: '银行卡' } as RecipeBriefInfo,
        { id: 4, title: '华为账号' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1008,
      name: '电池健康度',
      recipeList: [
        { id: 1, title: '95%及以上' } as RecipeBriefInfo,
        { id: 2, title: '90%' } as RecipeBriefInfo,
        { id: 3, title: '80%' } as RecipeBriefInfo,
        { id: 4, title: '60%' } as RecipeBriefInfo,
        { id: 5, title: '50%及以下' } as RecipeBriefInfo,
      ],
    },
    {
      id: 1009,
      name: '商品来源',
      recipeList: [
        { id: 1, title: '拼夕夕' } as RecipeBriefInfo,
        { id: 2, title: '淘宝' } as RecipeBriefInfo,
        { id: 3, title: '京东' } as RecipeBriefInfo,
        { id: 4, title: '海外' } as RecipeBriefInfo,
        { id: 5, title: '二手杂牌' } as RecipeBriefInfo,
      ],
    },
  ];
  static list1: ModelItemInfo =
    {
      label: '全部',
      content: [
        {
          title: '全部',
          content: ['不限型号'],
          description: ''
        },
        {
          title: '华为·Mate系列',
          content: ['华为 Mate X5', '华为 Mate 60 Pro', '华为 Mate X6', '华为 Mate XT 非凡大师',
            '华为 Mate 40 Pro(5G)'],
          description: '高端旗舰，强悍性能、商务、游戏专用'
        },
        {
          title: '华为·Pura系列',
          content: ['华为 Pura 70 Pro', '华为 Pura X', '华为 Pura 70', '华为 Pura 70 Ultra',
            '华为 Pura 80 Pro'],
          description: '高端旗舰，强悍性能、商务、游戏专用'
        },
        {
          title: '华为·nova系列',
          content: ['华为 nova 12 Pro', '华为 nova 12 Ultra', '华为 nova 12', '华为 nova 13', '华为 nova 11 SE'],
          description: ''
        },
        {
          title: '华为·畅享系列',
          content: ['华为 畅享 70 Pro', '华为 畅享 70', '华为 畅享 60 Pro', '华为 畅享 60', '华为 畅享 50z'],
          description: ''
        },
        {
          title: '华为·折叠屏系列',
          content: ['华为折叠屏 Mate X5', '华为折叠屏 Pocket 2', '华为折叠屏 Mate X3', '华为折叠屏 Pocket S',
            '华为折叠屏 Mate Xs 2'],
          description: ''
        },
        {
          title: '华为·旗舰影像系列',
          content: ['华为旗舰 Pura 70 Ultra', '华为旗舰 Mate 60 Pro+', '华为旗舰 P50 Pro', '华为旗舰 Mate 40 Pro+',
            '华为旗舰 P40 Pro+'],
          description: ''
        }
      ],
    };
  static list2: ModelItemInfo =
    {
      label: '华为',
      content: [
        {
          title: '华为',
          content: ['不限型号'],
          description: ''
        },
        {
          title: '华为·Mate系列',
          content: ['华为 Mate X5', '华为 Mate 60 Pro', '华为 Mate X6', '华为 Mate XT 非凡大师',
            '华为 Mate 40 Pro(5G)'],
          description: '高端旗舰，强悍性能、商务、游戏专用'
        },
        {
          title: '华为·Pura系列',
          content: ['华为 Pura 70 Pro', '华为 Pura X', '华为 Pura 70', '华为 Pura 70 Ultra',
            '华为 Pura 80 Pro'],
          description: '高端旗舰，强悍性能、商务、游戏专用'
        },
        {
          title: '华为·nova系列',
          content: ['华为 nova 12 Pro', '华为 nova 12 Ultra', '华为 nova 12', '华为 nova 13', '华为 nova 11 SE'],
          description: ''
        },
        {
          title: '华为·畅享系列',
          content: ['华为 畅享 70 Pro', '华为 畅享 70', '华为 畅享 60 Pro', '华为 畅享 60', '华为 畅享 50z'],
          description: ''
        },
        {
          title: '华为·折叠屏系列',
          content: ['华为折叠屏 Mate X5', '华为折叠屏 Pocket 2', '华为折叠屏 Mate X3', '华为折叠屏 Pocket S',
            '华为折叠屏 Mate Xs 2'],
          description: ''
        },
        {
          title: '华为·旗舰影像系列',
          content: ['华为旗舰 Pura 70 Ultra', '华为旗舰 Mate 60 Pro+', '华为旗舰 P50 Pro', '华为旗舰 Mate 40 Pro+',
            '华为旗舰 P40 Pro+'],
          description: ''
        }
      ],
    };
  static list3: ModelItemInfo = {
    label: '品牌1',
    content: [
      {
        title: '品牌1',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌1·Mate系列',
        content: ['品牌1 Mate X5', '品牌1 Mate 60 Pro', '品牌1 Mate X5', '品牌1 Mate XT 非凡大师',
          '品牌1 Mate 40 Pro(5G)'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌1·Pura系列',
        content: ['品牌1 Pura 70 Pro', '品牌1 Pura X', '品牌1 Pura 70', '品牌1 Pura 70 Ultra',
          '品牌1 Pura 80 Pro'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌1·nova系列',
        content: ['品牌1 nova 12 Pro', '品牌1 nova 12 Ultra', '品牌1 nova 12', '品牌1 nova 13', '品牌1 nova 11 SE'],
        description: ''
      },
      {
        title: '品牌1·旗舰影像系列',
        content: ['品牌1旗舰 Pura 70 Ultra', '品牌1旗舰 Mate 60 Pro+', '品牌1旗舰 P50 Pro', '品牌1旗舰 Mate 40 Pro+',
          '品牌1旗舰 P40 Pro+'],
        description: ''
      },
      {
        title: '品牌1·畅享系列',
        content: ['品牌1 畅享 70 Pro', '品牌1 畅享 70', '品牌1 畅享 60 Pro', '品牌1 畅享 60', '品牌1 畅享 50z'],
        description: ''
      }
    ],
  };
  static list4: ModelItemInfo = {
    label: '品牌2',
    content: [
      {
        title: '品牌2',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌2·Mate系列',
        content: ['品牌2 Mate X5', '品牌2 Mate 60 Pro', '品牌2 Mate X5', '品牌2 Mate XT 非凡大师',
          '品牌2 Mate 40 Pro(5G)'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌2·Pura系列',
        content: ['品牌2 Pura 70 Pro', '品牌2 Pura X', '品牌2 Pura 70', '品牌2 Pura 70 Ultra',
          '品牌1 Pura 80 Pro'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌2·nova系列',
        content: ['品牌2 nova 12 Pro', '品牌2 nova 12 Ultra', '品牌2 nova 12', '品牌2 nova 13', '品牌2 nova 11 SE'],
        description: ''
      },
      {
        title: '品牌2·旗舰影像系列',
        content: ['品牌2旗舰 Pura 70 Ultra', '品牌2旗舰 Mate 60 Pro+', '品牌2旗舰 P50 Pro', '品牌2旗舰 Mate 40 Pro+',
          '品牌2旗舰 P40 Pro+'],
        description: ''
      },
      {
        title: '品牌2·畅享系列',
        content: ['品牌2 畅享 70 Pro', '品牌2 畅享 70', '品牌2 畅享 60 Pro', '品牌2 畅享 60', '品牌2 畅享 50z'],
        description: ''
      }
    ]
  }
  static list5: ModelItemInfo = {
    label: '品牌3',
    content: [
      {
        title: '品牌3',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌3·Mate系列',
        content: ['品牌3 Mate X5', '品牌3 Mate 60 Pro', '品牌3 Mate X5', '品牌3 Mate XT 非凡大师',
          '品牌3 Mate 40 Pro(5G)'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌3·Pura系列',
        content: ['品牌3 Pura 70 Pro', '品牌3 Pura X', '品牌3 Pura 70', '品牌3 Pura 70 Ultra',
          '品牌3 Pura 80 Pro'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌3·nova系列',
        content: ['品牌3 nova 12 Pro', '品牌3 nova 12 Ultra', '品牌3 nova 12', '品牌3 nova 13', '品牌3 nova 11 SE'],
        description: ''
      },
      {
        title: '品牌3·旗舰影像系列',
        content: ['品牌3旗舰 Pura 70 Ultra', '品牌3旗舰 Mate 60 Pro+', '品牌3旗舰 P50 Pro', '品牌3旗舰 Mate 40 Pro+',
          '品牌3旗舰 P40 Pro+'],
        description: ''
      },
      {
        title: '品牌3·畅享系列',
        content: ['品牌3 畅享 70 Pro', '品牌3 畅享 70', '品牌3 畅享 60 Pro', '品牌3 畅享 60', '品牌3 畅享 50z'],
        description: ''
      }
    ]
  }
  static list6: ModelItemInfo = {
    label: '品牌4',
    content: [
      {
        title: '品牌4',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌4·Mate系列',
        content: ['品牌4 Mate X5', '品牌4 Mate 60 Pro', '品牌4 Mate X5', '品牌4 Mate XT 非凡大师',
          '品牌4 Mate 40 Pro(5G)'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌4·Pura系列',
        content: ['品牌4 Pura 70 Pro', '品牌4 Pura X', '品牌4 Pura 70', '品牌4 Pura 70 Ultra',
          '品牌4 Pura 80 Pro'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌4·nova系列',
        content: ['品牌4 nova 12 Pro', '品牌4 nova 12 Ultra', '品牌4 nova 12', '品牌4 nova 13', '品牌4 nova 11 SE'],
        description: ''
      },
      {
        title: '品牌4·旗舰影像系列',
        content: ['品牌4旗舰 Pura 70 Ultra', '品牌4旗舰 Mate 60 Pro+', '品牌4旗舰 P50 Pro', '品牌4旗舰 Mate 40 Pro+',
          '品牌4旗舰 P40 Pro+'],
        description: ''
      },
      {
        title: '品牌4·畅享系列',
        content: ['品牌4 畅享 70 Pro', '品牌4 畅享 70', '品牌4 畅享 60 Pro', '品牌4 畅享 60', '品牌4 畅享 50z'],
        description: ''
      }
    ]
  }
  static list7: ModelItemInfo = {
    label: '品牌5',
    content: [
      {
        title: '品牌5',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌5·Mate系列',
        content: ['品牌5 Mate X5', '品牌5 Mate 60 Pro', '品牌5 Mate X5', '品牌5 Mate XT 非凡大师',
          '品牌5 Mate 40 Pro(5G)'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌5·Pura系列',
        content: ['品牌5 Pura 70 Pro', '品牌5 Pura X', '品牌5 Pura 70', '品牌5 Pura 70 Ultra',
          '品牌5 Pura 80 Pro'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌5·nova系列',
        content: ['品牌5 nova 12 Pro', '品牌5 nova 12 Ultra', '品牌5 nova 12', '品牌5 nova 13', '品牌5 nova 11 SE'],
        description: ''
      },
      {
        title: '品牌5·旗舰影像系列',
        content: ['品牌5旗舰 Pura 70 Ultra', '品牌5旗舰 Mate 60 Pro+', '品牌5旗舰 P50 Pro', '品牌5旗舰 Mate 40 Pro+',
          '品牌5旗舰 P40 Pro+'],
        description: ''
      },
      {
        title: '品牌5·畅享系列',
        content: ['品牌5 畅享 70 Pro', '品牌5 畅享 70', '品牌5 畅享 60 Pro', '品牌5 畅享 60', '品牌5 畅享 50z'],
        description: ''
      }
    ]
  }
  static list8: ModelItemInfo = {
    label: '品牌6',
    content: [
      {
        title: '品牌6',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌6·Mate系列',
        content: ['品牌6 Mate X5', '品牌6 Mate 60 Pro', '品牌6 Mate X5', '品牌6 Mate XT 非凡大师',
          '品牌6 Mate 40 Pro(5G)'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌6·Pura系列',
        content: ['品牌6 Pura 70 Pro', '品牌6 Pura X', '品牌6 Pura 70', '品牌6 Pura 70 Ultra',
          '品牌6 Pura 80 Pro'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌6·nova系列',
        content: ['品牌6 nova 12 Pro', '品牌6 nova 12 Ultra', '品牌6 nova 12', '品牌6 nova 13', '品牌6 nova 11 SE'],
        description: ''
      },
      {
        title: '品牌6·旗舰影像系列',
        content: ['品牌6旗舰 Pura 70 Ultra', '品牌6旗舰 Mate 60 Pro+', '品牌6旗舰 P50 Pro', '品牌6旗舰 Mate 40 Pro+',
          '品牌6旗舰 P40 Pro+'],
        description: ''
      },
      {
        title: '品牌6·畅享系列',
        content: ['品牌6 畅享 70 Pro', '品牌6 畅享 70', '品牌6 畅享 60 Pro', '品牌6 畅享 60', '品牌6 畅享 50z'],
        description: ''
      }
    ]
  }
  static list9: ModelItemInfo = {
    label: '品牌7',
    content: [
      {
        title: '品牌7',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌7·Mate系列',
        content: ['品牌7 Mate X5', '品牌7 Mate 60 Pro', '品牌7 Mate X5', '品牌7 Mate XT 非凡大师',
          '品牌7 Mate 40 Pro(5G)'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌7·Pura系列',
        content: ['品牌7 Pura 70 Pro', '品牌7 Pura X', '品牌7 Pura 70', '品牌7 Pura 70 Ultra',
          '品牌7 Pura 80 Pro'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌7·nova系列',
        content: ['品牌7 nova 12 Pro', '品牌7 nova 12 Ultra', '品牌7 nova 12', '品牌7 nova 13', '品牌7 nova 11 SE'],
        description: ''
      },
      {
        title: '品牌7·旗舰影像系列',
        content: ['品牌7旗舰 Pura 70 Ultra', '品牌7旗舰 Mate 60 Pro+', '品牌7旗舰 P50 Pro', '品牌7旗舰 Mate 40 Pro+',
          '品牌7旗舰 P40 Pro+'],
        description: ''
      },
      {
        title: '品牌7·畅享系列',
        content: ['品牌7 畅享 70 Pro', '品牌7 畅享 70', '品牌7 畅享 60 Pro', '品牌7 畅享 60', '品牌7 畅享 50z'],
        description: ''
      }
    ]
  }
  static list10: ModelItemInfo = {
    label: '品牌8',
    content: [
      {
        title: '品牌8',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌8·Mate系列',
        content: ['品牌8 Mate X5', '品牌8 Mate 60 Pro', '品牌8 Mate X5', '品牌8 Mate XT 非凡大师',
          '品牌8 Mate 40 Pro(5G)'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌8·Pura系列',
        content: ['品牌8 Pura 70 Pro', '品牌8 Pura X', '品牌8 Pura 70', '品牌8 Pura 70 Ultra',
          '品牌8 Pura 80 Pro'],
        description: '高端旗舰，强悍性能、商务、游戏专用'
      },
      {
        title: '品牌8·nova系列',
        content: ['品牌8 nova 12 Pro', '品牌8 nova 12 Ultra', '品牌8 nova 12', '品牌8 nova 13', '品牌8 nova 11 SE'],
        description: ''
      },
      {
        title: '品牌8·旗舰影像系列',
        content: ['品牌8 旗舰 Pura 70 Ultra', '品牌8 旗舰 Mate 60 Pro+', '品牌8 旗舰 P50 Pro', '品牌8 旗舰 Mate 40 Pro+',
          '品牌8 旗舰 P40 Pro+'],
        description: ''
      },
      {
        title: '品牌8·畅享系列',
        content: ['品牌8 畅享 70 Pro', '品牌8 畅享 70', '品牌8 畅享 60 Pro', '品牌8 畅享 60', '品牌8 畅享 50z'],
        description: ''
      }
    ]
  }
  static modelCategoryList: ModelItemInfo[] =
    [MockData.list2, MockData.list3, MockData.list4, MockData.list5, MockData.list6, MockData.list7,
      MockData.list8, MockData.list9, MockData.list10]
  static cameraList1: ModelItemInfo =
    {
      label: '全部',
      content: [
        {
          title: '全部',
          content: ['不限型号'],
          description: ''
        },
        {
          title: '相机·EOS系列',
          content: ['相机·EOS600D', '相机·EOS600D', '相机·EOS600D', '相机·EOS600E',
            '相机·EOS600F'],
          description: ''
        },
        {
          title: '相机·α系列',
          content: ['相机·α7III', '相机·α7IV', '相机·α7RV', '相机·α7CII', '相机·α9III'],
          description: ''
        },
        {
          title: '相机·Z系列',
          content: ['相机·Z7II', '相机·Z8', '相机·Z9', '相机·Z6III', '相机·Z5'],
          description: ''
        },
        {
          title: '相机·GFX系列',
          content: ['相机·GFX50SII', '相机·GFX100S', '相机·GFX100II', '相机·GFX50R', '相机·GFX100'],
          description: ''
        },
        {
          title: '相机·X系列',
          content: ['相机·X-T5', '相机·X-H2S', '相机·X-H2', '相机·X-S20', '相机·X-E4'],
          description: ''
        }
      ],
    };
  static cameraList2: ModelItemInfo =
    {
      label: '华为',
      content: [
        {
          title: '相机',
          content: ['不限型号'],
          description: ''
        },
        {
          title: '相机·EOS系列',
          content: ['相机·EOS600D', '相机·EOS600D', '相机·EOS600D', '相机·EOS600E',
            '相机·EOS600F'],
          description: ''
        },
        {
          title: '相机·α系列',
          content: ['相机·α7III', '相机·α7IV', '相机·α7RV', '相机·α7CII', '相机·α9III'],
          description: ''
        },
        {
          title: '相机·Z系列',
          content: ['相机·Z7II', '相机·Z8', '相机·Z9', '相机·Z6III', '相机·Z5'],
          description: ''
        },
        {
          title: '相机·GFX系列',
          content: ['相机·GFX50SII', '相机·GFX100S', '相机·GFX100II', '相机·GFX50R', '相机·GFX100'],
          description: ''
        },
        {
          title: '相机·X系列',
          content: ['相机·X-T5', '相机·X-H2S', '相机·X-H2', '相机·X-S20', '相机·X-E4'],
          description: ''
        }
      ],
    };
  static cameraList3: ModelItemInfo = {
    label: '品牌1',
    content: [
      {
        title: '品牌1',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌1·EOS系列',
        content: ['品牌1·EOS600D', '品牌1·EOS600D', '品牌1·EOS600D', '品牌1·EOS600E',
          '品牌1·EOS600F'],
        description: ''
      },
      {
        title: '品牌1·α系列',
        content: ['品牌1·α7III', '品牌1·α7IV', '品牌1·α7RV', '品牌1·α7CII', '品牌1·α9III'],
        description: ''
      },
      {
        title: '品牌1·Z系列',
        content: ['品牌1·Z7II', '品牌1·Z8', '品牌1·Z9', '品牌1·Z6III', '品牌1·Z5'],
        description: ''
      },
      {
        title: '品牌1·GFX系列',
        content: ['品牌1·GFX50SII', '品牌1·GFX100S', '品牌1·GFX100II', '品牌1·GFX50R', '品牌1·GFX100'],
        description: ''
      },
      {
        title: '品牌1·X系列',
        content: ['品牌1·X-T5', '品牌1·X-H2S', '品牌1·X-H2', '品牌1·X-S20', '品牌1·X-E4'],
        description: ''
      }
    ],
  };
  static cameraList4: ModelItemInfo = {
    label: '品牌2',
    content: [
      {
        title: '品牌2',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌2·EOS系列',
        content: ['品牌2·EOS600D', '品牌2·EOS600D', '品牌2·EOS600D', '品牌2·EOS600E',
          '品牌2·EOS600F'],
        description: ''
      },
      {
        title: '品牌2·α系列',
        content: ['品牌2·α7III', '品牌2·α7IV', '品牌2·α7RV', '品牌2·α7CII', '品牌2·α9III'],
        description: ''
      },
      {
        title: '品牌2·Z系列',
        content: ['品牌2·Z7II', '品牌2·Z8', '品牌2·Z9', '品牌2·Z6III', '品牌2·Z5'],
        description: ''
      },
      {
        title: '品牌2·GFX系列',
        content: ['品牌2·GFX50SII', '品牌2·GFX100S', '品牌2·GFX100II', '品牌2·GFX50R', '品牌2·GFX100'],
        description: ''
      },
      {
        title: '品牌2·X系列',
        content: ['品牌2·X-T5', '品牌2·X-H2S', '品牌2·X-H2', '品牌2·X-S20', '品牌2·X-E4'],
        description: ''
      }
    ]
  }
  static cameraList5: ModelItemInfo = {
    label: '品牌3',
    content: [
      {
        title: '品牌3',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌3·EOS系列',
        content: ['品牌3·EOS600D', '品牌3·EOS600D', '品牌3·EOS600D', '品牌3·EOS600E',
          '品牌3·EOS600F'],
        description: ''
      },
      {
        title: '品牌3·α系列',
        content: ['品牌3·α7III', '品牌3·α7IV', '品牌3·α7RV', '品牌3·α7CII', '品牌3·α9III'],
        description: ''
      },
      {
        title: '品牌3·Z系列',
        content: ['品牌3·Z7II', '品牌3·Z8', '品牌3·Z9', '品牌3·Z6III', '品牌3·Z5'],
        description: ''
      },
      {
        title: '品牌3·GFX系列',
        content: ['品牌3·GFX50SII', '品牌3·GFX100S', '品牌3·GFX100II', '品牌3·GFX50R', '品牌3·GFX100'],
        description: ''
      },
      {
        title: '品牌3·X系列',
        content: ['品牌3·X-T5', '品牌3·X-H2S', '品牌3·X-H2', '品牌3·X-S20', '品牌3·X-E4'],
        description: ''
      }
    ]
  }
  static cameraList6: ModelItemInfo = {
    label: '品牌4',
    content: [
      {
        title: '品牌4',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌4·EOS系列',
        content: ['品牌4·EOS600D', '品牌4·EOS600D', '品牌4·EOS600D', '品牌4·EOS600E',
          '品牌4·EOS600F'],
        description: ''
      },
      {
        title: '品牌4·α系列',
        content: ['品牌4·α7III', '品牌4·α7IV', '品牌4·α7RV', '品牌4·α7CII', '品牌4·α9III'],
        description: ''
      },
      {
        title: '品牌4·Z系列',
        content: ['品牌4·Z7II', '品牌4·Z8', '品牌4·Z9', '品牌4·Z6III', '品牌4·Z5'],
        description: ''
      },
      {
        title: '品牌4·GFX系列',
        content: ['品牌4·GFX50SII', '品牌4·GFX100S', '品牌4·GFX100II', '品牌4·GFX50R', '品牌4·GFX100'],
        description: ''
      },
      {
        title: '品牌4·X系列',
        content: ['品牌4·X-T5', '品牌4·X-H2S', '品牌4·X-H2', '品牌4·X-S20', '品牌4·X-E4'],
        description: ''
      }
    ]
  }
  static cameraList7: ModelItemInfo = {
    label: '品牌5',
    content: [
      {
        title: '品牌5',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌5·EOS系列',
        content: ['品牌5·EOS600D', '品牌4·EOS600D', '品牌5·EOS600D', '品牌5·EOS600E',
          '品牌5·EOS600F'],
        description: ''
      },
      {
        title: '品牌5·α系列',
        content: ['品牌5·α7III', '品牌5·α7IV', '品牌5·α7RV', '品牌5·α7CII', '品牌5·α9III'],
        description: ''
      },
      {
        title: '品牌5·Z系列',
        content: ['品牌5·Z7II', '品牌5·Z8', '品牌5·Z9', '品牌5·Z6III', '品牌5·Z5'],
        description: ''
      },
      {
        title: '品牌5·GFX系列',
        content: ['品牌5·GFX50SII', '品牌5·GFX100S', '品牌5·GFX100II', '品牌5·GFX50R', '品牌5·GFX100'],
        description: ''
      },
      {
        title: '品牌5·X系列',
        content: ['品牌5·X-T5', '品牌5·X-H2S', '品牌5·X-H2', '品牌5·X-S20', '品牌5·X-E4'],
        description: ''
      }
    ]
  }
  static cameraList8: ModelItemInfo = {
    label: '品牌6',
    content: [
      {
        title: '品牌6',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌6·EOS系列',
        content: ['品牌6·EOS600D', '品牌6·EOS600D', '品牌6·EOS600D', '品牌6·EOS600E',
          '品牌6·EOS600F'],
        description: ''
      },
      {
        title: '品牌6·α系列',
        content: ['品牌6·α7III', '品牌6·α7IV', '品牌6·α7RV', '品牌6·α7CII', '品牌6·α9III'],
        description: ''
      },
      {
        title: '品牌6·Z系列',
        content: ['品牌6·Z7II', '品牌6·Z8', '品牌6·Z9', '品牌6·Z6III', '品牌6·Z5'],
        description: ''
      },
      {
        title: '品牌6·GFX系列',
        content: ['品牌6·GFX50SII', '品牌6·GFX100S', '品牌6·GFX100II', '品牌6·GFX50R', '品牌6·GFX100'],
        description: ''
      },
      {
        title: '品牌6·X系列',
        content: ['品牌6·X-T5', '品牌6·X-H2S', '品牌6·X-H2', '品牌6·X-S20', '品牌6·X-E4'],
        description: ''
      }
    ]
  }
  static cameraList9: ModelItemInfo = {
    label: '品牌7',
    content: [
      {
        title: '品牌7',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌7·EOS系列',
        content: ['品牌7·EOS600D', '品牌7·EOS600D', '品牌7·EOS600D', '品牌7·EOS600E',
          '品牌7·EOS600F'],
        description: ''
      },
      {
        title: '品牌7·α系列',
        content: ['品牌7·α7III', '品牌7·α7IV', '品牌7·α7RV', '品牌7·α7CII', '品牌7·α9III'],
        description: ''
      },
      {
        title: '品牌7·Z系列',
        content: ['品牌7·Z7II', '品牌7·Z8', '品牌7·Z9', '品牌7·Z6III', '品牌7·Z5'],
        description: ''
      },
      {
        title: '品牌7·GFX系列',
        content: ['品牌7·GFX50SII', '品牌7·GFX100S', '品牌7·GFX100II', '品牌7·GFX50R', '品牌7·GFX100'],
        description: ''
      },
      {
        title: '品牌7·X系列',
        content: ['品牌7·X-T5', '品牌7·X-H2S', '品牌7·X-H2', '品牌7·X-S20', '品牌7·X-E4'],
        description: ''
      }
    ]
  }
  static cameraList10: ModelItemInfo = {
    label: '品牌8',
    content: [
      {
        title: '品牌8',
        content: ['不限型号'],
        description: ''
      },
      {
        title: '品牌8·EOS系列',
        content: ['品牌8·EOS600D', '品牌8·EOS600D', '品牌8·EOS600D', '品牌8·EOS600E',
          '品牌8·EOS600F'],
        description: ''
      },
      {
        title: '品牌8·α系列',
        content: ['品牌8·α7III', '品牌8·α7IV', '品牌8·α7RV', '品牌8·α7CII', '品牌8·α9III'],
        description: ''
      },
      {
        title: '品牌8·Z系列',
        content: ['品牌8·Z7II', '品牌8·Z8', '品牌8·Z9', '品牌8·Z6III', '品牌8·Z5'],
        description: ''
      },
      {
        title: '品牌8·GFX系列',
        content: ['品牌8·GFX50SII', '品牌8·GFX100S', '品牌8·GFX100II', '品牌8·GFX50R', '品牌8·GFX100'],
        description: ''
      },
      {
        title: '品牌8·X系列',
        content: ['品牌8·X-T5', '品牌8·X-H2S', '品牌8·X-H2', '品牌8·X-S20', '品牌8·X-E4'],
        description: ''
      }
    ]
  }
  static cameraModelCategoryList: ModelItemInfo[] =
    [MockData.cameraList2, MockData.cameraList3, MockData.cameraList4, MockData.cameraList5,
      MockData.cameraList6, MockData.cameraList7,
      MockData.cameraList8, MockData.cameraList9, MockData.cameraList10]
  static classList2: SubCategoryItem[] = [{
    id: '2001',
    label: '手机品牌',
    itemList: [
      {
        id: '2001_1',
        title: '华为',
        imgSrc: 'img_huawei',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '2001_2',
        title: '品牌1',
        imgSrc: 'img_phone_brand',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '2001_3',
        title: '品牌2',
        imgSrc: 'img_phone_brand',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '2001_4',
        title: '品牌3',
        imgSrc: 'img_phone_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '2001_5',
        title: '品牌4',
        imgSrc: 'img_phone_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '2001_6',
        title: '品牌5',
        imgSrc: 'img_phone_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '2001_7',
        title: '品牌6',
        imgSrc: 'img_phone_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '2001_8',
        title: '品牌7',
        imgSrc: 'img_phone_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '2001_9',
        title: '品牌8',
        imgSrc: 'img_phone_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }];
  static classList3: SubCategoryItem[] = [{
    id: '3001',
    label: '平板品牌',
    itemList: [
      {
        id: '3001_1',
        title: '华为',
        imgSrc: 'img_huawei',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '3001_2',
        title: '品牌1',
        imgSrc: 'img_pad_brand',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '3001_3',
        title: '品牌2',
        imgSrc: 'img_pad_brand',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '3001_4',
        title: '品牌3',
        imgSrc: 'img_pad_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '3001_5',
        title: '品牌4',
        imgSrc: 'img_pad_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '3001_6',
        title: '品牌5',
        imgSrc: 'img_pad_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '3001_7',
        title: '品牌6',
        imgSrc: 'img_pad_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '3001_8',
        title: '品牌7',
        imgSrc: 'img_pad_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '3001_9',
        title: '品牌8',
        imgSrc: 'img_pad_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  static classList4: SubCategoryItem[] = [{
    id: '4001',
    label: '笔记本品牌',
    itemList: [
      {
        id: '4001_1',
        title: '华为',
        imgSrc: 'img_huawei',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '4001_2',
        title: '品牌1',
        imgSrc: 'img_notebook_brand',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '4001_3',
        title: '品牌2',
        imgSrc: 'img_notebook_brand',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '4001_4',
        title: '品牌3',
        imgSrc: 'img_notebook_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '4001_5',
        title: '品牌4',
        imgSrc: 'img_notebook_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '4001_6',
        title: '品牌5',
        imgSrc: 'img_notebook_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '4001_7',
        title: '品牌6',
        imgSrc: 'img_notebook_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '4001_8',
        title: '品牌7',
        imgSrc: 'img_notebook_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '4001_9',
        title: '品牌8',
        imgSrc: 'img_notebook_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  static classList5: SubCategoryItem[] = [{
    id: '5001',
    label: '手表品牌',
    itemList: [
      {
        id: '5001_2',
        title: '品牌1',
        imgSrc: 'img_watch_brand',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '5001_3',
        title: '品牌2',
        imgSrc: 'img_watch_brand',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '5001_4',
        title: '品牌3',
        imgSrc: 'img_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '5001_5',
        title: '品牌4',
        imgSrc: 'img_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '5001_6',
        title: '品牌5',
        imgSrc: 'img_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '5001_7',
        title: '品牌6',
        imgSrc: 'img_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '5001_8',
        title: '品牌7',
        imgSrc: 'img_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '5001_9',
        title: '品牌8',
        imgSrc: 'img_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '5001_10',
        title: '品牌9',
        imgSrc: 'img_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  static classList6: SubCategoryItem[] = [{
    id: '6001',
    label: '智能穿戴品牌',
    itemList: [
      {
        id: '6001_1',
        title: '华为',
        imgSrc: 'img_huawei',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '6001_2',
        title: '品牌1',
        imgSrc: 'img_smart_watch_brand',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '6001_3',
        title: '品牌2',
        imgSrc: 'img_smart_watch_brand',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '6001_4',
        title: '品牌3',
        imgSrc: 'img_smart_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '6001_5',
        title: '品牌4',
        imgSrc: 'img_smart_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '6001_6',
        title: '品牌5',
        imgSrc: 'img_smart_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '6001_7',
        title: '品牌6',
        imgSrc: 'img_smart_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '6001_8',
        title: '品牌7',
        imgSrc: 'img_smart_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '6001_9',
        title: '品牌8',
        imgSrc: 'img_smart_watch_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  static classList7: SubCategoryItem[] = [{
    id: '7001',
    label: '拍照摄像品牌',
    itemList: [
      {
        id: '7001_1',
        title: '华为',
        imgSrc: 'img_huawei',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '7001_2',
        title: '品牌1',
        imgSrc: 'img_camera_brand',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '7001_3',
        title: '品牌2',
        imgSrc: 'img_camera_brand',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '7001_4',
        title: '品牌3',
        imgSrc: 'img_camera_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '7001_5',
        title: '品牌4',
        imgSrc: 'img_camera_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '7001_6',
        title: '品牌5',
        imgSrc: 'img_camera_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '7001_7',
        title: '品牌6',
        imgSrc: 'img_camera_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '7001_8',
        title: '品牌7',
        imgSrc: 'img_camera_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '7001_9',
        title: '品牌8',
        imgSrc: 'img_camera_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  static classList8: SubCategoryItem[] = [{
    id: '8001',
    label: '无人机品牌',
    itemList: [
      {
        id: '8001_1',
        title: '华为',
        imgSrc: 'img_huawei',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: '品牌1',
        imgSrc: 'img_no_person_brand',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: '品牌2',
        imgSrc: 'img_no_person_brand',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: '品牌3',
        imgSrc: 'img_no_person_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: '品牌4',
        imgSrc: 'img_no_person_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: '品牌5',
        imgSrc: 'img_no_person_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: '品牌6',
        imgSrc: 'img_no_person_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: '品牌7',
        imgSrc: 'img_no_person_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: '品牌8',
        imgSrc: 'img_no_person_brand',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  static tabList: CategoryItem[] = [{
    id: '2',
    label: '手机',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '3',
    label: '平板',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '4',
    label: '笔记本',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '5',
    label: '手表',
    iconUrl: '',
  }, {
    id: '6',
    label: '智能穿戴',
    iconUrl: '',
  }, {
    id: '7',
    label: '拍照摄像',
  }, {
    id: '8',
    label: '无人机',
  }];
  // 手机品牌tab列表
  static phoneBrandTabList: CategoryItem[] = [
    {
      id: '2',
      label: '华为',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '3',
    label: '品牌1',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '4',
    label: '品牌2',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '5',
    label: '品牌3',
    iconUrl: '',
  }, {
    id: '6',
    label: '品牌4',
    iconUrl: '',
  }, {
    id: '7',
    label: '品牌5',
  }, {
    id: '8',
    label: '品牌6',
  },
    {
      id: '9',
      label: '品牌7',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '10',
    label: '品牌8',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '11',
    label: '品牌9',
    iconUrl: '',
  }, {
    id: '12',
    label: '品牌10',
    iconUrl: '',
  }, {
    id: '13',
    label: '品牌11',
  }, {
    id: '14',
    label: '品牌12',
  }
  ]
  // 平板品牌tab列表
  static padBrandTabList: CategoryItem[] = [
    {
      id: '2',
      label: '华为',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '3',
    label: '品牌1',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '4',
    label: '品牌2',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '5',
    label: '品牌3',
    iconUrl: '',
  }, {
    id: '6',
    label: '品牌4',
    iconUrl: '',
  }, {
    id: '7',
    label: '品牌5',
  }, {
    id: '8',
    label: '品牌6',
  },
    {
      id: '9',
      label: '品牌7',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '10',
    label: '品牌8',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '11',
    label: '品牌9',
    iconUrl: '',
  }, {
    id: '12',
    label: '品牌10',
    iconUrl: '',
  }, {
    id: '13',
    label: '品牌11',
  }, {
    id: '14',
    label: '品牌12',
  }
  ]
  // 笔记本品牌tab列表
  static notebookBrandTabList: CategoryItem[] = [
    {
      id: '2',
      label: '华为',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '3',
    label: '品牌1',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '4',
    label: '品牌2',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '5',
    label: '品牌3',
    iconUrl: '',
  }, {
    id: '6',
    label: '品牌4',
    iconUrl: '',
  }, {
    id: '7',
    label: '品牌5',
  }, {
    id: '8',
    label: '品牌6',
  },
    {
      id: '9',
      label: '品牌7',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '10',
    label: '品牌8',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '11',
    label: '品牌9',
    iconUrl: '',
  }, {
    id: '12',
    label: '品牌10',
    iconUrl: '',
  }, {
    id: '13',
    label: '品牌11',
  }, {
    id: '14',
    label: '品牌12',
  }
  ]
  // 手表品牌tab列表
  static watchBrandTabList: CategoryItem[] = [
    {
      id: '2',
      label: '品牌1',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '3',
    label: '品牌2',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '4',
    label: '品牌3',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '5',
    label: '品牌4',
    iconUrl: '',
  }, {
    id: '6',
    label: '品牌5',
    iconUrl: '',
  }, {
    id: '7',
    label: '品牌6',
  }, {
    id: '8',
    label: '品牌7',
  },
    {
      id: '9',
      label: '品牌7',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '10',
    label: '品牌8',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '11',
    label: '品牌9',
    iconUrl: '',
  }, {
    id: '12',
    label: '品牌10',
    iconUrl: '',
  }, {
    id: '13',
    label: '品牌11',
  }, {
    id: '14',
    label: '品牌12',
  }
  ]
  // 智能穿戴品牌tab列表
  static iWatchBrandTabList: CategoryItem[] = [
    {
      id: '2',
      label: '华为',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '3',
    label: '品牌1',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '4',
    label: '品牌2',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '5',
    label: '品牌3',
    iconUrl: '',
  }, {
    id: '6',
    label: '品牌4',
    iconUrl: '',
  }, {
    id: '7',
    label: '品牌5',
  }, {
    id: '8',
    label: '品牌6',
  },
    {
      id: '9',
      label: '品牌7',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '10',
    label: '品牌8',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '11',
    label: '品牌9',
    iconUrl: '',
  }, {
    id: '12',
    label: '品牌10',
    iconUrl: '',
  }, {
    id: '13',
    label: '品牌11',
  }, {
    id: '14',
    label: '品牌12',
  }
  ]
  // 拍照摄像品牌tab列表
  static cameraBrandTabList: CategoryItem[] = [
    {
      id: '2',
      label: '华为',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '3',
    label: '品牌1',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '4',
    label: '品牌2',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '5',
    label: '品牌3',
    iconUrl: '',
  }, {
    id: '6',
    label: '品牌4',
    iconUrl: '',
  }, {
    id: '7',
    label: '品牌5',
  }, {
    id: '8',
    label: '品牌6',
  },
    {
      id: '9',
      label: '品牌7',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '10',
    label: '品牌8',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '11',
    label: '品牌9',
    iconUrl: '',
  }, {
    id: '12',
    label: '品牌10',
    iconUrl: '',
  }, {
    id: '13',
    label: '品牌11',
  }, {
    id: '14',
    label: '品牌12',
  }
  ]
  // 无人机品牌tab列表
  static noPersonBrandTabList: CategoryItem[] = [
    {
      id: '2',
      label: '华为',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '3',
    label: '品牌1',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '4',
    label: '品牌2',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '5',
    label: '品牌3',
    iconUrl: '',
  }, {
    id: '6',
    label: '品牌4',
    iconUrl: '',
  }, {
    id: '7',
    label: '品牌5',
  }, {
    id: '8',
    label: '品牌6',
  },
    {
      id: '9',
      label: '品牌7',
      iconUrl: '',
      subCategoryId: [],
    }, {
    id: '10',
    label: '品牌8',
    iconUrl: '',
    subCategoryId: [],
  }, {
    id: '11',
    label: '品牌9',
    iconUrl: '',
  }, {
    id: '12',
    label: '品牌10',
    iconUrl: '',
  }, {
    id: '13',
    label: '品牌11',
  }, {
    id: '14',
    label: '品牌12',
  }
  ]
  // 手机型号列表1
  static phoneList1: SubCategoryItem[] = [{
    id: '8001',
    label: '华为手机·Mate系列',
    itemList: [
      {
        id: '8001_1',
        title: 'mate手机',
        imgSrc: 'image_demo_phone3',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'mate手机',
        imgSrc: 'image_demo_phone3',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'mate手机',
        imgSrc: 'image_demo_phone3',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'mate手机',
        imgSrc: 'image_demo_phone3',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'mate手机',
        imgSrc: 'image_demo_phone3',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'mate手机',
        imgSrc: 'image_demo_phone3',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'mate手机',
        imgSrc: 'image_demo_phone3',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'mate手机',
        imgSrc: 'image_demo_phone3',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'mate手机',
        imgSrc: 'image_demo_phone3',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 手机型号列表2
  static phoneList2: SubCategoryItem[] = [{
    id: '8001',
    label: '华为手机·Pro系列',
    itemList: [
      {
        id: '8001_1',
        title: 'pro手机',
        imgSrc: 'image_demo_phone2',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'pro手机',
        imgSrc: 'image_demo_phone2',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'pro手机',
        imgSrc: 'image_demo_phone2',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'pro手机',
        imgSrc: 'image_demo_phone2',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'pro手机',
        imgSrc: 'image_demo_phone2',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'pro手机',
        imgSrc: 'image_demo_phone2',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'pro手机',
        imgSrc: 'image_demo_phone2',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'pro手机',
        imgSrc: 'image_demo_phone2',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'pro手机',
        imgSrc: 'image_demo_phone2',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 平板型号列表1
  static padList1: SubCategoryItem[] = [{
    id: '8001',
    label: '华为平板·Pro系列',
    itemList: [
      {
        id: '8001_1',
        title: 'pro平板',
        imgSrc: 'img_demo_padA',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'pro平板',
        imgSrc: 'img_demo_padA',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'pro平板',
        imgSrc: 'img_demo_padA',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'pro平板',
        imgSrc: 'img_demo_padA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'pro平板',
        imgSrc: 'img_demo_padA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'pro平板',
        imgSrc: 'img_demo_padA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'pro平板',
        imgSrc: 'img_demo_padA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'pro平板',
        imgSrc: 'img_demo_padA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'pro平板',
        imgSrc: 'img_demo_padA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 平板型号列表2
  static padList2: SubCategoryItem[] = [{
    id: '8001',
    label: '华为平板·Max系列',
    itemList: [
      {
        id: '8001_1',
        title: 'max平板',
        imgSrc: 'img_demo_padB',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'max平板',
        imgSrc: 'img_demo_padB',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'max平板',
        imgSrc: 'img_demo_padB',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'max平板',
        imgSrc: 'img_demo_padB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'max平板',
        imgSrc: 'img_demo_padB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'max平板',
        imgSrc: 'img_demo_padB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'max平板',
        imgSrc: 'img_demo_padB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'max平板',
        imgSrc: 'img_demo_padB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'max平板',
        imgSrc: 'img_demo_padB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 笔记本型号列表1
  static notebookList1: SubCategoryItem[] = [{
    id: '8001',
    label: '华为笔记本·Pro系列',
    itemList: [
      {
        id: '8001_1',
        title: 'pro笔记本',
        imgSrc: 'img_demo_notebookA',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'pro笔记本',
        imgSrc: 'img_demo_notebookA',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'pro笔记本',
        imgSrc: 'img_demo_notebookA',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'pro笔记本',
        imgSrc: 'img_demo_notebookA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'pro笔记本',
        imgSrc: 'img_demo_notebookA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'pro笔记本',
        imgSrc: 'img_demo_notebookA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'pro笔记本',
        imgSrc: 'img_demo_notebookA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'pro笔记本',
        imgSrc: 'img_demo_notebookA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'pro笔记本',
        imgSrc: 'img_demo_notebookA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 笔记本型号列表2
  static notebookList2: SubCategoryItem[] = [{
    id: '8001',
    label: '华为笔记本·Max系列',
    itemList: [
      {
        id: '8001_1',
        title: 'max笔记本',
        imgSrc: 'img_demo_notebookB',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'max笔记本',
        imgSrc: 'img_demo_notebookB',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'max笔记本',
        imgSrc: 'img_demo_notebookB',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'max笔记本',
        imgSrc: 'img_demo_notebookB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'max笔记本',
        imgSrc: 'img_demo_notebookB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'max笔记本',
        imgSrc: 'img_demo_notebookB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'max笔记本',
        imgSrc: 'img_demo_notebookB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'max笔记本',
        imgSrc: 'img_demo_notebookB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'max笔记本',
        imgSrc: 'img_demo_notebookB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 手表型号列表1
  static watchList1: SubCategoryItem[] = [{
    id: '8001',
    label: '高档手表·Pro系列',
    itemList: [
      {
        id: '8001_1',
        title: 'pro手表',
        imgSrc: 'img_demo_watchA',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'pro手表',
        imgSrc: 'img_demo_watchA',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'pro手表',
        imgSrc: 'img_demo_watchA',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'pro手表',
        imgSrc: 'img_demo_watchA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'pro手表',
        imgSrc: 'img_demo_watchA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'pro手表',
        imgSrc: 'img_demo_watchA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'pro手表',
        imgSrc: 'img_demo_watchA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'pro手表',
        imgSrc: 'img_demo_watchA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'pro手表',
        imgSrc: 'img_demo_watchA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 手表型号列表2
  static watchList2: SubCategoryItem[] = [{
    id: '8001',
    label: '中高档手表·Max系列',
    itemList: [
      {
        id: '8001_1',
        title: 'max手表',
        imgSrc: 'img_demo_watchB',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'max手表',
        imgSrc: 'img_demo_watchB',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'max手表',
        imgSrc: 'img_demo_watchB',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'max手表',
        imgSrc: 'img_demo_watchB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'max手表',
        imgSrc: 'img_demo_watchB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'max手表',
        imgSrc: 'img_demo_watchB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'max手表',
        imgSrc: 'img_demo_watchB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'max手表',
        imgSrc: 'img_demo_watchB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'max手表',
        imgSrc: 'img_demo_watchB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 智能穿戴型号列表1
  static iWatchList1: SubCategoryItem[] = [{
    id: '8001',
    label: '华为智能穿戴·Pro系列',
    itemList: [
      {
        id: '8001_1',
        title: 'pro智能穿戴',
        imgSrc: 'img_demo_iWatchA',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'pro智能穿戴',
        imgSrc: 'img_demo_iWatchA',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'pro智能穿戴',
        imgSrc: 'img_demo_iWatchA',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'pro智能穿戴',
        imgSrc: 'img_demo_iWatchA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'pro智能穿戴',
        imgSrc: 'img_demo_iWatchA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'pro智能穿戴',
        imgSrc: 'img_demo_iWatchA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'pro智能穿戴',
        imgSrc: 'img_demo_iWatchA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'pro智能穿戴',
        imgSrc: 'img_demo_iWatchA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'pro智能穿戴',
        imgSrc: 'img_demo_iWatchA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 智能穿戴型号列表2
  static iWatchList2: SubCategoryItem[] = [{
    id: '8001',
    label: '华为智能穿戴·Max系列',
    itemList: [
      {
        id: '8001_1',
        title: 'max智能穿戴',
        imgSrc: 'img_demo_iWatchB',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'max智能穿戴',
        imgSrc: 'img_demo_iWatchB',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'max智能穿戴',
        imgSrc: 'img_demo_iWatchB',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'max智能穿戴',
        imgSrc: 'img_demo_iWatchB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'max智能穿戴',
        imgSrc: 'img_demo_iWatchB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'max智能穿戴',
        imgSrc: 'img_demo_iWatchB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'max智能穿戴',
        imgSrc: 'img_demo_iWatchB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'max智能穿戴',
        imgSrc: 'img_demo_iWatchB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'max智能穿戴',
        imgSrc: 'img_demo_iWatchB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 拍照摄像型号列表1
  static cameraProductList1: SubCategoryItem[] = [{
    id: '8001',
    label: '华为相机·Pro系列',
    itemList: [
      {
        id: '8001_1',
        title: 'pro华为相机',
        imgSrc: 'img_demo_cameraA',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'pro华为相机',
        imgSrc: 'img_demo_cameraA',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'pro华为相机',
        imgSrc: 'img_demo_cameraA',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'pro华为相机',
        imgSrc: 'img_demo_cameraA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'pro华为相机',
        imgSrc: 'img_demo_cameraA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'pro华为相机',
        imgSrc: 'img_demo_cameraA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'pro华为相机',
        imgSrc: 'img_demo_cameraA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'pro华为相机',
        imgSrc: 'img_demo_cameraA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'pro华为相机',
        imgSrc: 'img_demo_cameraA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 拍照摄像型号列表2
  static cameraProductList2: SubCategoryItem[] = [{
    id: '8001',
    label: '华为相机·Max系列',
    itemList: [
      {
        id: '8001_1',
        title: 'max华为相机',
        imgSrc: 'img_demo_cameraB',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'max华为相机',
        imgSrc: 'img_demo_cameraB',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'max华为相机',
        imgSrc: 'img_demo_cameraB',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'max华为相机',
        imgSrc: 'img_demo_cameraB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'max华为相机',
        imgSrc: 'img_demo_cameraB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'max华为相机',
        imgSrc: 'img_demo_cameraB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'max华为相机',
        imgSrc: 'img_demo_cameraB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'max华为相机',
        imgSrc: 'img_demo_cameraB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'max华为相机',
        imgSrc: 'img_demo_cameraB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 无人机型号列表1
  static noPersonProductList1: SubCategoryItem[] = [{
    id: '8001',
    label: '华为无人机·Pro系列',
    itemList: [
      {
        id: '8001_1',
        title: 'pro华为无人机',
        imgSrc: 'img_demo_no_personA',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'pro华为无人机',
        imgSrc: 'img_demo_no_personA',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'pro华为无人机',
        imgSrc: 'img_demo_no_personA',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'pro华为无人机',
        imgSrc: 'img_demo_no_personA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'pro华为无人机',
        imgSrc: 'img_demo_no_personA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'pro华为无人机',
        imgSrc: 'img_demo_no_personA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'pro华为无人机',
        imgSrc: 'img_demo_no_personA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'pro华为无人机',
        imgSrc: 'img_demo_no_personA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'pro华为无人机',
        imgSrc: 'img_demo_no_personA',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
  // 无人机型号列表2
  static noPersonProductList2: SubCategoryItem[] = [{
    id: '8001',
    label: '华为无人机·Max系列',
    itemList: [
      {
        id: '8001_1',
        title: 'max华为无人机',
        imgSrc: 'img_demo_no_personB',
        description: '色泽红亮，甜香可口的家常美食。'
      },
      {
        id: '8001_2',
        title: 'max华为无人机',
        imgSrc: 'img_demo_no_personB',
        description: '经典的中式家常菜，鸡肉鲜嫩，花生米香脆，口味香辣酸甜。'
      },
      {
        id: '8001_3',
        title: 'max华为无人机',
        imgSrc: 'img_demo_no_personB',
        description: '具有鱼香味的经典川菜，肉丝鲜嫩，配菜丰富。'
      },
      {
        id: '8001_4',
        title: 'max华为无人机',
        imgSrc: 'img_demo_no_personB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_5',
        title: 'max华为无人机',
        imgSrc: 'img_demo_no_personB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_6',
        title: 'max华为无人机',
        imgSrc: 'img_demo_no_personB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_7',
        title: 'max华为无人机',
        imgSrc: 'img_demo_no_personB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_8',
        title: 'max华为无人机',
        imgSrc: 'img_demo_no_personB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      },
      {
        id: '8001_9',
        title: 'max华为无人机',
        imgSrc: 'img_demo_no_personB',
        description: '色泽红亮，口味酸甜的经典家常菜。'
      }],
  }]
}