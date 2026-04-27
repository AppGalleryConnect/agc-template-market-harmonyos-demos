import Logger from '../util/Logger';
import { sensor } from '@kit.SensorServiceKit';
import { Constants, TWENTY_FOUR_MOUNTAINS } from '../common/Constants';
import { MountainInfo } from '../model/Index';

export class CompassController {
  private angle: number = 0;
  private pitch: number = 0;
  private roll: number = 0;
  private twentyFourMountains: MountainInfo[] = TWENTY_FOUR_MOUNTAINS

  // 获取八方方向名称（北、东北、东等）
  public getBasicDirectionName(angle: number): ResourceStr {
    const directions =
      [$r('app.string.N'), $r('app.string.EN'), $r('app.string.E'), $r('app.string.ES'), $r('app.string.S'),
        $r('app.string.WS'), $r('app.string.W'), $r('app.string.WN')];
    const index = Math.round(angle / 45) % 8;
    return directions[index];
  }

  // 获取二十四山名称
  public findMountain(angle: number): string {
    const normalizedAngle = (angle + 360) % 360;

    for (const mountain of this.twentyFourMountains) {
      if (mountain.start > mountain.end) {
        // 处理跨360°边界的情况（壬山）
        if (normalizedAngle >= mountain.start || normalizedAngle < mountain.end) {
          return mountain.name;
        }
      } else if (normalizedAngle >= mountain.start && normalizedAngle < mountain.end) {
        return mountain.name;
      }
    }

    return '壬'; // 默认
  }

  // 计算坐向角度
  public calculateSittingAngle(facingAngle: number): number {
    let sittingAngle = facingAngle + 180;
    return sittingAngle >= 360 ? sittingAngle - 360 : sittingAngle;
  }

  public getAngle() {
    Logger.info('subscribe to sensor data');
    try {
      sensor.on(
        sensor.SensorId.ORIENTATION,
        this.angleChange,
        {
          interval: Constants.SENSOR_INTERVAL,
        });
    } catch (err) {
      Logger.error('sensor error: ' + err);
    }
  }

  public angleChange = (data: sensor.OrientationResponse) => {
    this.angle = Math.round(data.alpha);
    this.pitch = Math.round(data.beta);
    this.roll = Math.round(data.gamma);
    this.notifyAngleChanges();
  }

  public destroy() {
    try {
      sensor.off(sensor.SensorId.ORIENTATION);
      Logger.info('unsubscribe orientation sensor');
    } catch (err) {
      Logger.error('sensor off error: ' + err);
    }
  }

  public setAngleUpdateListener(listener: (angle: number, pitch: number, roll: number) => void) {
    this.angleUpdateListener = listener;
  }

  private angleUpdateListener: (angle: number, pitch: number, roll: number) => void = () => {
  };

  private notifyAngleChanges() {
    if (this.angleUpdateListener) {
      this.angleUpdateListener(this.angle, this.pitch, this.roll);
    }
  }
}