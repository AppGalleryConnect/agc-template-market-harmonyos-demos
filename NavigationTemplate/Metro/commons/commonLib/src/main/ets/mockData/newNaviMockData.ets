export interface newStation{
  line:string[]
  currentLine:string
  name:string
  latitude:number
  longitude:number
  firstTime:string
  lastTime:string
  reverseFirstTime?:string
  reverseLastTime?:string
  infrastructure:infrastructure[]
  serial:number,
}
export interface infrastructure{
  name:string
  address:string
  image:Resource
}
const infrastructures:infrastructure[] = [
  {
    name:'洗手间',
    address:'1号口出口电梯右手边',
    image:$r('app.media.washroom')
  },
  {
    name:'无障碍电梯',
    address:'1号站台与3号站台',
    image:$r('app.media.barrierFreeElevator')
  },
  {
    name:'医务室',
    address:'1号站台左转指示牌处',
    image:$r('app.media.emergency')
  }
]

const lineForLine1: string[][] = [['1号线'], ['1号线'], ['1号线'], ['1号线'], ['1号线'], ['1号线'], ['1号线'], ['1号线'],
  ['1号线'], ['1号线'], ['1号线', '4号线'], ['1号线'], ['1号线', '2号线'], ['1号线'], ['1号线'],
  ['1号线'], ['1号线', '10号线'], ['1号线'], ['1号线'], ['1号线'], ['1号线','3号线','S1号线','S3号线'], ['1号线'], ['1号线'],
  ['1号线'], ['1号线'], ['1号线'], ['1号线'], ['1号线'], ['1号线'], ['1号线', '5号线'], ['1号线'],
  ['1号线'], ['1号线']]
const nameForLine1: string[] = [
  '八卦洲大桥南', '笆斗山', '燕子矶', '吉祥庵', '晓庄', '迈皋桥', '红山动物园', '南京站',
  '新模范马路', '玄武门', '鼓楼', '珠江路', '新街口', '张府园', '三山街', '中华门', '安德门',
  '天隆寺', '软件大道', '花神庙', '南京南站', '双龙大道', '河定桥', '胜太路', '百家湖', '小龙湾',
  '竹山路', '天印大道', '龙眠大道', '南医大·江苏经贸学院', '南京交院', '中国药科大学'
];
const latitudeForLine1: number[] = [
  32.1456125, 32.143253, 32.1360475, 32.1267186, 32.1179223, 32.10246, 32.09598, 32.08696,
  32.07998, 32.070314, 32.0586816, 32.0511203, 32.0404537, 32.03083, 32.02307, 32.00668, 31.99203,
  31.9792, 31.97721, 31.97789, 31.968745181626446, 31.9639653, 31.95119, 31.9438813, 31.9321, 31.9296,
  31.932, 31.9377, 31.93992, 31.93352, 31.9127905, 31.89768
];
const longitudeForLine1: number[] = [
  118.8424186, 118.8294176, 118.8215899, 118.821299, 118.8182562, 118.80955, 118.80224, 118.7964,
  118.7841059, 118.7840872, 118.7837133, 118.7840782, 118.7840835, 118.78411, 118.78162, 118.77446,
  118.76177, 118.76307, 118.77462, 118.78571, 118.79803854232787, 118.8172107, 118.82031, 118.8215348,
  118.82152, 118.83278, 118.84453, 118.86351, 118.87707, 118.8902, 118.9048864, 118.91412
];
const firstTimeForLine1: string[] = [
  '05:30', '05:32', '05:34', '05:36', '05:38', '05:42', '05:44', '05:46', '05:49', '05:51', '05:53',
  '05:55', '05:58', '06:00', '06:01', '06:04', '06:08', '06:10', '06:12', '06:14', '06:17', '06:20',
  '06:22', '06:24', '06:26', '06:29', '06:31', '06:34', '06:36', '06:38', '06:41', '无'
];
const lastTimeForLine1: string[] = [
  '23:08', '23:10', '23:12', '23:14', '23:16', '23:19', '23:21', '23:23', '23:26', '23:28', '23:30',
  '23:32', '23:34', '23:36', '23:38', '23:41', '23:44', '23:46', '23:49', '23:51', '23:54', '23:57',
  '23:59', '00:01', '00:03', '00:05', '00:07', '00:10', '00:12', '00:14', '00:18', '23:27'
];
const reverseFirstTimeForLine1: string[] = [
  '无', '07:01', '06:59', '06:57', '06:55', '无', '06:48', '06:46', '06:43', '06:41', '06:39', '06:37',
  '06:35', '06:32', '06:30', '06:28', '06:24', '06:21', '06:19', '06:17', '06:14', '06:11', '06:08',
  '06:07', '06:04', '06:02', '06:00', '05:57', '05:55', '05:52', '05:49', '05:47'
];
const reverseLastTimeForLine1: string[] = [
  '无', '00:40', '00:38', '00:36', '00:34', '无', '00:28', '00:25', '00:22', '00:20', '00:18', '00:16',
  '00:14', '00:12', '00:10', '00:07', '00:04', '00:01','23:59', '23:57', '23:54', '23:51', '23:48', '23:47',
  '23:44', '23:42', '23:40', '23:37', '23:35', '23:32', '23:29', '23:27'
];

