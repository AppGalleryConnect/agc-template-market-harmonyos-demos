import { cryptoFramework } from '@kit.CryptoArchitectureKit';

export class RandomCountdown {
  public generateRandomNumber(minNum: number, maxNum: number): number { // 整数随机数
    let rand = cryptoFramework.createRandom();
    let randData = rand.generateRandomSync(4)
    if(randData!==null){
      let randBuffer = new Uint32Array(randData.data.buffer);
      let randomValue = randBuffer[0] / 0xFFFFFFFF;
      return Math.floor(randomValue * (maxNum - minNum + 1)) + minNum
    }else{
      console.log('生成随机数失败');
      return 0;
    }
  }

  public generateRandomDecimalNumber(minNum: number, maxNum: number, decimalPlaces: number): number { // 小数随机数
    let rand = cryptoFramework.createRandom();
    const randomBytes = rand.generateRandom(16);
    const random = Number(rand.generateRandomSync(2))
    const range = maxNum - minNum;
    const multiplier = Math.pow(10, decimalPlaces);
    return Math.round(Math.floor((random * (range + 1)) * multiplier) / multiplier + minNum);
  }

  public line: string = ''
  public nearestFirstStation: number = this.generateRandomNumber(2, 7)
  public nearestFirstMin: number = this.generateRandomNumber(2, 10)
  public nearestFirstDis: number = this.generateRandomNumber(2, 10)
  public nearestSecondStation: number = this.generateRandomNumber(7, 10)
  public nearestSecondMin: number = this.generateRandomNumber(10, 15)
  public nearestSecondDis: number = this.generateRandomNumber(10, 15)
  public nearestThirdStation: number = this.generateRandomNumber(15, 20)
  public nearestThirdMin: number = this.generateRandomNumber(15, 20)
  public nearestThirdDis: number = this.generateRandomNumber(15, 20)

  constructor(line: string) {
    this.line = line;
    // this.countdown()
  }

  // countdown() {
  //   setInterval(() => { // 倒计时
  //     if (this.nearestFirstMin === 0 || this.nearestFirstStation === 0 || this.nearestFirstDis === 0) {
  //       this.nearestFirstStation = this.nearestSecondStation
  //       this.nearestFirstMin = this.nearestSecondMin
  //       this.nearestFirstDis = this.nearestSecondDis
  //       this.nearestSecondStation = this.nearestThirdStation
  //       this.nearestSecondMin = this.nearestThirdMin
  //       this.nearestSecondDis = this.nearestThirdDis
  //       this.nearestThirdStation = this.generateRandomNumber(15, 20)
  //       this.nearestThirdMin = this.generateRandomNumber(15, 20)
  //       this.nearestThirdDis = this.generateRandomDecimalNumber(6.0, 8.0, 1)
  //     }
  //     if (this.nearestFirstStation > 0) {
  //       this.nearestFirstStation--
  //       console.log(`last1station=========${JSON.stringify(this.line+'|'+this.nearestFirstStation)}`)
  //     }
  //     if (this.nearestFirstMin > 0) {
  //       this.nearestFirstMin--
  //     }
  //     if (this.nearestFirstDis > 0) {
  //       this.nearestFirstDis = Number((this.nearestFirstDis - 0.1).toFixed(2))
  //     }
  //     if (this.nearestSecondStation > 0) {
  //       this.nearestSecondStation--
  //     }
  //     if (this.nearestSecondMin > 0) {
  //       this.nearestSecondMin--
  //     }
  //     if (this.nearestSecondDis > 0) {
  //       this.nearestSecondDis = Number((this.nearestSecondDis - 0.1).toFixed(2))
  //     }
  //     if (this.nearestThirdStation > 0) {
  //       this.nearestThirdStation--
  //     }
  //     if (this.nearestThirdMin > 0) {
  //       this.nearestThirdMin--
  //     }
  //     if (this.nearestThirdDis > 0) {
  //       this.nearestThirdDis = Number((this.nearestThirdDis - 0.1).toFixed(2))
  //     }
  //   }, 5000)
  // }
}