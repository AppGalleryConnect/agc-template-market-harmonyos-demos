let myHandler = async function (event, context, callback, logger) {
  logger.info(event);

  const CLOUD_STORAGE_DOMAIN =
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-ta7go/comprehensive-mall%2F';

  const SUB_CATEGORY = [
    {
      id: '1001',
      label: '女士经典',
    },
    {
      id: '1002',
      label: '男士经典',
    },
    {
      id: '1003',
      label: '儿童',
    },
  ];

  let resp = {
    code: 0,
    categoryList: [
      {
        id: '1',
        label: '精选',
        iconUrl: CLOUD_STORAGE_DOMAIN + 'icon1.png',
        subCategory: SUB_CATEGORY,
      },
      {
        id: '2',
        label: '清洁用品',
        iconUrl: CLOUD_STORAGE_DOMAIN + 'icon2.png',
        subCategory: SUB_CATEGORY,
      },
      {
        id: '3',
        label: '全棉用品',
        iconUrl: CLOUD_STORAGE_DOMAIN + 'icon3.png',
        subCategory: SUB_CATEGORY,
      },
      {
        id: '4',
        label: '安睡香氛',
        iconUrl: CLOUD_STORAGE_DOMAIN + 'icon4.png',
      },
      {
        id: '5',
        label: '福利',
        subCategory: SUB_CATEGORY,
        iconUrl: CLOUD_STORAGE_DOMAIN + 'icon5.png',
      },
      {
        id: '6',
        label: '运动休闲',
        iconUrl: CLOUD_STORAGE_DOMAIN + 'icon6.png',
      },
      {
        id: '7',
        label: '成人服装',
        iconUrl: CLOUD_STORAGE_DOMAIN + 'icon7.png',
      },
      {
        id: '8',
        label: '折扣商品',
        iconUrl: CLOUD_STORAGE_DOMAIN + 'icon8.png',
      },
      {
        id: '9',
        label: '美妆彩妆',
        iconUrl: CLOUD_STORAGE_DOMAIN + 'icon9.png',
      },
      {
        id: '10',
        label: '饰品首饰',
        iconUrl: CLOUD_STORAGE_DOMAIN + 'icon10.png',
      },
    ],
    searchList: [
      '时尚轻商务系列',
      '秋季穿搭',
      '针织',
      '衬衫',
    ],
    bannerList: [
      CLOUD_STORAGE_DOMAIN + 'mock_homepage_banner1.png',
      CLOUD_STORAGE_DOMAIN + 'mock_homepage_banner2.jpg',
    ],
  };
  callback(resp);
};

module.exports.myHandler = myHandler;