const lineForLine2: string[][] = [
  ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'],
  ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'],
  ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'],
  ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线'], ['2号线']
];
const nameForLine2: string[] = [
  '鱼嘴', '天保街', '螺塘路', '油坊桥', '雨润大街', '元通', '奥体东', '兴隆大街', '集庆门大街', '云锦路',
  '莫愁湖', '汉中门', '上海路', '新街口', '大行宫', '西安门', '明故宫', '苜蓿园', '下马坊', '孝陵卫',
  '钟灵街', '马群', '金马路', '仙鹤门', '学则路', '仙林中心', '羊山公园', '羊山公园', '经天路'
];
const latitudeForLine2: number[] = [
  31.967596, 31.9659737, 31.9607012,
  31.96631, 31.98367, 31.9958651,
  32.00471, 32.01552, 32.0282617,
  32.03497, 32.0373434, 32.04276,
  32.04229, 32.0404537, 32.04101,
  32.0403, 32.03927, 32.04,
  32.0373283, 32.0355, 32.03915,
  32.0496155, 32.0713399, 32.08497,
  32.09141, 32.09885, 32.10393,
  32.1086752, 32.11623
];
const longitudeForLine2: number[] = [
  118.6687481, 118.6784873, 118.7016105,
  118.72132, 118.72259, 118.7215151,
  118.72893, 118.73607, 118.7396148,
  118.74755, 118.7588328, 118.76701,
  118.77612, 118.7840835, 118.79463,
  118.80573, 118.81964, 118.83494,
  118.8489918, 118.85843, 118.8694,
  118.8949104, 118.9059264, 118.90484,
  118.9168, 118.93039, 118.94006,
  118.9597271, 118.97661
];
const firstTimeForLine2: string[] = [
  '06:00', '06:19', '06:05', '06:00', '06:03', '06:06', '06:08', '06:10', '06:00', '06:02',
  '06:05', '06:07', '06:09', '06:11', '06:13', '06:15', '06:17', '06:19', '06:21', '06:23',
  '06:25', '06:00', '06:03', '06:06', '06:08', '06:10', '06:12', '06:15', '06:17', '06:19',
  '06:21', '06:23', '06:25', '06:00'
];
const lastTimeForLine2: string[] = [
  '23:00', '00:06', '23:06', '23:10', '23:13', '23:16', '23:18', '23:20', '23:22', '23:25',
  '23:28', '23:30', '23:32', '23:33', '23:35', '23:37', '23:40', '23:42', '23:44', '23:46',
  '23:48', '23:52', '23:55', '23:58', '00:00', '00:02', '00:04', '00:07', '00:07', '00:10',
  '00:12', '00:14', '00:16', '23:17'
];
const reverseFirstTimeForLine2: string[] = [
  '无', '06:19', '06:16', '06:12', '06:09', '06:06', '06:04', '06:02', '06:00', '06:06',
  '06:03', '06:01', '06:00', '06:08', '06:06', '06:04', '06:02', '06:07', '06:05', '06:02',
  '06:00', '06:13', '06:11', '06:09', '06:06', '06:09', '06:06', '06:02', '06:02', '06:03',
  '06:00', '06:04', '06:02', '06:00'
];
const reverseLastTimeForLine2: string[] = [
  '无', '00:06', '00:02', '23:59', '23:55', '23:53', '23:51', '23:49', '23:46', '23:43',
  '23:41', '23:39', '23:37', '23:36', '23:33', '23:31', '23:29', '23:27', '23:25', '23:23',
  '23:21', '23:17', '23:13', '23:11', '23:09', '23:06', '23:04', '23:02', '22:59', '23:02',
  '23:00', '22:58', '22:57', '23:17'
];

