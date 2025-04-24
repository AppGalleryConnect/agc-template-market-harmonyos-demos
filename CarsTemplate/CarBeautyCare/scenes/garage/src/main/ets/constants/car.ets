export interface CarType{
  id:number;
  name: string;
  logoUrl: Resource;
  initial: string;
}

export interface CarGroupType {
  type: string;
  data: CarType[];
}

export const carData:CarGroupType[] = [
  {
    type: 'A',
    data: [
      {
        'id': 9,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'A'
      },
    ]
  },
  {
    type: 'B',
    data: [
      {
        'id': 2,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'B'
      },
      {
        'id': 15,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'B'
      },
      {
        'id': 26,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'B'
      },
      {
        'id': 3,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'B'
      },
      {
        'id': 127,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'B'
      },
      {
        'id': 10166,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'B'
      }
    ]
  },
  {
    type: 'C',
    data: [
      {
        'id': 136,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'C'
      },
    ]
  },
  {
    type: 'D',
    data: [
      {
        'id': 8,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'D'
      },
    ]
  },
  {
    type:  'F',
    data: [
      {
        'id': 7,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'F'
      },
    ]
  },
  {
    type: 'H',
    data: [
      {
        'id': 58,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'H'
      },
    ]
  },
  {
    type: 'J',
    data: [
      {
        'id': 34,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'J'
      },
      {
        'id': 296,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'J'
      },
    ]
  },
  {
    type: 'Q',
    data: [
      {
        'id': 42,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'Q'
      },
    ]
  },
  {
    type: 'R',
    data: [
      {
        'id': 30,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'R'
      },
    ]
  },
  {
    type: 'W',
    data: [
      {
        'id': 48,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'W'
      },
    ]
  },
  {
    type: 'X',
    data: [
      {
        'id': 702,
        'name': '品牌',
        'logoUrl': $r('app.media.car_common_icon'),
        'initial': 'X'
      },
    ]
  }
]

export const HOT_CAR:CarType[] = [
  {
    'id': 9,
    'name': '品牌',
    'logoUrl': $r('app.media.car_common_icon'),
    'initial': 'A'
  },
  {
    'id': 2,
    'name': '品牌',
    'logoUrl': $r('app.media.car_common_icon'),
    'initial': 'B'
  },
  {
    'id': 26,
    'name': '品牌',
    'logoUrl': $r('app.media.car_common_icon'),
    'initial': 'B'
  },
  {
    'id': 3,
    'name': '品牌',
    'logoUrl': $r('app.media.car_common_icon'),
    'initial': 'B'
  },
  {
    'id': 127,
    'name': '品牌',
    'logoUrl': $r('app.media.car_common_icon'),
    'initial': 'B'
  },
  {
    'id': 8,
    'name': '品牌',
    'logoUrl': $r('app.media.car_common_icon'),
    'initial': 'D'
  },
  {
    'id': 7,
    'name': '品牌',
    'logoUrl': $r('app.media.car_common_icon'),
    'initial': 'F'
  },
  {
    'id': 58,
    'name': '品牌',
    'logoUrl': $r('app.media.car_common_icon'),
    'initial': 'H'
  },
  {
    'id': 30,
    'name': '品牌',
    'logoUrl': $r('app.media.car_common_icon'),
    'initial': 'R'
  },
  {
    'id': 136,
    'name': '品牌',
    'logoUrl': $r('app.media.car_common_icon'),
    'initial': 'C'
  },
]

// AlphabetIndexer字母索引
export const ALPHABET_VALUE = ['热', 'A', 'B', 'C', 'D', 'F', 'H', 'J' ,'Q', 'R', 'W', 'X'];