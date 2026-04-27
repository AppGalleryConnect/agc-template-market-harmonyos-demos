import { FilterTypeInterface } from './Types';

export const FILTER_TYPE_LIST: FilterTypeInterface[] = [
  {
    id: 'size',
    label: '尺码',
    mutiple: true,
    options: [
      {
        key: 'all',
        label: '全部',
      },
      {
        key: 'xxs',
        label: 'XXS',
      },
      {
        key: 'xs',
        label: 'XS',
      },
      {
        key: 's',
        label: 'S',
      },
      {
        key: 'm',
        label: 'M',
      },
      {
        key: 'l',
        label: 'L',
      },
      {
        key: 'xl',
        label: 'XL',
      },
      {
        key: 'xxl',
        label: 'XXL',
      },
      {
        key: 'xxl+',
        label: 'XXL以上',
      },
    ],
  },
  {
    id: 'price',
    label: '价格',
    options: [
      {
        key: 'all',
        label: '全部',
      },
      {
        key: '1-100',
        label: '1-100',
      },
      {
        key: '101-500',
        label: '101-500',
      },
      {
        key: '501-1000',
        label: '501-1000',
      },
      {
        key: '1001-2000',
        label: '1001-2000',
      },
      {
        key: '2001+',
        label: '2001以上',
      },
    ],
  },
  {
    id: 'place',
    label: '发货地',
    options: [
      {
        key: 'all',
        label: '全部',
      },
      {
        key: 'place_001',
        label: '江浙沪',
      },
      {
        key: 'place_002',
        label: '珠三角',
      },
      {
        key: 'place_003',
        label: '港澳台',
      },
      {
        key: 'place_004',
        label: '海外',
      },
      {
        key: 'others',
        label: '其他',
      },
    ],
  },
];
