import { sceneMap } from '@kit.MapKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { default as Logger } from '../Logger';

export async function getCascadeInfo(context: common.UIAbilityContext) {
  let district: string = '';
  let districtSelectOptions: sceneMap.DistrictSelectOptions = {
    countryCode: 'CN',
  };

  return new Promise<string>((resolve, reject) => {
    sceneMap.selectDistrict(context, districtSelectOptions).then((data) => {
      Logger.info('SelectDistrict', 'Succeeded in selecting district.');
      for (let i = 1; i < data.districts.length; i++) {
        district += data.districts[i].name;
      }
      resolve(district);
    }).catch((err: BusinessError) => {
      Logger.error('SelectDistrict', `Failed to select district, code: ${err.code}, message: ${err.message}`);
      reject('');
    });
  });
}