function setLine(lineForLine:string[][], currentLine:string, nameForLine:string[],
  latitudeForLine:number[], longitudeForLine:number[], firstTimeForLine:string[],
  lastTimeForLine:string[], reverseFirstTimeForLine:string[], reverseLastTimeForLine:string[],
  infrastructures:infrastructure[],isReverse:boolean):newStation[]{
  let lines:newStation[] = []
  let count:number = 0
  if (!isReverse) {
    for (let i = 0; i < nameForLine.length; i++) {
      let line:newStation = {
        line:lineForLine[i],
        currentLine:currentLine,
        name : nameForLine[i],
        latitude : latitudeForLine[i],
        longitude : longitudeForLine[i],
        firstTime : firstTimeForLine[i],
        lastTime : lastTimeForLine[i],
        reverseFirstTime : reverseFirstTimeForLine[i],
        reverseLastTime : reverseLastTimeForLine[i],
        infrastructure : infrastructures,
        serial : i
      }
      lines.push(line)
    }
  }else {
    for (let i = nameForLine.length-1; i > -1; i--) {
      let line:newStation = {
        line: lineForLine[i],
        currentLine: currentLine,
        name: nameForLine[i],
        latitude: latitudeForLine[i],
        longitude: longitudeForLine[i],
        firstTime: reverseFirstTimeForLine[i],
        lastTime: reverseFirstTimeForLine[i],
        reverseFirstTime: firstTimeForLine[i],
        reverseLastTime: lastTimeForLine[i],
        infrastructure: infrastructures,
        serial: count
      }
      lines.push(line)
      count++
    }
  }
  return lines
}

const line1:newStation[] = setLine(lineForLine1, '1号线', nameForLine1, latitudeForLine1,
  longitudeForLine1,firstTimeForLine1,lastTimeForLine1,
  reverseFirstTimeForLine1, reverseLastTimeForLine1,infrastructures,false)

const line1Reverse:newStation[] = setLine(lineForLine1, '1号线', nameForLine1, latitudeForLine1,
  longitudeForLine1,firstTimeForLine1,lastTimeForLine1,
  reverseFirstTimeForLine1, reverseLastTimeForLine1,infrastructures,true)

const line2:newStation[] = setLine(lineForLine2, '2号线', nameForLine2, latitudeForLine2,
  longitudeForLine2,firstTimeForLine2,lastTimeForLine2,
  reverseFirstTimeForLine2, reverseLastTimeForLine2,infrastructures,false)

const line2Reverse:newStation[] = setLine(lineForLine2, '2号线', nameForLine2, latitudeForLine2,
  longitudeForLine2,firstTimeForLine2,lastTimeForLine2,
  reverseFirstTimeForLine2, reverseLastTimeForLine2,infrastructures,true)


export const newStations: Array<newStation[]> = [
  line1, line2
]

export const newStationsReverse: Array<newStation[]> = [
  line1Reverse,line2Reverse
]

export const linesName:string[] = [
  '1号线','2号线','S1号线','S3号线'
]

export const stationsName:Set<string> = new Set()
for (let item of newStations) {
  for (let station of item) {
    stationsName.add(station.name)
  }
}