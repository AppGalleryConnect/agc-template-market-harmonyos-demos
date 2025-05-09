import { SearchSet } from 'common';
import { getDataFromJSON } from 'common';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

export function generateRandomNumber(minNum: number, maxNum: number): number {
  let rand = cryptoFramework.createRandom();
  let randData = rand.generateRandomSync(4)
  if(randData!==null){
    let randBuffer = new Uint32Array(randData.data.buffer);
    let randomValue = randBuffer[0] / 0xFFFFFFFF;
    return Math.floor(randomValue * (maxNum - minNum + 1)) + minNum
  } else{
    console.log('生成随机数失败');
    return 0;
  }
}

export class BusStationRandom {
  public busLineName: string | undefined = undefined;
  public busRand: number = 0;
  public busStation: string = '';
  public busSetItems: SearchSet[] = [];
  public busStationRandom: string[] = [];

  constructor(busLineName: string) {
    this.busLineName = busLineName
    this.busSetItems = getDataFromJSON<SearchSet>('Bus_Station.json', this);
    this.getLineStationName()
  }

  getLineStationName() {
    for (let i = 0; i < this.busSetItems.length; i++) {
      if (this.busLineName === this.busSetItems[i].lineName) {
        this.busStationRandom.push(this.busSetItems[i].stationName)
      }
    }
    this.busRand = generateRandomNumber(0, this.busStationRandom.length - 1)
  }
}