import { common, Want } from '@kit.AbilityKit';

export function routerToPetalMap(latitude: number, longitude: number, name: string, context: common.UIAbilityContext) {
  let petalMapWant: Want = {
    bundleName: 'com.huawei.hmos.maps.app',
    uri: 'maps://routes',
    parameters: {
      linkSource: 'com.atomicservice.5765880207855657821',
      destinationLatitude: latitude,
      destinationLongitude: longitude,
      destinationName: name
    }
  }
  context.startAbility(petalMapWant);
}