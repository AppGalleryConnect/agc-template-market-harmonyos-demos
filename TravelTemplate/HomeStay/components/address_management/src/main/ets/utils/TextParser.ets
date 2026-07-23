import { i18n } from '@kit.LocalizationKit';
import { site } from '@kit.MapKit';
import { EntityType, textProcessing } from '@kit.NaturalLanguageKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { ParsedAddressDTO } from '../models/ParsedAddressDTO';

export class TextParser {

  public static async parseAddress(text: string): Promise<ParsedAddressDTO> {
    const parsedAddress: ParsedAddressDTO = new ParsedAddressDTO();
    const formatInterNational: i18n.PhoneNumberFormat = new i18n.PhoneNumberFormat('CN', { type: 'INTERNATIONAL' });
    const formatNational: i18n.PhoneNumberFormat = new i18n.PhoneNumberFormat('CN', { type: 'NATIONAL' });
    const config: textProcessing.EntityConfig = {
      entityTypes: [
        EntityType.NAME,
        EntityType.PHONE_NO,
        EntityType.LOCATION
      ]
    };
    // 通过自然语言理解能力对文本进行实体抽取
    try {
      const entities: textProcessing.Entity[] = await textProcessing.getEntity(text, config);
      // 文本中可能包含多个同类实体，当某个实体成功解析后，后续需跳过对该类型实体的解析
      let hasPhone: boolean = false;
      let hasName: boolean = false;
      let hasRegion: boolean = false;
      let hasDetail: boolean = false;
      // 遍历实体集，正式进入解析流程
      for (const entity of entities) {
        if (entity.type === EntityType.NAME && !hasName) {
          parsedAddress.name = entity.text;
          hasName = true;
        } else if (entity.type === EntityType.PHONE_NO && !hasPhone) {
          // 排除固定电话类型
          if (TextParser.findJsonValueByKey(entity.jsonObject, 'type', true) === '1') {
            const phone: string = formatInterNational.format(entity.text);
            if (phone && formatInterNational.isValidNumber(phone)) {
              // 当前仅解析中国大陆地区手机号
              if (phone.startsWith('+86 ')) {
                parsedAddress.phone = formatNational.format(phone).replace(/\s+/g, '');
              }
            }
            hasPhone = Boolean(parsedAddress.phone);
          }
        } else if (entity.type === EntityType.LOCATION && !hasRegion && !hasDetail) {
          /**
           * 将省、市、区及街道单独抽取并记录其在原文中的索引，余下内容归为详细地址
           *
           * 当 subDistrict 不存在时，街道信息一定几率存放在 road 字段
           */
          let lastRegionEndIndex = -1;
          const subDistrict: string = TextParser.findJsonValueByKey(entity.jsonObject, 'subDistrict');
          const road: string = TextParser.findJsonValueByKey(entity.jsonObject, 'road');
          const regionFields: string[] = [
            TextParser.findJsonValueByKey(entity.jsonObject, 'country'),
            TextParser.findJsonValueByKey(entity.jsonObject, 'province'),
            TextParser.findJsonValueByKey(entity.jsonObject, 'city'),
            TextParser.findJsonValueByKey(entity.jsonObject, 'county'),
            TextParser.findJsonValueByKey(entity.jsonObject, 'district'), // 类似澳门半岛等地区会使用 district 字段
            subDistrict ? subDistrict : road
          ].filter(Boolean);
          for (let regionPart of regionFields) {
            const index = entity.text.indexOf(regionPart, lastRegionEndIndex + 1);
            if (index !== -1) {
              lastRegionEndIndex = index + regionPart.length - 1;
            }
          }
          // 地址文本不包含区划信息，直接视为详细地址
          if (lastRegionEndIndex === -1) {
            if (!hasDetail) {
              parsedAddress.detail = entity.text;
            }
            continue;
          }
          /**
           * 通过地点搜索能力，对地址实体进行错误修正、地址补全、名称规范
           *
           * 注：根据搜索规则约定，sites[0] 是与搜索关键字最契合的地点
           */
          let detail: string = entity.text.slice(lastRegionEndIndex + 1).trim();
          const region: string = entity.text.slice(0, lastRegionEndIndex + 1).trim();
          try {
            const result: site.SearchByTextResult = await site.searchByText({ query: region });
            if (result.sites && result.sites.length > 0) {
              const address: site.AddressComponent = result.sites[0].addressComponent;
              let parsedStreet = address.adminLevel4 ?? '';
              if (!subDistrict) {
                if (road && !parsedStreet.includes(road)) {
                  parsedStreet = '';
                  detail = road + detail;
                }
              } else {
                if (road) {
                  detail = road + detail;
                }
                if (!parsedStreet) {
                  detail = subDistrict  + detail;
                } else if (!parsedStreet.includes(subDistrict)) {
                  parsedStreet = subDistrict;
                }
              }
              if (!hasDetail) {
                parsedAddress.detail = detail;
                hasDetail = Boolean(parsedAddress.detail);
              }
              if (!hasRegion) {
                parsedAddress.countryCode = address.countryCode ?? '';
                parsedAddress.country = address.countryName ?? '';
                parsedAddress.province = address.adminLevel1 ?? '';
                parsedAddress.city = address.adminLevel2 ?? '';
                parsedAddress.district = address.adminLevel3 ?? '';
                parsedAddress.street = parsedStreet;
                if (parsedAddress.hasCompleteLocation()) {
                  hasRegion = true;
                } else {
                  parsedAddress.clearAddress();
                }
              }
            }
          } catch (error) {
            UtilLog.error(0x00FF, '[TextParser]',
              `Failed to search by text, errCode: ${error.code}, errMessage: ${error.message}`);
          }
        }
      }
      return parsedAddress;
    } catch (error) {
      UtilLog.error(0x00FF, '[TextParser]',
        `Failed to get entity, errCode: ${error.code}, errMessage: ${error.message}`);
      return new ParsedAddressDTO();
    }

  }

  private static findJsonValueByKey(jsonStr: string, key: string, isDirect: boolean = false): string {
    const regex: RegExp = new RegExp(
      isDirect ?
        `"${key}"\\s*:\\s*([0-9]+)` :
        `"${key}"\\s*:\\s*\\{\\s*"value"\\s*:\\s*"(.*?)"`,
      'i'
    );
    const match: RegExpMatchArray | null = jsonStr.match(regex);
    return match ? match[1] : '';
  }
}
